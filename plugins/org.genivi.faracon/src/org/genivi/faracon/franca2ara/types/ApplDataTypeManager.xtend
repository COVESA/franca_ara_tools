package org.genivi.faracon.franca2ara.types

import java.util.Map
import javax.inject.Singleton
import javax.inject.Inject
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.swcomponent.datatype.datatypes.ApplicationDataType
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.swcomponent.datatype.datatypes.DataTypeMappingSet
import autosar40.commonstructure.implementationdatatypes.ArraySizeSemanticsEnum
import autosar40.swcomponent.datatype.datatypes.ApplicationPrimitiveDataType
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.franca2ara.ARAModelSkeletonCreator
import org.genivi.faracon.franca2ara.config.Franca2ARAConfigProvider
import org.genivi.faracon.franca2ara.AutosarAnnotator
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FField
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FMapType
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FUnionType
import org.franca.core.FrancaModelExtensions

import static extension org.genivi.faracon.franca2ara.types.ARATypeHelper.*
import static extension org.genivi.faracon.util.FrancaUtil.*
import static extension org.franca.core.framework.FrancaHelpers.*
import autosar40.swcomponent.datatype.datatypes.ApplicationRecordDataType

@Singleton
class ApplDataTypeManager extends Franca2ARABase {

	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension ARAPrimitiveTypesCreator
	@Inject
	var extension Franca2ARAConfigProvider
	@Inject
	var extension AutosarAnnotator
	@Inject
	var extension DeploymentDataHelper

	// TODO: circular dependency, replace this by using IARATypeCreator
	@Inject
	var extension ARATypeCreator
	
	static final String ANNOTATION_LABEL_ORIGINAL_STRUCT_TYPE = "OriginalStructType"
	static final String DEFAULT_DATATYPEMAPPINGSET_NAME = "DataTypeMappings"
	
	
	val Map<ImplementationDataType, ApplicationDataType> impl2appl = newHashMap
	var ARPackage dtPackage = null
	var DataTypeMappingSet tms = null
	
	def initialize() {
		impl2appl.clear
		dtPackage = null
		tms = null
	}
	
	def getBaseApplDataType(ImplementationDataType idt, FTypeRef fType, TypeContext tc, ARPackage where) {
		if (!impl2appl.containsKey(idt)) {
			impl2appl.put(idt, fac.createApplicationPrimitiveDataType => [
				val n = idt.shortName.stripIDTPrefix
				shortName = ADTPrefix + n
				initUUID("ADT_" + n)
				if (fType.isString && generateStringAsArray) {
					category = CAT_STRING
					initADTString(idt, tc)
				} else if (fType.isByteBuffer) {
					category = CAT_ARRAY
				} else {
					category = CAT_VALUE
				}
				createTypeMapping(idt, where)
			])
		}
		impl2appl.get(idt)
	}
	
	def private initADTString(ApplicationPrimitiveDataType it, ImplementationDataType idt, TypeContext tc) {
		val len = tc.typedElement.getStringLength
		swDataDefProps = fac.createSwDataDefProps => [
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
				swTextProps = fac.createSwTextProps => [
					if (len!==null && len>0) {
						// fixed sized string
						arraySizeSemantics = ArraySizeSemanticsEnum.FIXED_SIZE
						swMaxTextSize = fac.createIntegerValueVariationPoint => [
							mixedText = "" + len
						]						
					} else {
						// variable sized string
						arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
					}
					baseType = getStringBaseType
					swFillCharacter = 0
				]
			]
		]
		
	}
	
	def private stripIDTPrefix(String idt) {
		if (!IDTPrefix.empty && idt.startsWith(IDTPrefix)) {
			idt.substring(IDTPrefix.length)
		} else {
			idt
		}
	}

	def getApplDataType(FType type, ImplementationDataType idt) {
		val adt = type.createApplDataType
		adt.createTypeMapping(idt, null)
		adt
	}

	def genInterfaceToMapping(ServiceInterface aInterface) {
		val pkg = createPackageWithName("ServiceInterfaceToDataTypeMappings", aInterface.ARPackage)
		pkg.elements.add(fac.createPortInterfaceToDataTypeMapping => [
			shortName = aInterface.shortName + "_ToDataTypeMapping"
			initUUID(shortName)
			val dtms = getTypeMappingSet
			dataTypeMappingSets.add(dtms)
			if (dtms.shortName == DEFAULT_DATATYPEMAPPINGSET_NAME) {
				// use name of the first interface using the DTMS as a prefix
				// this will ensure that different arxml files use different DTMS shortNames
				dtms.shortName = aInterface.shortName + "_" + DEFAULT_DATATYPEMAPPINGSET_NAME
				initUUID(dtms, dtms.shortName)
			} 
			portInterface = aInterface
		])
	}
	
	def private dispatch ApplicationDataType createApplDataType(FType type) {
		getLogger.logWarning('''Cannot create ApplicationDatatype because the Franca type "«type.eClass.name»" is not yet supported''')
		return null
	}

	def private dispatch create fac.createApplicationRecordDataType createApplDataType(FStructType fStructType) {
		// ImplDataType generation will check if Franca struct is polymorphic and issue a warning
		val fAllElements = FrancaModelExtensions.getAllElements(fStructType).filter(FTypedElement)
		initApplDataTypeForCompound(fStructType.name, fAllElements, [it !== fStructType])
	}
	
	def private dispatch create fac.createApplicationRecordDataType createApplDataType(FUnionType fUnionType) {
		val fAllElements = FrancaModelExtensions.getAllElements(fUnionType).filter(FTypedElement)
		initApplDataTypeForCompound(fUnionType.name, fAllElements, [it !== fUnionType])
		category = CAT_UNION
	}

	def void initApplDataTypeForCompound(
		ApplicationRecordDataType it,
		String compoundName,
		Iterable<FTypedElement> fAllElements,
		(FCompoundType) => boolean isInherited
	) {
		shortName = ADTPrefix + compoundName
		initUUID("ADT_" + compoundName)
		category = CAT_STRUCTURE
		elements.addAll(fAllElements.map[elem |
			val newElem = elem.createApplicationDataTypeElement
			if (elem.eContainer instanceof FCompoundType && isInherited!==null) {
				val cont = elem.eContainer as FCompoundType
				if (isInherited.apply(cont)) {
					newElem.addAnnotation(ANNOTATION_LABEL_ORIGINAL_STRUCT_TYPE, cont.ARFullyQualifiedName)				
				}
			}
			newElem
		])
	}

	def private create fac.createApplicationRecordElement createApplicationDataTypeElement(FTypedElement fTypedElement) {
		shortName = fTypedElement.name
		it.initUUID("ADT_" + fTypedElement.name)
		category = "VALUE"
		val t = createDataTypeReference(fTypedElement.type, fTypedElement)
		if (t instanceof ApplicationDataType) {
			type = t
		} else {
			getLogger.logWarning('''Cannot create ApplicationDatatype for element because the Franca type "«fTypedElement.type»" is not yet supported''')
		}
//		val dataDefProps = fac.createSwDataDefProps
//		val dataDefPropsConditional = fac.createSwDataDefPropsConditional
//		dataDefProps.swDataDefPropsVariants += dataDefPropsConditional
//		it.swDataDefProps = dataDefProps
	}


	def private dispatch create fac.createApplicationPrimitiveDataType createApplDataType(FEnumerationType fEnumerationType) {
		// TODO: should we create an extra CompuMethod for this? Or is it sufficient to have the CompuMethod of ImplDataType? 
		//val enumCompuMethod = fEnumerationType.createCompuMethod
		shortName = ADTPrefix + fEnumerationType.name
		initUUID("ADT_" + fEnumerationType.name)
		it.category = "VALUE"  // "TYPE_REFERENCE"
//		it.swDataDefProps = fac.createSwDataDefProps => [
//			swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
//				compuMethod = enumCompuMethod
//			// TODO: check whether we need a type for the compu-method itself
//			// implementationDataType = getBaseTypeForReference(FBasicTypeId.UINT32)
//			]
//		]
	}

	def private dispatch create fac.createApplicationAssocMapDataType createApplDataType(FMapType fMapType) {
		shortName = ADTPrefix + fMapType.name
		initUUID("ADT_" + fMapType.name)
		val tc = new TypeContext(fMapType.name, fMapType.francaNamespaceName)
		val tKey = fMapType.keyType.createDataTypeReference(tc)
		if (tKey instanceof ApplicationDataType) {
			key = fac.createApplicationAssocMapElement => [
				shortName = "elementKey"
				category = CAT_VALUE
				type = tKey
			]
		} else {
			getLogger.logWarning('''Cannot create ApplicationDatatype for map key because the Franca type "«fMapType.keyType»" is not yet supported''')
		}		
		val tValue = fMapType.valueType.createDataTypeReference(tc)
		if (tValue instanceof ApplicationDataType) {
			value = fac.createApplicationAssocMapElement => [
				shortName = "elementValue"
				category = CAT_VALUE
				type = tValue
			]
		} else {
			getLogger.logWarning('''Cannot create ApplicationDatatype for map value because the Franca type "«fMapType.valueType»" is not yet supported''')
		}		
	}
	
	def private dispatch create fac.createApplicationArrayDataType createApplDataType(FArrayType fArrayType) {
		shortName = ADTPrefix + fArrayType.name
		initUUID("ADT_" + fArrayType.name)
		category = CAT_ARRAY  // always use category array for application datatypes
//		val boolean isFixedSizedArray = fArrayType.isFixedSizedArray
//		val int arraySize = fArrayType.getArraySize
		val tc = new TypeContext(fArrayType.name, fArrayType.francaNamespaceName)
		val t = fArrayType.elementType.createDataTypeReference(tc)
		if (t instanceof ApplicationDataType) {
			element = fac.createApplicationArrayElement => [
				shortName = "valueType"
				initUUID("ADT_ELEM_" + fArrayType.name)
				category = CAT_VALUE
				type = t
			]
		} else {
			getLogger.logWarning('''Cannot create ApplicationDatatype for array because the Franca type "«fArrayType.elementType»" is not yet supported''')
		}
	}
	
	def private dispatch create fac.createApplicationPrimitiveDataType createApplDataType(FTypeDef fTypeDef) {
		shortName = ADTPrefix + fTypeDef.name
		initUUID("ADT_" + fTypeDef.name)
		if (fTypeDef.actualType.refsPrimitiveType) {
			it.category = CAT_VALUE
		} else {
			it.category = "TYPE_REF"			
		}
//		it.subElements += fac.createImplementationDataTypeElement => [
//			shortName = "valueType"
//			it.category = "TYPE_REFERENCE"
//			swDataDefProps = fac.createSwDataDefProps => [
//				swDataDefPropsVariants += fac.createSwDataDefPropsConditional => [
//					implementationDataType = fTypeDef.actualType.createImplDataTypeReference(fTypeDef.name, fTypeDef.francaNamespaceName)
//				]
//			]
//		]
	}


	// Create an artificial array or vector type if necessary.
	def private createAnonymousArrayTypeReference(FTypeRef fTypeRef, FTypedElement fTypedElement, String namespaceName) {
		// TODO: ApplDataType handling
	}



	def private createTypeMapping(ApplicationDataType adt, ImplementationDataType idt, ARPackage adtPackage) {
		adt.ARPackage = adtPackage!==null ? adtPackage : getDataTypesPackage
		createApplTypeMapping(adt, idt) 		
	}
	
	def private create fac.createDataTypeMap createApplTypeMapping(ApplicationDataType adt, ImplementationDataType idt) {
		applicationDataType = adt
		implementationDataType = idt
		typeMappingSet.dataTypeMaps.add(it)
	}
	
	def private getDataTypesPackage() {
		if (dtPackage===null) {
			dtPackage = createPackageWithName("ApplicationDataTypes", createRootPackage("DataTypes"))
		}
		dtPackage
	}
	
	def private getTypeMappingSet() {
		if (tms===null) {
			tms = fac.createDataTypeMappingSet => [
				shortName = DEFAULT_DATATYPEMAPPINGSET_NAME
				ARPackage = createRootPackage("DataTypeMappingSets")
			]
		}
		tms
	}
}
