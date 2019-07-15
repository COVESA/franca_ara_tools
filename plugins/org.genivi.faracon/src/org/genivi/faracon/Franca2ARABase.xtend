package org.genivi.faracon

import autosar40.util.Autosar40Factory
import org.genivi.faracon.logging.BaseWithLogger

class Franca2ARABase extends BaseWithLogger {
	def protected fac() {
		Autosar40Factory.eINSTANCE
	}
}