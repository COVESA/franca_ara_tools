package org.genivi.faracon.tests.aspects_on_broadcasts.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Tests Events to Broadcasts
 * Also covers IDL 1370 and IDL1380 for Autosar to Franca.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1250_Tests extends ARA2FrancaTestBase {

	@Test
	def void testSingleEventToBroacasts() {
		transformAndCheck(testPath + "singleEvent.arxml", testPath + "singleEvent.fidl")
	}
	
	@Test
	def void testMultipleEventToBroadcast(){
		transformAndCheck(testPath + "multipleEvent.arxml", testPath + "multipleEvent.fidl")
	}

}
