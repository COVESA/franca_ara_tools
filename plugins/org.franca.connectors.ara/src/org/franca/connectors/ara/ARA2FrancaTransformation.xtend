package org.franca.connectors.ara

import autosar40.autosartoplevelstructure.AUTOSAR
import org.franca.core.franca.FrancaFactory

class ARA2FrancaTransformation {
	
	def create fac.createFModel transform(AUTOSAR src) {
		// TODO: this just takes the first package in the arxml
		if (! src.arPackages.empty) {
			val pkg = src.arPackages.get(0)
			name = pkg.shortName
		} else {
			name = "NOT_AVAILABLE"
		}
	}
	
	def private fac() {
		FrancaFactory.eINSTANCE
	}
}
