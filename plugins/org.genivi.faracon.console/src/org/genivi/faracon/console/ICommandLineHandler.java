package org.genivi.faracon.console;

import org.apache.commons.cli.CommandLine;

public interface ICommandLineHandler
{
    /**
     * This method has to be implemented. It will be called by the console plug-in if the application arguments match the specification.
     *
     * @param parsedArguments
     *            The parsed arguments with their values
     * @return result of the excution
     */
    public int excute(CommandLine parsedArguments);
}
