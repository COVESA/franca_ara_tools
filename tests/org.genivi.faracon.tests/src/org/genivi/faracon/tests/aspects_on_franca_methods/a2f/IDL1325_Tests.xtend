package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.logging.AbstractLogger
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test Autosar INOUT Parameter to Franca transformation
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1325_Tests extends Franca2AraParameterTest {

	@Test(expected=AbstractLogger.StopOnErrorException)
	def void unitTestInOutParameter() {
		unitTestParameterDirection(ArgumentDirectionEnum.INOUT, false)
	}
	
	@Test(expected=AbstractLogger.StopOnErrorException)
	def void testInOutParameter(){
		transformAndCheck(testPath + "inOutArgument.arxml", testPath + "inOutExpected.fidl" )
	}
	
	@Test()
	def void testInOutParameterContinue(){
		logger.enableContinueOnErrors(true)
		transformAndCheck(testPath + "inOutArgument.arxml", testPath + "inOutExpected.fidl" )
	}	
}
