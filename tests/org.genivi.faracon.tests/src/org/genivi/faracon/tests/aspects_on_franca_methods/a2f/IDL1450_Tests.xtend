package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test Autosar operation argument to Franca broadcast
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1450_Tests extends ARA2FrancaTestBase {

	@Test
	def void testOperationArgumentToBroadcast() {
		transformAndCheck(testPath + "broadcastArgument.arxml", testPath + "broadcastArgumentExpected.fidl")
	}
}
