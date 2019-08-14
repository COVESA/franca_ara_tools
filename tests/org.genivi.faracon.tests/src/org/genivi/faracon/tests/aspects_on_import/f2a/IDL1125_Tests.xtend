package org.genivi.faracon.tests.aspects_on_import.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test transformation of imports from franca to autosar
 * Also includes the test for IDL1120
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1125_Tests extends Franca2ARATestBase {

	@Test
	def void testMultipleFilesFromFrancaWithImport() {
		doTransformAndCheckIntegrationTest(correspondingAutosar2FrancaTestPath,
			#["fileWithImport_a1.b2.c3", "fileWithImport_a1.b2.c3.d4"],
			#[testPath + "fileWithImport_a1.b2.c3.arxml", testPath + "fileWithImport_a1.b2.c3.d4.arxml"],
			"testMultipleFilesFromFrancaWithImport")
	}

	@Test
	def void testMultipleFrancaInputFilesWithMultipleInterfacesAndTypesWithImport() {
		doTransformAndCheckIntegrationTest(correspondingAutosar2FrancaTestPath,
			#["fileWithMultiImport_a1.b2.c3", "fileWithMultiImport_a1.b2.c3.d4", "fileWithMultiImport_a1.b2.c3.d4.e5"],
			#[testPath + "fileWithMultiImport_a1.b2.c3.arxml", testPath + "fileWithMultiImport_a1.b2.c3.d4.arxml",
				testPath + "fileWithMultiImport_a1.b2.c3.d4.e5.arxml"],
			"testMultipleFrancaInputFilesWithMultipleInterfacesAndTypesWithImport")
	}
	
	@Test
	def void testIncompleteFrancaInputModels(){
		doTransformAndCheckIntegrationTest(correspondingAutosar2FrancaTestPath,
			#["fileWithImport_a1.b2.c3"],
			#[testPath + "fileWithImport_a1.b2.c3.arxml"],
			"testIncompleteFrancaInputModels")
	}

}
