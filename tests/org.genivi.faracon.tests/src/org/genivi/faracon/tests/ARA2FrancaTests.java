package org.genivi.faracon.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.FrancaPersistenceManager;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider;
import org.genivi.faracon.tests.util.Franca2ARATestBase;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.inject.Inject;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FaraconTestsInjectorProvider.class)
public class ARA2FrancaTests extends Franca2ARATestBase {

	private static final String LOCAL_ARA_MODELS = "models/simple/";
//	private static final String REF_EXAMPLE_ARA_MODELS =
//			"../../examples/org.franca.examples.reference/models/org/reference/";

	@Inject	FrancaPersistenceManager loader;
	
	@Test
	public void test_20() {
		transformAndCheck(LOCAL_ARA_MODELS, "simple");
	}
	
//	@Test
//	public void test_30() {
//		transformAndCheck(LOCAL_ARA_MODELS, "30-SimpleAttribute");
//	}
//	
//	@Test
//	public void test_40() {
//		transformAndCheck(LOCAL_ARA_MODELS, "40-PolymorphicStructs");
//	}
//
//	@Test
//	public void test_ref_61() {
//		transformAndCheck(REF_EXAMPLE_ARA_MODELS, "61-Interface");
//	}
//

}

