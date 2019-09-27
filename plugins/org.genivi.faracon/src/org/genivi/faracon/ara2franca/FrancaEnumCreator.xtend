package org.genivi.faracon.ara2franca

import autosar40.commonstructure.datadefproperties.SwDataDefProps
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.IntervalTypeEnum
import autosar40.swcomponent.datatype.computationmethod.CompuScale
import autosar40.swcomponent.datatype.computationmethod.CompuScales
import java.math.BigInteger
import java.util.Objects
import javax.inject.Singleton
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FExpression
import org.genivi.faracon.ARA2FrancaBase
import autosar40.genericstructure.varianthandling.attributevaluevariationpoints.LimitValueVariationPoint
import org.apache.commons.lang.math.NumberUtils

@Singleton
class FrancaEnumCreator extends ARA2FrancaBase {

	def create fac.createFEnumerationType transformEnumeration(ImplementationDataType src) {
		name = src.shortName

		val araEnumerators = getEnumerationTypeEnumerators(src)
		if (araEnumerators !== null) {
			for (araEnumerator : araEnumerators) {
				enumerators.add(fac.createFEnumerator => [
					name = araEnumerator.symbol
					value = araEnumerator.createValueFromCompuScale(it, src)
				])
			}
		} else {
			getLogger.
				logError('''No Enumerators found for type "«src.shortName»". The Franca enumeration cannot be created correctly as it will not have any enumerators.''')
		}
	}

	def private getEnumerationTypeEnumerators(ImplementationDataType enumerationTypeDef) {
		val firstPropertyWithCompuMethod = getFirstPropertyWithTexttableCompuMethod(enumerationTypeDef.swDataDefProps)
		val errorMsg = "Cannot create enumerator. Reason: "
		if (firstPropertyWithCompuMethod === null) {
			getLogger.logError('''no property is defined for «enumerationTypeDef»".''')
			return null
		}
		val compuMethod = firstPropertyWithCompuMethod.compuMethod
		if (compuMethod === null) {
			getLogger.logError('''«errorMsg» no CompuMethod is defined for ""«firstPropertyWithCompuMethod»".''')
			return null
		}
		val compu = compuMethod.compuInternalToPhys
		if (compu === null) {
			getLogger.logError('''«errorMsg» no compuInternalToPhys is defined for "«compu»"''')
			return null
		}
		val compuScales = compu.compuContent as CompuScales
		if (compuScales === null) {
			getLogger.logError('''«errorMsg»no CompuScales is defined for CompuMethod "«compu»".''')
			return null
		}
		val enumerators = compuScales.compuScales
		return enumerators
	}

	def private getFirstPropertyWithTexttableCompuMethod(SwDataDefProps swDataDefProps) {
		val swDataDefPropsVariants = getSwDataDefPropsVariants(swDataDefProps)
		if (null === swDataDefPropsVariants) {
			return null
		}
		val firstPropertyWithTexttableCompuMethod = swDataDefPropsVariants.findFirst [
			it.compuMethod !== null && Objects.equals(it.compuMethod.category, "TEXTTABLE")
		]
		if (firstPropertyWithTexttableCompuMethod === null) {
			logger.logError('''No TEXTTABLE compu method found for "«swDataDefProps»" ''')
			return null
		}
		return firstPropertyWithTexttableCompuMethod
	}

	def private FExpression createValueFromCompuScale(CompuScale scale, FEnumerator fEnum, ImplementationDataType src) {
		if (scale.lowerLimit !== null && scale.upperLimit !== null) {
			val warningMsg = '''Cannot create lower limit and upper limit for Franca enumeration "«fEnum.name»" from Autosar ImplementationDataType "«src.shortName»". '''
			val lowerLimitValue = getLimit(scale.lowerLimit, warningMsg)
			val uppperLimitValue = getLimit(scale.upperLimit, warningMsg)
			if (scale.lowerLimit.intervalType == IntervalTypeEnum.CLOSED &&
				scale.upperLimit.intervalType == IntervalTypeEnum.CLOSED) {
				if (lowerLimitValue !== null && lowerLimitValue == uppperLimitValue) {
					try {
						val intValue = NumberUtils.createInteger(lowerLimitValue)
						val bigIntVal = BigInteger.valueOf(intValue)
						val fInteger = createFIntegerConstant
						fInteger.^val = bigIntVal
						return fInteger
					} catch (NumberFormatException e) {
						logger.logWarning(warningMsg +
							'''Reason: numbers are supported (no expressions). The value, however, is "«lowerLimitValue»". Creating a Franca String value instead.''')
						val stringConstant = createFStringConstant
						stringConstant.^val = lowerLimitValue
						return stringConstant
					}
				} else {
					logger.logWarning(warningMsg +
						'''Reason: only support values where upper limit and lower limit are equal. Lower limit has value "«lowerLimitValue»". Upper limit has value "«uppperLimitValue»"''')
				}
			} else {
				logger.logWarning(warningMsg +
					'''Reason: only CLOSED interval types are supported. Lower limit has interval type "«scale.lowerLimit.intervalType»". Upper limit has interval type "«scale.upperLimit.intervalType»". ''')
			}
		}
		return null
	}

	def getLimit(LimitValueVariationPoint valuePoint, String warningMsg) {
		val retVal = valuePoint?.getMixed()?.get(0)?.getValue()?.toString
		if (retVal.nullOrEmpty) {
			logger.logWarning(warningMsg + "Reason: Could not found value that can be used as limit.")
		}
		return retVal
	}

	def protected getFirstProperty(SwDataDefProps swDataDefProps) {
		val firstProperty = getSwDataDefPropsVariants(swDataDefProps)?.get(0)
		return firstProperty
	}

	def getSwDataDefPropsVariants(SwDataDefProps swDataDefProps) {
		val errorMsg = "Cannot find Autosar data property. Reason: "
		if (swDataDefProps === null) {
			return null
		}
		if (swDataDefProps.swDataDefPropsVariants.nullOrEmpty) {
			getLogger.logError('''«errorMsg» No variant is defined for «swDataDefProps».''')
			return null
		}
		return swDataDefProps.swDataDefPropsVariants
	}
}
