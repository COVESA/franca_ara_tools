package org.genivi.faracon.tests.aspects_for_franca_ftyperef.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the translation of different Autosar basic types
 * to Franca metaclass 'FTypeRef' that refer to predefined basic franca types
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1800_Tests extends ARA2FrancaTestBase {

	@Test
	def void predefinedBasicTypeMethodArguments() {
		transformAndCheck(testPath + "predefinedBasicTypeMethodArguments.arxml",
			correspondingFranca2AutosarTestPath + "predefinedBasicTypeMethodArguments.fidl");
	}

	@Test
	def void predefinedBasicTypeStructFields() {
		transformAndCheck(testPath + "predefinedBasicTypeStructFields.arxml",
			testPath + "predefinedBasicTypeStructFields.fidl");
	}

}
