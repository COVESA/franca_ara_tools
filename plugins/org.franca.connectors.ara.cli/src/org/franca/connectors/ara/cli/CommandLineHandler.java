package org.franca.connectors.ara.cli;

import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.franca.connectors.ara.console.AbstractCommandLineHandler;
import org.franca.connectors.ara.console.ConsoleLogger;
import org.franca.connectors.ara.console.ICommandLineHandler;

/**
 * Handle command line options
 */
public class CommandLineHandler extends AbstractCommandLineHandler implements ICommandLineHandler
{

    public static final String      FILE_EXTENSION_FDEPL = "fdepl";
    public static final String      FILE_EXTENSION_FIDL  = "fidl";
    private CommandlineToolMain cliTool;

    public CommandLineHandler()
    {
    	cliTool = new CommandlineToolMain();
    }

    @Override
	public int excute(CommandLine parsedArguments) {
		@SuppressWarnings("unchecked")
		List<String> files = parsedArguments.getArgList();
		// a search path may be specified, collect all fidl/fdepl files
		if (parsedArguments.hasOption("sp")) {
			files.addAll(cliTool.searchFidlandFdeplFiles(parsedArguments
					.getOptionValue("sp")));
		}
		// We expect at least one fidl/fdepl file as command line argument
		if (files.size() > 0 && files.get(0) != null) {
			String file = files.get(0);
			// handle command line options

			// -ll --loglevel quiet or verbose
			if (parsedArguments.hasOption("ll")) {
				cliTool.setLogLevel(parsedArguments.getOptionValue("ll"));
			}
			ConsoleLogger
					.printLog("Executing Franca ARA Conversion...\n");

			// Switch off generation of common code
			// -nc --no-common do not generate proxy code
			if (parsedArguments.hasOption("nc")) {
				cliTool.setNoCommonCode();
			}

			// Switch off generation of proxy code
			// -np --no-proxy do not generate proxy code
			if (parsedArguments.hasOption("np")) {
				cliTool.setNoProxyCode();
			}

			// Switch off generation of stub code
			// -ns --no-stub do not generate stub code
			if (parsedArguments.hasOption("ns")) {
				cliTool.setNoStubCode();
			}

			// destination: -d --dest overwrite default directory
			if (parsedArguments.hasOption("d")) {
				cliTool.setDefaultDirectory(parsedArguments.getOptionValue("d"));
			}

			// destination: -dsub --dest-subdirs use destination/<filename>/ subdirs
			// as dest directory
			if(parsedArguments.hasOption("dsub")) {
				cliTool.setDestinationSubdirs();
			}

			// destination: -dc --dest-common overwrite target directory for
			// common part
			if (parsedArguments.hasOption("dc")) {
				cliTool.setCommonDirectory(parsedArguments.getOptionValue("dc"));
			}

			// destination: -dp --dest-proxy overwrite target directory for
			// proxy code
			if (parsedArguments.hasOption("dp")) {
				cliTool.setProxyDirectory(parsedArguments.getOptionValue("dp"));
			}

			// destination: -ds --dest-stub overwrite target directory for stub
			// code
			if (parsedArguments.hasOption("ds")) {
				cliTool.setStubDirectory(parsedArguments.getOptionValue("ds"));
			}

			// A file path, that points to a file, that contains the license
			// text.
			// -l --license license text in generated files
			if (parsedArguments.hasOption("l")) {
				cliTool.setLicenseText(parsedArguments.getOptionValue("l"));
			}

			// Switch off validation
			if (parsedArguments.hasOption("nv")) {
				cliTool.disableValidation();
			}
			// Switch off code generation at all
			if (parsedArguments.hasOption("ng")) {
				cliTool.disableCodeGeneration();
			}
			// Don't generate code for included types and interfaces
			if (parsedArguments.hasOption("wod")) {
				cliTool.noCodeforDependencies();
			}
			// Don't generate synchronous calls
			if (parsedArguments.hasOption("nsc")) {
				cliTool.disableSyncCalls();
			}
			// print out generated files
			if (parsedArguments.hasOption("pf")) {
				cliTool.listGeneratedFiles();
			}
			// finally invoke the generator.
			return cliTool.generateDBus(files);
		} else {
			System.out.println("A *.fidl or *.fdepl file was not specified !");
		}
		return 0;
	}
}
