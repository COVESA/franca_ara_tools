package org.genivi.faracon.cli

import java.util.Collection
import javax.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.franca.FModel
import org.franca.core.franca.FTypedElement
import org.franca.core.utils.FileHelper
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer

import static org.genivi.faracon.cli.ConverterHelper.*

class Franca2AraConverter extends AbstractFaraconConverter<FrancaModelContainer, ARAModelContainer> {
	@Inject
	var ARAConnector araConnector
	@Inject
	var FrancaPersistenceManager francaLoader

	override protected loadAllSourceFiles(Collection<String> filesToConvert) {
		val francaModels = filesToConvert.map [ francaFilePath |
			// Load an input FrancaIDL model.
			val normalizedFrancaFilePath = normalize(francaFilePath);
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

	override protected transform(Collection<FrancaModelContainer> francaModelContainers) {
		val allNonPrimitiveElementTypesOfAnonymousArrays = francaModelContainers.map [ francaModelContainer |
			val francaModel = francaModelContainer.model
			francaModel.eAllContents.filter(FTypedElement).filter[array && type?.derived !== null].map[type?.derived].toList
		].flatten.toSet
		allNonPrimitiveElementTypesOfAnonymousArrays.forEach[getLogger().logInfo("allNonPrimitiveElementTypesOfAnonymousArrays: " + name)]
		araConnector.setAllNonPrimitiveElementTypesOfAnonymousArrays(allNonPrimitiveElementTypesOfAnonymousArrays)
		
		val araModelContainer = francaModelContainers.map [ francaModelContainer |
			val francaModel = francaModelContainer.model
			val francaModelUri = francaModel.eResource().getURI();
			if (!francaModelUri.fileExtension().toLowerCase().equals("fidl")) {
				getLogger().logWarning("The FrancaIDL file " + francaModelUri?.toString +
					" does not have the file extension \"fidl\".");
			}
			getLogger().decreaseIndentationLevel();

			// Transform the FrancaIDL model to an arxml model.
			getLogger().logInfo("Converting FrancaIDL file " + francaModelUri?.toString)
			val araModelContainer = araConnector.fromFranca(francaModel) as ARAModelContainer
			return francaModelContainer -> araModelContainer
		]
		return araModelContainer.toList
	}

	override protected putAllModelsInOneResourceSet(
		Collection<Pair<FrancaModelContainer, ARAModelContainer>> francaToAutosarModelContainer) {
		val resourceSet = new XtextResourceSet
		francaToAutosarModelContainer.forEach [
			val arModel = it.value
			val francaUri = it.key.model.findSourceModelUri
			val araFilePath = getAraFilePath(francaUri, arModel)
			val resource = resourceSet.createResource(FileHelper.createURI(araFilePath))
			resource.contents.add(arModel.model)
		]
	}

	def getAraFilePath(URI francaModelUri, ARAModelContainer autosar) {
		val transformedModelUri = francaModelUri.trimFileExtension().appendFileExtension("arxml");
		var String outputDirectoryPath = getOutputDirPath()
		val String araFilePath = normalize(outputDirectoryPath + transformedModelUri.lastSegment());
		return araFilePath
	}

	override protected saveAllGeneratedModels(
		Collection<Pair<FrancaModelContainer, ARAModelContainer>> francaToAutosarModelContainer) {
		francaToAutosarModelContainer.forEach [
			val araModelContainer = it.value
			val francaModelUri = it.key.model.findSourceModelUri
			val autosarFilePath = getAraFilePath(francaModelUri, araModelContainer)
			araConnector.saveModel(araModelContainer, autosarFilePath);
		]
	}

	override protected getSourceArtifactName() '''Franca IDL'''

	override protected getTargetArtifactName() ''''Adaptive AUTOSAR IDL'''

	override createResourceSet() {
		return new XtextResourceSet
	}

}
