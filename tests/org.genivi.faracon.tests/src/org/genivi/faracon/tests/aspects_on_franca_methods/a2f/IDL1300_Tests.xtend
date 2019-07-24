package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import javax.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.ARA2FrancaTransformation
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1300_Tests extends ARA2FrancaTestBase {

	@Inject
	var extension ARA2FrancaTransformation

	@Test
	def void testOperationWithFireAndForgetFlag() {
		this.transformAndCheck(testPath + "fireAndForgetMethod.arxml",
			"src/org/genivi/faracon/tests/aspects_on_franca_methods/f2a/fireAndForgetMethod.fidl")
	}
	
	@Test
	def void unitTestOperationWithFireAndForget(){
		unitTestFireAndForget(true)
	}
	
		@Test
	def void unitTestOperationWithoutFireAndForget(){
		unitTestFireAndForget(false)
	}
	
	@Test
	def void unitTestOperationWithNullFireAndForget(){
		unitTestFireAndForget(null)
	} 
	
	private def void unitTestFireAndForget(Boolean isFireAndForget) {
		// given
		val clientServerOp = createClientServerOperation => [
			shortName = "ClientServerOp"
			fireAndForget = isFireAndForget
		]
		
		//when
		val fMethod = transform(clientServerOp)
		
		//then
		// in case of fire and forget is null, we expect false
		val expectedValue = if(isFireAndForget === null) false else isFireAndForget
		assertEquals("Fire and forget has not been set correctly", expectedValue, fMethod.fireAndForget)
	}
}
