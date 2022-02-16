package org.genivi.faracon.franca2ara

interface IFranca2ARAConfig {

	// general
	def boolean generateAdminDataLanguage()

	// service interfaces
	def boolean generateOptionalFalse()
	def boolean genAlwaysFireAndForget()
	
	// application data types
	def boolean generateADTs()	
	def boolean storeADTsLocally()
	def String getADTPrefix()

	// implementation data types	
	def String getIDTPrefix()
	def boolean replaceIDTPrimitiveTypeDefs()
	//def boolean generateCppIDTs()
	def boolean storeIDTsLocally()
	def boolean alwaysGenIDTArray()
	def String getCompuMethodPrefix()
	def boolean generateStringAsArray()
	def boolean skipCompoundTypeRefs()

	// deployment
	def boolean generateDeployment()
	def boolean storeDeploymentLocally()
	def boolean createSeparateDeploymentFile()
	def String getSignalPrefix()
}
