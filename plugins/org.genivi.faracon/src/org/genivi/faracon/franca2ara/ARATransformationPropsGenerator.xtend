package org.genivi.faracon.franca2ara

import com.google.common.collect.Iterables
import java.util.Set
import javax.inject.Singleton
import javax.inject.Inject
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FMethod
import org.genivi.commonapi.someip.Deployment.InterfacePropertyAccessor
import org.genivi.commonapi.someip.Deployment.Enums.SomeIpBroadcastEndianess
import org.genivi.commonapi.someip.Deployment.Enums.SomeIpMethodEndianess
import org.genivi.commonapi.someip.Deployment.Enums.SomeIpAttributeEndianess
import org.genivi.faracon.franca2ara.types.DeploymentDataHelper
import org.genivi.faracon.Franca2ARABase
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ByteOrderEnum
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import autosar40.adaptiveplatform.applicationdesign.serializationproperties.ApSomeipTransformationProps
import autosar40.adaptiveplatform.applicationdesign.portinterface.Field
import autosar40.swcomponent.portinterface.ClientServerOperation
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable

import static extension org.franca.core.FrancaModelExtensions.*

@Singleton
class ARATransformationPropsGenerator extends Franca2ARABase {
	
	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension DeploymentDataHelper
//	@Inject
//	var SomeipFrancaDeploymentData someipFrancaDeploymentData
//	@Inject
//	var extension Franca2ARAConfigProvider

	var ARPackage trafoPropsRootPackage = null
	var ARPackage trafoProps1Package = null
	var ARPackage trafoProps2Package = null
	

	def create fac.createApSomeipTransformationProps createTrafoProps(
		ClientServerOperation aCSO,
		FMethod fMethod,
		InterfacePropertyAccessor ipa
	) {
		shortName = fMethod.shortName + "_TransformationProps"
		byteOrder = ipa.getSomeIpMethodEndianess(fMethod)===SomeIpMethodEndianess.be ? 
			ByteOrderEnum.MOST_SIGNIFICANT_BYTE_FIRST :
			ByteOrderEnum.MOST_SIGNIFICANT_BYTE_LAST
		
		val allArgs = Iterables.concat(fMethod.inArgs, fMethod.outArgs)
		val widths = allArgs.map[getArrayLengthWidth].filterNull.toSet
		setArrayLengthField("method", fMethod.name, widths)
		
		trafoPropsSet.transformationProps.add(it)
		fMethod.createMapping(aCSO, it)
	}
	
	def create fac.createApSomeipTransformationProps createTrafoProps(
		VariableDataPrototype aVDP,
		FBroadcast fBroadcast,
		InterfacePropertyAccessor ipa
	) {
		shortName = fBroadcast.shortName + "_TransformationProps"
		byteOrder = ipa.getSomeIpBroadcastEndianess(fBroadcast)===SomeIpBroadcastEndianess.be ? 
			ByteOrderEnum.MOST_SIGNIFICANT_BYTE_FIRST :
			ByteOrderEnum.MOST_SIGNIFICANT_BYTE_LAST
		
		val widths = fBroadcast.outArgs.map[getArrayLengthWidth].filterNull.toSet
		setArrayLengthField("broadcast", fBroadcast.name, widths)
		
		trafoPropsSet.transformationProps.add(it)
		fBroadcast.createMapping(aVDP, it)
	}

	def create fac.createApSomeipTransformationProps createTrafoProps(
		Field aField,
		FAttribute fAttribute,
		InterfacePropertyAccessor ipa
	) {
		shortName = fAttribute.shortName + "_TransformationProps"
		byteOrder = ipa.getSomeIpAttributeEndianess(fAttribute)===SomeIpAttributeEndianess.be ? 
			ByteOrderEnum.MOST_SIGNIFICANT_BYTE_FIRST :
			ByteOrderEnum.MOST_SIGNIFICANT_BYTE_LAST
		
		val width = fAttribute.getArrayLengthWidth
		setArrayLengthField("attribute", fAttribute.name, (width===null ? #[] : #[width]).toSet)
		
		trafoPropsSet.transformationProps.add(it)
		fAttribute.createMapping(aField, it)
	}
	
	def private setArrayLengthField(
		ApSomeipTransformationProps props,
		String type,
		String name,
		Set<Integer> widths
	) {
		if (widths.size==1) {
			props.sizeOfArrayLengthField = widths.head.longValue				
		} else if (widths.size>1) {
			logger.logError(
				"ArrayLengthField for " + type + " '" + name + "' " +
				"is not unique (" + widths.map[""+it].join(", ") + "), skipping!"
			)
		}
	}

	def private create fac.createTransformationPropsSet getTrafoPropsSet() {
		shortName = "Transformation_Properties"
		ARPackage = package1
	}
	
	def private create fac.createTransformationPropsToServiceInterfaceElementMapping createMapping(
		FModelElement fElem,
		Identifiable aElem,
		ApSomeipTransformationProps props
	) {
		shortName = fElem.shortName + "_Mapping"
		switch aElem {
			VariableDataPrototype: events.add(aElem)
			ClientServerOperation: methods.add(aElem)
			Field: fields.add(aElem)
		}
		transformationProps = props
		trafoPropsMappingsSet.mappings.add(it)
	}
	
	
	def private getShortName(FModelElement elem) {
		elem.interface.name + "_" + elem.name
	}
	
	def private create fac.createTransformationPropsToServiceInterfaceElementMappingSet getTrafoPropsMappingsSet() {
		shortName = "TransformationPropsMappingSet"
		ARPackage = package2
	}

	
	def private getPackage1() {
		if (trafoProps1Package===null) {
			trafoProps1Package = createPackageWithName("TransformationPropsSet", rootPackage)
		}
		trafoProps1Package
	}

	def private getPackage2() {
		if (trafoProps2Package===null) {
			trafoProps2Package = createPackageWithName("TransformationPropsToServiceInterfaceMappingSets", rootPackage)
		}
		trafoProps2Package
	}

	def private getRootPackage() {
		if (trafoPropsRootPackage===null) {
			trafoPropsRootPackage =
//				createSeparateDeploymentFile ?
//					createDeploymentRootPackage("TransformationProps") :
					createRootPackage("TransformationProps")
		}
		trafoPropsRootPackage
	}

}
