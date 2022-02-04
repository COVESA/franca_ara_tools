package org.genivi.faracon.franca2ara.types

import javax.inject.Singleton
import javax.inject.Inject
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.franca2ara.Franca2ARAConfigProvider
import autosar40.commonstructure.implementationdatatypes.ArraySizeSemanticsEnum
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage

@Singleton
class ARAStringTypeCreator extends Franca2ARABase {

	@Inject
	var extension ARAPrimitiveTypesCreator
	@Inject
	var extension DeploymentDataHelper
	@Inject
	var extension Franca2ARAConfigProvider

	def getImplStringType(TypeContext tc, ARPackage where) {
		val len = tc.typedElement.getStringLength
		if (len===null || len==0) {
			createStringType(where)
		} else {
			createStringType(len, where)
		}
	}
	
	def private create fac.createImplementationDataType createStringType(int len, ARPackage where) {
		shortName = IDTPrefix + "String_" + len
		category = CAT_ARRAY
		subElements += createTypeElemForString => [
			arraySizeSemantics = ArraySizeSemanticsEnum.FIXED_SIZE
			arraySize = fac.createPositiveIntegerValueVariationPoint => [
				it.mixedText = len.toString
			]
		]
		ARPackage = where
	}

	def private create fac.createImplementationDataType createStringType(ARPackage where) {
		shortName = IDTPrefix + "String"
		category = CAT_ARRAY
		subElements += createTypeElemForString => [
			arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
		]
		ARPackage = where
	}

	def private createTypeElemForString() {
		val it = fac.createImplementationDataTypeElement
		shortName = "valueType"
		it.category = "TYPE_REFERENCE"
		swDataDefProps = fac.createSwDataDefProps => [
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
				implementationDataType = getStringBaseType
			]
		]
		it
	} 
}
