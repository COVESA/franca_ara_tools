package org.genivi.faracon.tests.util

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable

import static org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static org.junit.Assert.assertEquals
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.emf.ecore.impl.EStringToStringMapEntryImpl
import static org.junit.Assert.assertTrue
import java.io.File
import java.io.FileReader
import java.nio.file.Files
import java.nio.file.Paths
import static org.junit.Assert.fail

class AutosarAssertHelper {
	new(){}
	
	def static <T extends Referrable> T assertName(T arReferrable, String expectedName){
		assertEquals("Wrong autosar name created", expectedName, arReferrable.shortName)
		return arReferrable
	} 
	
	def static <T extends Identifiable> T assertCategory(T identifiable, String expectedCategory){
		assertEquals("Wrong category created", expectedCategory, identifiable.category)
		return identifiable 
	}
	
	/**
	 * For Autosar models, we compare the actual output files
	 */
	def static void assertAutosarFilesAreEqual(String actualFileName, String expectedFileName){
		val actualContent = new String(Files.readAllBytes(Paths.get(actualFileName)));
		val expectedContent = new String(Files.readAllBytes(Paths.get(expectedFileName)));
		if(!actualContent.equals(expectedContent)){
			fail('''Actual file: "«actualFileName»" does not equal expected file "«expectedFileName»"''')
		}
	}
	
	def static void setUuidsTo0(AUTOSAR model){
		model.eAllContents.filter(Identifiable).forEach[
			uuid = "0"
		]		
	} 
	
}
