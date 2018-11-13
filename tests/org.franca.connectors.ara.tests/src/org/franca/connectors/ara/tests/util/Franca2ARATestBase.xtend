package org.franca.connectors.ara.tests.util

import com.google.inject.Inject
import org.franca.connectors.ara.ARAConnector
import org.franca.connectors.ara.ARAModelContainer
import org.franca.core.dsl.FrancaPersistenceManager

import static org.junit.Assert.assertNotNull

class Franca2ARATestBase {

	@Inject	FrancaPersistenceManager loader

	def void transform(String path, String fileBasename) {
		doTransformTest(path, fileBasename, false)
	}

	def void transformAndCheck(String path, String fileBasename) {
		doTransformTest(path, fileBasename, true)
	}

	@SuppressWarnings("restriction")
	def private void doTransformTest(String path, String fileBasename, boolean check) {
		// load example Franca IDL interface
		val inputfile = path + fileBasename + ".fidl"
		println("Loading Franca file " + inputfile + " ...")
		val fmodel = loader.loadModel(inputfile)
		assertNotNull(fmodel)
		
		// transform to arxml
		val conn = new ARAConnector
		val fromFranca = conn.fromFranca(fmodel) as ARAModelContainer
		conn.saveModel(fromFranca, "src-gen/testcases/" + fileBasename + ".arxml")
		
		if (check) {
			// load reference arxml file
			val referenceFile = "model/reference/" + fileBasename + ".arxml"
	// TODO: implement comparison against ref model
//			val ref = conn.loadModel(referenceFile) as ARAModelContainer
			
			// compare with reference file
//			val rset1 = fromFranca.model.eResource.resourceSet
//			val rset2 = ref.model.eResource.resourceSet
//	
//			val IComparisonScope scope = EMFCompare.createDefaultScope(rset1, rset2)
//			val Comparison comparison = EMFCompare.builder.build.compare(scope)
//			 
//			val List<Diff> differences = comparison.getDifferences
//			val nDiffs = 0
//			for(Diff diff : differences) {
//				if (! (diff instanceof ResourceAttachmentChangeSpec)) {
//					println(diff.toString);
//					nDiffs++
//				}
//			}
//			assertEquals(0, nDiffs)
		}
	}
}
