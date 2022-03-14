package org.genivi.faracon.cli;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.genivi.faracon.franca2ara.config.F2AConfig;

public class PropertiesHelper {
	private PropertiesHelper() { }

	public static F2AConfig readPropertiesFile(String pathToFile) throws IOException {
		F2AConfig f2aConf = null;

		try (InputStream input = new FileInputStream(pathToFile)) {

			Properties prop = new Properties();
			// load a properties file
			prop.load(input);

			// get the property value and print it out
			f2aConf =
				new F2AConfig(
					asBool(prop, "IsAdminDataLanguageGenerationNeeded"),
					asBool(prop, "IsAnnotationGenerationNeeded"),
					asBool(prop, "IsOptionalFalseGenerationNeeded"),
					asBool(prop, "IsAlwaysFireAndForgetGenerationNeeded"),
					asBool(prop, "IsADTsGenerationNeeded"),
					asBool(prop, "IsStoringADTsLocallyNeeded"),
					asString(prop, "ADTPrefix"),
					asString(prop, "IDTPrefixBasic"),
					asString(prop, "IDTPrefixComplex"),
					asBool(prop, "IsReplacingIDTPrimitiveTypeDefsNeeded"),
					asBool(prop, "IsStoringIDTsLocallyNeeded"),
					asBool(prop, "IsAlwaysIDTArrayGenerationNeeded"),
					prop.getProperty("CompuMethodPrefix"),
					asBool(prop, "IsStringAsArrayGenerationNeeded"),
					asBool(prop, "UseSizeAndPayloadStructs"),
					asBool(prop, "AvoidTypeReferences"),
					asBool(prop, "SkipCompoundTypeReferences"),
					asBool(prop, "IsDeploymentGenerationNeeded"),
					asBool(prop, "IsStoringDeploymentLocallyNeeded"),
					asBool(prop, "IsSeparateDeploymentFileCreationNeeded")
				);
		} catch (IOException ex) {
			throw new IOException(ex);
		}

		return f2aConf;
	}
	
	private static String asString(Properties prop, String property) {
		return prop.getProperty(property);
	}

	private static Boolean asBool(Properties prop, String property) {
		return getBooleanValue(prop.getProperty(property));
	}

	private static Boolean getBooleanValue(String property) {
		Boolean value = Boolean.valueOf(property);
		if (!value && !"false".equalsIgnoreCase(property)) {
			return null;
		}
		return value;
	}

}
