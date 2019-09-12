package org.genivi.faracon.cli

import java.util.Collection
import javax.inject.Inject
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.impl.BasicEObjectImpl
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.resource.XtextResourceSet
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.FrancaModelContainer
import org.franca.core.utils.FileHelper
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.FrancaMultiModelContainer
import org.genivi.faracon.logging.BaseWithLogger
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants

import static org.genivi.faracon.cli.ConverterHelper.*

class Ara2FrancaConverter extends BaseWithLogger {

	@Inject
	var ARAConnector araConnector
	@Inject
	var FrancaPersistenceManager francaLoader

	val Preferences preferences
	var ARAResourceSet araResourceSet

	new() {
		preferences = Preferences.getInstance();
	}

	def void convertARAFiles(Collection<String> araFilePaths) {
		if (araFilePaths.nullOrEmpty) {
			return
		}

		getLogger().logInfo("Converting Adaptive AUTOSAR IDL models to Franca IDL models...");
		getLogger().increaseIndentationLevel();

		val Collection<ARAModelContainer> modelContainers = loadAllAraFiles(araFilePaths)
		resolveProxiesAndCheckRemaining
		val ara2FrancaMultiModelContainers = modelContainers.transformToFranca()
		ara2FrancaMultiModelContainers.putAllFrancaModelsInOneResourceSet
		ara2FrancaMultiModelContainers.saveAllFrancaModels

		getLogger().decreaseIndentationLevel();
	}

	/**
	 * The methods loads all ARA files into a single resource Set and resolves all objects
	 */
	def Collection<ARAModelContainer> loadAllAraFiles(Collection<String> araFilePaths) {
		araResourceSet = new ARAResourceSet();
		val modelContainer = araFilePaths.map [ araFilePath |
			val normalizedARAFilePath = normalize(araFilePath);
			getLogger().logInfo("Loading arxml file " + normalizedARAFilePath);
			getLogger().increaseIndentationLevel();
			var ARAModelContainer araModelContainer;
			try {
				araModelContainer = araConnector.loadModel(araResourceSet, normalizedARAFilePath) as ARAModelContainer;
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

	def resolveProxiesAndCheckRemaining() {
		EcoreUtil.resolveAll(araResourceSet);
		val proxiesAfterResolution = EcoreUtil.ProxyCrossReferencer.find(araResourceSet)

		if (!proxiesAfterResolution.empty) {
			val proxiesAfterErrorMsg = proxiesAfterResolution.keySet.map [ eObject |
				if (eObject.eIsProxy && eObject instanceof BasicEObjectImpl) {
					val basicEObject = eObject as BasicEObjectImpl
					return "Cannot find object " + basicEObject.eProxyURI()
				} else {
					return "Cannot find object " + eObject.toString
				}
			].join(System.lineSeparator)
			logger.logError(
				"Cannot resolve all references in the provided ARXML files. Found following " +
					proxiesAfterResolution.size + " remaining unresolved objects " + System.lineSeparator +
					proxiesAfterErrorMsg + System.lineSeparator +
					"Include the necessary ARXML files containing the missing objects into the sources of ARXML in order to fix this error"
			)
		}
		return proxiesAfterResolution.size
	}

	def Collection<Pair<ARAModelContainer, FrancaMultiModelContainer>> transformToFranca(
		Collection<ARAModelContainer> containers) {
		containers.map [ araModelContainer |
			getLogger().logInfo("Converting arxml file " + araModelContainer?.model?.eResource?.URI);
			val francaMultiModelContainer = araConnector.toFranca(araModelContainer) as FrancaMultiModelContainer;
			return araModelContainer -> francaMultiModelContainer
		].toList
	}

	def putAllFrancaModelsInOneResourceSet(
		Collection<Pair<ARAModelContainer, FrancaMultiModelContainer>> ara2FrancaMultiModelContainers) {
		val resourceSet = new XtextResourceSet();
		ara2FrancaMultiModelContainers.forEach [
			it.value.francaModelContainers.forEach [ francaModelContainer |
				// put all Franca models in to one resource set
				val araModelUri = findAraModelUri(it)
				val francaFilePath = getFrancaFilePath(araModelUri, francaModelContainer);
				val resource = resourceSet.createResource(FileHelper.createURI(francaFilePath));
				resource.getContents().add(francaModelContainer.model());
			]
		]
	}

	def private URI findAraModelUri(Pair<ARAModelContainer, FrancaMultiModelContainer> containerMapping) {
		val araModelUri = containerMapping.key.model()?.eResource()?.getURI()
		if (araModelUri === null) {
			logger.logInfo("Cannot find model URI for Autosar model: " + containerMapping.key.model)
			return URI.createFileURI("")
		}
		return araModelUri
	}

	def saveAllFrancaModels(
		Collection<Pair<ARAModelContainer, FrancaMultiModelContainer>> ara2FrancaMultiModelContainers) {
		ara2FrancaMultiModelContainers.forEach [
			it.value.francaModelContainers.forEach [ francaModelContainer |
				// Store the output FrancaIDL model.
				val araModelUri = it.findAraModelUri
				val francaFilePath = getFrancaFilePath(araModelUri, francaModelContainer);
				getLogger().logInfo("Storing FrancaIDL file " + francaFilePath);
				francaLoader.saveModel(francaModelContainer.model(), francaFilePath);
			]
		]
	}

	def private String getFrancaFilePath(URI araModelUri, FrancaModelContainer francaModelContainer) {
		val transformedModelUri = OutputFileHelper.calculateFrancaOutputUri(araModelUri, francaModelContainer);
		var String outputDirectoryPath = null;
		try {
			outputDirectoryPath = preferences.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "");
		} catch (Preferences.UnknownPreferenceException e) {
			getLogger().logError(e.getMessage());
		}
		if (!outputDirectoryPath.isEmpty()) {
			outputDirectoryPath += "/";
		}
		val relativeFrancaFilePath = outputDirectoryPath + transformedModelUri.lastSegment()
		val francaFilePath = normalize(relativeFrancaFilePath);
		return francaFilePath;
	}
}
