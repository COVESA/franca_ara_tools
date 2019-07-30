package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test Autosar out-Parameter to Franca out parameter
 */
@RunWith(XtextRunner2_Franca) 
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1320_Tests extends Franca2AraParameterTest {
	
	@Test
	def void unitTestOutParameter(){
		unitTestParameterDirection(ArgumentDirectionEnum.OUT, false)
	}
	
	@Test
	def void testOneOutParameter(){
		logger.enableContinueOnErrors(true)
		transformAndCheck(testPath + "oneMethodReturnValue.arxml", "src/org/genivi/faracon/tests/aspects_on_franca_methods/f2a/oneMethodReturnValue.fidl" )
	}
	
	@Test
	def void testMultipleOutParameter(){
		logger.enableContinueOnErrors(true)
		transformAndCheck(testPath + "multipleMethodReturnValues.arxml", testPath + "multipleMethodReturnValuesExpected.fidl" )
	}
}
