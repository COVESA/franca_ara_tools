package org.genivi.faracon.tests.aspects_on_arrays.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Tests the transformation of named array types from Franca to AUTOSAR.
 * Also includes testing for IDL1550.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1540_Tests extends Franca2ARATestBase {

	@Test
	def void simpleNamedArrayType() {
		transformAndCheckIntegrationTest(testPath,
			#["simpleNamedArrayType.fidl"],
			#[testPath + "simpleNamedArrayType.arxml"],
			"simpleNamedArrayType")
	}

	@Test
	def void complexNamedArrayType() {
		transformAndCheckIntegrationTest(testPath,
			#["complexNamedArrayType.fidl"],
			#[testPath + "complexNamedArrayType.arxml"],
			"complexNamedArrayType")
	}

	@Test
	def void namedArrayTypesWithImport() {
		transformAndCheckIntegrationTest(testPath,
			#["namedArrayTypesWithImport.fidl",
			  "commonTypesForNamedArrayTypes.fidl"],
			#[testPath + "namedArrayTypesWithImport.arxml",
			  testPath + "commonTypesForNamedArrayTypes.arxml"],
			"namedArrayTypesWithImport")
	}

	@Test
	def void multipleNamedArrayTypesUsingTheSameElementType() {
		transformAndCheckIntegrationTest(testPath,
			#["namedArrayTypesWithImport.fidl",
			  "furtherNamedArrayTypeWithImport.fidl",
			  "commonTypesForNamedArrayTypes.fidl"],
			#[testPath + "namedArrayTypesWithImport.arxml",
			  testPath + "furtherNamedArrayTypeWithImport.arxml",
			  testPath + "commonTypesForNamedArrayTypes.arxml"],
			"multipleNamedArrayTypesUsingTheSameElementType")
	}

	@Test
	def void namedArrayTypesWithElementsTypesFromDifferentNamespaces() {
		transformAndCheckIntegrationTest(testPath,
			#["namedArrayTypesWithElementsTypesFromDifferentNamespaces.fidl",
			  "commonTypesForNamedArrayTypes.fidl",
			  "commonTypes2ForNamedArrayTypes.fidl"],
			#[testPath + "namedArrayTypesWithElementsTypesFromDifferentNamespaces.arxml",
			  testPath + "commonTypesForNamedArrayTypes.arxml",
			  testPath + "commonTypes2ForNamedArrayTypes.arxml"],
			"namedArrayTypesWithElementsTypesFromDifferentNamespaces")
	}

}
