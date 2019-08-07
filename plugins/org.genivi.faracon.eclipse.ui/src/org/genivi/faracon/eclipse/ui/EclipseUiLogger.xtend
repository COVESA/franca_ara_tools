package org.genivi.faracon.eclipse.ui

import org.eclipse.core.runtime.Platform
import org.eclipse.ui.PlatformUI
import org.eclipse.ui.console.ConsolePlugin
import org.eclipse.ui.console.MessageConsole
import org.eclipse.ui.console.MessageConsoleStream
import org.genivi.faracon.logging.AbstractLogger

class EclipseUiLogger extends AbstractLogger {

	var static FARACON_CONSOLE = "Faracon console"

	val MessageConsoleStream infoStream
	val MessageConsoleStream errorStream

	new() {
		if (Platform.isRunning) {
			infoStream = console.newMessageStream
			errorStream = console.newMessageStream
			errorStream.activateOnWrite = true
		} else {
			infoStream = null
			errorStream = null
		}
	}

	def private MessageConsole getConsole() {
		val consoleManager = ConsolePlugin.^default.consoleManager
		var faraconConsole = consoleManager.consoles.findFirst[it.name == FARACON_CONSOLE]
		if (null === faraconConsole) {
			faraconConsole = new MessageConsole(FARACON_CONSOLE, null)
			consoleManager.addConsoles(#[faraconConsole])
		}
		return faraconConsole as MessageConsole
	}

	override protected logErrorImpl(String errorMessage) {
		if (canLog) {
			errorStream.println(errorMessage)
		}
	}

	override protected logInfoImpl(String infoMessage) {
		if (canLog) {
			infoStream.println(infoMessage)
		}
	}

	override protected logWarningImpl(String warningMessage) {
		logInfo(warningMessage)
	}

	def private boolean canLog() {
		infoStream !== null && errorStream !== null && !infoStream.isClosed && !errorStream.isClosed &&
			PlatformUI.isWorkbenchRunning
	}

}
