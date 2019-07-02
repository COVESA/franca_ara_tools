package org.genivi.faracon.cli;

import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.genivi.faracon.console.AbstractCommandLineHandler;
import org.genivi.faracon.console.ConsoleLogger;
import org.genivi.faracon.console.ICommandLineHandler;

/**
 * Handle command line options
 */
public class CommandLineHandler extends AbstractCommandLineHandler implements ICommandLineHandler
{

//    public static final String FILE_EXTENSION_FDEPL = "fdepl";
//    public static final String FILE_EXTENSION_FIDL  = "fidl";

    private CommandlineToolMain cliTool;

    public CommandLineHandler()
    {
    	cliTool = new CommandlineToolMain();
    }

    @Override
	public int excute(CommandLine parsedArguments) {
		// Handle command line options.

//		@SuppressWarnings("unchecked")

		// -l --log-level quiet or verbose
		if (parsedArguments.hasOption("l")) {
			cliTool.setLogLevel(parsedArguments.getOptionValue("l"));
		}

		ConsoleLogger.printLog("Command: Franca ARA Converter");
    	
		List<String> commandLineArguments = parsedArguments.getArgList();
		if (!commandLineArguments.isEmpty()) {
			//TODO: error handling
		}

		String[] francaFilePaths = parsedArguments.getOptionValues('f');
		String[] araFilePaths = parsedArguments.getOptionValues('a');
//		// We expect at least one fidl/fdepl file as command line argument
//		if (files.size() > 0 && files.get(0) != null) {
		if ((francaFilePaths == null || francaFilePaths.length == 0) && (araFilePaths == null || araFilePaths.length == 0)) {
			//TODO: error handling
//			System.out.println("A *.fidl or *.fdepl file was not specified !");
		}		
//		// a search path may be specified, collect all fidl/fdepl files
//		if (parsedArguments.hasOption("sp")) {
//			files.addAll(cliTool.searchFidlandFdeplFiles(parsedArguments
//					.getOptionValue("sp")));
//		}

		// destination: -d --dest overwrite default output directory path
		if (parsedArguments.hasOption("d")) {
			cliTool.setOutputDirectoryPath(parsedArguments.getOptionValue("d"));
		}

		// A file path, that points to a file, that contains the license text.
		// -L --license license text in generated files
		if (parsedArguments.hasOption("L")) {
			cliTool.setLicenseText(parsedArguments.getOptionValue("L"));
		}

//			// Switch off validation
//			if (parsedArguments.hasOption("nv")) {
//				cliTool.disableValidation();
//			}

		// Invoke the converters.
		int result = cliTool.convertFrancaFiles(francaFilePaths);
		if (result == 0) {
			return result;
		}
		result = cliTool.convertARAFiles(araFilePaths);
		if (result == 0) {
			return result;
		}
		return 0;
	}
}
