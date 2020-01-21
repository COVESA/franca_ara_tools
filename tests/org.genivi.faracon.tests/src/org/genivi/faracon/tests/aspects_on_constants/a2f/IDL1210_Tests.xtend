package org.genivi.faracon.tests.aspects_on_constants.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test transformation of Autosar implementation data type with category 
 * STRUCTURE to franca struct type.
 *
 * Also tests IDL1830, IDL1840, IDL1850, IDL1860, IDL1870, IDL1880, IDL1890, IDL1900, IDL1910, IDL1920, IDL1930, IDL1940, IDL1950, IDL1960.
 *  IDL2410, IDL2440, IDL2450, IDL2500, and IDL2510.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1210_Tests extends ARA2FrancaTestBase {

	@Test
	def void primitiveTypesConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(
			#[correspondingFranca2AutosarTestPath + "primitiveTypesConstantsInTypeCollection.arxml"],
			#[testPath + "primitiveTypesConstantsInTypeCollection_a1.b2.c3.fidl"],
			"primitiveTypesConstantsInTypeCollection")
	}

	@Test
	def void primitiveTypesConstantsInInterface() {
		transformAndCheckIntegrationTest(
			#[correspondingFranca2AutosarTestPath + "primitiveTypesConstantsInInterface.arxml"],
			#[testPath + "primitiveTypesConstantsInInterface_a1.b2.c3.fidl",
			  testPath + "primitiveTypesConstantsInInterface_a1.b2.c3.ExampleInterface.fidl"],
			"primitiveTypesConstantsInInterface")
	}

	@Test
	def void arrayTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(
			#[correspondingFranca2AutosarTestPath + "arrayTypeConstantsInTypeCollection.arxml"],
			#[testPath + "arrayTypeConstantsInTypeCollection_a1.b2.c3.fidl"],
			"arrayTypeConstantsInTypeCollection")
	}

	@Test
	def void arrayTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(
			#[correspondingFranca2AutosarTestPath + "arrayTypeConstantsInInterface.arxml"],
			#[testPath + "arrayTypeConstantsInInterface_a1.b2.c3.fidl",
			  testPath + "arrayTypeConstantsInInterface_a1.b2.c3.ExampleInterface.fidl"],
			"arrayTypeConstantsInInterface")
	}

	@Test
	def void mapTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(
			#[correspondingFranca2AutosarTestPath + "mapTypeConstantsInTypeCollection.arxml"],
			#[testPath + "mapTypeConstantsInTypeCollection_a1.b2.c3.fidl"],
			"mapTypeConstantsInTypeCollection")
	}

	@Test
	def void mapTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(
			#[correspondingFranca2AutosarTestPath + "mapTypeConstantsInInterface.arxml"],
			#[testPath + "mapTypeConstantsInInterface_a1.b2.c3.fidl",
			  testPath + "mapTypeConstantsInInterface_a1.b2.c3.ExampleInterface.fidl"],
			"mapTypeConstantsInInterface")
	}

	@Test
	def void structTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(
			#[correspondingFranca2AutosarTestPath + "structTypeConstantsInTypeCollection.arxml"],
			#[testPath + "structTypeConstantsInTypeCollection_a1.b2.c3.fidl"],
			"structTypeConstantsInTypeCollection")
	}

	@Test
	def void structTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(
			#[correspondingFranca2AutosarTestPath + "structTypeConstantsInInterface.arxml"],
			#[testPath + "structTypeConstantsInInterface_a1.b2.c3.fidl",
			  testPath + "structTypeConstantsInInterface_a1.b2.c3.ExampleInterface.fidl"],
			"structTypeConstantsInInterface")
	}

	@Test
	def void typedefTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(
			#[testPath + "typedefTypeConstantsInTypeCollection.arxml"],
			#[testPath + "typedefTypeConstantsInTypeCollection_a1.b2.c3.fidl"],
			"typedefTypeConstantsInTypeCollection")
	}

	@Test
	def void typedefTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(
			#[testPath + "typedefTypeConstantsInInterface.arxml"],
			#[testPath + "typedefTypeConstantsInInterface_a1.b2.c3.fidl",
			  testPath + "typedefTypeConstantsInInterface_a1.b2.c3.ExampleInterface.fidl"],
			"typedefTypeConstantsInInterface")
	}

}
