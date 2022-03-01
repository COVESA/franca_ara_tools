package org.genivi.faracon

import autosar40.util.Autosar40Factory
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import org.genivi.faracon.logging.BaseWithLogger
import org.genivi.faracon.util.NamedUUIDGenerator
import org.franca.core.franca.FAnnotationType
import org.franca.core.franca.FModelElement
import java.util.Map

class Franca2ARABase extends BaseWithLogger {

	protected static final String CAT_VALUE = "VALUE"
	protected static final String CAT_TYPEREF = "TYPE_REFERENCE"
	protected static final String CAT_ARRAY = "ARRAY"
	protected static final String CAT_VECTOR = "VECTOR"
	protected static final String CAT_STRUCTURE = "STRUCTURE"
	protected static final String CAT_UNION = "UNION"
	protected static final String CAT_STRING = "STRING"
	
	def protected fac() {
		Autosar40Factory.eINSTANCE
	}

	// TODO: get this from IFranca2AraConfig
	static final Boolean ensureStableUUIDs = true
	static final Boolean extractUUIDFromFranca = false
	
	static String seedPerFile = ""
	
	def setSeedForUUID(String seed) {
		seedPerFile = seed
	}
	
	def protected initUUID(Identifiable id, FModelElement fElement) {
		if (!ensureStableUUIDs) {
			return
		}
		
		if (extractUUIDFromFranca) {
			val uuid = fElement.UUIDForFModelElement
			if (null !== uuid) {
				id.uuid = uuid
			}
			// if we cannot find any UUID in the input data, just keep the freshly generated UUID			
		} else {
			initUUID(id, fElement.name)
		}
	}

	val Map<String, String> uuids = newHashMap
	
	def protected initUUID(Identifiable id, String detailSeed) {
		if (!ensureStableUUIDs) {
			return
		}
		
		// create name-based UUID from seed string
		val seed = seedPerFile + "__" + detailSeed
		val uuid = NamedUUIDGenerator.makeUUID(seed).toString
		if (uuids.containsKey(uuid)) {
			println("WARNING: Generated duplicate UUID '" + uuid + "' for '" + uuids.get(uuid) + "' and '" + id.shortName + "'!")
		} else {
			uuids.put(uuid, id.shortName)
		}
		id.uuid = "F2A:" + uuid.toString
	}


	static final String FRANCA_UUID_TAG = "uuid=\""
	
	/**
	 * <p>Extract UUID from Franca structured comment.</p>
	 * 
	 * <p>Examples:
	 * <ul>
	 * 		<li><** @see: uuid="a519383c-da8a-4d92-9fa7-b2a74119b854" **></li>
	 * 		<li><** @see: uuid="FRA:a519383c-da8a-4d92-9fa7-b2a74119b854" **></li>
	 * </ul>
	 * </p>
	 */
	def protected String getUUIDForFModelElement(FModelElement fElement) {
		// first of all, the model element must have a structured comment
		if (fElement?.comment!==null) {
			for (anno : fElement.comment.elements) {
				// we are looking for the first annotation with a "SEE" tag
				if (anno.type==FAnnotationType.SEE) {
					val raw = anno.comment
					// the raw data should start with a predefined tag
					if (raw.startsWith(FRANCA_UUID_TAG) && raw.endsWith('"')) {
						return raw.substring(FRANCA_UUID_TAG.length, raw.length-1)
					}
				}
			}
		}
		null	
	}

}

