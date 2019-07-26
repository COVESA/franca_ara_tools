package org.genivi.faracon.console;

import org.genivi.faracon.logging.AbstractLogger;

/**
 * A simple command line logger.
 * 
 */

public class ConsoleLogger extends AbstractLogger {

	// Singleton realization.
	private static ConsoleLogger INSTANCE;
//	private ConsoleLogger() {}
	public static ConsoleLogger getInstance() {
		if (INSTANCE == null) {
			INSTANCE = new ConsoleLogger();
		}
		return INSTANCE;
	}

	@Override
	protected void logInfoImpl(String infoMessage) {
		System.out.println(indentationSpace() + infoMessage);
	}

	public static void staticLogInfo(String infoMessage) {
		getInstance().logInfo(infoMessage);
	}

	@Override
	protected void logWarningImpl(String warningMessage) {
		System.out.println(indentationSpace() + "WARNING: " + warningMessage);
	}
	
	public static void staticLogWarning(String warningMessage) {
		getInstance().logWarning(warningMessage);
	}

	@Override
	protected void logErrorImpl(String errorMessage) {
		System.out.println(indentationSpace() + "ERROR: " + errorMessage);
	}

	public static void staticLogError(String errorMessage) {
		getInstance().logError(errorMessage);
	}

	public static void staticIncreaseIndentationLevel() {
		getInstance().increaseIndentationLevel();
	}

	public static void staticDecreaseIndentationLevel() {
		getInstance().decreaseIndentationLevel();
	}

}
