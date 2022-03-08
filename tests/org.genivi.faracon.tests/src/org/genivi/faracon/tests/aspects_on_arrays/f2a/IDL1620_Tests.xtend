package org.genivi.faracon.tests.aspects_on_arrays.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Tests the transformation of anonymous array types from Franca to AUTOSAR.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1620_Tests extends Franca2ARATestBase {

	val static OUTPUT = "arrays/anonymous/"

	@Test
	def void simpleAnonymousArrayType() {
		transformAndCheckIntegrationTest(testPath,
			#["simpleAnonymousArrayType.fidl"],
			#[testPath + "simpleAnonymousArrayType.arxml"],
			OUTPUT + "simpleAnonymousArrayType")
	}

	@Test
	def void complexAnonymousArrayType() {
		transformAndCheckIntegrationTest(testPath,
			#["complexAnonymousArrayType.fidl"],
			#[testPath + "complexAnonymousArrayType.arxml"],
			OUTPUT + "complexAnonymousArrayType")
	}

	@Test
	def void anonymousArrayTypesWithImport() {
		transformAndCheckIntegrationTest(testPath,
			#["anonymousArrayTypesWithImport.fidl",
			  "commonTypesForAnonymousArrayTypes.fidl"],
			#[testPath + "anonymousArrayTypesWithImport.arxml",
			  testPath + "commonTypesForAnonymousArrayTypes.arxml"],
			OUTPUT + "anonymousArrayTypesWithImport")
	}

	@Test
	def void multipleAnonymousArrayTypesUsingTheSameElementType() {
		transformAndCheckIntegrationTest(testPath,
			#["anonymousArrayTypesWithImport.fidl",
			  "furtherAnonymousArrayTypeWithImport.fidl",
			  "commonTypesForAnonymousArrayTypes.fidl"],
			#[testPath + "anonymousArrayTypesWithImport.arxml",
			  testPath + "furtherAnonymousArrayTypeWithImport.arxml",
			  testPath + "commonTypesForAnonymousArrayTypes.arxml"],
			OUTPUT + "multipleAnonymousArrayTypesUsingTheSameElementType")
	}

	@Test
	def void anonymousArrayTypesWithElementsTypesFromDifferentNamespaces() {
		transformAndCheckIntegrationTest(testPath,
			#["anonymousArrayTypesWithElementsTypesFromDifferentNamespaces.fidl",
			  "commonTypesForNamedArrayTypes.fidl",
			  "commonTypes2ForNamedArrayTypes.fidl"],
			#[testPath + "anonymousArrayTypesWithElementsTypesFromDifferentNamespaces.arxml",
			  testPath + "commonTypesForNamedArrayTypes.arxml",
			  testPath + "commonTypes2ForNamedArrayTypes.arxml"],
			OUTPUT + "anonymousArrayTypesWithElementsTypesFromDifferentNamespaces")
	}

	@Test
	def void simpleAnonymousFixedSizedArrayTypeInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["simpleAnonymousFixedSizedArrayTypeInInterface.fidl",
			  "simpleAnonymousFixedSizedArrayTypeInInterface.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4_deployment_spec.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4-SOMEIP_deployment_spec.fdepl"],
			#[testPath + "simpleAnonymousFixedSizedArrayTypeInInterface.arxml",
			  testPath + "stdtypes_arrays.arxml"],
			OUTPUT + "simpleAnonymousFixedSizedArrayTypeInInterface")
	}

	@Test
	def void simpleAnonymousFixedSizedArrayTypeInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["simpleAnonymousFixedSizedArrayTypeInTypeCollection.fidl",
			  "simpleAnonymousFixedSizedArrayTypeInTypeCollection.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4_deployment_spec.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4-SOMEIP_deployment_spec.fdepl"],
			#[testPath + "simpleAnonymousFixedSizedArrayTypeInTypeCollection.arxml",
			  testPath + "stdtypes_arrays.arxml"],
			OUTPUT + "simpleAnonymousFixedSizedArrayTypeInTypeCollection")
	}

	@Test
	def void complexAnonymousFixedSizedArrayTypeInInterface() {
		transformAndCheckIntegrationTest(testPath,
			#["complexAnonymousFixedSizedArrayTypeInInterface.fidl",
			  "complexAnonymousFixedSizedArrayTypeInInterface.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4_deployment_spec.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4-SOMEIP_deployment_spec.fdepl"],
			#[testPath + "complexAnonymousFixedSizedArrayTypeInInterface.arxml"],
			OUTPUT + "complexAnonymousFixedSizedArrayTypeInInterface")
	}

	@Test
	def void complexAnonymousFixedSizedArrayTypeInTypeCollection() {
		transformAndCheckIntegrationTest(testPath,
			#["complexAnonymousFixedSizedArrayTypeInTypeCollection.fidl",
			  "complexAnonymousFixedSizedArrayTypeInTypeCollection.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4_deployment_spec.fdepl",
			  "../../../../../../../models/deployment-files/CommonAPI-4-SOMEIP_deployment_spec.fdepl"],
			#[testPath + "complexAnonymousFixedSizedArrayTypeInTypeCollection.arxml"],
			OUTPUT + "complexAnonymousFixedSizedArrayTypeInTypeCollection")
	}

}
