package org.genivi.faracon.console;

import java.util.Collections;

/**
 * A simple command line logger.
 * 
 * @author notbert
 *
 */


public class ConsoleLogger {

	// Singleton realization.
	private static ConsoleLogger INSTANCE;
	private ConsoleLogger() {}
	public static ConsoleLogger getInstance() {
		if (INSTANCE == null) {
			INSTANCE = new ConsoleLogger();
		}
		return INSTANCE;
	}

	private static boolean isLoggingInfos = true;
	private static boolean isLoggingWarnings = true;
	private static boolean isLoggingErrors = true;

	private static boolean isWarningsAsErrors = false;

	private static boolean isContinueOnErrors = false;
	class StopOnErrorException extends RuntimeException {}

	private static int indentationLevel = 0;
	private static final String INDENTATION_STEP_SPACE = "   ";

	/**
	 * Enable or disable the logging of infos.
	 * @param enabled true or false
	 */
	public static void enableInfosLogging(boolean enabled) {
		isLoggingInfos = enabled;
	}

	/**
	 * Enable or disable the logging of warnings.
	 * @param enabled true or false
	 */
	public static void enableWarningsLogging(boolean enabled) {
		isLoggingWarnings = enabled;
	}

	/**
	 * Enable or disable the logging of errors
	 * @param enabled true or false
	 */
	public static void enableErrorsLogging(boolean enabled) {
		isLoggingErrors = enabled;
	}

	/**
	 * Enable or disable that the processing continues after an error has been reported.
	 * @param enabled true or false
	 */
	public static void enableContinueOnErrors(boolean enabled) {
		isContinueOnErrors = enabled;
	}

	/**
	 * Enable or disable that reported warnings are handled as errors.
	 * @param enabled true or false
	 */
	public static void enableWarningsAsErrors(boolean enabled) {
		isWarningsAsErrors = enabled;
	}

	public static void increaseIndentationLevel() {
		indentationLevel++;
	}

	public static void decreaseIndentationLevel() {
		if (indentationLevel > 0) {
			indentationLevel--;
		}
	}

	public static void logInfo(String message) {
		if(isLoggingInfos) {
			System.out.println(indentationSpace() + message);
		}
	}

	public static void logWarning(String message) {
		if (isWarningsAsErrors) {
			logError(message);
		} else {
			if(isLoggingWarnings) {
				System.out.println(indentationSpace() + "WARNING:" + message);
			}
		}
	}

	public static void logError(String message) {
		getInstance().logErrorImpl(message);
	}

	protected void logErrorImpl(String message) {
		if(isLoggingErrors) {
			System.out.println(indentationSpace() + "ERROR: " + message);
		}
		if (!isContinueOnErrors) {
			throw new StopOnErrorException();
		}
	}
	
	private static String indentationSpace() {
		return String.join("", Collections.nCopies(indentationLevel, INDENTATION_STEP_SPACE));
	}

}
