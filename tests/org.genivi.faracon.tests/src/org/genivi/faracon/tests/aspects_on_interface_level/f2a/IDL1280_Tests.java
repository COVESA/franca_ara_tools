package org.genivi.faracon.tests.aspects_on_interface_level.f2a;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.genivi.faracon.logging.AbstractLogger;
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider;
import org.genivi.faracon.tests.util.Franca2ARATestBase;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * Test cases for testing the conversion of The Franca "manages" relation between inheritance definitions.
 */
@RunWith(XtextRunner2_Franca.class)
@InjectWith(FaraconTestsInjectorProvider.class)
public class IDL1280_Tests extends Franca2ARATestBase {

	private static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/";

	@Test(expected = AbstractLogger.StopOnErrorException.class)
	public void singleManagesRelationBetweenInterfaces() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "singleManagesRelationBetweenInterfaces");
	}

	@Test(expected = AbstractLogger.StopOnErrorException.class)
	public void multiManagesRelationBetweenInterfaces() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "multiManagesRelationBetweenInterfaces");
	}

}
