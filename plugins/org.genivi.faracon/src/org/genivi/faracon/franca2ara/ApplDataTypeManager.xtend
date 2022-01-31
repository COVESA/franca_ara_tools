package org.genivi.faracon.franca2ara

import org.genivi.faracon.Franca2ARABase
import javax.inject.Singleton
import javax.inject.Inject
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.swcomponent.datatype.datatypes.ApplicationDataType
import java.util.Map
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.swcomponent.datatype.datatypes.DataTypeMappingSet
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.FrancaModelExtensions
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FField

import static extension org.genivi.faracon.franca2ara.ARATypeHelper.*
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface

@Singleton
class ApplDataTypeManager extends Franca2ARABase {

	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension Franca2ARAConfigProvider
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
			getLogger.logWarning('''Cannot create ApplicationDatatype because the Franca type "«fTypedElement.type»" is not yet supported''')
		}
//		val dataDefProps = fac.createSwDataDefProps
//		val dataDefPropsConditional = fac.createSwDataDefPropsConditional
//		dataDefProps.swDataDefPropsVariants += dataDefPropsConditional
//		it.swDataDefProps = dataDefProps
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
