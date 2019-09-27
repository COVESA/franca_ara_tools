package org.genivi.faracon.tests.aspects_on_versions

import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertTrue

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

/**
 * Test cases for versions on Franca interfaces
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1490_Tests extends Franca2ARATestBase {

	@Test
	def void testUnitVersionsOnFInterface() {
		// given
		val fInterface = createFInterface => [
			version = createFVersion => [major = 2 minor = 5]
			it.name = "TestInterface"
		]
		val fModel = createFModel => [
			it.name = "TestModel"
			it.interfaces += fInterface
		]

		// when
		val autosar = fModel.transform

		// then
		val arPackage = autosar.arPackages.assertOneElement.assertName("TestModel")
		assertTrue("No elements in parent package expected, but found " + arPackage.elements,
			arPackage.elements.isEmpty)
		val elementPackage = arPackage.arPackages.assertOneElement
		elementPackage.assertName("v_2_5")
		val serviceInterface = elementPackage.elements.assertOneElement.assertIsInstanceOf(ServiceInterface)
		serviceInterface.assertName("TestInterface")
	}

	@Test
	def void testFInterfaceWithVersion() {
		transformAndCheck(testPath, "interfaceWithVersion", testPath + "interfaceWithVersion.arxml")
	}

}
