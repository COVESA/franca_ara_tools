package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1290_Tests extends ARA2FrancaTestBase {
	
	@Test 
	def void testOperationToMethod() {
		// given
		val operation1Name = "arClientServerOperation1"
		val operation2Name = "arClientServerOperation2"
		val arModel = createAUTOSAR =>[
			arPackages += createARPackage =>[
				it.shortName = "arPackage"
				elements += createServiceInterface =>[
					it.shortName = "ArServiceInterface"
					methods += createClientServerOperation => [shortName = operation1Name]
					methods += createClientServerOperation => [shortName = operation2Name]
				]
			]
		]
		
		//when
		val fModels = this.transformToFranca(arModel)
		
		//then
		val fInterface = fModels.assertOneElement.interfaces.assertOneElement
		val methods = fInterface.methods.assertElements(2).sortBy[name]
		assertEquals("Name of first method is wrong", operation1Name, methods.get(0).name)
		assertEquals("Name of second method is wrong", operation2Name, methods.get(1).name)
	}
}
