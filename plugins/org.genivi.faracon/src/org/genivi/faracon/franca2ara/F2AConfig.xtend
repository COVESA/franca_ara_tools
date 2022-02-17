package org.genivi.faracon.franca2ara

class F2AConfig {

	new(Boolean generateAdminDataLanguage, Boolean generateAnnotations,
		Boolean generateOptionalFalse, Boolean genAlwaysFireAndForget,
		Boolean generateADTs, Boolean storeADTsLocally, String getADTPrefix, String getIDTPrefix,
		Boolean replaceIDTPrimitiveTypeDefs, Boolean storeIDTsLocally, Boolean alwaysGenIDTArray,
		String getCompuMethodPrefix, Boolean generateStringAsArray,
		Boolean avoidTypeRefs, Boolean skipCompoundTypeRefs,
		Boolean generateDeployment, Boolean storeDeploymentLocally,
		Boolean createSeparateDeploymentFile, String getSignalPrefix
	) {
		super()
		this.generateAdminDataLanguage = generateAdminDataLanguage
		this.generateAnnotations = generateAnnotations
		this.generateOptionalFalse = generateOptionalFalse
		this.genAlwaysFireAndForget = genAlwaysFireAndForget
		this.generateADTs = generateADTs
		this.storeADTsLocally = storeADTsLocally
		this.getADTPrefix = getADTPrefix
		this.getIDTPrefix = getIDTPrefix
		this.replaceIDTPrimitiveTypeDefs = replaceIDTPrimitiveTypeDefs
		this.storeIDTsLocally = storeIDTsLocally
		this.alwaysGenIDTArray = alwaysGenIDTArray
		this.getCompuMethodPrefix = getCompuMethodPrefix
		this.generateStringAsArray = generateStringAsArray
		this.avoidTypeRefs = avoidTypeRefs
		this.skipCompoundTypeRefs = skipCompoundTypeRefs
		this.generateDeployment = generateDeployment
		this.storeDeploymentLocally = storeDeploymentLocally
		this.createSeparateDeploymentFile = createSeparateDeploymentFile
		this.getSignalPrefix = getSignalPrefix
	}

	// general
	Boolean generateAdminDataLanguage
	Boolean generateAnnotations

	// service interfaces
	Boolean generateOptionalFalse
	Boolean genAlwaysFireAndForget

	// application data types
	Boolean generateADTs
	Boolean storeADTsLocally
	String getADTPrefix

	// implementation data types	
	String getIDTPrefix
	Boolean replaceIDTPrimitiveTypeDefs

	// Boolean generateCppIDTs() { false }
	Boolean storeIDTsLocally
	Boolean alwaysGenIDTArray
	String getCompuMethodPrefix
	Boolean generateStringAsArray
	Boolean avoidTypeRefs
	Boolean skipCompoundTypeRefs

	// deployment
	Boolean generateDeployment
	Boolean storeDeploymentLocally
	Boolean createSeparateDeploymentFile
	String getSignalPrefix

	def Boolean isGenerateAdminDataLanguage() {
		return generateAdminDataLanguage
	}
	
	def Boolean isGenerateAnnotations() {
		return generateAnnotations
	}

	def Boolean isGenerateOptionalFalse() {
		return generateOptionalFalse
	}

	def Boolean isGenAlwaysFireAndForget() {
		return genAlwaysFireAndForget
	}

	def Boolean isGenerateADTs() {
		return generateADTs
	}

	def Boolean isStoreADTsLocally() {
		return storeADTsLocally
	}

	def String getGetADTPrefix() {
		return getADTPrefix
	}

	def String getGetIDTPrefix() {
		return getIDTPrefix
	}

	def Boolean isReplaceIDTPrimitiveTypeDefs() {
		return replaceIDTPrimitiveTypeDefs
	}

	def Boolean isStoreIDTsLocally() {
		return storeIDTsLocally
	}

	def Boolean isAlwaysGenIDTArray() {
		return alwaysGenIDTArray
	}

	def String getGetCompuMethodPrefix() {
		return getCompuMethodPrefix
	}

	def Boolean isGenerateStringAsArray() {
		return generateStringAsArray
	}
	
	def Boolean avoidTypeReferences() {
		return avoidTypeRefs
	}
	
	def Boolean isSkipCompoundTypeRefs() {
		return skipCompoundTypeRefs
	}

	def Boolean isGenerateDeployment() {
		return generateDeployment
	}

	def Boolean isStoreDeploymentLocally() {
		return storeDeploymentLocally
	}

	def Boolean isCreateSeparateDeploymentFile() {
		return createSeparateDeploymentFile
	}

	def String getGetSignalPrefix() {
		return getSignalPrefix
	}
}
