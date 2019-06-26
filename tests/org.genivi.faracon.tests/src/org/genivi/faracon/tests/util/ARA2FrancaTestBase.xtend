package org.franca.connectors.ara.tests.util

import com.google.inject.Inject
import org.franca.connectors.ara.ARAConnector
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.framework.FrancaModelContainer

import static org.junit.Assert.assertNotNull

class ARA2FrancaTestBase {

	@Inject	FrancaPersistenceManager loader

	def void transform(String path, String fileBasename) {
		doTransformTest(path, fileBasename, false)
	}

	def void transformAndCheck(String path, String fileBasename) {
		doTransformTest(path, fileBasename, true)
	}

	@SuppressWarnings("restriction")
	def private void doTransformTest(String path, String fileBasename, boolean check) {
		// load example ARA interface
		val inputfile = path + fileBasename + ".arxml"
		System.out.println("Loading arxml file " + inputfile + " ...")
		val conn = new ARAConnector()
		val amodel = conn.loadModel(inputfile)
		assertNotNull(amodel)
		
		// transform to Franca IDL
		val fmodel = conn.toFranca(amodel) as FrancaModelContainer
		loader.saveModel(fmodel.model, "src-gen/testcases/" + fileBasename + ".fidl")
		
		if (check) {
			// load reference fidl file
			val referenceFile = "model/reference/" + fileBasename + ".fidl";
//			FModel ref = loader.loadModel(referenceFile);
		
			// compare with reference file
//			ResourceSet rset1 = fromFranca.model().eResource().getResourceSet();
//			ResourceSet rset2 = ref.model().eResource().getResourceSet();
//
//			IComparisonScope scope = EMFCompare.createDefaultScope(rset1, rset2);
//			Comparison comparison = EMFCompare.builder().build().compare(scope);
//		 
//			List<Diff> differences = comparison.getDifferences();
//			int nDiffs = 0;
//			for (Diff diff : differences) {
//				if (! (diff instanceof ResourceAttachmentChangeSpec)) {
//					System.out.println(diff.toString());
//					nDiffs++;
//				}
//			}
//			assertEquals(0, nDiffs);
		}
	}

}
