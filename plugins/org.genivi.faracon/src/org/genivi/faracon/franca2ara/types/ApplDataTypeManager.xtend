package org.genivi.faracon.franca2ara.types

import java.util.Map
import javax.inject.Singleton
import javax.inject.Inject
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.swcomponent.datatype.datatypes.ApplicationDataType
import autosar40.adaptiveplatform.applicationdesign.applicationdatatype.ApplicationAssocMapDataType
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.swcomponent.datatype.datatypes.DataTypeMappingSet
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.franca2ara.ARAModelSkeletonCreator
import org.genivi.faracon.franca2ara.Franca2ARAConfigProvider
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
import org.franca.core.FrancaModelExtensions

import static extension org.genivi.faracon.franca2ara.types.ARATypeHelper.*
import static extension org.genivi.faracon.util.FrancaUtil.*

@Singleton
class ApplDataTypeManager extends Franca2ARABase {

	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension Franca2ARAConfigProvider
	@Inject
	var extension DeploymentDataHelper
	@Inject
	var extension AutosarAnnotator

	// TODO: circular dependency, replace this by using IARATypeCreator
	@Inject
	var extension ARATypeCreator
	
	static final String ANNOTATION_LABEL_ORIGINAL_STRUCT_TYPE = "OriginalStructType"
	
	
	val Map<ImplementationDataType, ApplicationDataType> impl2appl = newHashMap
	var ARPackage dtPackage = null
	var DataTypeMappingSet tms = null
	
	
	def getBaseApplDataType(ImplementationDataType idt, ARPackage where) {
		if (!impl2appl.containsKey(idt)) {
			val adt = fac.createApplicationPrimitiveDataType
			adt.shortName = ADTPrefix + idt.shortName
			adt.category = "VALUE"
			impl2appl.put(idt, adt)
			adt.createTypeMapping(idt, where)
		}
		impl2appl.get(idt)
	}

	def getApplDataType(FType type, ImplementationDataType idt, ARPackage where) {
		val adt = type.createApplDataType
		adt.createTypeMapping(idt, null)
		adt
	}

	def genInterfaceToMapping(ServiceInterface aInterface) {
		val pkg = createPackageWithName("ServiceInterfaceToDataTypeMappings", aInterface.ARPackage)
		pkg.elements.add(fac.createPortInterfaceToDataTypeMapping => [
			shortName = aInterface.shortName + "_ToDataTypeMapping"
			dataTypeMappingSets.add(getTypeMappingSet)
			portInterface = aInterface
		])
	}
	
	def private dispatch ApplicationDataType createApplDataType(FType type) {
		getLogger.logWarning('''Cannot create ApplicationDatatype because the Franca type "«type.eClass.name»" is not yet supported''')
		return null
	}

	def private dispatch create fac.createApplicationRecordDataType createApplDataType(FStructType fStructType) {
		// ImplDataType generation will check if Franca struct is polymorphic and issue a warning
		shortName = ADTPrefix + fStructType.name
		category = "STRUCTURE"
		val fAllElements = FrancaModelExtensions.getAllElements(fStructType).filter(FField)
		val aAllElements = fAllElements.map[
			val newElement = it.createApplicationDataTypeElement(fStructType)
			val FCompoundType originalCompoundType = it.eContainer as FCompoundType
			if (originalCompoundType !== fStructType) {
				newElement.addAnnotation(ANNOTATION_LABEL_ORIGINAL_STRUCT_TYPE, originalCompoundType.ARFullyQualifiedName)
			}
			newElement
		]
		elements.addAll(aAllElements)
	}

	def private create fac.createApplicationRecordElement createApplicationDataTypeElement(FTypedElement fTypedElement,
		FCompoundType fParentCompoundType) {
		shortName = fTypedElement.name
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
		category = CAT_ARRAY  // always use category array for application datatypes
//		val boolean isFixedSizedArray = fArrayType.isFixedSizedArray
//		val int arraySize = fArrayType.getArraySize
		val tc = new TypeContext(fArrayType.name, fArrayType.francaNamespaceName)
		val t = fArrayType.elementType.createDataTypeReference(tc)
		if (t instanceof ApplicationDataType) {
			element = fac.createApplicationArrayElement => [
				shortName = "valueType"
				category = CAT_VALUE
				type = t
			]
		} else {
			getLogger.logWarning('''Cannot create ApplicationDatatype for array because the Franca type "«fArrayType.elementType»" is not yet supported''')
		}
	}
	
	def private dispatch create fac.createApplicationPrimitiveDataType createApplDataType(FTypeDef fTypeDef) {
		shortName = ADTPrefix + fTypeDef.name
		if (fTypeDef.actualType.refsPrimitiveType) {
			it.category = "VALUE"
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
				shortName = "DataTypeMappings"
				ARPackage = createRootPackage("DataTypeMappingSets")
			]
		}
		tms
	}
}
