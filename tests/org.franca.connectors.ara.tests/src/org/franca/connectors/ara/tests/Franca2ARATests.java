package org.franca.connectors.ara.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.connectors.ara.tests.util.Franca2ARATestBase;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class Franca2ARATests extends Franca2ARATestBase {

	private static final String LOCAL_FRANCA_MODELS = "models/simple/";
	private static final String REF_EXAMPLE_FRANCA_MODELS =
			"../../examples/org.franca.examples.reference/models/org/reference/";

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

}

