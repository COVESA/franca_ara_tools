package org.genivi.faracon.franca2ara

import com.google.inject.Singleton
import java.util.Map
import org.franca.core.franca.FInterface
import org.franca.core.franca.FTypeCollection
import org.franca.deploymodel.core.FDeployedInterface
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.genivi.commonapi.someip.DeploymentV2.InterfacePropertyAccessor
import org.genivi.commonapi.someip.DeploymentV2.TypeCollectionPropertyAccessor

@Singleton
class SomeipFrancaDeploymentData {
	
	var Map<FInterface, InterfacePropertyAccessor> interfacesDeploymentData
	var Map<FTypeCollection, TypeCollectionPropertyAccessor> typeCollectionDeploymentData

	def clear() {
		interfacesDeploymentData = newHashMap
		typeCollectionDeploymentData = newHashMap
	}

	def registerInterfaceDeployment(FInterface fInterface, FDeployedInterface deployedInterface) {
		val accessor = new InterfacePropertyAccessor(deployedInterface)
		interfacesDeploymentData.put(fInterface, accessor)
	}

	def registerTypeCollectionDeployment(FTypeCollection fTypeCollection, FDeployedTypeCollection deployedTypeCollection) {
		val accessor = new TypeCollectionPropertyAccessor(deployedTypeCollection)
		typeCollectionDeploymentData.put(fTypeCollection, accessor)
	}

	def lookupAccessor(FInterface fInterface) {
		interfacesDeploymentData?.get(fInterface)
	}

	def lookupAccessor(FTypeCollection fTypeCollection) {
		typeCollectionDeploymentData?.get(fTypeCollection)
	}

}
