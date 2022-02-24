package org.genivi.faracon.tests.aspects_on_franca_deployment.f2a

import javax.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.cli.PropertiesHelper
import org.genivi.faracon.franca2ara.Franca2ARAConfigProvider
import org.genivi.faracon.franca2ara.Franca2ARAUserConfig
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.genivi.faracon.franca2ara.Franca2ARAConfigDefault

@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class Franca2ARADeployment_Tests extends Franca2ARATestBase {

	@Inject
	var extension Franca2ARAConfigProvider

	static final String ALL_MODELS = "models/"
	// static final String LOCAL_FRANCA_MODELS = "src/org/genivi/faracon/tests/aspects_on_franca_deployment/f2a/"
	static final String CONFIG_PROPERTY_FILE = ALL_MODELS + "Config/config.properties"

	@Before
	def void beforeAllTestMethods() {
		var conf = PropertiesHelper.readPropertiesFile(CONFIG_PROPERTY_FILE)
		var f2aConf = new Franca2ARAUserConfig(conf);
		configuration = f2aConf
	}
	
	@After
	def void cleanup() {
		// switch back to default configuration
		configuration = new Franca2ARAConfigDefault
	}

	@Test
	def void testServiceIDVersionDepl() {
		testTransformation("ServiceID_Version.fidl", "ServiceID_Version.fdepl", "ServiceID_Version",
			"ServiceID_VersionOutputFolder")
	}

	@Test
	def void testAttributesDepl() {
		testTransformation("Attributes.fidl", "Attributes.fdepl", "Attributes", "AttributesOutputFolder")
	}

	@Test
	def void testEventGroupDepl() {
		testTransformation("EventGroup.fidl", "EventGroup.fdepl", "EventGroup", "EventGroupOutputFolder")
	}

	@Test
	def void testMethodDepl() {
		testTransformation("Method.fidl", "Method.fdepl", "Method", "MethodsOutputFolder")
	}

	@Test
	def void testStringsDepl() {
		testTransformation("Strings.fidl", "Strings.fdepl", "Strings", "StringsOutputFolder")
	}
	
	@Test
	def void testArraysDepl() {
		testTransformation("Arrays.fidl", "Arrays.fdepl", "Arrays", "ArraysOutputFolder")
	}
	
	@Test
	def void testStructsDepl() {
		testTransformation("Structs.fidl", "Structs.fdepl", "Structs", "StructsOutputFolder")
	}

	protected def void testTransformation(String francaIDLfilePath, String francaDeplFilePath, String arxmlFilePrefix,
		String outputFolder) {
		franca2AraTransformation.logger.enableContinueOnErrors(true)

		transformAndCheckIntegrationTest(
			testPath,
			#[
				francaIDLfilePath,
				francaDeplFilePath,
				"../../../../../../../models/deployment-files/CommonAPI-4_deployment_spec.fdepl",
				"../../../../../../../models/deployment-files/CommonAPI-4-SOMEIP_deployment_spec.fdepl"
			],
			#[testPath + arxmlFilePrefix + ".arxml", testPath + arxmlFilePrefix + "_Deployment.arxml"],
			outputFolder
		)
	}

}
