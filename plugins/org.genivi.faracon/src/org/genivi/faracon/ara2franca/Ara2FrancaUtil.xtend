package org.genivi.faracon.ara2franca

import org.eclipse.emf.common.util.URI
import org.franca.core.franca.FModel

class Ara2FrancaUtil {
	new(){}
	
	/**
	 * Calculates the Franca file name based on the autosar URI and the name of the FModel
	 * We use the name of the input file with ".fidl" as extension and the name of the fModel
	 * 
	 */
	def static String calculateFrancaFileNameFromAutosarUri(URI araModelUri, FModel fModel) {
		val modelName = fModel.name
		return araModelUri.calculateFrancaFileNameFromAutosarUri(modelName)
	}
	
	def static String calculateFrancaFileNameFromAutosarUri(URI araModelUri, String modelName){
		val araFileName = araModelUri.trimFileExtension.lastSegment();
		val francaFileName = araFileName + "_" + modelName;
		return francaFileName + ".fidl"
	}
	
}