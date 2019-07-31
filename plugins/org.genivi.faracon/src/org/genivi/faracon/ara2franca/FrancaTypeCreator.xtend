package org.genivi.faracon.ara2franca

import autosar40.commonstructure.datadefproperties.SwDataDefProps
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.commonstructure.implementationdatatypes.ImplementationDataTypeElement
import autosar40.swcomponent.datatype.computationmethod.CompuScales
import java.util.Objects
import javax.inject.Singleton
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.ARA2FrancaBase

@Singleton
class FrancaTypeCreator extends ARA2FrancaBase {

	def transform(ImplementationDataType src) {
		if (src == null) {
			getLogger.logWarning('''Cannot create Franca type for not set implementation type.''')
			return null
		}
		if (src.category == "STRUCTURE") {
			return transformStructure(src)
		} else if (src.category == "ASSOCIATIVE_MAP") {
			return transformMap(src)
		} else if (src.category == "TYPE_REFERENCE") {
			return transformEnumeration(src)
		} else if (src.category == "VECTOR") {
			return transformArray(src)
		} else {
			getLogger.
				logWarning('''Cannot create Franca type for "«src.shortName»" because AutosarDatatypes of category "«src.category»" are not yet supported''')
			return null
		}
	}

	/**
	 * Creates a default type, which can be used for the transformation if no source type is provided.
	 * Before calling this method an error should be logged.
	 */
	def createDefaultTypeRef() {
		val typeRef = fac.createFTypeRef
		typeRef.predefined = FBasicTypeId.get(FBasicTypeId.UINT32_VALUE)
		return typeRef
	}

	def protected create fac.createFStructType transformStructure(ImplementationDataType src) {
		name = src.shortName
		if (src.subElements !== null) {
			for (subElement : src.subElements) {
				val araStructElementType = getTypeRefTargetType(subElement)
				if (araStructElementType !== null) {
					val field = fac.createFField => [
						name = subElement.shortName
						type = createFTypeRef(araStructElementType)
					]
					elements.add(field)
				} else {
					getLogger.logError('''araStructElementType === null''')
				}
			}
		}
	}

	def protected create fac.createFMapType transformMap(ImplementationDataType src) {
		name = src.shortName

		val araKeyType = getPropertyType(src, "keyType")
		if (araKeyType !== null) {
			keyType = createFTypeRef(araKeyType)
		} else {
			getLogger.logError('''araKeyType === null''')
		}

		val araValueType = getPropertyType(src, "valueType")
		if (araValueType !== null) {
			valueType = createFTypeRef(araValueType)
		} else {
			getLogger.logError('''araValueType === null''')
		}
	}

	def protected create fac.createFEnumerationType transformEnumeration(ImplementationDataType src) {
		name = src.shortName

		val araEnumerators = getEnumerationTypeEnumerators(src)
		if (araEnumerators !== null) {
			for (araEnumerator : araEnumerators) {
				enumerators.add(fac.createFEnumerator => [
					name = araEnumerator.symbol
				])
			}
		} else {
			getLogger.
				logError('''No Enumerators found for type "«src.shortName»". The Franca enumeration cannot be created correctly as it will not have any enumerators.''')
		}
	}

	def protected create fac.createFArrayType transformArray(ImplementationDataType src) {
		name = src.shortName

		val araElementType = getPropertyType(src, "valueType")
		if (araElementType !== null) {
			elementType = createFTypeRef(araElementType)
		} else {
			getLogger.logError('''araElementType === null''')
		}
	}

	def protected getPropertyType(ImplementationDataType typeDef, String properyName) {
		val subElements = typeDef.subElements
		if (subElements === null) {
			getLogger.logError('''subElements === null''')
			return null
		}
		// Search for the matching sub element.
		var ImplementationDataTypeElement typeRefElement = null
		for (subElement : subElements) {
			if (subElement.shortName == properyName) {
				typeRefElement = subElement
			}
		}
		val propertyType = getTypeRefTargetType(typeRefElement)
		propertyType
	}

	def protected getTypeRefTargetType(ImplementationDataTypeElement typeRef) {
		if (typeRef === null) {
			getLogger.logError('''typeRef === null''')
			return null
		}
		if (typeRef.category != "TYPE_REFERENCE") {
			getLogger.logError('''typeRef.category != "TYPE_REFERENCE"''')
			return null
		}
		val firstProperty = getFirstProperty(typeRef.swDataDefProps)
		if (firstProperty === null) {
			getLogger.logError('''firstProperty === null''')
			return null
		}
		val typeRefTargetType = firstProperty.implementationDataType as ImplementationDataType
		typeRefTargetType
	}

	def protected getEnumerationTypeEnumerators(ImplementationDataType enumerationTypeDef) {
		val firstPropertyWithCompuMethod = getFirstPropertyWithTexttableCompuMethod(enumerationTypeDef.swDataDefProps)
		val errorMsg = "Cannot create enumerator. Reason: "
		if (firstPropertyWithCompuMethod === null) {
			getLogger.logError('''no property is defined for "«enumerationTypeDef»".''')
			return null
		}
		val compuMethod = firstPropertyWithCompuMethod.compuMethod
		if (compuMethod === null) {
			getLogger.logError('''«errorMsg»no CompuMethod is defined for ""«firstPropertyWithCompuMethod»".''')
			return null
		}
		val compu = compuMethod.compuInternalToPhys
		if (compu === null) {
			getLogger.logError('''«errorMsg»no compuInternalToPhys is defined for "«compu»"''')
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

	def protected getFirstPropertyWithTexttableCompuMethod(SwDataDefProps swDataDefProps) {
		val swDataDefPropsVariants = getSwDataDefPropsVariants(swDataDefProps)
		if (null === swDataDefPropsVariants) {
			return null
		}
		val firstPropertyWithTexttableCompuMethod = swDataDefPropsVariants.findFirst [
			it.compuMethod !== null && Objects.equals(it.compuMethod.category, "TEXTTABLE")
		]
		if(firstPropertyWithTexttableCompuMethod === null){
			logger.logError('''No TEXTTABLE compu method found for "«swDataDefProps»" ''')
			return null
		}
		return firstPropertyWithTexttableCompuMethod

	}

	def protected getFirstProperty(SwDataDefProps swDataDefProps) {
		val firstProperty = getSwDataDefPropsVariants(swDataDefProps)?.get(0)
		return firstProperty
	}

	def private getSwDataDefPropsVariants(SwDataDefProps swDataDefProps) {
		val errorMsg = "Cannot find Autosar data property. Reason: "
		if (swDataDefProps === null) {
			return null
		}
		if (swDataDefProps.swDataDefPropsVariants.nullOrEmpty) {
			getLogger.logError('''«errorMsg»No variant is defined for «swDataDefProps».''')
			return null
		}
		return swDataDefProps.swDataDefPropsVariants
	}

	// Important: This cannot be realized as a Xtend create function because we need
	// to create multiple type ref objects that point to the same type object!
	def createFTypeRef(ImplementationDataType src) {
		val typeRef = fac.createFTypeRef
		if (isPrimitiveType(src)) {
			typeRef.predefined = FBasicTypeId.getByName(src.shortName)
		} else {
			typeRef.derived = transform(src)
		}
		typeRef
	}

	// TODO: This is just a preliminary solution. It should be replaced by an implementation
	// that identifies primitive types more reliably.
	def protected isPrimitiveType(ImplementationDataType src) {
		src?.category == "VALUE" || src?.category == "STRING"
	}

}
