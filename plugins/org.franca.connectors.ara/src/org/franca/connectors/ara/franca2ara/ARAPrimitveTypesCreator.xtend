package org.franca.connectors.ara.franca2ara

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import java.util.HashMap
import javax.inject.Singleton
import org.franca.connectors.ara.Franca2ARABase
import org.franca.core.franca.FBasicTypeId
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.IntervalTypeEnum

@Singleton
class ARAPrimitveTypesCreator extends Franca2ARABase {

	var ImplementationDataType int8
	var ImplementationDataType uint8
	var ImplementationDataType int16
	var ImplementationDataType uint16
	var ImplementationDataType int32
	var ImplementationDataType uint32
	var ImplementationDataType int64
	var ImplementationDataType uint64
	var ImplementationDataType booleanType
	var ImplementationDataType stringType
	var ImplementationDataType floatType
	var ImplementationDataType doubleType
	var ImplementationDataType byteBuffer

	val nameToType = new HashMap<String, ImplementationDataType>()

	def create fac.createARPackage createPrimitiveTypesPackage() {
		it.shortName = "PrimitiveTypes"

		this.int8 = createImplementationValueDataType(FBasicTypeId.INT8.getName(), it, "-128", "127")
		this.uint8 = createImplementationValueDataType(FBasicTypeId.UINT8.getName(), it, "0", "255")
		this.int16 = createImplementationValueDataType(FBasicTypeId.INT16.getName(), it, "-32768", "32767" )
		this.uint16 = createImplementationValueDataType(FBasicTypeId.UINT16.getName(), it, "0", "65535" )
		this.int32 = createImplementationValueDataType(FBasicTypeId.INT32.getName(), it, "-2147483648", "2147483647" )
		this.uint32 = createImplementationValueDataType(FBasicTypeId.UINT32.getName(), it, "0", "4294967295" )
		this.int64 = createImplementationValueDataType(FBasicTypeId.INT64.getName(), it, "-9223372036854775808", "9223372036854775807")
		this.uint64 = createImplementationValueDataType(FBasicTypeId.UINT64.getName(), it, "0", "18446744073709551616" )
		this.floatType = createImplementationValueDataType(FBasicTypeId.FLOAT.getName(), it, Float.MIN_VALUE.toString, Float.MAX_VALUE.toString)
		this.doubleType = createImplementationValueDataType(FBasicTypeId.DOUBLE.getName(), it, Double.MIN_VALUE.toString, Double.MIN_VALUE.toString)
		this.booleanType = createImplementationValueDataType(FBasicTypeId.BOOLEAN.getName(), it, "0", "1")
		this.stringType = createImplementationStringDataType(FBasicTypeId.STRING.getName(), it)
		//this.byteBuffer = createImplementationValueDataType(FBasicTypeId.BYTE_BUFFER.getName(), it)
	}
	
	private def create fac.createImplementationDataType createImplementationStringDataType(String name, ARPackage targetPackage) {
		shortName = name
		category = "STRING"
		it.ARPackage = targetPackage
		nameToType.put(name, it)
	}

	private def create fac.createImplementationDataType createImplementationValueDataType(String name,
		ARPackage targetPackage, String lowerLimit, String upperLimit) {
		shortName = name
		category = "VALUE"
		nameToType.put(name, it)
		it.ARPackage = targetPackage
		it.withDataConstr(lowerLimit, upperLimit)
	}

	private def create fac.createDataConstr  withDataConstr(ImplementationDataType implementationDataType,
		String lowerLimit, String upperLimit) {
		val newDataConstr = it
		newDataConstr.ARPackage = implementationDataType.ARPackage
		newDataConstr.shortName = implementationDataType.shortName + "_DataConstr"
		newDataConstr.dataConstrRules += fac.createDataConstrRule => [
			physConstrs = fac.createPhysConstrs => [
				it.lowerLimit = fac.createLimitValueVariationPoint => [
					it.intervalType = IntervalTypeEnum.CLOSED
					it.gSetValue(lowerLimit)
				]
				it.upperLimit = fac.createLimitValueVariationPoint => [
					it.intervalType = IntervalTypeEnum.CLOSED
					it.gSetValue(upperLimit)
				]
			]
		]
		implementationDataType.swDataDefProps = fac.createSwDataDefProps
		implementationDataType.swDataDefProps.swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
			it.dataConstr = newDataConstr
		]
	}

	def getBaseTypeForReference(FBasicTypeId fBasicTypeId) {
		this.nameToType.get(fBasicTypeId.getName)
	}
}
