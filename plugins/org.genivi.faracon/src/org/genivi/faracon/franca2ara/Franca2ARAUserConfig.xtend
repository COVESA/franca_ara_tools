package org.genivi.faracon.franca2ara

class Franca2ARAUserConfig implements IFranca2ARAConfig {

	var F2AConfig f2aConfig;
	var IFranca2ARAConfig f2aDefaultConfig;

	new(F2AConfig f2aConf) {
		super()
		this.f2aConfig = f2aConf
		this.f2aDefaultConfig = new Franca2ARAConfigDefault
	}

	// general
	override boolean generateAdminDataLanguage() {
		val genAdminDataLanguage = f2aConfig.generateAdminDataLanguage
		genAdminDataLanguage !== null ? genAdminDataLanguage : f2aDefaultConfig.generateAdminDataLanguage
	}

	override boolean generateAnnotations() {
		val genAnnotations = f2aConfig.generateAnnotations
		genAnnotations!== null ? genAnnotations : f2aDefaultConfig.generateAnnotations
	}

	// service interfaces
	override boolean generateOptionalFalse() {
		val genOptionalFalse = f2aConfig.generateOptionalFalse
		genOptionalFalse !== null ? genOptionalFalse : f2aDefaultConfig.generateOptionalFalse
	}

	override boolean genAlwaysFireAndForget() {
		val genAlwaysFireAndForget = f2aConfig.genAlwaysFireAndForget
		genAlwaysFireAndForget !== null ? genAlwaysFireAndForget : f2aDefaultConfig.genAlwaysFireAndForget
	}

	// application data types
	override boolean generateADTs() {
		val genADTs = f2aConfig.generateADTs
		genADTs !== null ? genADTs : f2aDefaultConfig.generateADTs
	}

	override boolean storeADTsLocally() {
		val storeADTsLocally = f2aConfig.storeADTsLocally
		storeADTsLocally !== null ? storeADTsLocally : f2aDefaultConfig.storeADTsLocally
	}

	override String getADTPrefix() {
		val adtPrefix = f2aConfig.getADTPrefix
		!adtPrefix.nullOrEmpty ? adtPrefix : f2aDefaultConfig.getADTPrefix
	}

	// implementation data types	
	override String getIDTPrefix() {
		val idtPrefix = f2aConfig.getIDTPrefix
		!idtPrefix.nullOrEmpty ? idtPrefix : f2aDefaultConfig.getIDTPrefix
	}

	override boolean replaceIDTPrimitiveTypeDefs() {
		val replaceIDTPrimitiveTypeDefs = f2aConfig.replaceIDTPrimitiveTypeDefs
		replaceIDTPrimitiveTypeDefs !== null ? replaceIDTPrimitiveTypeDefs : f2aDefaultConfig.
			replaceIDTPrimitiveTypeDefs
	}

	// override boolean generateCppIDTs() { false }
	override boolean storeIDTsLocally() {
		val storeIDTsLocally = f2aConfig.storeIDTsLocally
		storeIDTsLocally !== null ? storeIDTsLocally : f2aDefaultConfig.storeIDTsLocally
	}

	override boolean alwaysGenIDTArray() {
		val alwaysGenIDTArray = f2aConfig.alwaysGenIDTArray
		alwaysGenIDTArray !== null ? alwaysGenIDTArray : f2aDefaultConfig.alwaysGenIDTArray
	}

	override String getCompuMethodPrefix() {
		val compuMethodPrefix = f2aConfig.getCompuMethodPrefix
		!compuMethodPrefix.nullOrEmpty ? compuMethodPrefix : f2aDefaultConfig.getCompuMethodPrefix
	}

	override boolean generateStringAsArray() {
		val genStringAsArray = f2aConfig.generateStringAsArray
		genStringAsArray !== null ? genStringAsArray : f2aDefaultConfig.generateStringAsArray
	}

	override boolean useSizeAndPayloadStructs() {
		val useSizeAndPayloadStructs = f2aConfig.useSizeAndPayloadStructs
		useSizeAndPayloadStructs !== null ? useSizeAndPayloadStructs : f2aDefaultConfig.useSizeAndPayloadStructs
	}

	override boolean avoidTypeReferences() {
		val avoidTypeReferences = f2aConfig.avoidTypeReferences
		avoidTypeReferences !== null ? avoidTypeReferences : f2aDefaultConfig.avoidTypeReferences
	}
	
	override boolean skipCompoundTypeRefs() {
		val skipCompoundTypeRefs = f2aConfig.skipCompoundTypeRefs
		skipCompoundTypeRefs !== null ? skipCompoundTypeRefs : f2aDefaultConfig.skipCompoundTypeRefs
	}

	// deployment
	override boolean generateDeployment() {
		val genDeployment = f2aConfig.generateDeployment
		genDeployment !== null ? genDeployment : f2aDefaultConfig.generateDeployment
	}

	override boolean storeDeploymentLocally() {
		val storeDeploymentLocally = f2aConfig.storeDeploymentLocally
		storeDeploymentLocally !== null ? storeDeploymentLocally : f2aDefaultConfig.storeDeploymentLocally
	}

	override boolean createSeparateDeploymentFile() {
		val createSeparateDeploymentFile = f2aConfig.createSeparateDeploymentFile
		createSeparateDeploymentFile !== null ? createSeparateDeploymentFile : f2aDefaultConfig.
			createSeparateDeploymentFile
	}
}
