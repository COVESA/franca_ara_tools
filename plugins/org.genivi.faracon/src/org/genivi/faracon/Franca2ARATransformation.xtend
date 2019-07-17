package org.genivi.faracon

import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import javax.inject.Inject
import javax.inject.Singleton
import org.genivi.faracon.franca2ara.ARANamespaceCreator
import org.genivi.faracon.franca2ara.ARAPackageCreator
import org.genivi.faracon.franca2ara.ARAPrimitveTypesCreator
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel

@Singleton
class Franca2ARATransformation extends Franca2ARABase {

	@Inject
	private var extension ARAPrimitveTypesCreator aRAPrimitveTypesCreator
	@Inject 
	private var extension ARATypeCreator araTypeCreator
	@Inject
	private var extension ARAPackageCreator araPackageCreator
	@Inject
	private var extension ARANamespaceCreator

	def create fac.createAUTOSAR transform(FModel src) {
		createPrimitiveTypesPackage(null)
		// we are intentionally not adding the primitive types to the AUTOSAR target model
		// arPackages.add(createPrimitiveTypesPackage)
		val elementPackage = src.createPackageHierarchyForElementPackage(it)
		elementPackage.elements.addAll(src.interfaces.map[transform(elementPackage)])
	}
	
	def create fac.createServiceInterface transform(FInterface src, ARPackage targetPackage) {
		if (!src.managedInterfaces.empty) {
			getLogger.logError("The manages relation(s) of interface " + src.name + " cannot be converted!")
		}
		shortName = src.name
		events.addAll(src.broadcasts.map[transform])
		fields.addAll(src.attributes.map[transform])
		namespaces.addAll(targetPackage.createNamespaceForPackage)
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
		type = createDataTypeReference(arg.type, arg)
		direction = if (isIn) ArgumentDirectionEnum.IN else ArgumentDirectionEnum.OUT
	}
	
	def create fac.createField transform(FAttribute src) {
		shortName = src.name
		type = src.type.createDataTypeReference(src)
		hasGetter = !src.noRead
		hasNotifier = !src.noSubscriptions
		hasSetter = !src.readonly
	}
	
	def create fac.createVariableDataPrototype transform(FBroadcast src) {
		shortName = src.name
		if (!src.outArgs.empty) {
			type = src.outArgs.get(0).type.createDataTypeReference(src.outArgs.get(0))
		}
	}
	
}
