package org.genivi.faracon.cli

import autosar40.autosartoplevelstructure.AUTOSAR
import java.nio.file.Paths
import java.util.Collection
import javax.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.resource.XtextResourceSet
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypedElement
import org.franca.core.utils.FileHelper
import org.franca.deploymodel.core.FDModelExtender
import org.franca.deploymodel.core.FDeployedInterface
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.franca.deploymodel.dsl.FDeployPersistenceManager
import org.franca.deploymodel.dsl.FDeployStandaloneSetup
import org.franca.deploymodel.dsl.fDeploy.FDInterface
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.franca.deploymodel.dsl.fDeploy.FDTypes
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.InputFile
import org.genivi.faracon.franca2ara.SomeipFrancaDeploymentData
import org.genivi.faracon.names.FrancaNamesCollector
import org.genivi.faracon.names.NamesHierarchy
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.stdtypes.AraStandardTypeDefinitionsModel

import static org.genivi.faracon.cli.ConverterHelper.*
import org.genivi.faracon.franca2ara.ARAPrimitiveTypesCreator

class Franca2AraConverter extends AbstractFaraconConverter<FrancaModelContainer, ARAModelContainer> {
	@Inject
	var ARAConnector araConnector
	@Inject
	var FrancaPersistenceManager francaLoader
	@Inject
	var ARAPrimitiveTypesCreator araPrimitveTypesCreator
	@Inject
	var FDeployPersistenceManager francaDeploymentLoader
	@Inject
	var SomeipFrancaDeploymentData someipFrancaDeploymentData
	@Inject
	NamesHierarchy namesHierarchy

	var ARAResourceSet targetResourceSet

	override protected loadAllSourceFiles(Collection<InputFile> filesToConvert) {
		val francaModels = filesToConvert.map [ francaFilePath |
			// Load an input FrancaIDL model.
			val normalizedFrancaFilePath = francaFilePath.absolutePath
			getLogger().logInfo("Loading FrancaIDL file " + normalizedFrancaFilePath);
			var FModel francaModel;
			try {
				francaModel = francaLoader.loadModel(normalizedFrancaFilePath);
				if (francaModel === null) {
					getLogger().logError("File " + normalizedFrancaFilePath + " could not be loaded!");
					return null
				}
				return francaModel
			} catch (Exception e) {
				getLogger().logError("File " + normalizedFrancaFilePath + " could not be loaded!");
				return null
			}
		].filterNull.toList
		// add all created franca models to the resource set of the converter
		francaModels.forEach [
			resourceSet.resources.add(it.eResource)
		]
		return francaModels.map [new FrancaModelContainer(it)].toList
	}

	override protected loadAllDeploymentSourceFiles(Collection<InputFile> deploymentInputFilePaths) {
		FDeployStandaloneSetup.doSetup
		val francaDeploymentModels = deploymentInputFilePaths.map [ deploymentInputFilePath |
			// Load an input Franca deployment model.
			val normalizedFrancaDeploymentFilePath = deploymentInputFilePath.absolutePath
			getLogger().logInfo("Loading Franca deployment file " + normalizedFrancaDeploymentFilePath);
			var FDModel francaDeploymentModel;
			try {
				francaDeploymentModel = francaDeploymentLoader.loadModel(normalizedFrancaDeploymentFilePath);
				if (francaDeploymentModel === null) {
					getLogger().logError("File " + normalizedFrancaDeploymentFilePath + " could not be loaded!");
					return null
				}
				return francaDeploymentModel
			} catch (Exception e) {
				getLogger().logError("File " + normalizedFrancaDeploymentFilePath + " could not be loaded!");
				return null
			}
		].filterNull.toList
		// add all created franca models to the resource set of the converter
		francaDeploymentModels.forEach [
			resourceSet.resources.add(it.eResource)
		]

		// Register the deployment sections for interface types and type collections.
		someipFrancaDeploymentData.clear
		francaDeploymentModels.forEach [
			val FDModelExtender fdmodelExt = new FDModelExtender(it)
			for(FDInterface fdInterface : fdmodelExt.FDInterfaces) {
				val FDeployedInterface deployedInterface = new FDeployedInterface(fdInterface)
				someipFrancaDeploymentData.registerInterfaceDeployment(fdInterface.target, deployedInterface)
			}
			for(FDTypes fdTypes : fdmodelExt.FDTypesList) {
				val FDeployedTypeCollection deployedTypeCollection = new FDeployedTypeCollection(fdTypes)
				someipFrancaDeploymentData.registerTypeCollectionDeployment(fdTypes.target, deployedTypeCollection)
			}
		]
	}

	override protected transform(Collection<FrancaModelContainer> francaModelContainers) {
		// Initialization.
		//   Fill all names of the Franca models into a hierarchy of names.
		namesHierarchy.clear();
		val FrancaNamesCollector francaNamesCollector = new FrancaNamesCollector
		for (francaModelContainer : francaModelContainers) {
			francaNamesCollector.fillNamesHierarchy(francaModelContainer.model, namesHierarchy)
		}
		//   Initialization for primitive and non-primitive anonymous arrays.
		val allNonPrimitiveElementTypesOfAnonymousArrays = francaModelContainers.map [ francaModelContainer |
			val francaModel = francaModelContainer.model
			francaModel.eAllContents.filter(FTypedElement).filter[array && type?.derived !== null].map[type?.derived].toList
		].flatten.toSet
		araConnector.setAllNonPrimitiveElementTypesOfAnonymousArrays(allNonPrimitiveElementTypesOfAnonymousArrays)
		araPrimitveTypesCreator.clearPrimitiveTypesAnonymousArrays

		// The transformation itself.
		val araModelContainer = francaModelContainers.map [ francaModelContainer |
			val francaModel = francaModelContainer.model
			val francaModelUri = francaModel.eResource().getURI();
			if (!francaModelUri.fileExtension().toLowerCase().equals("fidl")) {
				getLogger().logWarning("The FrancaIDL file " + francaModelUri?.toString +
					" does not have the file extension \"fidl\".");
			}

			// Transform the FrancaIDL model to an arxml model.
			getLogger().logInfo("Converting FrancaIDL file " + francaModelUri?.toString)
			val araModelContainer = araConnector.fromFranca(francaModel) as ARAModelContainer
			return francaModelContainer -> araModelContainer
		]
		return araModelContainer.toList
	}

	override protected putAllModelsInOneResourceSet(
		Collection<Pair<FrancaModelContainer, ARAModelContainer>> francaToAutosarModelContainer) {
		targetResourceSet = new ARAResourceSet
		francaToAutosarModelContainer.forEach [
			val arModel = it.value
			val francaModelUri = it.key.model.findSourceModelUri
			if (francaModelUri !== null) {
				val araFilePath = getAraFilePath(francaModelUri, arModel)
				val resource = targetResourceSet.createResource(FileHelper.createURI(araFilePath))
				resource.contents.add(arModel.model)
			}
		]

		// Add a resource for the AUTOSAR model with the anonymous fixed sized arrays of primitive types if any.
		val primitiveTypesAnonymousArraysModel = araPrimitveTypesCreator.primitiveTypesAnonymousArraysModel
		if (primitiveTypesAnonymousArraysModel !== null) {
			val resource = targetResourceSet.createResource(FileHelper.createURI(primitiveTypesAnonymousArraysModelFilePath))
			resource.contents.add(primitiveTypesAnonymousArraysModel)
		}
	}
	
	override protected saveAllGeneratedModels(
		Collection<Pair<FrancaModelContainer, ARAModelContainer>> francaToAutosarModelContainer) {
		francaToAutosarModelContainer.forEach [
			val araModelContainer = it.value
			val francaModelUri = it.key.model.findSourceModelUri
			if (francaModelUri !== null) {
				val autosarFilePath = getAraFilePath(francaModelUri, araModelContainer)
				araConnector.saveModel(araModelContainer, autosarFilePath);
			}
		]

		saveAutosarStdTypes	

		// Save a file with the AUTOSAR model with the anonymous fixed sized arrays of primitive types if any.
		val primitiveTypesAnonymousArraysModel = araPrimitveTypesCreator.primitiveTypesAnonymousArraysModel
		if (primitiveTypesAnonymousArraysModel !== null) {
			var primitiveTypesAnonymousArraysModelContainer = new ARAModelContainer(primitiveTypesAnonymousArraysModel, null)
			araConnector.saveModel(primitiveTypesAnonymousArraysModelContainer, primitiveTypesAnonymousArraysModelFilePath);
		}
	}
	
	def private getAraFilePath(URI francaModelUri, ARAModelContainer autosar) {
		val inputFilePath = francaModelUri.toFileString
		val basePathLength = inputFilesToBasePathLengthsMap.get(inputFilePath)
		URI.createFileURI(Paths.get(normalize(outputDirPath), inputFilePath.substring(basePathLength)).toString)
			.trimFileExtension
			.appendFileExtension("arxml")
			.toFileString
	}

	def private getPrimitiveTypesAnonymousArraysModelFilePath() {
		val stdTypesUri = targetResourceSet.araStandardTypeDefinitionsModel.standardTypeDefinitionsModel.eResource.URI
		val fileExtension = stdTypesUri.fileExtension
		val stdArrayTypesFilename = stdTypesUri.trimFileExtension.lastSegment + "_arrays." + fileExtension 
		normalize(outputDirPath + stdArrayTypesFilename)
	}

	def private saveAutosarStdTypes(){
		val araStandardTypeDefinitionsModel = targetResourceSet.araStandardTypeDefinitionsModel
		if (!AraStandardTypeDefinitionsModel.customAraStdTypesUsed(Preferences.instance)) {
			araStandardTypeDefinitionsModel.standardTypeDefinitionsModel.saveStdTypesFile
		}
		araStandardTypeDefinitionsModel.standardVectorTypeDefinitionsModel.saveStdTypesFile
	}

 	def private saveStdTypesFile(AUTOSAR aModel){
		val copiedModel = EcoreUtil.copy(aModel)
		val fileName = aModel.eResource.URI.lastSegment
 		val filePath = normalize(outputDirPath + fileName)
 		araConnector.saveARXML(targetResourceSet, copiedModel, filePath)
 	}

	override protected getInputFileExtension() '''fidl'''

	override protected getDeploymentInputFileExtension() '''fdepl'''

	override protected getSourceArtifactName() '''Franca IDL'''

	override protected getTargetArtifactName() '''Adaptive AUTOSAR IDL'''

	override protected createResourceSet() {
		return new XtextResourceSet
	}

}
