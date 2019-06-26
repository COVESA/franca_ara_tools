package org.franca.connectors.ara.cli;

import java.io.File;
import java.util.List;

import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EStructuralFeature;
import org.eclipse.xtext.validation.AbstractValidationMessageAcceptor;
import org.eclipse.xtext.validation.ValidationMessageAcceptor;
import org.franca.connectors.ara.ARAConnector;
import org.franca.connectors.ara.console.CommandlineTool;
import org.franca.connectors.ara.console.ConsoleLogger;
//import org.genivi.commonapi.core.generator.GeneratorFileSystemAccess;
//import org.genivi.commonapi.core.verification.CommandlineValidator;
//import org.genivi.commonapi.core.verification.ValidatorCore;
//import org.genivi.commonapi.dbus.generator.FrancaDBusGenerator;
import org.franca.connectors.ara.preferences.Preferences;
import org.franca.connectors.ara.preferences.PreferencesConstants;
import org.franca.core.dsl.FrancaIDLRuntimeModule;
import org.franca.core.framework.IModelContainer;

import com.google.inject.Guice;
import com.google.inject.Injector;

/**
 * Receive command line arguments and set them as preference values for the code
 * generation.
 */
public class CommandlineToolMain extends CommandlineTool {
	protected Injector injector;
	protected CreateShowcaseARATests createShowcaseARATests;
//	protected GeneratorFileSystemAccess fsa;
	protected Preferences preferences;
//	protected IGenerator francaGenerator;
	protected String SCOPE = "DBus validation: ";

	private ValidationMessageAcceptor cliMessageAcceptor = new AbstractValidationMessageAcceptor() {

		@Override
		public void acceptInfo(String message, EObject object,
				EStructuralFeature feature, int index, String code,
				String... issueData) {
			ConsoleLogger.printLog(SCOPE + message);
		}

		@Override
		public void acceptWarning(String message, EObject object,
				EStructuralFeature feature, int index, String code,
				String... issueData) {
			ConsoleLogger.printLog("Warning: " + SCOPE + message);
		}

		@Override
		public void acceptError(String message, EObject object,
				EStructuralFeature feature, int index, String code,
				String... issueData) {
			hasValidationError = true;
			ConsoleLogger.printErrorLog("Error: " + SCOPE + message);
		}
	};

	/**
	 * The constructor registers the needed bindings to use the generator
	 */
	public CommandlineToolMain() {

		injector = Guice.createInjector(new FrancaIDLRuntimeModule());

		createShowcaseARATests = injector.getInstance(CreateShowcaseARATests.class);

//		fsa = injector.getInstance(GeneratorFileSystemAccess.class);

		preferences = Preferences.getInstance();

	}

	public int generateDBus(List<String> fileList) {
		String inputfile = "C:/Users/tgoerg/git/franca_ara_tools/tests/org.franca.connectors.ara.tests/src-gen/testcases/drivingLane.arxml";
		System.out.println("Loading arxml file " + inputfile + " ...");
		ARAConnector conn = new ARAConnector();
		IModelContainer amodel = conn.loadModel(inputfile);

		createShowcaseARATests.createDrivingLaneARXML();
		
//		francaGenerator = injector.getInstance(FrancaDBusGenerator.class);

		System.out.println("Franca Ara Connector");
		return 0;
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
		ConsoleLogger.printLog("No common code will be generated");
	}

	public void setNoProxyCode() {
		preferences.setPreference(PreferencesConstants.P_GENERATE_PROXY_DBUS,
				"false");
		ConsoleLogger.printLog("No proxy code will be generated");
	}

	public void setNoStubCode() {
		preferences.setPreference(PreferencesConstants.P_GENERATE_STUB_DBUS,
				"false");
		ConsoleLogger.printLog("No stub code will be generated");
	}

	public void setDefaultDirectory(String optionValue) {
		ConsoleLogger.printLog("Default output directory: " + optionValue);
		preferences.setPreference(PreferencesConstants.P_OUTPUT_DEFAULT_DBUS,
				optionValue);
		// In the case where no other output directories are set,
		// this default directory will be used for them
		preferences.setPreference(PreferencesConstants.P_OUTPUT_COMMON_DBUS,
				optionValue);
		preferences.setPreference(PreferencesConstants.P_OUTPUT_PROXIES_DBUS,
				optionValue);
		preferences.setPreference(PreferencesConstants.P_OUTPUT_STUBS_DBUS,
				optionValue);
	}

	public void setDestinationSubdirs() {
		ConsoleLogger.printLog("Using destination subdirs");
		preferences.setPreference(PreferencesConstants.P_OUTPUT_SUBDIRS_DBUS,
			"true");
	}

	public void setCommonDirectory(String optionValue) {
		ConsoleLogger.printLog("Common output directory: " + optionValue);
		preferences.setPreference(PreferencesConstants.P_OUTPUT_COMMON_DBUS,
				optionValue);
	}

	public void setProxyDirectory(String optionValue) {
		ConsoleLogger.printLog("Proxy output directory: " + optionValue);
		preferences.setPreference(PreferencesConstants.P_OUTPUT_PROXIES_DBUS,
				optionValue);
	}

	public void setStubDirectory(String optionValue) {
		ConsoleLogger.printLog("Stub output directory: " + optionValue);
		preferences.setPreference(PreferencesConstants.P_OUTPUT_STUBS_DBUS,
				optionValue);
	}

	public void setLogLevel(String optionValue) {
		if (PreferencesConstants.LOGLEVEL_QUIET.equals(optionValue)) {
			preferences.setPreference(PreferencesConstants.P_LOGOUTPUT_DBUS,
					"false");
			ConsoleLogger.enableLogging(false);
			ConsoleLogger.enableErrorLogging(false);
		}
		if (PreferencesConstants.LOGLEVEL_VERBOSE.equals(optionValue)) {
			preferences.setPreference(PreferencesConstants.P_LOGOUTPUT_DBUS,
					"true");
			ConsoleLogger.enableErrorLogging(true);
			ConsoleLogger.enableLogging(true);
		}
	}

	public void disableValidation() {
		ConsoleLogger.printLog("Validation is off");
		isValidation = false;
	}

	/**
	 * set a preference value to disable code generation
	 */
	public void disableCodeGeneration() {
		ConsoleLogger.printLog("Code generation is off");
		preferences.setPreference(PreferencesConstants.P_GENERATE_CODE_DBUS,
				"false");
	}

	/**
	 * Set a preference value to disable code generation for included types and
	 * interfaces
	 */
	public void noCodeforDependencies() {
		ConsoleLogger.printLog("Code generation for includes is off");
		preferences.setPreference(
				PreferencesConstants.P_GENERATE_DEPENDENCIES_DBUS, "false");
	}

	public void disableSyncCalls() {
		ConsoleLogger.printLog("Code generation for synchronous calls is off");
		preferences.setPreference(
				PreferencesConstants.P_GENERATE_SYNC_CALLS_DBUS, "false");
	}

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
			preferences.setPreference(PreferencesConstants.P_LICENSE_DBUS,
					licenseText);
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
