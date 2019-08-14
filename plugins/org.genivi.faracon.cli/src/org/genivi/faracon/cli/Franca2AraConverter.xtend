package org.genivi.faracon.cli

import java.util.Collection
import javax.inject.Inject
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.franca.FModel
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.logging.BaseWithLogger
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants

import static org.genivi.faracon.cli.ConverterHelper.*

class Franca2AraConverter extends BaseWithLogger{
	@Inject
	var ARAConnector araConnector
	@Inject
	var FrancaPersistenceManager francaLoader
	
	val Preferences preferences

	new(){
		preferences = Preferences.getInstance();
	}

	def void convertFrancaFiles(Collection<String> francaFilePaths) {
		if (francaFilePaths.nullOrEmpty) {
			return;
		}

		getLogger().logInfo("Converting Franca IDL models to Adaptive AUTOSAR IDL models...");
		getLogger().increaseIndentationLevel();
		
		for (String francaFilePath : francaFilePaths) {
			// Load an input FrancaIDL model.
			val normalizedFrancaFilePath = normalize(francaFilePath);
			getLogger().logInfo("Loading FrancaIDL file " + normalizedFrancaFilePath);
			getLogger().increaseIndentationLevel();
			var FModel francaModel;
			try {
				francaModel = francaLoader.loadModel(normalizedFrancaFilePath);
			} catch (Exception e) {
				getLogger().logError("File " + normalizedFrancaFilePath + " could not be loaded!");
				getLogger().decreaseIndentationLevel();
				return
			}
			if (francaModel === null) {
				getLogger().logError("File " + normalizedFrancaFilePath + " could not be loaded!");
				getLogger().decreaseIndentationLevel();
				return
			}
			val francaModelUri = francaModel.eResource().getURI();
			if (!francaModelUri.fileExtension().toLowerCase().equals("fidl")) {
				getLogger().logWarning("The FrancaIDL file " + normalizedFrancaFilePath
						+ " does not have the file extension \"fidl\".");
			}
			getLogger().decreaseIndentationLevel();

			// Transform the FrancaIDL model to an arxml model.
			getLogger().logInfo("Converting FrancaIDL file " + normalizedFrancaFilePath)
			val araModelContainer = araConnector.fromFranca(francaModel) as ARAModelContainer

			// Store the output arxml model.
			val transformedModelUri = francaModelUri.trimFileExtension().appendFileExtension("arxml");
			var String outputDirectoryPath = null;
			try {
				outputDirectoryPath = preferences.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "");
			} catch (Preferences.UnknownPreferenceException e) {
				getLogger().logError(e.getMessage());
			}
			if (!outputDirectoryPath.isEmpty()) {
				outputDirectoryPath += "/";
			}
			val String araFilePath = normalize(outputDirectoryPath + transformedModelUri.lastSegment());
			getLogger().logInfo("Storing arxml file " + araFilePath);
			araConnector.saveModel(araModelContainer, araFilePath);
		}

		getLogger().decreaseIndentationLevel();
	}
	 
}