package org.genivi.faracon.franca2ara.types

import com.google.inject.Inject
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FField
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FType
import org.franca.core.franca.FUnionType
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.franca2ara.SomeipFrancaDeploymentData
import org.genivi.commonapi.someip.DeploymentV2.InterfacePropertyAccessor
import org.genivi.commonapi.someip.DeploymentV2.IDataPropertyAccessor
import org.genivi.commonapi.core.DeploymentV2.Enums.EnumBackingType

import static extension org.franca.core.FrancaModelExtensions.*

/**
 * <p>Get values of SOME/IP deployment properties according to SOME/IP deployment rules.</p> 
 */
class DeploymentDataHelper {
	
	@Inject
	var SomeipFrancaDeploymentData someipFrancaDeploymentData

	def isFixedSizedArray(FModelElement elem) {
		val arrayLengthWidth = elem.getArrayLengthWidth
		arrayLengthWidth!==null && arrayLengthWidth==0
	}


	/*
	 * NOTE: The comment lines in the method implementations below were used
	 *       with DeploymentV1. With DeploymentV2, many of the specific deployment
	 *       properties were not necessary anymore.
	 * 
	 *       For supporting V1 as well as V2, we would have to somehow use the
	 *       commented out lines, therefore we do not delete them now.
	 */
	def Integer getArrayLengthWidth(FModelElement elem) {
		getDeploymentData(elem, typeof(FArrayType),
			[pa, e | pa.getSomeIpArrayLengthWidth(e)],
			[pa, e | pa.getSomeIpArrayLengthWidth(e)],
//			[pa, e | pa.getSomeIpStructArrayLengthWidth(e)],
			[pa, e | pa.getSomeIpArrayLengthWidth(e)],
//			[pa, e | pa.getSomeIpUnionArrayLengthWidth(e)],
			[pa, e | pa.getSomeIpArrayLengthWidth(e)],
//			[pa, e | pa.getSomeIpArgArrayLengthWidth(e)],
			[pa, e | pa.getSomeIpArrayLengthWidth(e)],
//			[pa, e | pa.getSomeIpAttrArrayLengthWidth(e)],
			[getArrayLengthWidth]
		)
	}

	def int getArraySize(FModelElement elem) {
		elem.getValueOrDefault([getArrayMaxLength0], 0)
	}

	def private Integer getArrayMaxLength0(FModelElement elem) {
		getDeploymentData(elem, typeof(FArrayType),
			[pa, e | pa.getSomeIpArrayMaxLength(e)],
			[pa, e | pa.getSomeIpArrayMaxLength(e)],
//			[pa, e | pa.getSomeIpStructArrayMaxLength(e)],
			[pa, e | pa.getSomeIpArrayMaxLength(e)],
//			[pa, e | pa.getSomeIpUnionArrayMaxLength(e)],
			[pa, e | pa.getSomeIpArrayMaxLength(e)],
//			[pa, e | pa.getSomeIpArgArrayMaxLength(e)],
			[pa, e | pa.getSomeIpArrayMaxLength(e)],
//			[pa, e | pa.getSomeIpAttrArrayMaxLength(e)],
			[getArrayMaxLength0]
		)
	}

//	def Long getArrayMinLength(FModelElement elem) {
//		elem.getValueOrDefault([getArrayMinLength0], 0L)
//	}

	def Integer getArrayMinLength(FModelElement elem) {
		getDeploymentData(elem, typeof(FArrayType),
			[pa, e | pa.getSomeIpArrayMinLength(e)],
			[pa, e | pa.getSomeIpArrayMinLength(e)],
//			[pa, e | pa.getSomeIpStructArrayMinLength(e)],
			[pa, e | pa.getSomeIpArrayMinLength(e)],
//			[pa, e | pa.getSomeIpUnionArrayMinLength(e)],
			[pa, e | pa.getSomeIpArrayMaxLength(e)],
//			[pa, e | pa.getSomeIpArgArrayMinLength(e)],
			[pa, e | pa.getSomeIpArrayMaxLength(e)],
//			[pa, e | pa.getSomeIpAttrArrayMinLength(e)],
			[getArrayMinLength]
		)
	}

	def Integer getStructLengthWidth(FModelElement elem) {
		getDeploymentData(elem, typeof(FStructType),
			[pa, e | pa.getSomeIpStructLengthWidth(e)],
			null,
//			[pa, e | pa.getSomeIpStructStructLengthWidth(e)],
			null,
//			[pa, e | pa.getSomeIpUnionStructLengthWidth(e)],
			null,
//			[pa, e | pa.getSomeIpArgStructLengthWidth(e)],
			null,
//			[pa, e | pa.getSomeIpAttrStructLengthWidth(e)],
			[getStructLengthWidth]
		)
	}

	def Integer getUnionLengthWidth(FModelElement elem) {
		getDeploymentData(elem, typeof(FUnionType),
			[pa, e | pa.getSomeIpUnionLengthWidth(e)],
			null,
//			[pa, e | pa.getSomeIpStructUnionLengthWidth(e)],
			null,
//			[pa, e | pa.getSomeIpUnionUnionLengthWidth(e)],
			null,
//			[pa, e | pa.getSomeIpArgUnionLengthWidth(e)],
			null,
//			[pa, e | pa.getSomeIpAttrUnionLengthWidth(e)],
			[getUnionLengthWidth]
		)
	}
	
	def Integer getUnionMaxLength(FModelElement elem) {
		getDeploymentData(elem, typeof(FUnionType),
			[pa, e | pa.getSomeIpUnionMaxLength(e)],
			null,
//			[pa, e | pa.getSomeIpStructUnionMaxLength(e)],
			null,
//			[pa, e | pa.getSomeIpUnionUnionMaxLength(e)],
			null,
//			[pa, e | pa.getSomeIpArgUnionMaxLength(e)],
			null,
//			[pa, e | pa.getSomeIpAttrUnionMaxLength(e)],
			[getUnionMaxLength]
		)
	}

	def Integer getUnionTypeWidth(FModelElement elem) {
		getDeploymentData(elem, typeof(FUnionType),
			[pa, e | pa.getSomeIpUnionTypeWidth(e)],
			null,
//			[pa, e | pa.getSomeIpStructUnionTypeWidth(e)],
			null,
//			[pa, e | pa.getSomeIpUnionUnionTypeWidth(e)],
			null,
//			[pa, e | pa.getSomeIpArgUnionTypeWidth(e)],
			null,
//			[pa, e | pa.getSomeIpAttrUnionTypeWidth(e)],
			[getUnionTypeWidth]
		)
	}

	def Boolean getUnionDefaultOrder(FModelElement elem) {
		getDeploymentData(elem, typeof(FUnionType),
			[pa, e | pa.getSomeIpUnionDefaultOrder(e)],
			null,
//			[pa, e | pa.getSomeIpStructUnionDefaultOrder(e)],
			null,
//			[pa, e | pa.getSomeIpUnionUnionDefaultOrder(e)],
			null,
//			[pa, e | pa.getSomeIpArgUnionDefaultOrder(e)],
			null,
//			[pa, e | pa.getSomeIpAttrUnionDefaultOrder(e)],
			[getUnionDefaultOrder]
		)
	}

	def Integer getEnumWidth(FModelElement elem) {
		getDeploymentData(elem, typeof(FEnumerationType),
			[pa, e | pa.getSomeIpEnumWidth(e)],
			null,
//			[pa, e | pa.getSomeIpStructEnumWidth(e)],
			null,
//			[pa, e | pa.getSomeIpUnionEnumWidth(e)],
			null,
//			[pa, e | pa.getSomeIpArgEnumWidth(e)],
			null,
//			[pa, e | pa.getSomeIpAttrEnumWidth(e)],
			[getEnumWidth]
		)
	}

	def getEnumBaseType(FModelElement elem) {
		val ebt = elem.getEnumBackingType
		if (null === ebt) {
			return FBasicTypeId.UNDEFINED
		}
		switch (ebt) {
			case UInt8: FBasicTypeId.UINT8
			case UInt16: FBasicTypeId.UINT16
			case UInt32: FBasicTypeId.UINT32
			case UInt64: FBasicTypeId.UINT64
			case Int8: FBasicTypeId.INT8
			case Int16: FBasicTypeId.INT16
			case Int32: FBasicTypeId.INT32
			case Int64: FBasicTypeId.INT64
			default: FBasicTypeId.UNDEFINED
		}
	}
	
 	def private EnumBackingType getEnumBackingType(FModelElement elem) {
		getDeploymentData(elem, typeof(FEnumerationType),
			[pa, e | pa.getEnumBackingType(e)],
			null,
//			[pa, e | pa.getEnumBackingType(e)],
			null,
//			[pa, e | pa.getEnumBackingType(e)],
			null,
//			[pa, e | pa.getEnumBackingType(e)],
			null,
//			[pa, e | pa.getEnumBackingType(e)],
			[getEnumBackingType]
		)
	}

	def FBasicTypeId convertLengthWidth(Integer lw) {
		if (lw!==null) {
			return switch (lw) {
				case 1: FBasicTypeId.UINT8
				case 2: FBasicTypeId.UINT16
				case 4: FBasicTypeId.UINT32
				case 8: FBasicTypeId.UINT64
				default: null
			}
		}
		null
	}


	/**
	 * Helper which allows to return a default, and could also do a type cast.
	 */
	def <R,T> T getValueOrDefault(FModelElement elem, (FModelElement) => R getter, T dflt) {
		val result = getter.apply(elem) as T
		result!==null ? result : dflt
	}

	
	/**
	 * <p>Retrieve SOME/IP deployment data for some Franca model element.</p>
	 * 
	 * <p>The logic being followed here is based on the pattern of the deployment
	 * properties of CommonAPI++ SOME/IP deployment. The caller has to provide a
	 * set of related deployment property accessor functions, and this method
	 * will use these in a well-defined order to get the property value which
	 * is actually valid.</p>
	 * 
	 * <p>We have to use this pattern with a lot of closures because of the
	 * specific API of PropertyAccessors generated by Franca's deployment
	 * specification generator.</p> 
	 */
	def private <T,Elem> T getDeploymentData(
		FModelElement elem,
		Class<Elem> clazz,
		(IDataPropertyAccessor, Elem) => T f1,
		(IDataPropertyAccessor, FField) => T f2,
		(IDataPropertyAccessor, FField) => T f3,
		(InterfacePropertyAccessor, FArgument) => T f4,
		(InterfacePropertyAccessor, FAttribute) => T f5,
		(FModelElement) => T recursiveCall
	) {
		processDeployment(elem,
			[dpa |
				switch elem {
					case clazz.isInstance(elem): f1.apply(dpa, elem as Elem)
					FField:
						elem.locallyOrViaType(recursiveCall,
							[
								if (elem.eContainer instanceof FStructType) {
									f2!==null ? f2.apply(dpa, elem) : null
								} else {
									f3!==null ? f3.apply(dpa, elem) : null
								}						
							]
						)
					default: null
				}
			],
			[ipa |
				switch elem {
					FArgument:
						elem.locallyOrViaType(recursiveCall, [
							f4!==null ? f4.apply(ipa, elem) : null
						])
					FAttribute:
						elem.locallyOrViaType(recursiveCall, [
							f5!==null ? f5.apply(ipa, elem) : null
						])
					default: null
				}
			]
		)
	}
	
	/**
	 * <p>Two-step process for retrieving deployment data.</p>
	 * 
	 * <p>First try to get the data from the element itself, otherwise get the data from its type.</p>
	 */
	def private <T> T locallyOrViaType(FTypedElement elem, (FModelElement) => T recursiveCall, () => T processLocally) {
		val res = processLocally===null ? null : processLocally.apply()
		(res!==null) ? res : forwardToType(elem, recursiveCall)
	}

	/**
	 * <p>Helper function which calls a function on the Franca type of a typed element.</p> 
	 */
	def private <T> T forwardToType(FTypedElement te, (FType) => T func) {
		val t = te.type.derived
		if (t===null) {
			null
		} else {
			func.apply(t)
		}	
	}
	
	/**
	 * <p>Helper function for doing short-circuit execution of two functions.</p>
	 */
//	def private <T> T chain(() => T first, () => T second) {
//		val res = first.apply()
//		(res!==null) ? res : second.apply()
//	}


	def isFixedSizedString(FTypedElement elem) {
		val stringLengthWidth = elem.getStringLengthWidth
		stringLengthWidth!==null && stringLengthWidth==0
	}

	def getStringLength(FTypedElement elem) {
		processDeployment(elem, [ ipa | ipa.getSomeIpStringLength(elem) ])		
	}

	def getStringLengthWidth(FTypedElement elem) {
		processDeployment(elem, [ ipa | ipa.getSomeIpStringLengthWidth(elem) ])		
	}

	def getStringEncoding(FTypedElement elem) {
		val enc = processDeployment(elem, [ ipa | ipa.getSomeIpStringEncoding(elem) ])
		if (enc===null) {
			return null
		}
		val mapped = switch (enc) {
			case utf8: "UTF-8"
			case utf16le: "UTF-16LE"
			case utf16be: "UTF-16BE"
			default: null
		}
		mapped
	}


	def private <T> T processDeployment(FModelElement elem, (IDataPropertyAccessor) => T func) {
		processDeployment(elem, func, [null])
	}		

	
	/**
	 * <p>Get deployment data for some Franca element by checking a sequence
	 * of deployment accessors.</p>
	 * 
	 * <p>This uses the chain-of-responsibility pattern. We have a maximum of three steps:
	 * <ul>
	 * <li>check deployment data for type collection</li>
	 * <li>check deployment data for interface, but only data-related part (e.g., arrays, struct fields)</li>
	 * <li>check deployment data for interface, real interface-related part (e.g., attributes, arguments)</li>
	 * </ul>
	 * </p>  
	 */
	def private <T> T processDeployment(
		FModelElement elem,
		(IDataPropertyAccessor) => T processDataDeployment,
		(InterfacePropertyAccessor) => T processInterfaceDeployment
	) {
		val tc = elem.typeCollection
		if (tc!==null) {
			// the model element is part of a Franca type collection
			val tcpa = someipFrancaDeploymentData.lookupAccessor(tc)
			if (tcpa!==null) {
				// we have a deployment definition for this type collection
				// process the deployment for the model element
				val ret = processDataDeployment.apply(tcpa)
				if (ret!==null) {
					return ret
				}
			}
		}
		val intf = elem.interface
		if (intf!==null) {
			// the model element is part of a Franca interface definition
			val ipa = someipFrancaDeploymentData.lookupAccessor(intf)
			if (ipa!==null) {
				// we have a deployment definition for this Franca interface
				// process the deployment for the model element	(as data deployment)			
				val ret1 = processDataDeployment.apply(ipa)
				if (ret1!==null) {
					return ret1
				}
				// no data deployment applicable, check interface deployment
				val ret2 = processInterfaceDeployment.apply(ipa)
				if (ret2!==null) {
					return ret2
				}
			}
		}
		null
	}

}
