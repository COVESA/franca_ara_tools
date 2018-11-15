package org.franca.connectors.ara.franca2ara

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import javax.inject.Inject
import javax.inject.Singleton
import org.apache.log4j.Logger
import org.franca.connectors.ara.Franca2ARABase
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FField
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef

import static extension org.franca.connectors.ara.franca2ara.ARATypeHelper.*

@Singleton
class ARATypeCreator extends Franca2ARABase {

	private static final Logger logger = Logger.getLogger(ARATypeCreator.simpleName)

	@Inject
	var extension ARAPrimitveTypesCreator
	@Inject
	var extension ARAPackageCreator
	
	def AutosarDataType createDataTypeReference(FTypeRef fTypeRef) {
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
	
	def private create fac.createImplementationDataTypeElement createImplementationDataTypeElement(FField fField) {
		it.shortName = fField.name
		if (fField.isArray) {
			logger.
				warn('''Can not create Autosar array for the Franca field "«fField.name»", because arrays are not yet supported,''')
		}
		it.category = "TYPE_REFERENCE"
		val dataDefProps = fac.createSwDataDefProps
		val dataDefPropsConditional = fac.createSwDataDefPropsConditional 
		val typeRef = createDataTypeReference(fField.type)
		if(typeRef instanceof ImplementationDataType){
			dataDefPropsConditional.implementationDataType = typeRef	
		}else{
			logger.warn("Cannot set implementation data type for element '" + it.shortName + "'.")
		}
		dataDefProps.swDataDefPropsVariants += dataDefPropsConditional
		it.swDataDefProps = dataDefProps
	}

}
