package org.genivi.faracon

import autosar40.util.Autosar40Factory
import org.genivi.faracon.logging.BaseWithLogger
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FModelElement

class Franca2ARABase extends BaseWithLogger {
	
	static final String FRANCA_UUID_TAG = "uuid=\""
	 
	def protected fac() {
		Autosar40Factory.eINSTANCE
	}

	def protected initUUID(Identifiable id, FModelElement fElement) {
		if (fElement?.comment!==null) {
			for (anno : fElement.comment.elements) {
				val uuid = anno.getUUIDFromAnnotation()
				if (uuid!==null) {
 					id.uuid = uuid
 					return
				}
			}
		}
	}

	def protected String getUUIDFromAnnotation(FAnnotation anno) {
		if (anno.type==FAnnotationType.SEE) {
			val raw = anno.comment
			if (raw.startsWith(FRANCA_UUID_TAG) && raw.endsWith('"')) {
				return raw.substring(FRANCA_UUID_TAG.length, raw.length-1)
			}
		}
		null
	}
}

