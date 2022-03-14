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
import org.genivi.faracon.franca2ara.config.Franca2ARAConfigProvider

import static extension org.genivi.faracon.franca2ara.FConstantHelper.*
import static extension org.genivi.faracon.util.FrancaUtil.*
import static extension org.genivi.faracon.franca2ara.types.ARATypeHelper.*
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import autosar40.commonstructure.datadefproperties.SwDataDefProps
import autosar40.swcomponent.datatype.datatypes.ArraySizeHandlingEnum

@Singleton
class ARAImplDataTypeCreator extends Franca2ARABase {

	@Inject
	var extension ARAPrimitiveTypesCreator
	@Inject
	var extension ARAStringTypeCreator
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

	def initialize() {
		dtPackage = null
	}

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
			if (FrancaHelpers.isString(fTypeRef) && generateStringAsArray && tc.hasTypedElement) {
				val pkg = storeIDTsLocally ? tc.typedElement.createAccordingArPackage : getDataTypesPackage
				getImplStringType(tc, pkg)
			} else {
				getStdTypeForReference(fTypeRef.predefined, tc)				
			}
		} else {
			val derived = fTypeRef.derived
			if (replaceIDTPrimitiveTypeDefs) {
				if (derived instanceof FTypeDef) {
					// this follows the typedef chain until primitive type is reached
					val primType = FrancaHelpers.getActualPredefined(fTypeRef)
					if (primType!=FBasicTypeId.UNDEFINED) {
						return getStdTypeForReference(derived.actualType.predefined, tc)
					}
				}
			}
			getImplDataType(derived)	
		}
	}
	
	def ImplementationDataType getImplDataType(FType type) {
		type.createDataTypeForReference
	}

	def private dispatch ImplementationDataType createDataTypeForReference(FType type) {
		getLogger.logWarning('''Cannot create AutosarDatatype because the Franca type "«type.eClass.name»" is not yet supported''')
		return null
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FStructType fStructType) {
		fillAutosarCompoundType(fStructType, CAT_STRUCTURE, ANNOTATION_LABEL_ORIGINAL_STRUCT_TYPE, it)
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FUnionType fUnionType) {
		fillAutosarCompoundType(fUnionType, CAT_UNION, ANNOTATION_LABEL_ORIGINAL_UNION_TYPE, it)
	}

	// Use 'FCompoundType' in order to deal with union and struct types in the same way.
	def private fillAutosarCompoundType(
		FCompoundType fCompoundType,
		String category,
		String annotationLabelText,
		ImplementationDataType aCompoundType
	) {
		fCompoundType.checkCompoundType
		aCompoundType.shortName = getIDTPrefixComplex + fCompoundType.name
		aCompoundType.category = category
		val fAllElements = FrancaModelExtensions.getAllElements(fCompoundType).map[it as FField]
		val aAllElements = fAllElements.map [
			val newElement = it.createImplDataTypeElement(fCompoundType.name)
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

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FEnumerationType fEnumerationType) {
		shortName = getIDTPrefixBasic + fEnumerationType.name
		initAsEnumeration([props | swDataDefProps = props], fEnumerationType)
		it.postprocess(fEnumerationType, true)
	}
	
	def private initAsEnumeration(Identifiable it, (SwDataDefProps) => void dataDefPropsSetter, FEnumerationType fEnumerationType) {
		initUUID(shortName + "_" + fEnumerationType.name)
		category = avoidTypeReferences ? CAT_VALUE : CAT_TYPEREF
		val enumCompuMethod = fEnumerationType.createCompuMethod
		dataDefPropsSetter.apply(
			fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					compuMethod = enumCompuMethod
					val ebt = getEnumBaseType(fEnumerationType)
					if (ebt != FBasicTypeId.UNDEFINED) {
						baseType = getBaseTypeForReference(ebt)
					}
				]
			]					
		)
	} 

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FMapType fMapType) {
		it.shortName = getIDTPrefixComplex + fMapType.name
		initUUID(fMapType)
		it.category = "ASSOCIATIVE_MAP"
		it.subElements += createTypeRefImplementationDataTypeElement("keyType", fMapType.francaNamespaceName, fMapType.keyType)
		it.subElements += createTypeRefImplementationDataTypeElement("valueType", fMapType.francaNamespaceName, fMapType.valueType)
		it.postprocess(fMapType, true)
	}

	def private createTypeRefImplementationDataTypeElement(String elementShortName, String namespaceName, FTypeRef referencedType) {
		fac.createImplementationDataTypeElement => [
			shortName = elementShortName
			initUUID(shortName + "_" + namespaceName)
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
		initUUID(shortName)
		category = "TEXTTABLE"
		val allEnumerators = FrancaModelExtensions.getInheritationSet(fEnumerationType).map[it as FEnumerationType].map [
			it.enumerators
		].flatten
		val compuScalesForEnum = allEnumerators.map [ enumerator |
			fac.createCompuScale => [ compuScale |
				compuScale.shortLabel = enumerator.name
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
		String ownerName
	) {
		shortName = fTypedElement.name
		if (generateOptionalFalse)
			isOptional = false
			
		if (skipCompoundTypeRefs) {
			if (fTypedElement.type.refsPrimitiveType) {
				// skip type reference for primitive types
				val bt = getBaseTypeForReference(fTypedElement.type.predefined)
				if (bt!==null) {
					initUUID(ownerName + "_" + fTypedElement.name)
					category = CAT_VALUE
					swDataDefProps = fac.createSwDataDefProps => [
						swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
							baseType = bt
						]
					]
					return					
				}
			}
			if (FrancaHelpers.isEnumeration(fTypedElement.type)) {
				// skip type reference for enumerations
				initAsEnumeration([props | swDataDefProps = props], fTypedElement.type.derived as FEnumerationType)
				return
			}
		}
		
		// for all other types, create a type reference
		initUUID(ownerName + "_" + fTypedElement.name)
		// not sure CAT_VALUE will be correct here at all, this is a type reference after all 
		category = skipCompoundTypeRefs ? CAT_VALUE : CAT_TYPEREF
		swDataDefProps = fac.createSwDataDefProps => [
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
				val typeRef = createImplDataTypeReference(fTypedElement.type, fTypedElement)
				if (typeRef instanceof ImplementationDataType) {
					implementationDataType = typeRef
				} else {
					getLogger.logWarning("Cannot set implementation data type for element '" + fTypedElement.name + "'.")
				}
			]
		]
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
		val int sizeOfArray = fArrayType.getArraySize
		val lengthWidthType = fArrayType.getArrayLengthWidth.convertLengthWidth
		val n = getIDTPrefixComplex + fArrayType.name
		shortName = n
		if (!isFixedSizedArray && useSizeAndPayloadStructs) {
			category = CAT_STRUCTURE
			//dynamicArraySizeProfile = VSA_LINEAR
			subElements += fac.createImplementationDataTypeElement => [
				shortName = n + "_Size"
				initUUID(shortName)
				category = CAT_VALUE
				swDataDefProps = fac.createSwDataDefProps => [
					swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
						baseType = getBaseTypeForReference(
							lengthWidthType!==null ? lengthWidthType : FBasicTypeId.UINT16
						)
					]
				]
			]
			subElements += fac.createImplementationDataTypeElement => [
				shortName = n + "_Payload"
				initUUID(shortName)
				category = CAT_ARRAY
				subElements += createTypeElemForArray(fArrayType) => [
					arraySizeHandling = ArraySizeHandlingEnum.ALL_INDICES_SAME_ARRAY_SIZE
					arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
				]
			]
		} else {
			if (isFixedSizedArray || alwaysGenIDTArray) {
				category = CAT_ARRAY
			} else {
				category = CAT_VECTOR
			}
			it.subElements += createTypeElemForArray(fArrayType) => [
				if (isFixedSizedArray) {
					arraySizeSemantics = ArraySizeSemanticsEnum.FIXED_SIZE
					arraySize = sizeOfArray.asPositiveInteger
				} else {
					//arraySizeHandling = ArraySizeHandlingEnum.ALL_INDICES_SAME_ARRAY_SIZE
					arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
				}
			]
		}
		it.postprocess(fArrayType, true)
	// TODO: ImplementationDataTypeExtension seems to no more exist in 18.10, what can we do about it?
//		it.createImplementationDataTypeExtension
	}
	
	def private createTypeElemForArray(FArrayType fArrayType) {
		val it = fac.createImplementationDataTypeElement
		shortName = "valueType"
		initUUID("Elem_" + fArrayType.name)
		category = avoidTypeReferences ? CAT_VALUE : CAT_TYPEREF
		swDataDefProps = fac.createSwDataDefProps => [
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
				val tc = new TypeContext(fArrayType.name, fArrayType.francaNamespaceName)
				implementationDataType = fArrayType.elementType.createImplDataTypeReference(tc) as ImplementationDataType
			]
		]
		it
	} 
	
	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FTypeDef fTypeDef) {
		it.shortName = getIDTPrefixBasic + fTypeDef.name
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
		shortName = getIDTPrefixComplex + fType.name + "Vector"
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
		int sizeOfArray,
		ARPackage aPackage
	) {
		shortName = getIDTPrefixComplex + aElementType.shortName + "Array" + sizeOfArray
		category = CAT_ARRAY
		subElements += fac.createImplementationDataTypeElement => [
			shortName = "valueType"
			category = CAT_TYPEREF
			arraySizeSemantics = ArraySizeSemanticsEnum.FIXED_SIZE
			arraySize = sizeOfArray.asPositiveInteger
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
		aType.initUUID(fType)
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
				val aElementType = getStdTypeForReference(fTypeRef.predefined, tc)
				createArtificialArrayType(aElementType, arraySize, getOrCreatePrimitiveTypesAnonymousArraysMainPackage)
			} else {
				getStdTypeVectorForReference(fTypeRef.predefined, tc)
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
