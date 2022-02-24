package org.genivi.faracon.franca2ara

class Franca2ARAConfigDefault implements IFranca2ARAConfig {
	
	// general
	override boolean generateAdminDataLanguage() { false }
	override boolean generateAnnotations() { true }

	// service interfaces
	override boolean generateOptionalFalse() { false }
	override boolean genAlwaysFireAndForget() { false }
	
	// application data types
	override boolean generateADTs() { false }	
	override boolean storeADTsLocally() { false }
	override String getADTPrefix() { "" }
	
	// implementation data types	
	override String getIDTPrefix() { "" }
	override boolean replaceIDTPrimitiveTypeDefs() { false }
	//override boolean generateCppIDTs() { false }
	override boolean storeIDTsLocally() { true }
	override boolean alwaysGenIDTArray() { false }
	override String getCompuMethodPrefix() { "" }
	override boolean generateStringAsArray() { false }
	override boolean avoidTypeReferences() { false }
	override boolean skipCompoundTypeRefs() { false }
	
	// deployment
	override boolean generateDeployment() { false }
	override boolean storeDeploymentLocally() { false }
	override boolean createSeparateDeploymentFile() { false }
}
