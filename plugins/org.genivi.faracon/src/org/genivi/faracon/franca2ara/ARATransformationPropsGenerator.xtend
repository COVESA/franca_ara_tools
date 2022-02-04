package org.genivi.faracon.franca2ara

import javax.inject.Singleton
import javax.inject.Inject
import org.franca.core.franca.FBroadcast
import org.genivi.faracon.Franca2ARABase
import org.genivi.commonapi.someip.Deployment.InterfacePropertyAccessor
import org.genivi.commonapi.someip.Deployment.Enums.SomeIpBroadcastEndianess
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ByteOrderEnum
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import autosar40.adaptiveplatform.applicationdesign.serializationproperties.ApSomeipTransformationProps

import static extension org.franca.core.FrancaModelExtensions.*
import org.genivi.faracon.franca2ara.types.DeploymentDataHelper

@Singleton
class ARATransformationPropsGenerator extends Franca2ARABase {
	
	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension DeploymentDataHelper
	@Inject
	var SomeipFrancaDeploymentData someipFrancaDeploymentData
	@Inject
	var extension Franca2ARAConfigProvider

	var ARPackage trafoPropsRootPackage = null
	var ARPackage trafoProps1Package = null
	var ARPackage trafoProps2Package = null
	

	def create fac.createApSomeipTransformationProps createTrafoProps(
		VariableDataPrototype aVDP,
		FBroadcast fBroadcast,
		InterfacePropertyAccessor ipa
	) {
		shortName = fBroadcast.name + "TransformationProps"
		byteOrder = ipa.getSomeIpBroadcastEndianess(fBroadcast).getByteOrder
		
		val widths = fBroadcast.outArgs.map[getArrayLengthWidth].filterNull.toSet
		if (widths.size==1) {
			sizeOfArrayLengthField = widths.head.longValue				
		} else if (widths.size>1) {
			logger.logError("ArrayLengthField for broadcast '" + fBroadcast.name + "' is not unique, skipping!")
		}
		
		trafoPropsSet.transformationProps.add(it)
		aVDP.createMapping(fBroadcast, it)
	}

	def private getByteOrder(SomeIpBroadcastEndianess e) {
		e===SomeIpBroadcastEndianess.be ? 
			ByteOrderEnum.MOST_SIGNIFICANT_BYTE_FIRST :
			ByteOrderEnum.MOST_SIGNIFICANT_BYTE_LAST
	}
	
	def create fac.createTransformationPropsSet getTrafoPropsSet() {
		shortName = "Transformation_Properties"
		ARPackage = package1
	}
	
	def create fac.createTransformationPropsToServiceInterfaceElementMapping createMapping(
		VariableDataPrototype aVDP,
		FBroadcast fBroadcast,
		ApSomeipTransformationProps props
	) {
		shortName = fBroadcast.interface.name + "_" + fBroadcast.name + "_Mapping"
		events.add(aVDP)
		transformationProps = props
		trafoPropsMappingsSet.mappings.add(it)
	}
	
	def create fac.createTransformationPropsToServiceInterfaceElementMappingSet getTrafoPropsMappingsSet() {
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
