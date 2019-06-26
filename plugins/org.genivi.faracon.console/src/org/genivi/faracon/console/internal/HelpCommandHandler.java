package org.genivi.faracon.console.internal;

import org.apache.commons.cli.CommandLine;
import org.genivi.faracon.console.AbstractCommandLineHandler;
import org.genivi.faracon.console.CommandExecuter;

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
