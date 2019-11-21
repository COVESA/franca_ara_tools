package org.genivi.faracon.franca2ara

import com.google.inject.Singleton
import java.util.Map
import org.franca.core.franca.FInterface
import org.franca.core.franca.FTypeCollection
import org.franca.deploymodel.core.FDeployedInterface
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.genivi.commonapi.someip.Deployment

@Singleton
class SomeipFrancaDeploymentData {
	
	var Map<FInterface, Deployment.InterfacePropertyAccessor> interfacesDeploymentData
	var Map<FTypeCollection, Deployment.TypeCollectionPropertyAccessor> typeCollectionDeploymentData

	def clear() {
		interfacesDeploymentData = newHashMap
		typeCollectionDeploymentData = newHashMap
	}

	def registerInterfaceDeployment(FInterface fInterface, FDeployedInterface deployedInterface) {
		val Deployment.InterfacePropertyAccessor accessor = new Deployment.InterfacePropertyAccessor(deployedInterface)
		interfacesDeploymentData.put(fInterface, accessor)
	}

	def registerTypeCollectionDeployment(FTypeCollection fTypeCollection, FDeployedTypeCollection deployedTypeCollection) {
		val Deployment.TypeCollectionPropertyAccessor accessor = new Deployment.TypeCollectionPropertyAccessor(deployedTypeCollection)
		typeCollectionDeploymentData.put(fTypeCollection, accessor)
	}

	def lookupAccessor(FInterface fInterface) {
		interfacesDeploymentData?.get(fInterface)
	}

	def lookupAccessor(FTypeCollection fTypeCollection) {
		typeCollectionDeploymentData?.get(fTypeCollection)
	}

}
