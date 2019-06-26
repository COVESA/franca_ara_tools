package org.franca.connectors.ara.franca2ara

import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FBasicTypeId

class ARATypeHelper {
	private new (){}
	
	def static boolean refsPrimitiveType(FTypeRef fTypeRef){
		return fTypeRef !== null && FBasicTypeId.UNDEFINED != fTypeRef.predefined 
	}
}
