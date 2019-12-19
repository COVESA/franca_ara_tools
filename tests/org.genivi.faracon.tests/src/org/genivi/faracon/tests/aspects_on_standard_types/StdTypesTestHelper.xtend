package org.genivi.faracon.tests.aspects_on_standard_types

import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants

class StdTypesTestHelper {
	private new() {
	}

	def static useDefaultAutosarStdTypes() {
		setAraStdTypesPreferences(false, "")
	}

	def static useCustomizedAutosarStdTypes(String fileName) {
		setAraStdTypesPreferences(true, fileName)
	}

	def static useCustomizedAutosarStdTypes() {
		useCustomizedAutosarStdTypes("src/org/genivi/faracon/tests/aspects_on_standard_types/customizedAutosarStdTypes.arxml")
	}

	def private static setAraStdTypesPreferences(boolean customAraStdTypesUsed, String customAraStdTypesPath) {
		val preferences = Preferences.instance
		preferences.setPreference(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_USED, customAraStdTypesUsed.toString)
		preferences.setPreference(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_PATH, customAraStdTypesPath)
	}
}