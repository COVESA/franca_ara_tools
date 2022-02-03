package org.genivi.faracon.franca2ara

import org.genivi.faracon.franca2ara.IFranca2ARAConfig

import javax.inject.Singleton

@Singleton
class Franca2ARAConfigProvider implements IFranca2ARAConfig {
	
	val config =
		//new Franca2ARAConfigDefault
		new Franca2ARAConfig2022
		//new Franca2ARAConfig2022_navigator

	// general
	override boolean generateAdminDataLanguage() {
		config.generateAdminDataLanguage
	}

	// service interfaces
	override boolean generateOptionalFalse() {
		config.generateOptionalFalse
	}
	override boolean genAlwaysFireAndForget() {
		config.genAlwaysFireAndForget
	}
	
	// application data types
	override boolean generateADTs() {
		config.generateADTs
	}
	override boolean storeADTsLocally() {
		config.storeADTsLocally
	}
	override String getADTPrefix() {
		config.getADTPrefix
	}

	// implementation data types	
	override boolean replaceIDTPrimitiveTypeDefs() {
		config.replaceIDTPrimitiveTypeDefs
	}
	//override boolean generateCppIDTs() {
	//	config.generateCppIDTs
	//}
	override boolean storeIDTsLocally() {
		config.storeIDTsLocally
	}
	override boolean alwaysGenIDTArray() {
		config.alwaysGenIDTArray
	}

	// deployment
	override boolean generateDeployment() {
		config.generateDeployment
	}
	override boolean storeDeploymentLocally() {
		config.storeDeploymentLocally
	}
	override boolean createSeparateDeploymentFile() {
		config.createSeparateDeploymentFile
	}

}

