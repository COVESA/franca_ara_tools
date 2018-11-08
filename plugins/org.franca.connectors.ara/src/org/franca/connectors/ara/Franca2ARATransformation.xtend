package org.franca.connectors.ara

import autosar40.util.Autosar40Factory
import org.franca.core.franca.FArgument
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum

class Franca2ARATransformation {

	def create fac.createAUTOSAR transform(FModel src) {
		val segments = src.name.split(".")
		val pkg = fac.createARPackage => [ shortName = (if (segments==null) segments.get(0) else src.name) ]
		arPackages.add(pkg)
		
		pkg.elements.addAll(src.interfaces.map[transform])
	}
	
	def create fac.createServiceInterface transform(FInterface src) {
		shortName = src.name
		methods.addAll(src.methods.map[transform])
	}
	
	def create fac.createClientServerOperation transform(FMethod src) {
		shortName = src.name
		arguments.addAll(src.inArgs.map[transform(true)])
		arguments.addAll(src.outArgs.map[transform(false)])
	}
	
	def create fac.createArgumentDataPrototype transform(FArgument arg, boolean isIn) {
		shortName = arg.name
		//category = xxx
		//type = ttt
		direction = if (isIn) ArgumentDirectionEnum.IN else ArgumentDirectionEnum.OUT
	}
	
	def private fac() {
		Autosar40Factory.eINSTANCE
	}
}
