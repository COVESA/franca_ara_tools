package org.genivi.faracon.stdtypes

import autosar40.autosartoplevelstructure.AUTOSAR
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtend.lib.annotations.Data

class AraStandardTypeDefinitionsModel {

	var AraStandardTypes araStandardTypes

	var IAraStdTypesLoader araStdTypesLoader
	
	new(){
		araStdTypesLoader = new AraStdTypesFromPluginLoader
	}

	def loadStandardTypeDefinitions(ResourceSet resourceSet) {
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
