package org.genivi.faracon.franca2ara

class Franca2ARAUserConfig implements IFranca2ARAConfig {

	var F2AConfig f2aConfig;

	new(F2AConfig f2aConf) {
		super()
		this.f2aConfig = f2aConf
	}

	// general
	override boolean generateAdminDataLanguage() {
		f2aConfig.generateAdminDataLanguage
	}

	// service interfaces
	override boolean generateOptionalFalse() {
		f2aConfig.generateOptionalFalse
	}

	override boolean genAlwaysFireAndForget() {
		f2aConfig.genAlwaysFireAndForget
	}

	// application data types
	override boolean generateADTs() {
		f2aConfig.generateADTs
	}

	override boolean storeADTsLocally() {
		f2aConfig.storeADTsLocally
	}

	override String getADTPrefix() {
		f2aConfig.getADTPrefix
	}

	// implementation data types	
	override String getIDTPrefix() {
		f2aConfig.getIDTPrefix
	}

	override boolean replaceIDTPrimitiveTypeDefs() {
		f2aConfig.replaceIDTPrimitiveTypeDefs
	}

	// override boolean generateCppIDTs() { false }
	override boolean storeIDTsLocally() {
		f2aConfig.storeIDTsLocally
	}

	override boolean alwaysGenIDTArray() {
		f2aConfig.alwaysGenIDTArray
	}

	override String getCompuMethodPrefix() {
		f2aConfig.getCompuMethodPrefix
	}

	override boolean generateStringAsArray() {
		f2aConfig.generateStringAsArray
	}

	// deployment
	override boolean generateDeployment() {
		f2aConfig.generateDeployment
	}

	override boolean storeDeploymentLocally() {
		f2aConfig.storeDeploymentLocally
	}

	override boolean createSeparateDeploymentFile() {
		f2aConfig.createSeparateDeploymentFile
	}

	override String getSignalPrefix() {
		f2aConfig.getSignalPrefix
	}
}
