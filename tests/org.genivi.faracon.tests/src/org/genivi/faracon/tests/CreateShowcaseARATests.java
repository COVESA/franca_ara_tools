package org.genivi.faracon.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider;
import org.genivi.faracon.tests.util.Franca2ARATestBase;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FaraconTestsInjectorProvider.class)
public class CreateShowcaseARATests extends Franca2ARATestBase {

	// TODO: currently the input models are copied, they should be taken from original repo instead
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
