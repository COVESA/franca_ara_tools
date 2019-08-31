package org.genivi.faracon.tests.aspects_for_franca_ftyperef.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the translation of instances of the Autosar Type refs to
 * the  metaclass 'FTypeRef' that point to user-defined complex types.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1810_Tests extends ARA2FrancaTestBase {

	@Test
	def void userDefinedTypeMethodArguments() {
		transformAndCheck(testPath + "userDefinedTypeMethodArguments.arxml",
			testPath + "userDefinedTypeMethodArguments.fidl");
	}

	@Test
	def void userDefinedTypeStructFields() {
		transformAndCheck(testPath + "userDefinedTypeStructFields.arxml",
			testPath + "userDefinedTypeStructFields.fidl");
	}

}
