package org.genivi.faracon.eclipse.ui

import org.eclipse.core.resources.IProject
import org.eclipse.core.runtime.preferences.InstanceScope
import org.eclipse.jface.preference.BooleanFieldEditor
import org.eclipse.jface.preference.DirectoryFieldEditor
import org.eclipse.jface.preference.FieldEditorPreferencePage
import org.eclipse.jface.preference.RadioGroupFieldEditor
import org.eclipse.ui.IWorkbench
import org.eclipse.ui.IWorkbenchPreferencePage
import org.eclipse.ui.preferences.ScopedPreferenceStore
import static extension org.genivi.faracon.preferences.PreferencesConstants.*

class FaraconPreferencesPage extends FieldEditorPreferencePage implements IWorkbenchPreferencePage{

	val static String PREFERENCES_ID = "org.genivi.faracon.eclipse.ui.faraconpreferencespage.id"


	var IProject project

	new (){
		super(GRID)
	}

	override void init(IWorkbench workbench) {
		this.preferenceStore = new ScopedPreferenceStore(InstanceScope.INSTANCE, PREFERENCES_ID)
	}

	override protected void createFieldEditors() {
		val outDir = new DirectoryFieldEditor(P_OUTPUT_DIRECTORY_PATH, "Transformation Output Folder", fieldEditorParent)
		outDir.filterPath = project?.location?.toFile
		addField(outDir)
				
		addField(new BooleanFieldEditor(P_CONTINUE_ON_ERRORS, "Continue on Error", fieldEditorParent))
		addField(new BooleanFieldEditor(P_WARNINGS_AS_ERRORS, "Warnings as Errors", fieldEditorParent))

		val String[][] possibleLogLevels = #[#["Verbose", LOGLEVEL_VERBOSE], #["Quiet", LOGLEVEL_QUIET]]
		val useGroup = true
		val logLevelRadioGroup = new RadioGroupFieldEditor(P_LOGOUTPUT, "Logger setting", 1, possibleLogLevels,
			fieldEditorParent, useGroup)
		addField(logLevelRadioGroup)
	}
	
	def static getInstancePreferences(){
		InstanceScope.INSTANCE.getNode(PREFERENCES_ID)
	} 
}
