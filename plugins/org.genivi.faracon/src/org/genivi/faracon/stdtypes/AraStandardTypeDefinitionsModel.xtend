package org.genivi.faracon.stdtypes

import autosar40.autosartoplevelstructure.AUTOSAR
import org.eclipse.xtend.lib.annotations.Data
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants

class AraStandardTypeDefinitionsModel {

	var AraStandardTypes araStandardTypes

	var IAraStdTypesLoader araStdTypesLoader

	new() {
		val preferences = Preferences.instance
		if (preferences.customAraStdTypesUsed) {
			// use user specified std types lib
			val customAraStdTypesPath = preferences.getPreference(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_PATH, "")
			araStdTypesLoader = new AraStdTypesFromFileLoader(customAraStdTypesPath)
		} else {
			// use stdtypes from plugin
			araStdTypesLoader = new AraStdTypesFromPluginLoader
		}
	}

	def loadStandardTypeDefinitions(ARAResourceSet resourceSet) {
		this.araStandardTypes = araStdTypesLoader.loadStdTypes(resourceSet)
	}

	def getStandardTypeDefinitionsModel() {
		return araStandardTypes.standardTypeDefinitionsModel
	}

	def getStandardVectorTypeDefinitionsModel() {
		return araStandardTypes.standardVectorTypeDefinitionsModel
	}

	 def static customAraStdTypesUsed(Preferences preferences) {
		if (!preferences.hasPreference(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_USED)) {
			return false
		}
		if (!Boolean.parseBoolean(preferences.getPreference(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_USED, "false"))) {
			return false
		}
		if (!preferences.hasPreference(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_PATH)) {
			return false
		}
	 	if (preferences.getPreference(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_PATH, "").nullOrEmpty) {
	 		return false
	 	}
		return true
	}

}

@Data
package class AraStandardTypes {
	AUTOSAR standardTypeDefinitionsModel
	AUTOSAR standardVectorTypeDefinitionsModel
}
