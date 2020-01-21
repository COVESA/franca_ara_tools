package org.genivi.faracon.cli

import java.nio.file.Paths
import java.util.Collection
import javax.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.utils.FileHelper
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.FrancaMultiModelContainer
import org.genivi.faracon.InputFile
import org.genivi.faracon.ara2franca.FrancaConstantsCreator
import org.genivi.faracon.names.ARANamesCollector
import org.genivi.faracon.names.NamesHierarchy

import static org.genivi.faracon.cli.ConverterHelper.*

class Ara2FrancaConverter extends AbstractFaraconConverter<ARAModelContainer, FrancaMultiModelContainer> {

	@Inject
	var ARAConnector araConnector
	@Inject
	var FrancaConstantsCreator francaConstantsCreator
	@Inject
	var FrancaPersistenceManager francaLoader
	@Inject
	NamesHierarchy namesHierarchy

	/**
	 * The methods loads all ARA files into a single resource Set and resolves all objects
	 */
	override protected loadAllSourceFiles(Collection<InputFile> araFilePaths) {
		val modelContainer = araFilePaths.map [ araFilePath |
			val normalizedARAFilePath = araFilePath.absolutePath
			getLogger().logInfo("Loading arxml file " + normalizedARAFilePath);
			getLogger().increaseIndentationLevel();
			var ARAModelContainer araModelContainer;
			try {
				araModelContainer = araConnector.loadModel(resourceSet as ARAResourceSet, normalizedARAFilePath) as ARAModelContainer;
			} catch (Exception e) {
				getLogger().logError("File " + normalizedARAFilePath + " could not be loaded!");
				getLogger().decreaseIndentationLevel();
				return null
			}

			val araModelUri = araModelContainer.model().eResource().getURI();
			if (!araModelUri.fileExtension().toLowerCase().equals("arxml")) {
				getLogger().logWarning("The Adaptive AUTOSAR file " + normalizedARAFilePath +
					" does not have the file extension \"arxml\".");
				return null
			}
			logger.decreaseIndentationLevel();
			return araModelContainer

		].filterNull.toList

		return modelContainer
	}

	override protected loadAllDeploymentSourceFiles(Collection<InputFile> deploymentInputFilePaths) {
	}

	override protected Collection<Pair<ARAModelContainer, FrancaMultiModelContainer>> transform(
		Collection<ARAModelContainer> containers) {
		// Initialization.
		//   Fill all names of the AUTOSAR model into a hierarchy of names.
		namesHierarchy.clear();
		val ARANamesCollector araNamesCollector = new ARANamesCollector
		for (araModelContainer : containers) {
			araNamesCollector.fillNamesHierarchy(araModelContainer.model, namesHierarchy)
		}
		//   Initialize the naming of artificial types for constants.
		francaConstantsCreator.resetArtificialTypesIndices;

		// The transformation itself.
		containers.map [ araModelContainer |
			getLogger().logInfo("Converting arxml file " + araModelContainer?.model?.eResource?.URI);
			val francaMultiModelContainer = araConnector.toFranca(araModelContainer) as FrancaMultiModelContainer;
			return araModelContainer -> francaMultiModelContainer
		].toList
	}

	override protected putAllModelsInOneResourceSet(
		Collection<Pair<ARAModelContainer, FrancaMultiModelContainer>> ara2FrancaMultiModelContainers) {
		val resourceSet = new XtextResourceSet();
		ara2FrancaMultiModelContainers.forEach [
			it.value.francaModelContainers.forEach [ francaModelContainer |
				// put all Franca models in to one resource set
				val araModelUri = it.key.model.findSourceModelUri
				if (araModelUri !== null) {
					val francaFilePath = getFrancaFilePath(araModelUri, francaModelContainer);
					val resource = resourceSet.createResource(FileHelper.createURI(francaFilePath));
					resource.getContents().add(francaModelContainer.model());
				}
			]
		]
	}

	override protected saveAllGeneratedModels(
		Collection<Pair<ARAModelContainer, FrancaMultiModelContainer>> ara2FrancaMultiModelContainers) {
		ara2FrancaMultiModelContainers.forEach [
			it.value.francaModelContainers.forEach [ francaModelContainer |
				// Store the output FrancaIDL model.
				val araModelUri = it.key.model.findSourceModelUri
				if (araModelUri !== null) {
					val francaFilePath = getFrancaFilePath(araModelUri, francaModelContainer);
					getLogger().logInfo("Storing FrancaIDL file " + francaFilePath);
					francaLoader.saveModel(francaModelContainer.model(), francaFilePath);
				}
			]
		]
	}

	def private String getFrancaFilePath(URI araModelUri, FrancaModelContainer francaModelContainer) {
		val francaModelNamespace = francaModelContainer.model.name
		var francaFileName = araModelUri.trimFileExtension.lastSegment
		if (!francaModelNamespace.nullOrEmpty) {
			francaFileName += "_" + francaModelNamespace
		}
		francaFileName += ".fidl"

		val inputFilePath = normalize(araModelUri.toFileString)
		val basePathLength = inputFilesToBasePathLengthsMap.get(inputFilePath)
		URI.createFileURI(Paths.get(normalize(outputDirPath), inputFilePath.substring(basePathLength)).toString)
			.trimSegments(1)
			.appendSegment(francaFileName)
			.toFileString
	}

	override protected getInputFileExtension() '''arxml'''

	override protected getDeploymentInputFileExtension() { null } 

	override protected getSourceArtifactName() ''''Adaptive AUTOSAR IDL'''

	override protected getTargetArtifactName() '''Franca IDL'''
	
	override protected createResourceSet() {
		this.resourceSet = new ARAResourceSet
		return this.resourceSet
	}
	
}
