package org.franca.connectors.ara.franca2ara

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.IntervalTypeEnum
import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import java.util.Map
import javax.inject.Inject
import javax.inject.Singleton
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.connectors.ara.Franca2ARABase
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FField
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement

import static extension org.franca.connectors.ara.franca2ara.ARATypeHelper.*

@Singleton
class ARATypeCreator extends Franca2ARABase {

	private static final Logger logger = Logger.getLogger(ARATypeCreator.simpleName)

	@Inject
	var extension ARAPrimitveTypesCreator
	@Inject
	var extension ARAPackageCreator
	
	def AutosarDataType createDataTypeReference(FTypeRef fTypeRef, FTypedElement fTypedElement) {
		if(fTypedElement===null || !fTypedElement.isArray){
			return fTypeRef.createDataTypeReference
		}else{
			val arrayType = fTypeRef.createArrayTypeForTypedElement(fTypedElement)
			return arrayType
		}
	}
	
	def private AutosarDataType createDataTypeReference(FTypeRef fTypeRef) {
		if (fTypeRef.refsPrimitiveType) {
			getBaseTypeForReference(fTypeRef.predefined)
		} else {
			return getDataTypeForReference(fTypeRef.derived)
		}
	}

	def private AutosarDataType getDataTypeForReference(FType type) {
		return type.createDataTypeForReference
	}

	def private dispatch AutosarDataType createDataTypeForReference(FType type) {
		logger.
			warn('''Cannot create AutosarDatatype because the Franca type "«type.eClass.name»" is not yet supported''')
		return null
	}
	def private dispatch create fac.createImplementationDataType createDataTypeForReference(
		// use FCompoundType in order to deal with union and struct types (unions are treated like structs)
		FCompoundType fStructType) {
		it.shortName = fStructType.name
		it.category = "STRUCTURE"
		val typeRefs = fStructType.elements.map[it.createImplementationDataTypeElement]
		it.subElements.addAll(typeRefs)
		it.ARPackage = fStructType.findArPackageForFrancaElement
	}
	
	def private dispatch create fac.createImplementationDataType createDataTypeForReference(FEnumerationType fEnumerationTyppe){
		val enumCompuMethod = fEnumerationTyppe.createCompuMethod
		val arPackage = findArPackageForFrancaElement(fEnumerationTyppe)
		enumCompuMethod.ARPackage = arPackage
		it.ARPackage = arPackage
		shortName = fEnumerationTyppe.name
		it.category = "TYPE_REFERENCE"
		it.swDataDefProps = fac.createSwDataDefProps =>[
			swDataDefPropsVariants += fac.createSwDataDefPropsConditional =>[
				compuMethod = enumCompuMethod
				implementationDataType = getBaseTypeForReference(FBasicTypeId.UINT32)
			]
		]
	}
	
	def create fac.createCompuMethod createCompuMethod(FEnumerationType fEnumerationTyppe){
		shortName = fEnumerationTyppe.name + "_CompuMethod"
		it.category = "TEXTABLE"
		val compuScalesForEnum = fEnumerationTyppe.enumerators.map[enumerator|
			fac.createCompuScale =>[ compuScale|
				compuScale.symbol = enumerator.name
				val limitText = String.format("0x%02X", fEnumerationTyppe.enumerators.indexOf(enumerator)+1)
				val arLimit = fac.createLimitValueVariationPoint =>[
					it.intervalType = IntervalTypeEnum.CLOSED 
					it.mixedText = limitText
				]
				compuScale.lowerLimit = EcoreUtil.copy(arLimit)
				compuScale.upperLimit = arLimit
		]]
		it.compuInternalToPhys = fac.createCompu =>[
			it.compuContent = fac.createCompuScales =>[
				it.compuScales.addAll(compuScalesForEnum)
			]
		]
	}
	
	def private create fac.createImplementationDataTypeElement createImplementationDataTypeElement(FField fField) {
		it.shortName = fField.name
		it.category = "TYPE_REFERENCE"
		val dataDefProps = fac.createSwDataDefProps
		val dataDefPropsConditional = fac.createSwDataDefPropsConditional 
		val typeRef = createDataTypeReference(fField.type, fField)
		if(typeRef instanceof ImplementationDataType){
			dataDefPropsConditional.implementationDataType = typeRef	
		}else{
			logger.warn("Cannot set implementation data type for element '" + it.shortName + "'.")
		}
		dataDefProps.swDataDefPropsVariants += dataDefPropsConditional
		it.swDataDefProps = dataDefProps
	}
	
	val Map<String,ImplementationDataType> arrayTypeNameToImplementationDataType = newHashMap()
	
	def private ImplementationDataType createArrayTypeForTypedElement(FTypeRef fTypeRef, FTypedElement fTypedElement){
		val nameOfArrayType = fTypeRef.nameOfReferencedType + "Vector" 
		if(arrayTypeNameToImplementationDataType.containsKey(nameOfArrayType)){
			return arrayTypeNameToImplementationDataType.get(nameOfArrayType)
		}
		val vectorImplementationDataType = fac.createImplementationDataType
		arrayTypeNameToImplementationDataType.put(nameOfArrayType, vectorImplementationDataType)
		vectorImplementationDataType.shortName =  nameOfArrayType
		vectorImplementationDataType.category = "VECTOR"
		vectorImplementationDataType.ARPackage = findArPackageForFrancaElement(fTypedElement)
		vectorImplementationDataType.subElements += fac.createImplementationDataTypeElement =>[
			shortName = "valueType"
			it.category = "TYPE_REFERENCE"
			swDataDefProps = fac.createSwDataDefProps =>[
				swDataDefPropsVariants += fac.createSwDataDefPropsConditional =>[
					implementationDataType = fTypeRef.createDataTypeReference as ImplementationDataType
				]
			]
		]
		return vectorImplementationDataType
	}
	
	def private getNameOfReferencedType(FTypeRef fTypeRef){
		if(fTypeRef.refsPrimitiveType){
			return fTypeRef.predefined.getName
		}else{
			return fTypeRef.derived.name  
		}
	}

}
