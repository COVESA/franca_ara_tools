package org.genivi.faracon.tests.aspects_on_franca_methods.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Test cases for testing the basic conversion of a Franca method declaration.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1290_Tests extends Franca2ARATestBase {

	static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_on_franca_methods/f2a/"
	val static OUTPUT = "methods/"
	
	@Test
	def void methodWithInAndOutArguments() {
		transformWithoutCheck(LOCAL_FRANCA_MODELS, "methodWithInAndOutArguments")
	}

	@Test
	def void methodWithInAndOutArguments_fdepl() {
		transformAndCheckIntegrationTest(
			testPath,
			#[ "methodWithInAndOutArguments.fidl",
				"methodWithInAndOutArguments.fdepl",
			 	"../../../../../../../models/deployment-files/CommonAPI-4_deployment_spec.fdepl",
				"../../../../../../../models/deployment-files/CommonAPI-4-SOMEIP_deployment_spec.fdepl"
			],
			#[ testPath + "methodWithInAndOutArguments.arxml" ],
			OUTPUT + "methodTestOutputFolder"
		)
	}

}
