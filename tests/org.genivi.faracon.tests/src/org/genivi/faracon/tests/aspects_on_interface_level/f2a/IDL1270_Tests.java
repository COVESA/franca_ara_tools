package org.genivi.faracon.tests.aspects_on_interface_level.f2a;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider;
import org.genivi.faracon.tests.util.Franca2ARATestBase;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Test cases for testing the conversion of The Franca interface inheritance.
 */
@RunWith(XtextRunner2_Franca.class)
@InjectWith(FaraconTestsInjectorProvider.class)
public class IDL1270_Tests extends Franca2ARATestBase {

	private static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/";

	@Test
	public void interfaceInheritance() {	
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "interfaceInheritance");
	}

	@Test
	public void interfaceInheritanceWithContent() {	
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "interfaceInheritanceWithContent");
	}

}
