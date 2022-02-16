package org.genivi.faracon.cli;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.genivi.faracon.franca2ara.F2AConfig;

public class PropertiesHelper {
	private PropertiesHelper() { }

	public static F2AConfig readPropertiesFile(String pathToFile) throws IOException {
		F2AConfig f2aConf = null;

		try (InputStream input = new FileInputStream(pathToFile)) {

			Properties prop = new Properties();
			// load a properties file
			prop.load(input);

			// get the property value and print it out
			f2aConf = new F2AConfig(getBooleanValue(prop.getProperty("IsAdminDataLanguageGenerationNeeded")),
					getBooleanValue(prop.getProperty("IsOptionalFalseGenerationNeeded")),
					getBooleanValue(prop.getProperty("IsAlwaysFireAndForgetGenerationNeeded")),
					getBooleanValue(prop.getProperty("IsADTsGenerationNeeded")),
					getBooleanValue(prop.getProperty("IsStoringADTsLocallyNeeded")),
					prop.getProperty("ADTPrefix"),
					prop.getProperty("IDTPrefix"),
					getBooleanValue(prop.getProperty("IsReplacingIDTPrimitiveTypeDefsNeeded")),
					getBooleanValue(prop.getProperty("IsStoringIDTsLocallyNeeded")),
					getBooleanValue(prop.getProperty("IsAlwaysIDTArrayGenerationNeeded")),
					prop.getProperty("CompuMethodPrefix"),
					getBooleanValue(prop.getProperty("IsStringAsArrayGenerationNeeded")),					
					getBooleanValue(prop.getProperty("SkipCompoundTypeReferences")),
					getBooleanValue(prop.getProperty("IsDeploymentGenerationNeeded")),
					getBooleanValue(prop.getProperty("IsStoringDeploymentLocallyNeeded")),
					getBooleanValue(prop.getProperty("IsSeparateDeploymentFileCreationNeeded")),
					prop.getProperty("SignalPrefix"));
		} catch (IOException ex) {
			throw new IOException(ex);
		}

		return f2aConf;
	}

	private static Boolean getBooleanValue(String property) {
		Boolean value = Boolean.valueOf(property);
		if (!value && !"false".equalsIgnoreCase(property)) {
			return null;
		}
		return value;
	}

}
