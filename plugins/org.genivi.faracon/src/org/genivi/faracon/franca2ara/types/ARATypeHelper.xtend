package org.genivi.faracon.franca2ara.types

import org.franca.core.franca.FArgument
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FCompoundType

import static extension org.franca.core.FrancaModelExtensions.*

class ARATypeHelper {
	private new (){}
	
	def static boolean refsPrimitiveType(FTypeRef fTypeRef){
		return fTypeRef !== null && FBasicTypeId.UNDEFINED != fTypeRef.predefined 
	}


	static def dispatch String getARFullyQualifiedName(FModel fModel) {
		if (!fModel.name.nullOrEmpty) "/" + fModel.name.replace('.', '/') else ""
	}

	static def dispatch String getARFullyQualifiedName(FTypeCollection fTypeCollection) {
		val fModel = fTypeCollection.model;
		(if (fModel !== null) fModel.ARFullyQualifiedName else "") + 
			(if(!fTypeCollection.name.nullOrEmpty) "/" + fTypeCollection.name else "")
	}

	static def dispatch String getARFullyQualifiedName(FModelElement fModelElement) {
		val fTypeCollection = fModelElement.typeCollection;
		(if (fTypeCollection !== null) fTypeCollection.ARFullyQualifiedName else "") +
			"/" + fModelElement?.name
	}

	static def dispatch String getARFullyQualifiedName(FEnumerator fEnumerator) {
		fEnumerator.enumeration.getARFullyQualifiedName +
			"/" + fEnumerator.name
	}

	static def dispatch String getARFullyQualifiedName(FArgument fArgument) {
		(fArgument.eContainer as FMethod).getARFullyQualifiedName +
			"/" + fArgument.name
	}

	static def dispatch String getARFullyQualifiedName(FField fField) {
		(fField.eContainer as FCompoundType).getARFullyQualifiedName +
			"/" + fField.name
	}

}
