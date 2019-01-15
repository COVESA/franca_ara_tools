package org.franca.connectors.ara.ara2franca

import autosar40.commonstructure.datadefproperties.SwDataDefProps
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.commonstructure.implementationdatatypes.ImplementationDataTypeElement
import autosar40.swcomponent.datatype.computationmethod.CompuScales
import javax.inject.Singleton
import org.apache.log4j.Logger
import org.franca.connectors.ara.ARA2FrancaBase
import org.franca.core.franca.FBasicTypeId

@Singleton
class FrancaTypeCreator extends ARA2FrancaBase {

	static final Logger logger = Logger.getLogger(FrancaTypeCreator.simpleName)

	def transform(ImplementationDataType src) {
		if (src.category == "STRUCTURE") {
			return transformStructure(src)
		} else if (src.category == "ASSOCIATIVE_MAP") {
			return transformMap(src)
		} else if (src.category == "TYPE_REFERENCE") {
			return transformEnumeration(src)
		} else if (src.category == "VECTOR") {
			return transformArray(src)
		} else {
			logger.warn('''Cannot create Franca type for "«src.shortName»" because AutosarDatatypes of category "«src.category»" are not yet supported''')
			return null
		}
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
					logger.error('''araStructElementType === null''')
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
			logger.error('''araKeyType === null''')
		}

		val araValueType = getPropertyType(src, "valueType")
		if (araValueType !== null) {
			valueType = createFTypeRef(araValueType)
		} else {
			logger.error('''araValueType === null''')
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
			logger.error('''araEnumerators === null''')
		}
	}

	def protected create fac.createFArrayType transformArray(ImplementationDataType src) {
		name = src.shortName

		val araElementType = getPropertyType(src, "valueType")
		if (araElementType !== null) {
			elementType = createFTypeRef(araElementType)
		} else {
			logger.error('''araElementType === null''')
		}
	}

	def protected getPropertyType(ImplementationDataType typeDef, String properyName) {
		val subElements = typeDef.subElements
		if (subElements === null) {
			logger.error('''subElements === null''')
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
			logger.error('''typeRef === null''')
			return null
		}
		if (typeRef.category != "TYPE_REFERENCE") {
			logger.error('''typeRef.category != "TYPE_REFERENCE"''')
			return null
		}
		val firstProperty = getFirstProperty(typeRef.swDataDefProps)
		if (firstProperty === null) {
			logger.error('''firstProperty === null''')
			return null
		}
		val typeRefTargetType = firstProperty.implementationDataType as ImplementationDataType
		typeRefTargetType
	}

	def protected getEnumerationTypeEnumerators(ImplementationDataType enumerationTypeDef) {
		val firstProperty = getFirstProperty(enumerationTypeDef.swDataDefProps)
		if (firstProperty === null) {
			logger.error('''firstProperty === null''')
			return null
		}
		val compuMethod = firstProperty.compuMethod
		if (compuMethod === null) {
			logger.error('''compuMethod === null''')
			return null
		}
		val compu = compuMethod.compuInternalToPhys
		if (compu === null) {
			logger.error('''compu === null''')
			return null
		}
		val compuScales = compu.compuContent as CompuScales
		if (compuScales === null) {
			logger.error('''compuScales === null''')
			return null
		}
		val enumerators = compuScales.compuScales
		enumerators
	}

	def protected getFirstProperty(SwDataDefProps swDataDefProps) {
		if (swDataDefProps === null) {
			logger.error('''swDataDefProps === null''')
			return null
		}
		if (swDataDefProps.swDataDefPropsVariants.nullOrEmpty) {
			logger.error('''swDataDefProps.swDataDefPropsVariants.nullOrEmpty''')
			return null
		}
		val firstProperty = swDataDefProps.swDataDefPropsVariants.get(0)
		firstProperty
	}

	// Important: This cannot be realized as a Xtend create function because we need
	//            to create multiple type ref objects that point to the same type object!
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
	//       that identifies primitive types more reliably.
	def protected isPrimitiveType(ImplementationDataType src) {
		src.category == "VALUE" || src.category == "STRING"
	}

}
