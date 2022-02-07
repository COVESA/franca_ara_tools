package org.genivi.faracon.cli

import java.nio.file.Paths
import java.util.Collection
import java.util.Map
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.impl.BasicEObjectImpl
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.framework.IModelContainer
import org.genivi.faracon.InputFile
import org.genivi.faracon.logging.BaseWithLogger
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants

/**
 * Abstract base class for converters in the Faracon project.
 * Ensures that the abstract methods are called correctly from the public method convertFiles
 */
abstract class AbstractFaraconConverter<SRC extends IModelContainer, TAR extends IModelContainer> extends BaseWithLogger {

	val protected Preferences preferences
	var protected ResourceSet resourceSet
	var protected Map<String, Integer> inputFilesToBasePathLengthsMap

	new() {
		preferences = Preferences.getInstance();
	}

	def void registerSingleInputFilePath(String inputFilePath) {
		inputFilesToBasePathLengthsMap = newHashMap
		val absoluteInputFilePath = Paths.get(inputFilePath).toFile.canonicalFile.toPath
		val basePathLength = FilePathsHelper.calculateBasePathLength(absoluteInputFilePath)
		inputFilesToBasePathLengthsMap.put(absoluteInputFilePath.toString, basePathLength)
	}

	def void convertFiles(Collection<String> inputPaths) {
		if (inputPaths.nullOrEmpty) {
			return
		}

		val inputFiles = FilePathsHelper.findInputFiles(inputPaths, inputFileExtension)
		if (inputFiles.nullOrEmpty) {
			return
		}
		inputFilesToBasePathLengthsMap = newHashMap
		for (inputFile : inputFiles) {
			inputFilesToBasePathLengthsMap.put(inputFile.absolutePath, inputFile.basePathLength)
		}

		getLogger().logInfo("Loading " + sourceArtifactName + " model input files...");
		getLogger().increaseIndentationLevel();

		resourceSet = createResourceSet

		val modelContainers = inputFiles.loadAllSourceFiles

		if (hasSeparateDeploymentInputFiles) {
			val deploymentInputFiles = FilePathsHelper.findInputFiles(inputPaths, deploymentInputFileExtension)
			deploymentInputFiles.loadAllDeploymentSourceFiles
		}

		getLogger().decreaseIndentationLevel();

		resolveProxiesAndCheckRemaining
		convertModelContainersAndSaveResults(modelContainers)
	}

	def convertModelContainersAndSaveResults(Collection<SRC> modelContainers) {
		getLogger().logInfo("Converting " + sourceArtifactName + " models to " + targetArtifactName + " models...");
		getLogger().increaseIndentationLevel();
		val srcToTargetContainer = modelContainers.transform
		getLogger().decreaseIndentationLevel();

		srcToTargetContainer.putAllModelsInOneResourceSet

		getLogger().logInfo("Saving " + targetArtifactName + " model output files...");
		getLogger().increaseIndentationLevel();
		srcToTargetContainer.saveAllGeneratedModels
		getLogger().decreaseIndentationLevel();

		return srcToTargetContainer.map[it.value]
	}
	
	def loadFilesAndCheckProxies(Collection<InputFile> filesToConvert){
		resourceSet = createResourceSet
		filesToConvert.loadAllSourceFiles
		return resolveProxiesAndCheckRemaining
	}

	def protected abstract ResourceSet createResourceSet()

	def protected abstract Collection<SRC> loadAllSourceFiles(Collection<InputFile> filesToConvert)

	def protected abstract void loadAllDeploymentSourceFiles(Collection<InputFile> deploymentInputFilePaths)

	def protected abstract Collection<Pair<SRC, TAR>> transform(Collection<SRC> containers)

	def protected abstract void putAllModelsInOneResourceSet(Collection<Pair<SRC, TAR>> srcToTargetContainer)

	def protected abstract void saveAllGeneratedModels(Collection<Pair<SRC, TAR>> srcToTargetContainer)

	def protected abstract String getInputFileExtension()

	def protected abstract String getDeploymentInputFileExtension()

	def protected hasSeparateDeploymentInputFiles() {
		!deploymentInputFileExtension.nullOrEmpty
	}

	def protected abstract String getSourceArtifactName()

	def protected abstract String getTargetArtifactName()

	def protected findSourceModelUri(EObject sourceModel) {
		sourceModel?.eResource()?.getURI()
	}

	protected def String getOutputDirPath() {
		var String outputDirectoryPath
		try {
			outputDirectoryPath = preferences.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "");
		} catch (Preferences.UnknownPreferenceException e) {
			getLogger().logError(e.getMessage());
		}
		if (!outputDirectoryPath.isEmpty()) {
			outputDirectoryPath += "/";
		}
		return outputDirectoryPath
	}

	def private int resolveProxiesAndCheckRemaining() {
		EcoreUtil.resolveAll(resourceSet);
		val proxiesAfterResolution = EcoreUtil.ProxyCrossReferencer.find(resourceSet)

		if (!proxiesAfterResolution.empty) {
			val proxiesAfterErrorMsg = proxiesAfterResolution.keySet.map [ eObject |
				if (eObject.eIsProxy && eObject instanceof BasicEObjectImpl) {
					val basicEObject = eObject as BasicEObjectImpl
					return "Cannot find object for proxy: " + basicEObject.eProxyURI()
				} else {
					return "Cannot find object (no proxy): " + eObject.toString
				}
			].join(System.lineSeparator)
			logger.logError(
				"Cannot resolve all references in the provided " + sourceArtifactName + " files. Found following " +
					proxiesAfterResolution.size + " remaining unresolved objects " + System.lineSeparator +
					proxiesAfterErrorMsg + System.lineSeparator + "Include the necessary " + sourceArtifactName +
					" files containing the missing objects into the sources of " + sourceArtifactName +
					" in order to fix this error"
			)
		}
		return proxiesAfterResolution.size
	}

}
