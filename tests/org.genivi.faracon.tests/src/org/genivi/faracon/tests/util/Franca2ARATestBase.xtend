package org.genivi.faracon.tests.util

import java.util.Collection
import javax.inject.Inject
import org.junit.Before
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.Franca2ARATransformation
import org.genivi.faracon.cli.Franca2AraConverter
import org.genivi.faracon.franca2ara.types.ARATypeCreator
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.preferences.PreferencesConstants
import org.genivi.faracon.tests.FaraconTestBase

import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertNotNull

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*

abstract class Franca2ARATestBase extends FaraconTestBase {

	@Inject
	protected var extension Franca2ARATransformation franca2AraTransformation
	@Inject
	protected var extension ARATypeCreator araTypeCreator
	@Inject
	var Franca2AraConverter franca2AraConverter
	
	protected val static DEPLOYMENT_SPEC_PATH = "../../../../../../../models/deployment-files/"

	@Before
	def void initTestEnvironment() {
		initializeTransformation
	}

	def void transform(String path, String fileBasename) {
		transformationTest(path, fileBasename, null, false, "transformOnly")
	}

	/**
	 * Do not use this method any longer as it does not perform any check
	 */
	@Deprecated
	def void transformWithoutCheck(String path, String fileBasename) {
		transformationTest(path, fileBasename, null, true, "withoutCheck")
	}

	def void transformAndCheck(String path, String fileBasename, String expectedFilePath) {
		transformationTest(path, fileBasename, expectedFilePath, true, "withCheck")
	}

	def void transformAndCheckIntegrationTest(String path, Collection<String> files,
		Collection<String> expectedFilePaths, String outputFolderName
	) {
		transformAndCheckIntegrationTest(path, files, expectedFilePaths, outputFolderName, true)
	}

	def void transformAndCheckIntegrationTest(
		String path, Collection<String> files,
		Collection<String> expectedFilePaths, String outputFolderName,
		boolean resetUUIDs
	) {
		// given: non-null strings, which are not empty
		val inputPaths = files.map[path + it].toList
		assertFalse("No source file path given", inputPaths.nullOrEmpty)
		Preferences.instance.setPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH,
			"src-gen/testcases/" + outputFolderName)

		// when
		franca2AraConverter.convertFiles(inputPaths)

		// assert
		val doCheck = expectedFilePaths!==null
		val autosarModelPaths = Preferences.instance.getPreference(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, null)
		assertNotNull("no outputpath found", autosarModelPaths)
		val actualAutosarFiles = findArxmlFilesStdFiles(autosarModelPaths, true)
		if (doCheck && resetUUIDs) {
			actualAutosarFiles.forEach [ autosarFileName |
				// load Autosar models and set UUID to 0
				val modelContainer = araConnector.loadModel(autosarFileName) as ARAModelContainer
				modelContainer.model.setUuidsTo0
				if (modelContainer.deploymentModel!==null)
					modelContainer.deploymentModel.setUuidsTo0				
				araConnector.saveModel(modelContainer, autosarFileName)
			]			
		}
		
		if (doCheck) {
			assertAutosarFilesAreEqual(actualAutosarFiles, expectedFilePaths)
		} else {
			println("NOTE: This test doesn't provide expected files, no check will be executed.")
		}
	}
	
	protected def Collection<String> findArxmlFilesStdFiles(String autosarModelPaths, boolean ignoreStdFiles) {
		val arxmlFiles = findFiles(autosarModelPaths, "arxml")
		if (ignoreStdFiles) {
			return arxmlFiles.filter[
				! (endsWith("stdtypes.arxml") || endsWith("stdtypes_vectors.arxml"))
			].toList	
		}
		return arxmlFiles
	}

	def private void transformationTest(
		String path,
		String fileBasename,
		String expectedFileName,
		boolean check,
		String outputPath
	) {
		// given
		// load example Franca IDL interface
		val inputfile = path + fileBasename + ".fidl"
		val fmodel = loader.loadModel(inputfile)
		assertNotNull("The franca model " + inputfile + " is null", fmodel)

		// when
		// transform to arxml
		val fromFranca = araConnector.fromFranca(fmodel) as ARAModelContainer
		val outPath = outputPath!==null ? outputPath + "/" : ""
		val araFileName = "src-gen/testcases/" + outPath + fileBasename + ".arxml"
		println("Save ara file " + araFileName)
		if (check) {
			fromFranca.model.setUuidsTo0		
		}
		araConnector.saveModel(fromFranca, araFileName)

		// then
		if (check && expectedFileName !== null) {
			// ensure both use the same resource set
			assertAutosarFilesAreEqual(araFileName, expectedFileName)
		}
	}

	/**
	 * Returns the path to the corresponding autosar to franca test path.
	 * The default implementation assumes that the autosar to franca test path
	 * has the same path, but with "a2f" instead of "f2a" as last segment 
	 */
	def protected String getCorrespondingAutosar2FrancaTestPath() {
		testPath.replaceFirst("f2a", "a2f")
	}

}
