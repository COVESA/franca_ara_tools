package org.genivi.faracon.tests.aspects_for_franca_ftyperef.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.logging.AbstractLogger
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the emulated Franca to AUTOSAR conversion of integer interval types.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1820_Tests extends Franca2ARATestBase {

	@Test
	def void integerIntervalTypeMethodArguments() {	
		transformAndCheck(
			testPath, "integerIntervalTypeMethodArguments",
			testPath + "integerIntervalTypeMethodArguments.arxml"
		);
	}

	@Test
	def void integerIntervalTypeStructFields() {
		transformAndCheck(
			testPath, "integerIntervalTypeStructFields",
			testPath + "integerIntervalTypeStructFields.arxml"
		);
	}

	@Test
	def void integerIntervalTypeTypedef() {	
		transformAndCheck(
			testPath, "integerIntervalTypeTypedef",
			testPath + "integerIntervalTypeTypedef.arxml"
		);
	}

}
