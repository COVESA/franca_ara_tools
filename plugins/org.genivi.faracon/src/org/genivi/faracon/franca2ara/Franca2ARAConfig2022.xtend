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
	override String getADTPrefix() { "ADT_" }

	// implementation data types	
	override String getIDTPrefix() { "IDT_" }
	override boolean replaceIDTPrimitiveTypeDefs() { true }
	//override boolean generateCppIDTs() { true }
	override boolean storeIDTsLocally() { false }
	override boolean alwaysGenIDTArray() { true }
	override String getCompuMethodPrefix() { "CM_" }
	override boolean generateStringAsArray() { true }

	// deployment
	override boolean generateDeployment() { true }
	override boolean storeDeploymentLocally() { false }
	override boolean createSeparateDeploymentFile() { true }
	override String getSignalPrefix() { "eSOME_IP_" }
}
