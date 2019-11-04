package org.genivi.faracon.tests.aspects_on_standard_types

import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants

class StdTypesTestHelper {
	private new(){
	}
	
	
	def static useDefaultStdTypes(){
		setStdTypeUsage(false, "")
	}
	
	def static setUseStdTypes(String fileName){
		setStdTypeUsage(true, fileName)
	}
	
	def static setUseCustomizedAutosarStdTypes(){
		setUseStdTypes("src/org/genivi/faracon/tests/aspects_on_standard_types/customizedAutosarStdTypes.arxml")
	}
	
	def private static setStdTypeUsage(boolean useStdFiles, String fileName){
		val preferences = Preferences.instance
		preferences.setPreference(PreferencesConstants.P_USE_CUSTOM_ARA_STD_TYPES, useStdFiles.toString)
		preferences.setPreference(PreferencesConstants.P_ARA_CUSTOM_STD_TYPES_PATH, fileName)
	}
}