package org.genivi.faracon.tests.util

import javax.inject.Inject
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.Franca2ARATransformation
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.tests.FaraconTestBase

import static org.junit.Assert.assertNotNull

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*

abstract class Franca2ARATestBase extends FaraconTestBase {

	@Inject 
	var protected extension Franca2ARATransformation franca2AraTransformation
	@Inject
	var protected extension ARATypeCreator araTypeCreator

	def void transform(String path, String fileBasename) {
		doTransformTest(path, fileBasename, null, false)
	}

	/**
	 * Do not use this method any longer as it does not perform any check
	 */
	@Deprecated
	def void transformAndCheck(String path, String fileBasename) {
		doTransformTest(path, fileBasename, null, true)
	}
	
	def void transformAndCheck(String path, String fileBasename, String expectedFilePath){
		doTransformTest(path, fileBasename, expectedFilePath, true)
	}
	@SuppressWarnings("restriction")
	def private void doTransformTest(String path, String fileBasename, String expectedFileName, boolean check) {
		// load example Franca IDL interface
		val inputfile = path + fileBasename + ".fidl"
		println("Loading Franca file " + inputfile + " ...")
		val fmodel = loader.loadModel(inputfile)
		assertNotNull(fmodel)
		
		// transform to arxml
		val fromFranca = araConnector.fromFranca(fmodel) as ARAModelContainer
		val araFileName = "src-gen/testcases/" + fileBasename + ".arxml"
		println("Save ara file " + araFileName)
		fromFranca.model.setUuidsTo0
		araConnector.saveModel(fromFranca, araFileName)
		
		if (check && expectedFileName !== null) {
			//ensure both use the same resource set
			assertAutosarFilesAreEqual(araFileName, expectedFileName)
		}
	}

}
