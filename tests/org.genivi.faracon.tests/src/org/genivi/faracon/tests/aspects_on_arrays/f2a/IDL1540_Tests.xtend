package org.genivi.faracon.tests.aspects_on_arrays.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FrancaPackage
import org.franca.deploymodel.dsl.fDeploy.FDeployPackage
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith
import org.eclipse.emf.ecore.EPackage

/**
 * Tests the transformation of named array types from Franca to AUTOSAR.
 * Also includes testing for IDL1550.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1540_Tests extends Franca2ARATestBase {

	val static OUTPUT = "arrays/named/"
	
	@Test
	def void simpleNamedArrayType() {
		transformAndCheckIntegrationTest(testPath,
			#["simpleNamedArrayType.fidl"],
			#[testPath + "simpleNamedArrayType.arxml"],
			OUTPUT + "simpleNamedArrayType")
	}

	@Test
	def void complexNamedArrayType() {
		transformAndCheckIntegrationTest(testPath,
			#["complexNamedArrayType.fidl"],
			#[testPath + "complexNamedArrayType.arxml"],
			OUTPUT + "complexNamedArrayType")
	}

	@Test
	def void namedArrayTypesWithImport() {
		transformAndCheckIntegrationTest(testPath,
			#["namedArrayTypesWithImport.fidl",
			  "commonTypesForNamedArrayTypes.fidl"],
			#[testPath + "namedArrayTypesWithImport.arxml",
			  testPath + "commonTypesForNamedArrayTypes.arxml"],
			OUTPUT + "namedArrayTypesWithImport")
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
			OUTPUT + "multipleNamedArrayTypesUsingTheSameElementType")
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
			OUTPUT + "namedArrayTypesWithElementsTypesFromDifferentNamespaces")
	}

	@Test
	def void namedFixedSizedArrayTypeInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["namedFixedSizedArrayTypeInTypeCollection.fidl",
			  "namedFixedSizedArrayTypeInTypeCollection.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4_deployment_spec.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4-SOMEIP_deployment_spec.fdepl"],
			#[testPath + "namedFixedSizedArrayTypeInTypeCollection.arxml"],
			OUTPUT + "namedFixedSizedArrayTypeInTypeCollection")
	}

	@Test
	def void namedFixedSizedArrayTypeInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["namedFixedSizedArrayTypeInInterface.fidl",
			  "namedFixedSizedArrayTypeInInterface.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4_deployment_spec.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4-SOMEIP_deployment_spec.fdepl"],
			#[testPath + "namedFixedSizedArrayTypeInInterface.arxml"],
			OUTPUT + "namedFixedSizedArrayTypeInInterface")
	}

}
