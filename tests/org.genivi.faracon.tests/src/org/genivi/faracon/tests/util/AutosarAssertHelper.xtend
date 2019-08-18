package org.genivi.faracon.tests.util

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable

import static org.junit.Assert.assertEquals

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
}