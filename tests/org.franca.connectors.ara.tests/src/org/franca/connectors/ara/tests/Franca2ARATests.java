package org.franca.connectors.ara.tests;

import static org.junit.Assert.assertNotNull;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.connectors.ara.ARAConnector;
import org.franca.connectors.ara.ARAModelContainer;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.franca.core.franca.FModel;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class Franca2ARATests {

	private static final String LOCAL_FRANCA_MODELS = "models/simple/";
	private static final String REF_EXAMPLE_FRANCA_MODELS =
			"../../examples/org.franca.examples.reference/models/org/reference/";

	@Inject	FrancaPersistenceManager loader;
	
	@Test
	public void test_20() {
		doTransformTest(LOCAL_FRANCA_MODELS, "simple");
	}
	
//	@Test
//	public void test_30() {
//		doTransformTest(LOCAL_FRANCA_MODELS, "30-SimpleAttribute");
//	}
//	
//	@Test
//	public void test_40() {
//		doTransformTest(LOCAL_FRANCA_MODELS, "40-PolymorphicStructs");
//	}
//
//	@Test
//	public void test_ref_61() {
//		doTransformTest(REF_EXAMPLE_FRANCA_MODELS, "61-Interface");
//	}
//

	@SuppressWarnings("restriction")
	private void doTransformTest (String path, String fileBasename) {
		// load example Franca IDL interface
		String inputfile = path + fileBasename + ".fidl";
		System.out.println("Loading Franca file " + inputfile + " ...");
		FModel fmodel = loader.loadModel(inputfile);
		assertNotNull(fmodel);
		
		// transform to arxml
		ARAConnector conn = new ARAConnector();
		ARAModelContainer fromFranca = (ARAModelContainer)conn.fromFranca(fmodel);
		conn.saveModel(fromFranca, "src-gen/testcases/" + fileBasename + ".arxml");
		
		// load reference arxml file
		String referenceFile = "model/reference/" + fileBasename + ".arxml";
		ARAModelContainer ref = (ARAModelContainer)conn.loadModel(referenceFile);
		
		// compare with reference file
//		ResourceSet rset1 = fromFranca.model().eResource().getResourceSet();
//		ResourceSet rset2 = ref.model().eResource().getResourceSet();
//
//		IComparisonScope scope = EMFCompare.createDefaultScope(rset1, rset2);
//		Comparison comparison = EMFCompare.builder().build().compare(scope);
//		 
//		List<Diff> differences = comparison.getDifferences();
//		int nDiffs = 0;
//		for (Diff diff : differences) {
//			if (! (diff instanceof ResourceAttachmentChangeSpec)) {
//				System.out.println(diff.toString());
//				nDiffs++;
//			}
//		}
//		assertEquals(0, nDiffs);
	}
}

