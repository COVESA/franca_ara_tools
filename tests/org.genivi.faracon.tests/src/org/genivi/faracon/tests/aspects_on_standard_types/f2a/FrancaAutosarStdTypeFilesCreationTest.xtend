package org.genivi.faracon.tests.aspects_on_standard_types.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.After
import org.junit.Test
import org.junit.runner.RunWith

import static org.genivi.faracon.tests.aspects_on_standard_types.StdTypesTestHelper.*

import static extension org.junit.Assert.assertNotNull
import static extension org.junit.Assert.assertNull

/**
 * Tests whether the autosar std-types are created during test-execution 
 * 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class FrancaAutosarStdTypeFilesCreationTest extends Franca2ARATestBase {
	
	@After
	def void afterTest() {
		Preferences.instance.resetPreferences
	}
	
	@Test
	def void testAutosarStdFilesCreation() {
		testStdFileCreation("testAutosarStdFilesCreation", true, "stdtypes_vectors.arxml")
	}
	
	@Test
	def void testCustomizedAutosarStdFilesCreation() {
		useCustomizedAutosarStdTypes
		testStdFileCreation("testCustomizedAutosarStdFilesCreation", false, "customizedAutosarStdTypes_vectors.arxml")
	}
	
	private def void testStdFileCreation(String outputDirName, boolean stdTypesExpected, String stdVectorTypesFileName) {
		//given
		val inputDirPath = "src/org/genivi/faracon/tests/aspects_on_standard_types/f2a/" 
		val inputFileName = "emptyFile.fidl"
		val expectedOutputFilePath = inputDirPath + "emptyFile.arxml"
		val expectedStdVectorTypesFilePath = inputDirPath + stdVectorTypesFileName
		
		//when 
		transformAndCheckIntegrationTest(inputDirPath,
			#[inputFileName],
			stdVectorTypesFileName == "stdtypes_vectors.arxml" ?
				#[expectedOutputFilePath] : #[expectedOutputFilePath, expectedStdVectorTypesFilePath],
			outputDirName)
		
		//then: after a transformation the std type files must be in the output folder
		val outputDirPath = Preferences.instance.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, null)
		val arxmlFiles = findArxmlFilesStdFiles(outputDirPath, false)
		val stdTypes = arxmlFiles.findFirst[it.endsWith("stdtypes.arxml")]
		if (stdTypesExpected) {
			stdTypes.assertNotNull
		} else {
			stdTypes.assertNull
		}
		val stdVectorTypes = arxmlFiles.findFirst[it.endsWith(stdVectorTypesFileName)]
		stdVectorTypes.assertNotNull
	}
	
}