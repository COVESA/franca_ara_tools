package org.genivi.faracon.franca2ara.types

import com.google.inject.Inject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FField
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FTypedElement
import org.genivi.commonapi.someip.Deployment

import static extension org.franca.core.FrancaModelExtensions.*
import org.genivi.faracon.franca2ara.SomeipFrancaDeploymentData
import org.genivi.commonapi.someip.Deployment.TypeCollectionPropertyAccessor
import org.genivi.commonapi.someip.Deployment.InterfacePropertyAccessor
import org.genivi.commonapi.someip.Deployment.IDataPropertyAccessor

// This helper class extracts required deployment data from the Franca deployment input models and provides it in a convenient form.
class DeploymentDataHelper {
	
	@Inject
	var SomeipFrancaDeploymentData someipFrancaDeploymentData

	// Derives from the deployment data if a given array data type or the type of a given typed model element is a fixed size array.
	def isFixedSizedArray(FModelElement elem) {
		val arrayLengthWidth = elem.getArrayLengthWidth
		arrayLengthWidth!==null && arrayLengthWidth==0
	}

	// Extracts the size of fixed sized array type from the deployment data for a given array data type or the type of a given typed model element.
	def getArraySize(FModelElement elem) {
		val arrayMaxLength = elem.getArrayMaxLength
		arrayMaxLength!==null ? arrayMaxLength : 0
	}
	

	def Integer getArrayLengthWidth(FModelElement elem) {
		deploy(elem,
			[dpa |
				switch elem {
					FArrayType: dpa.getSomeIpArrayLengthWidth(elem)
					FField: chain([
						if (elem.eContainer instanceof FStructType) {
							dpa.getSomeIpStructArrayLengthWidth(elem)
						} else {
							dpa.getSomeIpUnionArrayLengthWidth(elem)
						}						
					], [
						forwardToType(elem, [getArrayLengthWidth])
					])
					default: null
				}
			],
			[ipa |
				switch elem {
					FArgument: ipa.getSomeIpArgArrayLengthWidth(elem)
					FAttribute: ipa.getSomeIpAttrArrayLengthWidth(elem)
					default: null
				} 
			]
		)
	}
		
	def Integer getArrayMaxLength(FModelElement elem) {
		deploy(elem,
			[dpa |
				switch elem {
					FArrayType: dpa.getSomeIpArrayMaxLength(elem)
					FField: chain([
						if (elem.eContainer instanceof FStructType) {
							dpa.getSomeIpStructArrayMaxLength(elem)
						} else {
							dpa.getSomeIpUnionArrayMaxLength(elem)
						}						
					], [
						forwardToType(elem, [getArrayLengthWidth])
					])
					default: null
				}
			],
			[ipa |
				switch elem {
					FArgument: ipa.getSomeIpArgArrayMaxLength(elem)
					FAttribute: ipa.getSomeIpAttrArrayMaxLength(elem)
					default: null
				} 
			]
		)
	}
		
	
	
	def private <T> T forwardToType(FTypedElement te, (FModelElement) => T func) {
		val t = te.type.derived
		if (t===null) {
			null
		} else {
			func.apply(t)
		}
		
	}
	
	def private <T> T chain(() => T first, () => T second) {
		val res = first.apply()
		(res!==null) ? res : second.apply()
	}
	
	def private <T> T deploy(
		FModelElement elem,
		(IDataPropertyAccessor) => T func1,
		(InterfacePropertyAccessor) => T func2
	) {
		val tc = elem.typeCollection
		if (tc!==null) {
			val tcpa = someipFrancaDeploymentData.lookupAccessor(tc)
			if (tcpa!==null) {
				val ret = func1.apply(tcpa)
				if (ret!==null) {
					return ret
				}
			}
		}
		val intf = elem.interface
		if (intf!==null) {
			val ipa = someipFrancaDeploymentData.lookupAccessor(intf)
			if (ipa!==null) {
				val ret1 = func1.apply(ipa)
				if (ret1!==null) {
					return ret1
				}
				val ret2 = func2.apply(ipa)
				if (ret2!==null) {
					return ret2
				}
			}
		}
		null
	}

}
