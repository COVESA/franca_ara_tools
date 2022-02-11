package org.genivi.faracon.franca2ara

class Franca2ARAConfigDefault implements IFranca2ARAConfig {

	var F2AConfig f2aConfig = new F2AConfig();

	new() {
		super()
	}

	new(F2AConfig f2aConf) {
		super()
		this.f2aConfig = f2aConf
	}

	// general
	override boolean generateAdminDataLanguage() {
		val genAdminDataLanguage = f2aConfig.generateAdminDataLanguage
		genAdminDataLanguage !== null ? genAdminDataLanguage : false
	}

	// service interfaces
	override boolean generateOptionalFalse() {
		val genOptionalFalse = f2aConfig.generateOptionalFalse
		genOptionalFalse !== null ? genOptionalFalse : false
	}

	override boolean genAlwaysFireAndForget() {
		val genAlwaysFireAndForget = f2aConfig.genAlwaysFireAndForget
		genAlwaysFireAndForget !== null ? genAlwaysFireAndForget : false
	}

	// application data types
	override boolean generateADTs() {
		val genADTs = f2aConfig.generateADTs
		genADTs !== null ? genADTs : false
	}

	override boolean storeADTsLocally() {
		val storeADTsLocally = f2aConfig.storeADTsLocally
		storeADTsLocally !== null ? storeADTsLocally : false
	}

	override String getADTPrefix() {
		val adtPrefix = f2aConfig.getADTPrefix
		!adtPrefix.nullOrEmpty ? adtPrefix : ""
	}

	// implementation data types	
	override String getIDTPrefix() {
		val idtPrefix = f2aConfig.getIDTPrefix
		!idtPrefix.nullOrEmpty ? idtPrefix : ""
	}

	override boolean replaceIDTPrimitiveTypeDefs() {
		val replaceIDTPrimitiveTypeDefs = f2aConfig.replaceIDTPrimitiveTypeDefs
		replaceIDTPrimitiveTypeDefs !== null ? replaceIDTPrimitiveTypeDefs : false
	}

	// override boolean generateCppIDTs() { false }
	override boolean storeIDTsLocally() {
		val storeIDTsLocally = f2aConfig.storeIDTsLocally
		storeIDTsLocally !== null ? storeIDTsLocally : true
	}

	override boolean alwaysGenIDTArray() {
		val alwaysGenIDTArray = f2aConfig.alwaysGenIDTArray
		alwaysGenIDTArray !== null ? alwaysGenIDTArray : false
	}

	override String getCompuMethodPrefix() {
		val compuMethodPrefix = f2aConfig.getCompuMethodPrefix
		!compuMethodPrefix.nullOrEmpty ? compuMethodPrefix : ""
	}

	override boolean generateStringAsArray() {
		val genStringAsArray = f2aConfig.generateStringAsArray
		genStringAsArray !== null ? genStringAsArray : false
	}

	// deployment
	override boolean generateDeployment() {
		val genDeployment = f2aConfig.generateDeployment
		genDeployment !== null ? genDeployment : false
	}

	override boolean storeDeploymentLocally() {
		val storeDeploymentLocally = f2aConfig.storeDeploymentLocally
		storeDeploymentLocally !== null ? storeDeploymentLocally : false
	}

	override boolean createSeparateDeploymentFile() {
		val createSeparateDeploymentFile = f2aConfig.createSeparateDeploymentFile
		createSeparateDeploymentFile !== null ? createSeparateDeploymentFile : false
	}

	override String getSignalPrefix() {
		val signalPrefix = f2aConfig.getSignalPrefix
		!signalPrefix.nullOrEmpty ? signalPrefix : ""
	}
}
