package org.franca.connectors.ara.tests;

import org.eclipse.xtext.testing.InjectWith;
import org.franca.connectors.ara.tests.util.ARA2FrancaTestBase;
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;
import org.franca.core.dsl.tests.util.XtextRunner2_Franca;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(XtextRunner2_Franca.class)
@InjectWith(FrancaIDLTestsInjectorProvider.class)
public class ShowcaseReverseTransformationTests extends ARA2FrancaTestBase {

	private static final String GENERATED_SHOWCASE_ARA_MODELS = "src-gen/testcases/";

	@Test
	public void createDrivingLaneFranca() {
		transform(GENERATED_SHOWCASE_ARA_MODELS, "drivingLane");
	}
	
	@Test
	public void createVehiclesFranca() {
		transform(GENERATED_SHOWCASE_ARA_MODELS, "vehicles");
	}
	
}
