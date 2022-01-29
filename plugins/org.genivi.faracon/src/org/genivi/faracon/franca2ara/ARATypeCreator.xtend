package org.genivi.faracon.franca2ara

import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import javax.inject.Inject
import javax.inject.Singleton
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.genivi.faracon.Franca2ARABase

import static extension org.genivi.faracon.franca2ara.ARATypeHelper.*
import static extension org.genivi.faracon.util.FrancaUtil.*
import org.franca.core.franca.FType

@Singleton
class ARATypeCreator extends Franca2ARABase implements IARATypeCreator {

	@Inject
	var extension ApplDataTypeManager
	@Inject
	var extension ARAImplDataTypeCreator
	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension DeploymentDataHelper
	@Inject
	var extension AutosarAnnotator
	@Inject
	var extension Franca2ARAConfigProvider


	def AutosarDataType createDataTypeReference(FTypeRef fTypeRef, FTypedElement fTypedElement) {
		if (fTypedElement === null || !fTypedElement.isArray) {
			fTypeRef.createDataTypeReference(fTypedElement.name, fTypedElement.francaNamespaceName)
		} else {
			fTypeRef.createAnonymousArrayTypeReference(fTypedElement, fTypedElement.francaNamespaceName)
		}
	}

	def AutosarDataType getDataType(FType type) {
		val idt = getImplDataType(type)
		if (idt===null)
			return null
			
		if (generateADTs) {
			val adt = getApplDataType(type, idt, null)
			if (adt===null) {
				logger.logWarning("Couldn't create ApplicationDataType for " + type + ". " +
					"Using ImplementationDataType instead.")
				idt
			} else {
				adt
			}
		} else {
			idt
		}
	}
	 
	def private AutosarDataType createDataTypeReference(FTypeRef fTypeRef, String typedElementName, String namespaceName) {
		val idt = createImplDataTypeReference(fTypeRef, typedElementName, namespaceName)
		if (idt===null)
			return null
	
		if (generateADTs) {
			if (fTypeRef.refsPrimitiveType) {
				idt.getBaseApplDataType(null)
			} else {
				val adt = getApplDataType(fTypeRef.derived, idt, null)
				if (adt===null) {
					logger.logWarning("Couldn't create ApplicationDataType for " + fTypeRef.derived + ". " +
						"Using ImplementationDataType instead.")
					idt
				} else {
					adt
				}
			}
		} else {
			idt
		}
	}
	
	// Create an artificial array or vector type if necessary.
	def private createAnonymousArrayTypeReference(FTypeRef fTypeRef, FTypedElement fTypedElement, String namespaceName) {
		// TODO: ApplDataType handling
		createImplAnonymousArrayTypeReference(fTypeRef, fTypedElement, namespaceName)
	}

}
