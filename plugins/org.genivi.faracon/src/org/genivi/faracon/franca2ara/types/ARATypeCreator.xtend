package org.genivi.faracon.franca2ara.types

import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import javax.inject.Inject
import javax.inject.Singleton
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.genivi.faracon.Franca2ARABase
import org.franca.core.franca.FType
import org.genivi.faracon.franca2ara.config.Franca2ARAConfigProvider

import static extension org.genivi.faracon.franca2ara.types.ARATypeHelper.*

@Singleton
class ARATypeCreator extends Franca2ARABase implements IARATypeCreator {

	@Inject
	var extension ApplDataTypeManager
	@Inject
	var extension ARAImplDataTypeCreator
	@Inject
	var extension Franca2ARAConfigProvider


	def AutosarDataType createDataTypeReference(FTypeRef fTypeRef, FTypedElement fTypedElement) {
		if (fTypedElement===null) {
			throw new RuntimeException("Missing fTypedElement")
		}
		val tc = new TypeContext(fTypedElement)
		if (!fTypedElement.isArray) {
			fTypeRef.createDataTypeReference(tc)
		} else {
			fTypeRef.createAnonymousArrayTypeReference(tc)
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
	 
	def AutosarDataType createDataTypeReference(FTypeRef fTypeRef, TypeContext tc) {
		val idt = createImplDataTypeReference(fTypeRef, tc)
		if (idt===null)
			return null
	
		if (generateADTs) {
			if (fTypeRef.refsPrimitiveType) {
				idt.getBaseApplDataType(fTypeRef, tc, null)
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
	def private createAnonymousArrayTypeReference(FTypeRef fTypeRef, TypeContext tc) {
		// TODO: ApplDataType handling
		createImplAnonymousArrayTypeReference(fTypeRef, tc)
	}

}
