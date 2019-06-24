package org.franca.connectors.ara.cli;

public class CreateShowcaseARATests extends Franca2ARATestBase {

	// TODO: currently the input models are copied, they should be taken from original repo instead
	private static final String SHOWCASE_FRANCA_MODELS = "models/showcase/";
//	private static final String SHOWCASE_FRANCA_MODELS = "C:/Users/tgoerg/git/franca_ara_tools/tests/org.franca.connectors.ara.tests/models/showcase/";

	public void createDrivingLaneARXML() {
		transform(SHOWCASE_FRANCA_MODELS, "drivingLane");
	}
	
	public void createVehiclesARXML() {
		transform(SHOWCASE_FRANCA_MODELS, "vehicles");
	}
	
}
