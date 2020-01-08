package org.genivi.faracon.ara2franca

import autosar40.genericstructure.generaltemplateclasses.arobject.ARObject
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable
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
	

	static def String getARFullyQualifiedName(ARObject arObject) {
		val ARObject aParent = arObject.eContainer as ARObject
		val parentARFullyQualifiedName =
			if (aParent !== null) aParent.ARFullyQualifiedName else ""
		val unqualifiedName =
			if (arObject instanceof Referrable) "/" + arObject.shortName else ""
		parentARFullyQualifiedName + unqualifiedName
	}

}