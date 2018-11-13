package org.franca.connectors.ara.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.connectors.ara.tests.util.Franca2ARATestBase;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class CreateShowcaseARATests extends Franca2ARATestBase {

	private static final String SHOWCASE_FRANCA_MODELS = "models/showcase/";

	@Test
	public void createDrivingLaneARXML() {
		transform(SHOWCASE_FRANCA_MODELS, "drivingLane");
	}
	
	@Test
	public void createVehiclesARXML() {
		transform(SHOWCASE_FRANCA_MODELS, "vehicles");
	}
	
}
