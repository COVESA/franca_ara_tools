package org.genivi.faracon.cli;

import java.io.File;

import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.validation.AbstractValidationMessageAcceptor;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.core.dsl.FrancaIDLRuntimeModule;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.framework.FrancaModelContainer;
import org.franca.core.franca.FModel;
import org.genivi.faracon.ARAConnector;
import org.genivi.faracon.ARAModelContainer;
import org.genivi.faracon.console.CommandlineTool;
import org.genivi.faracon.console.ConsoleLogger;
//import org.genivi.faracon.generator.GeneratorFileSystemAccess;
//import org.genivi.faracon.verification.CommandlineValidator;
//import org.genivi.faracon.verification.ValidatorCore;
//import org.genivi.faracon.generator.FrancaDBusGenerator;
import org.genivi.faracon.preferences.Preferences;
import org.genivi.faracon.preferences.PreferencesConstants;

import com.google.inject.Guice;
import com.google.inject.Injector;

/**
 * Receive command line arguments and set them as preference values for the code
 * generation.
 */
public class CommandlineToolMain extends CommandlineTool {
	protected Injector injector;
	protected CreateShowcaseARATests createShowcaseARATests;
	protected FrancaPersistenceManager francaLoader;
//	protected GeneratorFileSystemAccess fsa;
	protected Preferences preferences;
//	protected IGenerator francaGenerator;
	protected String SCOPE = "DBus validation: ";

	private ValidationMessageAcceptor cliMessageAcceptor = new AbstractValidationMessageAcceptor() {

		@Override
		public void acceptInfo(String message, EObject object,
				EStructuralFeature feature, int index, String code,
				String... issueData) {
			ConsoleLogger.logInfo(SCOPE + message);
		}

		@Override
		public void acceptWarning(String message, EObject object,
				EStructuralFeature feature, int index, String code,
				String... issueData) {
			ConsoleLogger.logWarning(SCOPE + message);
		}

		@Override
		public void acceptError(String message, EObject object,
				EStructuralFeature feature, int index, String code,
				String... issueData) {
			hasValidationError = true;
			ConsoleLogger.logError(SCOPE + message);
		}
	};

	/**
	 * The constructor registers the needed bindings to use the generator
	 */
	public CommandlineToolMain() {

		injector = Guice.createInjector(new FrancaIDLRuntimeModule());

		createShowcaseARATests = injector.getInstance(CreateShowcaseARATests.class);
		
		francaLoader = injector.getInstance(FrancaPersistenceManager.class);

//		fsa = injector.getInstance(GeneratorFileSystemAccess.class);

		preferences = Preferences.getInstance();

	}

	public void convertFrancaFiles(String[] francaFilePaths) {
		if (francaFilePaths == null || francaFilePaths.length == 0) {
			return;
		}

		ConsoleLogger.logInfo("Converting Franca IDL models to Adaptive AUTOSAR IDL models...");
		ConsoleLogger.increaseIndentationLevel();

		ARAConnector conn = new ARAConnector();
		for (String francaFilePath : francaFilePaths) {
			// Load an input FrancaIDL model.
			String normalizedFrancaFilePath = normalize(francaFilePath);
			ConsoleLogger.logInfo("Loading FrancaIDL file " + normalizedFrancaFilePath);
			ConsoleLogger.increaseIndentationLevel();
			FModel francaModel;
			try {
				francaModel = francaLoader.loadModel(normalizedFrancaFilePath);
			} catch(Exception e) {
				ConsoleLogger.logError("File " + normalizedFrancaFilePath + " could not be loaded!");
				ConsoleLogger.decreaseIndentationLevel();
				continue;
			}
			if (francaModel == null) {
				ConsoleLogger.logError("File " + normalizedFrancaFilePath + " could not be loaded!");
				ConsoleLogger.decreaseIndentationLevel();
				continue;
			}
			URI francaModelUri = francaModel.eResource().getURI();
			if (!francaModelUri.fileExtension().toLowerCase().equals("fidl")) {
				ConsoleLogger.logWarning("The FrancaIDL file " + normalizedFrancaFilePath + " does not have the file extension \"fidl\".");
			}
			ConsoleLogger.decreaseIndentationLevel();
			
			// Transform the FrancaIDL model to an arxml model.
			ConsoleLogger.logInfo("Converting FrancaIDL file " + normalizedFrancaFilePath);
			ARAModelContainer araModelContainer = (ARAModelContainer)conn.fromFranca(francaModel);

			// Store the output arxml model.
			URI transformedModelUri = francaModelUri.trimFileExtension().appendFileExtension("arxml");
			String outputDirectoryPath = preferences.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "");
			if (!outputDirectoryPath.isEmpty()) {
				outputDirectoryPath += "/";
			}
			String araFilePath = normalize(outputDirectoryPath + transformedModelUri.lastSegment());
			ConsoleLogger.logInfo("Storing arxml file " + araFilePath);
			conn.saveModel(araModelContainer, araFilePath);
		}

//		createShowcaseARATests.createDrivingLaneARXML();

		ConsoleLogger.decreaseIndentationLevel();

//		francaGenerator = injector.getInstance(FrancaDBusGenerator.class);
	}

	public void convertARAFiles(String[] araFilePaths) {
		if (araFilePaths == null || araFilePaths.length == 0) {
			return;
		}

		ConsoleLogger.logInfo("Converting Adaptive AUTOSAR IDL models to Franca IDL models...");
		ConsoleLogger.increaseIndentationLevel();

		ARAConnector conn = new ARAConnector();
		for (String araFilePath : araFilePaths) {
			// Load an input arxml model.
			String normalizedARAFilePath = normalize(araFilePath);
			ConsoleLogger.logInfo("Loading arxml file " + normalizedARAFilePath);
			ConsoleLogger.increaseIndentationLevel();
			ARAModelContainer araModelContainer;
			try {
				araModelContainer = (ARAModelContainer)conn.loadModel(normalizedARAFilePath);
			} catch(Exception e) {
				ConsoleLogger.logError("File " + normalizedARAFilePath + " could not be loaded!");
				ConsoleLogger.decreaseIndentationLevel();
				continue;
			}
			URI araModelUri = araModelContainer.model().eResource().getURI();
			if (!araModelUri.fileExtension().toLowerCase().equals("arxml")) {
				ConsoleLogger.logWarning("The Adaptive AUTOSAR file " + normalizedARAFilePath + " does not have the file extension \"arxml\".");
			}
			ConsoleLogger.decreaseIndentationLevel();

			// Transform the arxml model to a FrancaIDL model.
			ConsoleLogger.logInfo("Converting arxml file " + normalizedARAFilePath);
			FrancaModelContainer fmodel = (FrancaModelContainer)conn.toFranca(araModelContainer);

			// Store the output FrancaIDL model.
			URI transformedModelUri = araModelUri.trimFileExtension().appendFileExtension("fidl");
			String outputDirectoryPath = preferences.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "");
			if (!outputDirectoryPath.isEmpty()) {
				outputDirectoryPath += "/";
			}
			String francaFilePath = normalize(outputDirectoryPath + transformedModelUri.lastSegment());
			ConsoleLogger.logInfo("Storing FrancaIDL file " + francaFilePath);
			francaLoader.saveModel(fmodel.model(), francaFilePath);
		}

		ConsoleLogger.decreaseIndentationLevel();
	}

	protected String normalize(String _path) {
		File itsFile = new File(_path);
		return itsFile.getAbsolutePath();
	}

//	/**
//	 * Call the franca generator for the specified list of files.
//	 *
//	 * @param fileList
//	 *            the list of files to generate code from
//	 */
//	protected int doGenerate(List<String> _fileList) {
//		fsa.setOutputConfigurations(Preferences.getInstance()
//				.getOutputpathConfiguration());
//
//		XtextResourceSet rsset = injector.getProvider(XtextResourceSet.class)
//				.get();
//
//		int error_state = NO_ERROR_STATE;
//		ConsoleLogger.printLog("Using Franca Version " + getFrancaVersion());
//
//		// Create absolute paths
//		List<String> fileList = new ArrayList<String>();
//		for (String path : _fileList) {
//			String absolutePath = normalize(path);
//			fileList.add(absolutePath);
//		}
//
//		for (String file : fileList) {
//			URI uri = URI.createFileURI(file);
//			Resource resource = null;
//			try {
//				resource = rsset.createResource(uri);
//			} catch (IllegalStateException ise) {
//				ConsoleLogger.printErrorLog("Failed to create a resource from "
//						+ file + "\n" + ise.getMessage());
//				error_state = ERROR_STATE;
//				continue;
//			}
//			hasValidationError = false;
//			if (isValidation) {
//				validateDBus(resource);
//			}
//			if (!hasValidationError) {
//				ConsoleLogger.printLog("Generating code for " + file);
//				try {
//					if (Preferences.getInstance().getPreference(
//							PreferencesConstants.P_OUTPUT_SUBDIRS_DBUS, "false").equals("true")) {
//						String subdir = (new File(file)).getName();
//						subdir = subdir.replace(".fidl", "");
//						subdir = subdir.replace(".fdepl", "");
//						fsa.setOutputConfigurations(Preferences.getInstance()
//							.getOutputpathConfiguration(subdir));
//					}
////					francaGenerator.doGenerate(resource, fsa);
//				} catch (Exception e) {
//					ConsoleLogger
//							.printErrorLog("Failed to generate dbus code: "
//									+ e.getMessage());
//					error_state = ERROR_STATE;
//				}
//			} else {
//				error_state = ERROR_STATE;
//			}
//			if (resource != null) {
//				// Clear each resource from the resource set in order to let
//				// other fidl files import it.
//				// Otherwise an IllegalStateException will be thrown for a
//				// resource that was already created.
//				resource.unload();
//				rsset.getResources().clear();
//			}
//		}
//		if (dumpGeneratedFiles) {
//			fsa.dumpGeneratedFiles();
//		}
//		fsa.clearFileList();
//		dumpGeneratedFiles = false;
//		return error_state;
//	}

//	/**
//	 * Validate the fidl/fdepl file resource
//	 *
//	 * @param resource
//	 */
//	public void validateDBus(Resource resource) {
//		EObject model = null;
//		CommandlineValidator cliValidator = new CommandlineValidator(
//				cliMessageAcceptor);
//
//		//ConsoleLogger.printLog("validating " + resource.getURI().lastSegment());
//
//		model = cliValidator.loadResource(resource);
//
//		if (model != null) {
//			if (model instanceof FDModel) {
//				// Many error logs would be displayed if a SomeIP deployment file had DBus
//				// deployment information (or vice versa).
//				// Therefore don't validate fdepl files for DBus at the moment
//				return;
//				// cliValidator.validateImports((FDModel) model, resource.getURI());
//			}
//			// check existence of imported fidl/fdepl files
//			if (model instanceof FModel) {
//				cliValidator.validateImports((FModel) model, resource.getURI());
//
//				// validate against GENIVI rules
//				ValidatorCore validator = new ValidatorCore();
//				try {
//					validator.validateModel((FModel) model, cliMessageAcceptor);
//				} catch (Exception e) {
//					ConsoleLogger.printErrorLog(e.getMessage());
//					hasValidationError = true;
//					return;
//				}
//			}
//			// XText validation
//			cliValidator.validateResourceWithImports(resource);
//		} else {
//			// model is null, no resource factory was registered !
//			hasValidationError = true;
//		}
//	}

	public void setNoCommonCode() {
		preferences.setPreference(PreferencesConstants.P_GENERATE_COMMON_DBUS,
				"false");
		ConsoleLogger.logInfo("No common code will be generated");
	}

	public void setNoProxyCode() {
		preferences.setPreference(PreferencesConstants.P_GENERATE_PROXY_DBUS,
				"false");
		ConsoleLogger.logInfo("No proxy code will be generated");
	}

	public void setNoStubCode() {
		preferences.setPreference(PreferencesConstants.P_GENERATE_STUB_DBUS,
				"false");
		ConsoleLogger.logInfo("No stub code will be generated");
	}

	public void setOutputDirectoryPath(String outputDirectoryPath) {
		String normalizedOutputDirectoryPath = normalize(outputDirectoryPath);
		ConsoleLogger.logInfo("Output directory path: " + normalizedOutputDirectoryPath);
		preferences.setPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, normalizedOutputDirectoryPath);
	}

	public void setLogLevel(String optionValue) {
		if (PreferencesConstants.LOGLEVEL_QUIET.equals(optionValue)) {
			preferences.setPreference(PreferencesConstants.P_LOGOUTPUT, "false");
			ConsoleLogger.enableInfosLogging(false);
			ConsoleLogger.enableWarningsLogging(false);
			ConsoleLogger.enableErrorsLogging(false);
		}
		if (PreferencesConstants.LOGLEVEL_VERBOSE.equals(optionValue)) {
			preferences.setPreference(PreferencesConstants.P_LOGOUTPUT, "true");
			ConsoleLogger.enableInfosLogging(true);
			ConsoleLogger.enableWarningsLogging(true);
			ConsoleLogger.enableErrorsLogging(true);
		}
	}

	public void setWarningsAsErrors(boolean enabled) {
		preferences.setPreference(PreferencesConstants.P_WARNINGS_AS_ERRORS, enabled ? "true" : "false");
		ConsoleLogger.enableWarningsAsErrors(enabled);
	}

	public void setContinueOnErrors(boolean enabled) {
		preferences.setPreference(PreferencesConstants.P_CONTINUE_ON_ERRORS, enabled ? "true" : "false");
		ConsoleLogger.enableContinueOnErrors(enabled);
	}

//	public void disableValidation() {
//		ConsoleLogger.printLog("Validation is off");
//		isValidation = false;
//	}

	/**
	 * Set the text from a file which will be inserted as a comment in each
	 * generated file (for example your license)
	 *
	 * @param fileWithText
	 * @return
	 */
	public void setLicenseText(String fileWithText) {

		String licenseText = getLicenseText(fileWithText);

		if (licenseText != null && !licenseText.isEmpty()) {
			preferences.setPreference(PreferencesConstants.P_LICENSE, licenseText);
		}
	}

	@Override
    public String getFrancaVersion() {
		return Platform.getBundle("org.franca.core").getVersion().toString();
	}

	public void listGeneratedFiles() {
		dumpGeneratedFiles = true;
	}

}
