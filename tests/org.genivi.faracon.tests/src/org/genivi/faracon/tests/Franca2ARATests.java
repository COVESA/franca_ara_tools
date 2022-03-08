package org.genivi.faracon.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider;
import org.genivi.faracon.tests.util.Franca2ARATestBase;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FaraconTestsInjectorProvider.class)
public class Franca2ARATests extends Franca2ARATestBase {

	private static final String LOCAL_FRANCA_MODELS = "models/simple/";
//	private static final String REF_EXAMPLE_FRANCA_MODELS =
//			"../../examples/org.franca.examples.reference/models/org/reference/";

	@Test
	public void test_20() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "simple");
	}
	
	@Test
	@Ignore
	public void testSimpleStruct() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "simpleStruct");
	}
	
	@Test
	public void testSimpleAttribute() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "simpleAttribute");
	}
	
	@Test
	public void testSimpleBroadcast() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "simpleBroadcast");
	}
	
	@Test
	public void testSimpleEnum() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "simpleEnum");
	}
	
	@Test
	public void testSimpleArray() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "simpleArray");
	}
	
	@Test
	public void testSimpleMap() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "simpleMap");
	}
	
//	@Test
//	public void test_40() {
//		transformWithoutCheck(LOCAL_FRANCA_MODELS, "40-PolymorphicStructs");
//	}
//
//	@Test
//	public void test_ref_61() {
//		transformWithoutCheck(REF_EXAMPLE_FRANCA_MODELS, "61-Interface");
//	}
//

}

