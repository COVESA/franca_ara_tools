package org.genivi.faracon

import org.franca.core.franca.FrancaFactory
import org.genivi.faracon.logging.BaseWithLogger

class ARA2FrancaBase extends BaseWithLogger {

	def protected fac() {
		FrancaFactory.eINSTANCE
	}

}