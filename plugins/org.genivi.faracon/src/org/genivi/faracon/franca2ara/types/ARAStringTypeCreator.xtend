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
		val te = tc.typedElement
		val len = te.getStringLength
		val len1 = len!==null ? len : 0
		val isFixedSize = te.isFixedSizedString
		val enc = te.stringEncoding
		if (isFixedSize) {
			createFixedStringType(len1, enc, where)
		} else {
			createVariableStringType(te.getStringLengthWidth, len1, enc, where)
		}
	}
	
	/**
	 * Create fixed-size string.
	 */
	def private create fac.createImplementationDataType createFixedStringType(
		int len,
		String enc,
		ARPackage where
	) {
		shortName = IDTPrefix + "String" + enc.makeNameSegment + "_" + len
		initUUID(shortName)
		category = CAT_ARRAY
		subElements += createTypeElemForString(shortName) => [
			arraySizeHandling = ArraySizeHandlingEnum.ALL_INDICES_SAME_ARRAY_SIZE
			arraySizeSemantics = ArraySizeSemanticsEnum.FIXED_SIZE
			arraySize = len.asPositiveInteger
		]
		ARPackage = where
	}
	
	/**
	 * Create variable-sized string. 
	 */
	def private create fac.createImplementationDataType createVariableStringType(
		int lengthWidth,
		int maxlen,
		String enc,
		ARPackage where
	) {
		val ml = maxlen>0 ? "_max" + maxlen : ""
		val n = IDTPrefix + "String_varSize_lenbt" + lengthWidth + enc.makeNameSegment + ml
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
						baseType = getBaseTypeForReference(lengthWidth.convertLengthWidth)
					]
				]
			]
			subElements += fac.createImplementationDataTypeElement => [
				shortName = n + "_Payload"
				initUUID(shortName)
				category = CAT_ARRAY
				subElements += createTypeElemForString(n) => [
					arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
					if (maxlen>0) {
						arraySize = maxlen.asPositiveInteger						
					}
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
	
	def private makeNameSegment(String encoding) {
		if (encoding===null)
			return ""
	
		if (encoding=="UTF-8")
			return "_utf8"
		else if (encoding.startsWith("UTF-16"))
			return "_utf16"
		
		return ""
	}

	

	def private createTypeElemForString(String parentName) {
		val it = fac.createImplementationDataTypeElement
		shortName = "IDT_uint8"
		initUUID(parentName + "_stringelem")
		category = CAT_VALUE
		swDataDefProps = fac.createSwDataDefProps => [
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
				baseType = getStringBaseType(null)
			]
		]
		it
	} 
	
}
