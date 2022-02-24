package org.genivi.faracon.franca2ara.types

import javax.inject.Singleton
import javax.inject.Inject
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.franca2ara.config.Franca2ARAConfigProvider
import autosar40.commonstructure.implementationdatatypes.ArraySizeSemanticsEnum
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.swcomponent.datatype.datatypes.ArraySizeHandlingEnum
import org.franca.core.franca.FBasicTypeId

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
	
	/**
	 * Create fixed-size string.
	 */
	def private create fac.createImplementationDataType createStringType(int len, ARPackage where) {
		shortName = IDTPrefix + "String_" + len
		initUUID(shortName)
		category = CAT_ARRAY
		subElements += createTypeElemForString(shortName) => [
			arraySizeHandling = ArraySizeHandlingEnum.ALL_INDICES_SAME_ARRAY_SIZE
			arraySizeSemantics = ArraySizeSemanticsEnum.FIXED_SIZE
			arraySize = fac.createPositiveIntegerValueVariationPoint => [
				it.mixedText = len.toString
			]
		]
		ARPackage = where
	}

	/**
	 * Create variable-sized string. 
	 */
	def private create fac.createImplementationDataType createStringType(ARPackage where) {
		val n = IDTPrefix + "String_varSize"
		shortName = n
		initUUID(shortName)
		if (useSizeAndPayloadStructs) {
			category = CAT_STRUCTURE
			subElements += fac.createImplementationDataTypeElement => [
				shortName = n + "_Size"
				initUUID(shortName)
				category = CAT_VALUE
				swDataDefProps = fac.createSwDataDefProps => [
					swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
						baseType = getBaseTypeForReference(FBasicTypeId.UINT16)
					]
				]
			]
			subElements += fac.createImplementationDataTypeElement => [
				shortName = n + "_Payload"
				initUUID(shortName)
				category = CAT_ARRAY
				subElements += createTypeElemForString(n) => [
					arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
				]
			]
		} else {
			category = CAT_ARRAY
			subElements += createTypeElemForString(n) => [
				arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
			]
		}
		ARPackage = where
	}

	def private createTypeElemForString(String parentName) {
		val it = fac.createImplementationDataTypeElement
		shortName = "IDT_uint8"
		initUUID(parentName + "_stringelem")
		category = CAT_VALUE
		swDataDefProps = fac.createSwDataDefProps => [
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
				baseType = getStringBaseType
			]
		]
		it
	} 
	
}
