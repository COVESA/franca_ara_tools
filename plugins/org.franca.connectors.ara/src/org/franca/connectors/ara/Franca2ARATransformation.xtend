package org.franca.connectors.ara

import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import com.google.inject.Guice
import javax.inject.Inject
import org.franca.connectors.ara.franca2ara.ARAPackageCreator
import org.franca.connectors.ara.franca2ara.ARAPrimitveTypesCreator
import org.franca.connectors.ara.franca2ara.ARATypeCreator
import org.franca.core.franca.FArgument
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel

class Franca2ARATransformation extends Franca2ARABase {

	@Inject
	private var extension ARAPrimitveTypesCreator aRAPrimitveTypesCreator
	@Inject 
	private var extension ARATypeCreator araTypeCreator
	@Inject
	private var extension ARAPackageCreator araPackageCreator

	new(){
		Guice.createInjector.injectMembers(this)
	}

	def create fac.createAUTOSAR transform(FModel src) {
		arPackages.add(createPrimitiveTypesPackage)
		val pkg = src.createPackage
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
		type = createDataTypeReference(arg.type)
		direction = if (isIn) ArgumentDirectionEnum.IN else ArgumentDirectionEnum.OUT
	}
	
}
