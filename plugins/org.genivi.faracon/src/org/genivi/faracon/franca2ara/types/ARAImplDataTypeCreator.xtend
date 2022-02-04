package org.genivi.faracon.franca2ara.types

import autosar40.commonstructure.implementationdatatypes.ArraySizeSemanticsEnum
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.IntervalTypeEnum
import javax.inject.Inject
import javax.inject.Singleton
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.FrancaModelExtensions
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FConstant
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FField
import org.franca.core.franca.FIntegerInterval
import org.franca.core.franca.FMapType
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.franca.core.framework.FrancaHelpers
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.franca2ara.ARAModelSkeletonCreator
import org.genivi.faracon.franca2ara.AutosarAnnotator
import org.genivi.faracon.franca2ara.AutosarSpecialDataGroupCreator
import org.genivi.faracon.franca2ara.Franca2ARAConfigProvider

import static extension org.genivi.faracon.franca2ara.FConstantHelper.*
import static extension org.genivi.faracon.util.FrancaUtil.*
import static extension org.genivi.faracon.franca2ara.types.ARATypeHelper.*


@Singleton
class ARAImplDataTypeCreator extends Franca2ARABase {

	@Inject
	var extension ARAPrimitiveTypesCreator
	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension DeploymentDataHelper
	@Inject
	var extension AutosarAnnotator
	@Inject
	var extension AutosarSpecialDataGroupCreator
	@Inject
	var extension Franca2ARAConfigProvider

	static final String ANNOTATION_LABEL_ORIGINAL_STRUCT_TYPE = "OriginalStructType"
	static final String ANNOTATION_LABEL_ORIGINAL_UNION_TYPE = "OriginalUnionType"


	//val Map<String, ImplementationDataType> arrayTypeNameToImplementationDataType = newHashMap()
	var ARPackage dtPackage = null


	def ImplementationDataType createImplDataTypeReference(FTypeRef fTypeRef, FTypedElement fTypedElement) {
		val tc = new TypeContext(fTypedElement)
		if (!fTypedElement.isArray) {
			fTypeRef.createImplDataTypeReference(tc)
		} else {
			fTypeRef.createImplAnonymousArrayTypeReference(tc)
		}
	}

	def ImplementationDataType createImplDataTypeReference(FTypeRef fTypeRef, TypeContext tc) {
		if (fTypeRef.interval !== null) {
			logger.logError('''Cannot properly convert '«tc.typedElementName»' in '«tc.namespaceName»' because integer interval types are not supported.''')
			null
		} else if (fTypeRef.refsPrimitiveType) {
			if (false && FrancaHelpers.isString(fTypeRef)) {
				// TODO implement string handling
			} else {
				getBaseTypeForReference(fTypeRef.predefined, tc)				
			}
		} else {
			val derived = fTypeRef.derived
			if (replaceIDTPrimitiveTypeDefs) {
				if (derived instanceof FTypeDef) {
					// this follows the typedef chain until primitive type is reached
					val primType = FrancaHelpers.getActualPredefined(fTypeRef)
					if (primType!=FBasicTypeId.UNDEFINED) {
						return getBaseTypeForReference(derived.actualType.predefined, tc)
					}
				}
			}
			getImplDataType(derived)				
		}
	}
	
	def private getImplStringType() {
		
	}
	
	def ImplementationDataType getImplDataType(FType type) {
		type.createDataTypeForReference
	}

	def private dispatch ImplementationDataType createDataTypeForReference(FType type) {
		getLogger.logWarning('''Cannot create AutosarDatatype because the Franca type "«type.eClass.name»" is not yet supported''')
		return null
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FStructType fStructType) {
		fillAutosarCompoundType(fStructType, "STRUCTURE", ANNOTATION_LABEL_ORIGINAL_STRUCT_TYPE, it)
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FUnionType fUnionType) {
		fillAutosarCompoundType(fUnionType, "UNION", ANNOTATION_LABEL_ORIGINAL_UNION_TYPE, it)
	}

	// Use 'FCompoundType' in order to deal with union and struct types in the same way.
	def private fillAutosarCompoundType(
		FCompoundType fCompoundType,
		String category,
		String annotationLabelText,
		ImplementationDataType aCompoundType
	) {
		fCompoundType.checkCompoundType
		aCompoundType.shortName = getIDTPrefix + fCompoundType.name
		aCompoundType.category = category
		val fAllElements = FrancaModelExtensions.getAllElements(fCompoundType).map[it as FField]
		val aAllElements = fAllElements.map [
			val newElement = it.createImplDataTypeElement(fCompoundType)
			val FCompoundType originalCompoundType = it.eContainer as FCompoundType
			if (originalCompoundType !== fCompoundType) {
				newElement.addAnnotation(annotationLabelText, originalCompoundType.ARFullyQualifiedName)
			}
			newElement
		]
		aCompoundType.subElements.addAll(aAllElements)
		aCompoundType.postprocess(fCompoundType, true)
	}

	def dispatch void checkCompoundType(FCompoundType type) {
		logger.logWarning("Unknown compound type found " + type +
			". Transformation to Autosar might not work correctly.")
	}

	def dispatch void checkCompoundType(FStructType type) {
		if (type.polymorphic) {
			logger.
				logError('''Struct type "«type.name»" is polymorphic. This cannot be transformed to Autosar (IDL1670).''')
		}
	}

	def dispatch void checkCompoundType(FUnionType type) {
		// nothing to check
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(
		FEnumerationType fEnumerationType) {
		val enumCompuMethod = fEnumerationType.createCompuMethod
		shortName = getIDTPrefix + fEnumerationType.name
		it.category = "TYPE_REFERENCE"
		it.swDataDefProps = fac.createSwDataDefProps => [
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
				compuMethod = enumCompuMethod
			// TODO: check whether we need a type for the compu-method itself
			// implementationDataType = getBaseTypeForReference(FBasicTypeId.UINT32)
			]
		]
		it.postprocess(fEnumerationType, true)
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FMapType fMapType) {
		it.shortName = getIDTPrefix + fMapType.name
		it.category = "ASSOCIATIVE_MAP"
		it.subElements += createTypeRefImplementationDataTypeElement("keyType", fMapType.francaNamespaceName, fMapType.keyType)
		it.subElements += createTypeRefImplementationDataTypeElement("valueType", fMapType.francaNamespaceName, fMapType.valueType)
		it.postprocess(fMapType, true)
	}

	def private createTypeRefImplementationDataTypeElement(String elementShortName, String namespaceName, FTypeRef referencedType) {
		fac.createImplementationDataTypeElement => [
			shortName = elementShortName
			category = "TYPE_REFERENCE"
			it.swDataDefProps = fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					val tc = new TypeContext(elementShortName, namespaceName)
					implementationDataType = referencedType.createImplDataTypeReference(tc) as ImplementationDataType
				]
			]
		]
	}

	def create fac.createCompuMethod createCompuMethod(FEnumerationType fEnumerationType) {
		shortName = getCompuMethodPrefix + fEnumerationType.name + "_CompuMethod"
		it.category = "TEXTTABLE"
		val allEnumerators = FrancaModelExtensions.getInheritationSet(fEnumerationType).map[it as FEnumerationType].map [
			it.enumerators
		].flatten
		val compuScalesForEnum = allEnumerators.map [ enumerator |
			fac.createCompuScale => [ compuScale |
				compuScale.symbol = enumerator.name
				if (enumerator.value !== null) {
					val enumValue = enumerator.value
					if (enumValue instanceof FConstant) {
						val limitText = enumValue.valueFromFConstant
						if (limitText === null) {
							logger.
								logError('''Did not found a constant values for "«enumerator.value.class.simpleName»" in enumerator "«enumerator.name»" of enumeration "«fEnumerationType.name»"''')
						}
						val arLimit = fac.createLimitValueVariationPoint => [
							it.intervalType = IntervalTypeEnum.CLOSED
							it.mixedText = limitText
						]
						compuScale.lowerLimit = EcoreUtil.copy(arLimit)
						compuScale.upperLimit = arLimit
					} else {
						logger.
							logError('''Only constant values are supported for enums, but found "«enumerator.value.class.simpleName»" in enumerator "«enumerator.name»" of enumeration "«fEnumerationType.name»"''')
					}
				}
			]
		]
		it.compuInternalToPhys = fac.createCompu => [
			it.compuContent = fac.createCompuScales => [
				it.compuScales.addAll(compuScalesForEnum)
			]
		]

		it.ARPackage = storeIDTsLocally ? fEnumerationType.createAccordingArPackage : getDataTypesPackage
	}

	def private dispatch ImplementationDataType createDataTypeForReference(FIntegerInterval type) {
		getLogger.logError("The Franca model element \"" + type.name +
			"\" of metatype 'FIntegerInterval' cannot be converted into an AUTOSAR representation! (IDL2590)")
		return null
	}

	def create fac.createImplementationDataTypeElement createImplDataTypeElement(
		FTypedElement fTypedElement,
		FCompoundType fParentCompoundType
	) {
		it.shortName = fTypedElement.name
		it.category = CAT_TYPEREF
		if (generateOptionalFalse)
			it.isOptional = false
		val dataDefProps = fac.createSwDataDefProps
		val dataDefPropsConditional = fac.createSwDataDefPropsConditional
		val typeRef = createImplDataTypeReference(fTypedElement.type, fTypedElement)
		if (typeRef instanceof ImplementationDataType) {
			dataDefPropsConditional.implementationDataType = typeRef
		} else {
			getLogger.logWarning("Cannot set implementation data type for element '" + it.shortName + "'.")
		}
		dataDefProps.swDataDefPropsVariants += dataDefPropsConditional
		it.swDataDefProps = dataDefProps
	}

	/*
	def create fac.createCppImplementationDataTypeElement createCppImplDataTypeElement(FTypedElement fTypedElement,
		FCompoundType fParentCompoundType) {
		it.shortName = fTypedElement.name
		it.category = "TYPE_REFERENCE"
		it.typeReference = fac.createCppImplementationDataTypeElementQualifier => [
			it.typeReference = createImplDataTypeReference(fTypedElement.type, fTypedElement)
		]
		it.isOptional = false
	}
	*/

	// Generate AUTOSAR representation of the given array data type.
	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FArrayType fArrayType) {
		val boolean isFixedSizedArray = fArrayType.isFixedSizedArray
		val int arraySize = fArrayType.getArraySize
		it.shortName = getIDTPrefix + fArrayType.name
		if (isFixedSizedArray || alwaysGenIDTArray) {
			it.category = CAT_ARRAY
		} else {
			it.category = CAT_VECTOR
		}
		it.subElements += fac.createImplementationDataTypeElement => [
			shortName = "valueType"
			if (isFixedSizedArray) {
				it.arraySizeSemantics = ArraySizeSemanticsEnum.FIXED_SIZE
				it.arraySize = fac.createPositiveIntegerValueVariationPoint => [
					it.mixedText = arraySize.toString
				]
			} else {
				it.arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
			}
			it.category = CAT_TYPEREF
			swDataDefProps = fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					val tc = new TypeContext(fArrayType.name, fArrayType.francaNamespaceName)
					implementationDataType = fArrayType.elementType.createImplDataTypeReference(tc) as ImplementationDataType
				]
			]
		]
		it.postprocess(fArrayType, true)
	// TODO: ImplementationDataTypeExtension seems to no more exist in 18.10, what can we do about it?
//		it.createImplementationDataTypeExtension
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FTypeDef fTypeDef) {
		it.shortName = getIDTPrefix + fTypeDef.name
		it.category = CAT_TYPEREF
		it.subElements += fac.createImplementationDataTypeElement => [
			shortName = "valueType"
			it.category = CAT_TYPEREF
			swDataDefProps = fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					val tc = new TypeContext(fTypeDef.name, fTypeDef.francaNamespaceName)
					implementationDataType = fTypeDef.actualType.createImplDataTypeReference(tc)
				]
			]
		]
		it.postprocess(fTypeDef, false)
	}

	def create fac.createImplementationDataType createArtificialVectorType(FType fType) {
		shortName = getIDTPrefix + fType.name + "Vector"
		category = CAT_VECTOR
		subElements += fac.createImplementationDataTypeElement => [
			shortName = "valueType"
			it.arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
			it.category = CAT_TYPEREF
			swDataDefProps = fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					implementationDataType = fType.getImplDataType
				]
			]
		]
		ARPackage = fType.createAccordingArPackage
	}

	def private createArtificialArrayType(FType fType, int arraySize) {
		createArtificialArrayType(
			fType.getImplDataType,
			arraySize,
			fType.createAccordingArPackage
		)
	}

	def private create fac.createImplementationDataType createArtificialArrayType(
		ImplementationDataType aElementType,
		int arraySize,
		ARPackage aPackage
	) {
		shortName = getIDTPrefix + aElementType.shortName + "Array" + arraySize
		category = CAT_ARRAY
		subElements += fac.createImplementationDataTypeElement => [
			shortName = "valueType"
			it.arraySizeSemantics = ArraySizeSemanticsEnum.FIXED_SIZE
			it.arraySize = fac.createPositiveIntegerValueVariationPoint => [
				it.mixedText = arraySize.toString
			]
			it.category = "TYPE_REFERENCE"
			swDataDefProps = fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					implementationDataType = aElementType
				]
			]
		]
		ARPackage = aPackage
	}


	def private postprocess(ImplementationDataType aType, FType fType, boolean setPackage) {
		if (setPackage) {
			aType.ARPackage = storeIDTsLocally ? fType.createAccordingArPackage : getDataTypesPackage
		}
		aType.addSdgForFrancaElement(fType)
		
		// TODO: ImplementationDataTypeExtension seems to no more exist in 18.10, what can we do about it?
//		aType.createImplementationDataTypeExtension		
	}

	// TODO: ImplementationDataTypeExtension seems to no more exist in 18.10, what can we do about it?
//	def private create fac.createImplementationDataTypeExtension createImplementationDataTypeExtension(
//		AutosarDataType autosarType) {
//		it.shortName = autosarType.shortName + "Ext"
//		it.implementationDataType = autosarType as ImplementationDataType
//		it.namespaces.addAll(autosarType.createNamespaceForElement)
//		autosarType.ARPackage.elements.add(it)
//	}



	// Create an artificial array or vector type if necessary.
	def createImplAnonymousArrayTypeReference(FTypeRef fTypeRef, TypeContext tc) {
		val boolean isFixedSizedArray = tc.typedElement.isFixedSizedArray
		val int arraySize = tc.typedElement.getArraySize
		if (fTypeRef.refsPrimitiveType) {
			if (isFixedSizedArray) {
				val aElementType = getBaseTypeForReference(fTypeRef.predefined, tc)
				createArtificialArrayType(aElementType, arraySize, getOrCreatePrimitiveTypesAnonymousArraysMainPackage)
			} else {
				getBaseTypeVectorForReference(fTypeRef.predefined, tc)
			}
		} else {
			if (isFixedSizedArray) {
				createArtificialArrayType(fTypeRef.derived, arraySize)
			} else {
				createArtificialVectorType(fTypeRef.derived)
			}
		}
	}

	def private getDataTypesPackage() {
		if (dtPackage===null) {
			dtPackage = createPackageWithName("ImplementationDataTypes", createRootPackage("DataTypes"))
		}
		dtPackage
	}


}
