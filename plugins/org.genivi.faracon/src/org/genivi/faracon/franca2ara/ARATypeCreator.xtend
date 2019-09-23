package org.genivi.faracon.franca2ara

import autosar40.commonstructure.implementationdatatypes.ArraySizeSemanticsEnum
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.IntervalTypeEnum
import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import java.util.Map
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
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnionType
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.util.AutosarAnnotator

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.genivi.faracon.franca2ara.ARATypeHelper.*
import static extension org.genivi.faracon.franca2ara.FConstantHelper.*

@Singleton
class ARATypeCreator extends Franca2ARABase {

	@Inject
	var extension ARAPrimitveTypesCreator
	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension AutosarAnnotator

	val Map<String, ImplementationDataType> arrayTypeNameToImplementationDataType = newHashMap()

	static final String ANNOTATION_LABEL_ORIGINAL_STRUCT_TYPE = "OriginalStructType"
	static final String ANNOTATION_LABEL_ORIGINAL_UNION_TYPE = "OriginalUnionType"

	def AutosarDataType createDataTypeReference(FTypeRef fTypeRef, FTypedElement fTypedElement) {
		if (fTypedElement === null || !fTypedElement.isArray) {
			fTypeRef.createDataTypeReference
		} else {
			fTypeRef.createAnonymousArrayTypeReference
		}
	}

	def private AutosarDataType createDataTypeReference(FTypeRef fTypeRef) {
		if (fTypeRef.refsPrimitiveType) {
			getBaseTypeForReference(fTypeRef.predefined)
		} else {
			return getDataTypeForReference(fTypeRef.derived)
		}
	}

	def AutosarDataType getDataTypeForReference(FType type) {
		val autosarType = type.createDataTypeForReference
		// TODO: ImplementationDataTypeExtension seems to no more exist in 18.10, what can we do about it?
//		autosarType.createImplementationDataTypeExtension
		return autosarType
	}

	// TODO: ImplementationDataTypeExtension seems to no more exist in 18.10, what can we do about it?
//	def private create fac.createImplementationDataTypeExtension createImplementationDataTypeExtension(
//		AutosarDataType autosarType) {
//		it.shortName = autosarType.shortName + "Ext"
//		it.implementationDataType = autosarType as ImplementationDataType
//		it.namespaces.addAll(autosarType.createNamespaceForElement)
//		autosarType.ARPackage.elements.add(it)
//	}
	def private dispatch AutosarDataType createDataTypeForReference(FType type) {
		getLogger.
			logWarning('''Cannot create AutosarDatatype because the Franca type "?type.eClass.name?" is not yet supported''')
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
		aCompoundType.shortName = fCompoundType.name
		aCompoundType.category = category
		val fAllElements = FrancaModelExtensions.getAllElements(fCompoundType).map[it as FField]
		val aAllElements = fAllElements.map [
			val newElement = it.createImplementationDataTypeElement(fCompoundType)
			val FCompoundType originalCompoundType = it.eContainer as FCompoundType
			if (originalCompoundType !== fCompoundType) {
				newElement.addAnnotation(annotationLabelText, originalCompoundType.getARFullyQualifiedName)
			}
			newElement
		]
		aCompoundType.subElements.addAll(aAllElements)
		aCompoundType.ARPackage = fCompoundType.createAccordingArPackage
	}

	static def String getARFullyQualifiedName(FCompoundType fCompoundType) {
		val FModel model = fCompoundType.getModel
		val FTypeCollection typeCollection = fCompoundType.getTypeCollection;
		(if(!model?.name.nullOrEmpty) "/" + model.name.replace('.', '/') else "") +
			(if(!typeCollection?.name.nullOrEmpty) "/" + typeCollection?.name else "") + "/" + fCompoundType?.name
	}

	def dispatch void checkCompoundType(FCompoundType type) {
		logger.logWarning("Unknown compond type found " + type +
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
		shortName = fEnumerationType.name
		it.category = "TYPE_REFERENCE"
		it.swDataDefProps = fac.createSwDataDefProps => [
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
				compuMethod = enumCompuMethod
			// TODO: check whether we need a type for the compu-method itself
			// implementationDataType = getBaseTypeForReference(FBasicTypeId.UINT32)
			]
		]
		it.ARPackage = fEnumerationType.createAccordingArPackage
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FMapType fMapType) {
		it.shortName = fMapType.name
		it.category = "ASSOCIATIVE_MAP"
		it.subElements += createTypeRefImplementationDataTypeElement("keyType", fMapType.keyType)
		it.subElements += createTypeRefImplementationDataTypeElement("valueType", fMapType.valueType)
		it.ARPackage = fMapType.createAccordingArPackage
	}
	
	
	def private createTypeRefImplementationDataTypeElement(String elementShortName, FTypeRef referencedType){
		fac.createImplementationDataTypeElement => [
			shortName = elementShortName
			category = "TYPE_REFERENCE"
			it.swDataDefProps = fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					implementationDataType = referencedType.createDataTypeReference as ImplementationDataType
				]
			]
		]
	}
	

	def create fac.createCompuMethod createCompuMethod(FEnumerationType fEnumerationType) {
		shortName = fEnumerationType.name + "_CompuMethod"
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
								logError('''Did not found a constant values for "«enumerator.value.class.simpleName»" in enumerator "«enumerator.name»" of enumeration "«fEnumerationType.name»''')
						}
						val arLimit = fac.createLimitValueVariationPoint => [
							it.intervalType = IntervalTypeEnum.CLOSED
							it.mixedText = limitText
						]
						compuScale.lowerLimit = EcoreUtil.copy(arLimit)
						compuScale.upperLimit = arLimit
					} else {
						logger.
							logError('''Only constant values are supported for enums, but found "«enumerator.value.class.simpleName»" in enumerator "«enumerator.name»" of enumeration "«fEnumerationType.name»''')
					}
				}
			]
		]
		it.compuInternalToPhys = fac.createCompu => [
			it.compuContent = fac.createCompuScales => [
				it.compuScales.addAll(compuScalesForEnum)
			]
		]
		it.ARPackage = fEnumerationType.createAccordingArPackage
	}

	def private dispatch AutosarDataType createDataTypeForReference(FIntegerInterval type) {
		getLogger.logError("The Franca model element \"" + type.name +
			"\" of metatype 'FIntegerInterval' cannot be converted into an AUTOSAR representation! (IDL2590)")
		return null
	}

	def create fac.createImplementationDataTypeElement createImplementationDataTypeElement(
		FTypedElement fTypedElement,
		FCompoundType fParentCompoundType) {
		it.shortName = fTypedElement.name
		it.category = "TYPE_REFERENCE"
		val dataDefProps = fac.createSwDataDefProps
		val dataDefPropsConditional = fac.createSwDataDefPropsConditional
		val typeRef = createDataTypeReference(fTypedElement.type, fTypedElement)
		if (typeRef instanceof ImplementationDataType) {
			dataDefPropsConditional.implementationDataType = typeRef
		} else {
			getLogger.logWarning("Cannot set implementation data type for element '" + it.shortName + "'.")
		}
		dataDefProps.swDataDefPropsVariants += dataDefPropsConditional
		it.swDataDefProps = dataDefProps
	}

	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FArrayType fArrayType) {
		it.shortName = fArrayType.name
		it.category = "VECTOR"
		it.subElements += fac.createImplementationDataTypeElement => [
			shortName = "valueType"
			it.arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
			it.category = "TYPE_REFERENCE"
			swDataDefProps = fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					implementationDataType = fArrayType.elementType.createDataTypeReference as ImplementationDataType
				]
			]
		]
		it.ARPackage = fArrayType.createAccordingArPackage
	// TODO: ImplementationDataTypeExtension seems to no more exist in 18.10, what can we do about it?
//		it.createImplementationDataTypeExtension
	}

	def create fac.createImplementationDataType createArtificialVectorType(FType fType) {
		shortName = fType.name + "Vector"
		category = "VECTOR"
		subElements += fac.createImplementationDataTypeElement => [
			shortName = "valueType"
			it.arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
			it.category = "TYPE_REFERENCE"
			swDataDefProps = fac.createSwDataDefProps => [
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
					implementationDataType = fType.dataTypeForReference as ImplementationDataType
				]
			]
		]
		ARPackage = fType.createAccordingArPackage
	}

	def private ImplementationDataType createAnonymousArrayTypeReference(FTypeRef fTypeRef) {
		if (fTypeRef.refsPrimitiveType) {
			getBaseTypeVectorForReference(fTypeRef.predefined)
		} else {
			createArtificialVectorType(fTypeRef.derived)
		}
	}

	def private getNameOfReferencedType(FTypeRef fTypeRef) {
		if (fTypeRef.refsPrimitiveType) {
			fTypeRef.predefined.getName
		} else {
			fTypeRef.derived.name
		}
	}

}
