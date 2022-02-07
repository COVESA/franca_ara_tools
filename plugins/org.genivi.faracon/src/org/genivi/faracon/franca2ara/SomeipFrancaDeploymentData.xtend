package org.genivi.faracon.franca2ara

import com.google.inject.Singleton
import java.util.Map
import org.franca.core.franca.FInterface
import org.franca.core.franca.FTypeCollection
import org.franca.deploymodel.core.FDeployedInterface
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.genivi.commonapi.someip.DeploymentV1

@Singleton
class SomeipFrancaDeploymentData {
	
	var Map<FInterface, DeploymentV1.InterfacePropertyAccessor> interfacesDeploymentData
	var Map<FTypeCollection, DeploymentV1.TypeCollectionPropertyAccessor> typeCollectionDeploymentData

	def clear() {
		interfacesDeploymentData = newHashMap
		typeCollectionDeploymentData = newHashMap
	}

	def registerInterfaceDeployment(FInterface fInterface, FDeployedInterface deployedInterface) {
		val DeploymentV1.InterfacePropertyAccessor accessor = new DeploymentV1.InterfacePropertyAccessor(deployedInterface)
		interfacesDeploymentData.put(fInterface, accessor)
	}

	def registerTypeCollectionDeployment(FTypeCollection fTypeCollection, FDeployedTypeCollection deployedTypeCollection) {
		val DeploymentV1.TypeCollectionPropertyAccessor accessor = new DeploymentV1.TypeCollectionPropertyAccessor(deployedTypeCollection)
		typeCollectionDeploymentData.put(fTypeCollection, accessor)
	}

	def lookupAccessor(FInterface fInterface) {
		interfacesDeploymentData?.get(fInterface)
	}

	def lookupAccessor(FTypeCollection fTypeCollection) {
		typeCollectionDeploymentData?.get(fTypeCollection)
	}

}
