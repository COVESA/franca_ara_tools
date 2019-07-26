package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner2_Franca) 
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1310_Tests extends Franca2AraParameterTest {
	
	@Test 
	def void unitTestInParameters() {
		unitTestParameterDirection(ArgumentDirectionEnum.IN, true)
	}
	
	@Test
	def void testInParamerter(){
		ara2FrancaTransformation.logger.enableContinueOnErrors(true)
		this.transformAndCheck(testPath+"oneInputArgument.arxml", "src/org/genivi/faracon/tests/aspects_on_franca_methods/f2a/oneMethodInputArgument.fidl" )
	}
	
	@Test
	def void testMultipleInParameter(){
		ara2FrancaTransformation.logger.enableContinueOnErrors(true)
		this.transformAndCheck(testPath + "multipleMethodInputArguments.arxml", testPath + "multipleMethodInputArgumentsExpected.fidl")
	}
	
}
