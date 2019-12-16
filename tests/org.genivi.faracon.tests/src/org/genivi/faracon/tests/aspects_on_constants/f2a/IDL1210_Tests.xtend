package org.genivi.faracon.tests.aspects_on_constants.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Tests the transformation of named constant definitions from Franca to AUTOSAR.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1210_Tests extends Franca2ARATestBase {

	@Test
	def void primitiveTypesConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["primitiveTypesConstantsInTypeCollection.fidl"],
			#[testPath + "primitiveTypesConstantsInTypeCollection.arxml"],
			"primitiveTypesConstantsInTypeCollection")
	}

	@Test
	def void primitiveTypesConstantsInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["primitiveTypesConstantsInInterface.fidl"],
			#[testPath + "primitiveTypesConstantsInInterface.arxml"],
			"primitiveTypesConstantsInInterface")
	}

	@Test
	def void arrayTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["arrayTypeConstantsInTypeCollection.fidl"],
			#[testPath + "arrayTypeConstantsInTypeCollection.arxml"],
			"arrayTypeConstantsInTypeCollection")
	}

	@Test
	def void arrayTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["arrayTypeConstantsInInterface.fidl"],
			#[testPath + "arrayTypeConstantsInInterface.arxml"],
			"arrayTypeConstantsInInterface")
	}

	@Test
	def void mapTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["mapTypeConstantsInTypeCollection.fidl"],
			#[testPath + "mapTypeConstantsInTypeCollection.arxml"],
			"mapTypeConstantsInTypeCollection")
	}

	@Test
	def void mapTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["mapTypeConstantsInInterface.fidl"],
			#[testPath + "mapTypeConstantsInInterface.arxml"],
			"mapTypeConstantsInInterface")
	}

	@Test
	def void structTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["structTypeConstantsInTypeCollection.fidl"],
			#[testPath + "structTypeConstantsInTypeCollection.arxml"],
			"structTypeConstantsInTypeCollection")
	}

	@Test
	def void structTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["structTypeConstantsInInterface.fidl"],
			#[testPath + "structTypeConstantsInInterface.arxml"],
			"structTypeConstantsInInterface")
	}

	@Test
	def void unionTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["unionTypeConstantsInTypeCollection.fidl"],
			#[testPath + "unionTypeConstantsInTypeCollection.arxml"],
			"unionTypeConstantsInTypeCollection")
	}

	@Test
	def void unionTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["unionTypeConstantsInInterface.fidl"],
			#[testPath + "unionTypeConstantsInInterface.arxml"],
			"unionTypeConstantsInInterface")
	}

	@Test
	def void enumerationTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["enumerationTypeConstantsInTypeCollection.fidl"],
			#[testPath + "enumerationTypeConstantsInTypeCollection.arxml"],
			"enumerationTypeConstantsInTypeCollection")
	}

	@Test
	def void enumerationTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["enumerationTypeConstantsInInterface.fidl"],
			#[testPath + "enumerationTypeConstantsInInterface.arxml"],
			"enumerationTypeConstantsInInterface")
	}

	@Test
	def void typedefTypeConstantsInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["typedefTypeConstantsInTypeCollection.fidl"],
			#[testPath + "typedefTypeConstantsInTypeCollection.arxml"],
			"typedefTypeConstantsInTypeCollection")
	}

	@Test
	def void typedefTypeConstantsInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["typedefTypeConstantsInInterface.fidl"],
			#[testPath + "typedefTypeConstantsInInterface.arxml"],
			"typedefTypeConstantsInInterface")
	}

}
