package org.genivi.faracon.franca2ara

class Franca2ARAConfig2022 implements IFranca2ARAConfig {
	
	// general
	override boolean generateAdminDataLanguage() { true }

	// service interfaces
	override boolean generateOptionalFalse() { true }
	override boolean genAlwaysFireAndForget() { true }
	
	// application data types
	override boolean generateADTs() { true }	
	override boolean storeADTsLocally() { false }
	override String getADTPrefix() { "" }

	// implementation data types	
	override boolean replaceIDTPrimitiveTypeDefs() { true }
	//override boolean generateCppIDTs() { true }
	override boolean storeIDTsLocally() { false }

	// deployment
	override boolean generateDeployment() { true }
	override boolean storeDeploymentLocally() { false }
	override boolean createSeparateDeploymentFile() { true }
}
