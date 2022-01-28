package org.genivi.faracon.franca2ara

import javax.inject.Singleton

@Singleton
class Franca2ARAConfiguration {

	def boolean generateADTs() { true }
	
	def boolean storeADTsLocally() { false }
	
	def String getADTPrefix() { "" }
	
	def boolean genAlwaysFireAndForget() { true }
}
