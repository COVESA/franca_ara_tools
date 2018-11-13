package org.franca.connectors.ara.tests;

import static org.junit.Assert.assertNotNull;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.connectors.ara.ARAConnector;
import org.franca.connectors.ara.ARAModelContainer;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.franca.core.framework.FrancaModelContainer;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class ARA2FrancaTests {

	private static final String LOCAL_ARA_MODELS = "models/simple/";
//	private static final String REF_EXAMPLE_ARA_MODELS =
//			"../../examples/org.franca.examples.reference/models/org/reference/";

	@Inject	FrancaPersistenceManager loader;
	
	@Test
	public void test_20() {
		doTransformTest(LOCAL_ARA_MODELS, "simple");
	}
	
//	@Test
//	public void test_30() {
//		doTransformTest(LOCAL_ARA_MODELS, "30-SimpleAttribute");
//	}
//	
//	@Test
//	public void test_40() {
//		doTransformTest(LOCAL_ARA_MODELS, "40-PolymorphicStructs");
//	}
//
//	@Test
//	public void test_ref_61() {
//		doTransformTest(REF_EXAMPLE_ARA_MODELS, "61-Interface");
//	}
//

	@SuppressWarnings("restriction")
	private void doTransformTest(String path, String fileBasename) {
		// load example ARA interface
		String inputfile = path + fileBasename + ".arxml";
		ARAConnector conn = new ARAConnector();
		System.out.println("Loading arxml file " + inputfile + " ...");
		ARAModelContainer amodel = (ARAModelContainer)conn.loadModel(inputfile);
		assertNotNull(amodel);
		
		// transform to Franca IDL
		FrancaModelContainer fmodel = conn.toFranca(amodel);
		loader.saveModel(fmodel.model(), "src-gen/testcases/" + fileBasename + ".fidl");
		
		// load reference fidl file
		String referenceFile = "model/reference/" + fileBasename + ".fidl";
//		FModel ref = loader.loadModel(referenceFile);
		
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

