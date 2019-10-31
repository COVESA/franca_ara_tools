package org.genivi.faracon.stdtypes

import autosar40.autosartoplevelstructure.AUTOSAR
import org.eclipse.xtend.lib.annotations.Data
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants

class AraStandardTypeDefinitionsModel {

	var AraStandardTypes araStandardTypes

	var IAraStdTypesLoader araStdTypesLoader
	
	new(){
		if(Preferences.instance.hasPreference(PreferencesConstants.P_ARA_STD_TYPES_PATH)){
			// use user specified std types lib
			val stdTypesPath = Preferences.instance.getPreference(PreferencesConstants.P_ARA_STD_TYPES_PATH, "")
			araStdTypesLoader = new AraStdTypesFromFileLoader(stdTypesPath)			
		}else{
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

}

@Data
package class AraStandardTypes {
	AUTOSAR standardTypeDefinitionsModel
	AUTOSAR standardVectorTypeDefinitionsModel
}
