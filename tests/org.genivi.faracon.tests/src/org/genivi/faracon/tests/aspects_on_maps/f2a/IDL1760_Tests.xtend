package org.genivi.faracon.tests.aspects_on_maps.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Tests Franca maps to autosar maps.
 * Also covers IDL 1770 and 1780 for Franca to Autosar.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1760_Tests extends Franca2ARATestBase {

	@Test
	def void testMapTypeTransformation() {
		transformAndCheck(testPath, "mapTypeTest", testPath + "mapTypeTest.arxml")
	}

	@Test
	def void testMapTypeUsageTransformation() {
		transformAndCheck(testPath, "mapTypeUsage", testPath + "mapTypeUsage.arxml")
	}

}
