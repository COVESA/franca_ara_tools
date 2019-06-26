package org.franca.connectors.ara.console.internal;

import org.apache.commons.cli.CommandLine;
import org.franca.connectors.ara.console.AbstractCommandLineHandler;
import org.franca.connectors.ara.console.CommandExecuter;

public class HelpCommandHandler extends AbstractCommandLineHandler
{
    @Override
    public int excute(CommandLine parsedArguments)
    {
        // Command executer will print help on empty command.
        CommandExecuter.INSTANCE.executeCommand("");

        return 0;
    }
}
