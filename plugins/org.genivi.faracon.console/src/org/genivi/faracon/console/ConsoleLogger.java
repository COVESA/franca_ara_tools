package org.genivi.faracon.console;

/**
 * A simple command line logger.
 * 
 * @author notbert
 *
 */


public class ConsoleLogger {

	private static boolean isLogoutput = true;
	private static boolean isErrorLogoutput = true;

	/**
	 * Enable or disable the log output
	 * @param enabled true or false
	 */
	public static void enableLogging(boolean enabled) {
		isLogoutput = enabled;
	}

	/**
	 * Enable or disable the error log output
	 * @param enabled true or false
	 */
	public static void enableErrorLogging(boolean enabled) {
		isErrorLogoutput = enabled;
	}

	public static void printLog(String message) {
		if(isLogoutput) {
			System.out.println(message);
		}
	}

	public static void printErrorLog(String message) {
		if(isErrorLogoutput) {
			System.err.println(message);
		}
	}
}
