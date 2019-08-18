package org.genivi.faracon.tests.aspects_on_fields.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test Franca attributes field to Autosar fields transformation 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1230_Tests extends Franca2ARATestBase {

	@Test
	def void testSingleFieldToAttribute() {
		transformAndCheck(correspondingAutosar2FrancaTestPath, "singleField", 
			correspondingAutosar2FrancaTestPath + "singleField.arxml")
	}

	@Test
	def void testMultipleFieldsToAttributes() {
		transformAndCheck(correspondingAutosar2FrancaTestPath, "multipleFields",
			correspondingAutosar2FrancaTestPath + "multipleFields.arxml")
	}

}
