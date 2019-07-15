package org.genivi.faracon.cli;

import org.apache.commons.cli.CommandLine;
import org.genivi.faracon.console.AbstractCommandLineHandler;
import org.genivi.faracon.console.ConsoleLogger;
import org.genivi.faracon.console.ICommandLineHandler;
import org.genivi.faracon.logging.ILogger;

import com.google.inject.Guice;
import com.google.inject.Injector;

/**
 * The main purpose of this handler class is to instantiate the real converter command implementation 
 * with a proper dependency injection.
 */
public class ConverterCliCommandHandler extends AbstractCommandLineHandler implements ICommandLineHandler
{

	protected Injector injector;
	protected ConverterCliCommand converterCliCommand;

    public ConverterCliCommandHandler()
    {
		injector = Guice.createInjector(new ConverterCliModule());

		converterCliCommand = injector.getInstance(ConverterCliCommand.class);
    }

    @Override
	public int execute(CommandLine parsedArguments) {
		// Delegate the converter execution to the class 'ConverterCliCommand'.
    	return converterCliCommand.execute(parsedArguments);
    }
    
}
