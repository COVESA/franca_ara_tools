
package org.genivi.faracon.tests.aspects_on_fields.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test Autosar field to Franca attribute transformation 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1230_Tests extends ARA2FrancaTestBase{
	
	@Test
	def void testSingleFieldToAttribute(){
		transformAndCheck(testPath + "singleField.arxml", testPath+ "singleField.fidl")
	}
	
	@Test
	def void testMultipleFieldsToAttributes(){
		transformAndCheck(testPath + "multipleFields.arxml", testPath+ "multipleFields.fidl")	
	}
	
}