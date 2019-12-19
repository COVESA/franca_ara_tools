package org.genivi.faracon.eclipse.ui

import com.google.inject.Guice
import java.util.Collection
import java.util.Collections
import java.util.Set
import org.eclipse.core.filesystem.EFS
import org.eclipse.core.resources.IContainer
import org.eclipse.core.resources.IFile
import org.eclipse.core.runtime.NullProgressMonitor
import org.eclipse.jface.action.IAction
import org.eclipse.jface.viewers.ISelection
import org.eclipse.jface.viewers.StructuredSelection
import org.eclipse.ui.IObjectActionDelegate
import org.eclipse.ui.IWorkbenchPart
import org.genivi.faracon.cli.ConverterCliCommand
import org.genivi.faracon.cli.ConverterCliModule
import org.genivi.faracon.logging.ILogger

import static org.genivi.faracon.eclipse.ui.FaraconPreferencesPage.*
import static org.genivi.faracon.preferences.PreferencesConstants.*

abstract class AbstractTransformationAction implements IObjectActionDelegate {
	var ISelection selection
	var ILogger logger
	val String fileExtension
	var protected ConverterCliCommand converter
	
	new(String fileExtension){
		this.fileExtension = fileExtension
	}
	
	def protected Set<String> initConverterAndFindFile(){
		// init converter and logger in order to use it during traversal of the selection
		this.converter = initConverter
		this.logger = converter.logger
		val relevantIFiles = findRelevantFilesInSelection
		val filePaths = relevantIFiles.map [
			val file = EFS.getStore(it.locationURI).toLocalFile(0, new NullProgressMonitor)
			return file.absolutePath
		]
		if(filePaths.isEmpty){
			logger.logError('''No files with extension «fileExtension» selected. No transformation will be executed!''')
		}
		return filePaths.toSet
	}
	
	def private Collection<IFile> findRelevantFilesInSelection() {
		if (selection.empty || !(selection instanceof StructuredSelection)) {
			logger.logError("No elements selected. Transformation cannot be performed")
			return Collections.emptyList
		}
		val structuredSelection = selection as StructuredSelection
		val selectedElements = structuredSelection.toList
		val relevantFiles = newHashSet()
		selectedElements.forEach[
			it.findRelevantFiles(relevantFiles)
		]
		return relevantFiles
	}

	def dispatch void findRelevantFiles(Object object, Set<IFile> relevantIFiles) {
		logger.logError(
			"Selection of element " + object + " is not supported. Files contained in " + object +
				" are not used for the transformation")
	}

	def dispatch void findRelevantFiles(IFile iFile, Set<IFile> relevantIFiles) {
		if(iFile?.fileExtension == fileExtension){
			relevantIFiles.add(iFile)
		}
	}
	
	def dispatch void findRelevantFiles(IContainer iFolder, Set<IFile> relevantFiles){
		iFolder.members.forEach[
			it.findRelevantFiles(relevantFiles)
		]
	}

	def protected initConverter() {
		val injector = Guice.createInjector(new ConverterCliModule(EclipseUiLogger))
		val converter = injector.getInstance(ConverterCliCommand)
		converter.setPreferences
		return converter
	}

	def private void setPreferences(ConverterCliCommand converter) {
		val preferences = instancePreferences
		converter.continueOnErrors = Boolean.parseBoolean(preferences.get(P_CONTINUE_ON_ERRORS, "false"))
		converter.logLevel = preferences.get(P_LOGOUTPUT, LOGLEVEL_VERBOSE)
		converter.outputDirectoryPath = preferences.get(P_OUTPUT_DIRECTORY_PATH, "./output")
		converter.warningsAsErrors = Boolean.parseBoolean(preferences.get(P_WARNINGS_AS_ERRORS, "false"))
		val customAraStdTypesUsed = Boolean.parseBoolean(preferences.get(P_CUSTOM_ARA_STD_TYPES_USED, "false"))
		converter.setAraStdTypesPreferences(customAraStdTypesUsed, preferences.get(P_CUSTOM_ARA_STD_TYPES_PATH, ""))
	}

	override void selectionChanged(IAction action, ISelection selection) {
		this.selection = selection
	}

	override void setActivePart(IAction action, IWorkbenchPart targetPart) {
	}
}