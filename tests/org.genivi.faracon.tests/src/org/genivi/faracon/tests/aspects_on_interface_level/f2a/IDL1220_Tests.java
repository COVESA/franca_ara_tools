package org.genivi.faracon.tests.aspects_on_interface_level.f2a;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider;
import org.genivi.faracon.tests.util.Franca2ARATestBase;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Test cases for testing the basic conversion of an Franca interface definition without content.
 */
@RunWith(XtextRunner2_Franca.class)
@InjectWith(FaraconTestsInjectorProvider.class)
public class IDL1220_Tests extends Franca2ARATestBase {

	private static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/";

	@Test
	public void interfaceDefinition() {	
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "interfaceDefinition");
	}

}
