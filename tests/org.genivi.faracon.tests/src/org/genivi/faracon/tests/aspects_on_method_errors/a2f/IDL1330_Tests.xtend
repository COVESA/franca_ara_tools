package org.genivi.faracon.tests.aspects_on_method_errors.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.logging.AbstractLogger
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test Autosar method errors.
 */
@RunWith(XtextRunner2_Franca) 
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1330_Tests extends ARA2FrancaTestBase{
	
	@Test(expected = AbstractLogger.StopOnErrorException)
	def void testUnitAutosarMethodApErrors(){
		//given 
		val clientServerOperation = createClientServerOperation =>[
			it.shortName = "TestClientServerOperation"
			it.possibleApErrors += createApApplicationError =>[it.shortName = "SimpleError"]
		]
		
		//when 
		clientServerOperation.transform
		
		//then: expect the exception
	}
	
	@Test(expected = AbstractLogger.StopOnErrorException)
	def void testUnitAutosarMethodErrorsSet(){
		//given 
		val clientServerOperation = createClientServerOperation =>[
			it.shortName = "TestClientServerOperation"
			it.possibleApErrorSets += createApApplicationErrorSet =>[it.shortName = "SimpleError"]
		]
		
		//when 
		clientServerOperation.transform
		
		//then: expect the exception
	}
	
}
