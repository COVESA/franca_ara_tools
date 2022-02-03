package org.genivi.faracon.franca2ara.types

import com.google.inject.Inject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FField
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.genivi.commonapi.someip.Deployment

import static extension org.franca.core.FrancaModelExtensions.*
import org.genivi.faracon.franca2ara.SomeipFrancaDeploymentData

// This helper class extracts required deployment data from the Franca deployment input models and provides it in a convenient form.
class DeploymentDataHelper {
	
	@Inject
	var SomeipFrancaDeploymentData someipFrancaDeploymentData

	// Derives from the deployment data if a given array data type or the type of a given typed model element is a fixed size array.
	def isFixedSizedArray(FModelElement fModelElement) {
		val fTypeCollection = fModelElement.typeCollection
		if (fTypeCollection !== null) {
			val Deployment.TypeCollectionPropertyAccessor typeCollectionPropertyAccessor = someipFrancaDeploymentData.lookupAccessor(fTypeCollection)
			if (typeCollectionPropertyAccessor !== null) {
				val arrayLengthWidth = typeCollectionPropertyAccessor.getArrayLengthWidth(fModelElement)
				if (arrayLengthWidth !== null) {
					if (arrayLengthWidth == 0) {
						return true
					}
				}
			}
		}
		val fInterface = fModelElement.interface
		if (fInterface !== null) {
			val Deployment.InterfacePropertyAccessor interfacePropertyAccessor = someipFrancaDeploymentData.lookupAccessor(fInterface)
			if (interfacePropertyAccessor !== null) {
				val arrayLengthWidth = interfacePropertyAccessor.getArrayLengthWidth(fModelElement)
				if (arrayLengthWidth !== null) {
					if (arrayLengthWidth == 0) {
						return true
					}
				}
			}
		}
		return false
	}

	// Extracts the size of fixed sized array type from the deployment data for a given array data type or the type of a given typed model element.
	def getArraySize(FModelElement fModelElement) {
		val fTypeCollection = fModelElement.typeCollection
		if (fTypeCollection !== null) {
			val Deployment.TypeCollectionPropertyAccessor typeCollectionPropertyAccessor = someipFrancaDeploymentData.lookupAccessor(fTypeCollection)
			if (typeCollectionPropertyAccessor !== null) {
				val arrayMaxLength = typeCollectionPropertyAccessor.getArrayMaxLength(fModelElement)
				if (arrayMaxLength !== null) {
					return arrayMaxLength
				}
			}
		}
		val fInterface = fModelElement.interface
		if (fInterface !== null) {
			val Deployment.InterfacePropertyAccessor interfacePropertyAccessor = someipFrancaDeploymentData.lookupAccessor(fInterface)
			if (interfacePropertyAccessor !== null) {
				val arrayMaxLength = interfacePropertyAccessor.getArrayMaxLength(fModelElement)
				if (arrayMaxLength !== null) {
					return arrayMaxLength
				}
			}
		}
		return 0
	}


	dispatch def getArrayLengthWidth(Deployment.TypeCollectionPropertyAccessor typeCollectionPropertyAccessor, FArrayType fArrayType) {
		typeCollectionPropertyAccessor.getSomeIpArrayLengthWidth(fArrayType)
	}
	dispatch def getArrayLengthWidth(Deployment.TypeCollectionPropertyAccessor typeCollectionPropertyAccessor, FField fField) {
		if (fField.eContainer instanceof FStructType) {
			typeCollectionPropertyAccessor.getSomeIpStructArrayLengthWidth(fField)
		} else {
			typeCollectionPropertyAccessor.getSomeIpUnionArrayLengthWidth(fField)
		}
	}

	dispatch def getArrayLengthWidth(Deployment.InterfacePropertyAccessor interfacePropertyAccessor, FArrayType fArrayType) {
		interfacePropertyAccessor.getSomeIpArrayLengthWidth(fArrayType)
	}
	dispatch def getArrayLengthWidth(Deployment.InterfacePropertyAccessor interfacePropertyAccessor, FField fField) {
		if (fField.eContainer instanceof FStructType) {
			interfacePropertyAccessor.getSomeIpStructArrayLengthWidth(fField)
		} else {
			interfacePropertyAccessor.getSomeIpUnionArrayLengthWidth(fField)
		}
	}
	dispatch def getArrayLengthWidth(Deployment.InterfacePropertyAccessor interfacePropertyAccessor, FArgument fArgument) {
		interfacePropertyAccessor.getSomeIpArgArrayLengthWidth(fArgument)
	}
	dispatch def getArrayLengthWidth(Deployment.InterfacePropertyAccessor interfacePropertyAccessor, FAttribute fAttribute) {
		interfacePropertyAccessor.getSomeIpAttrArrayLengthWidth(fAttribute)
	}

	dispatch def getArrayMaxLength(Deployment.TypeCollectionPropertyAccessor typeCollectionPropertyAccessor, FArrayType fArrayType) {
		typeCollectionPropertyAccessor.getSomeIpArrayMaxLength(fArrayType)
	}
	dispatch def getArrayMaxLength(Deployment.TypeCollectionPropertyAccessor typeCollectionPropertyAccessor, FField fField) {
		if (fField.eContainer instanceof FStructType) {
			typeCollectionPropertyAccessor.getSomeIpStructArrayMaxLength(fField)
		} else {
			typeCollectionPropertyAccessor.getSomeIpUnionArrayMaxLength(fField)
		}
	}

	dispatch def getArrayMaxLength(Deployment.InterfacePropertyAccessor interfacePropertyAccessor, FArrayType fArrayType) {
		interfacePropertyAccessor.getSomeIpArrayMaxLength(fArrayType)
	}
	dispatch def getArrayMaxLength(Deployment.InterfacePropertyAccessor interfacePropertyAccessor, FField fField) {
		if (fField.eContainer instanceof FStructType) {
			interfacePropertyAccessor.getSomeIpStructArrayMaxLength(fField)
		} else {
			interfacePropertyAccessor.getSomeIpUnionArrayMaxLength(fField)
		}
	}
	dispatch def getArrayMaxLength(Deployment.InterfacePropertyAccessor interfacePropertyAccessor, FArgument fArgument) {
		interfacePropertyAccessor.getSomeIpArgArrayMaxLength(fArgument)
	}
	dispatch def getArrayMaxLength(Deployment.InterfacePropertyAccessor interfacePropertyAccessor, FAttribute fAttribute) {
		interfacePropertyAccessor.getSomeIpAttrArrayMaxLength(fAttribute)
	}

}
