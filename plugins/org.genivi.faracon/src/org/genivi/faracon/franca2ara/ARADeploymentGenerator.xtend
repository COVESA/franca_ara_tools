package org.genivi.faracon.franca2ara

import java.util.List
import javax.inject.Singleton
import javax.inject.Inject
import org.genivi.faracon.Franca2ARABase
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinterfacedeployment.SomeipServiceInterfaceDeployment
import autosar40.adaptiveplatform.applicationdesign.portinterface.Field
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinterfacedeployment.SomeipEventDeployment
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinstancedeployment.TransportLayerProtocolEnum
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.swcomponent.portinterface.ClientServerOperation
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FAttribute
import org.genivi.commonapi.someip.DeploymentV2.InterfacePropertyAccessor

@Singleton
class ARADeploymentGenerator extends Franca2ARABase {

	static final String SOMEIP_SUFFIX = "_Someip"
	
	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var SomeipFrancaDeploymentData someipFrancaDeploymentData
	@Inject
	var extension ARATransformationPropsGenerator
	@Inject
	var extension Franca2ARAConfigProvider

	var ARPackage deployPackage = null
		
	def create fac.createSomeipServiceInterfaceDeployment getServiceInterfaceDeployment(
		ServiceInterface aSI,
		FInterface fSI
	) {
		shortName = fSI.name + SOMEIP_SUFFIX
		serviceInterface = aSI
		fSI.deploy[ipa |
			serviceInterfaceId = ipa.getSomeIpServiceID(fSI) as long
			ARPackage = storeDeploymentLocally ? fSI.accordingInterfacePackage : getDeploymentPackage
			
			ipa.getSomeIpEventGroups(fSI)?.forEach[eg | getEventGroup(eg)]
		]
	}

	def create fac.createSomeipMethodDeployment getMethodDeployment(
		ClientServerOperation aOp,
		FMethod fMethod,
		FInterface fSI
	) {
		shortName = fMethod.name
		method = aOp
		fSI.deploy[ipa |
			methodId = ipa.getSomeIpMethodID(fMethod) as long
			transportProtocol = ipa.getSomeIpReliable(fMethod).chooseTLP
			createTrafoProps(aOp, fMethod, ipa)
		]
	}

	def create fac.createSomeipEventDeployment getEventDeployment(
		VariableDataPrototype aVDP,
		FBroadcast fBroadcast,
		FInterface fSI,
		SomeipServiceInterfaceDeployment sid
	) {
		shortName = fBroadcast.name + '_Event'
		event = aVDP
		fSI.deploy[ipa |
			eventId = ipa.getSomeIpEventID(fBroadcast) as long
			transformEventGroups(ipa.getSomeIpEventGroups(fBroadcast), sid)			
			createTrafoProps(aVDP, fBroadcast, ipa)
		]
	}

	def create fac.createSomeipFieldDeployment getFieldDeployment(
		Field aField,
		FAttribute fAttribute,
		FInterface fSI,
		SomeipServiceInterfaceDeployment sid
	) {
		val n = fAttribute.name
		shortName = n + SOMEIP_SUFFIX
		field = aField
		fSI.deploy[ipa |
			val getterID = ipa.getSomeIpGetterID(fAttribute) 
			val notifierID = ipa.getSomeIpNotifierID(fAttribute) 
			val setterID = ipa.getSomeIpSetterID(fAttribute)
			
			// the property SomeIpAttributeReliable has been introduced in CommonAPI-4
			val tp = ipa.getSomeIpAttributeReliable(fAttribute).chooseTLP
			
			if (null !== getterID) {
				get = fac.createSomeipMethodDeployment => [
					shortName = 'get' + n.toFirstUpper
					methodId = getterID as long
					transportProtocol = tp					
				]
			}
			
			if (null !== notifierID) {
				notifier = fac.createSomeipEventDeployment => [
					shortName = n + 'Notifier'
					eventId = notifierID as long
					transportProtocol = tp
					transformEventGroups(ipa.getSomeIpEventGroups(fAttribute), sid)			
				]
			}
			
			if (null !== setterID) {
				set = fac.createSomeipMethodDeployment => [
					shortName = 'set' + n.toFirstUpper
					methodId = setterID as long
					transportProtocol = tp
				]
			}

			createTrafoProps(aField, fAttribute, ipa)
		]
	}
	
	def private TransportLayerProtocolEnum chooseTLP(Boolean reliable) {
		if (reliable===null) {
			null
		} else {
			reliable ? TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
		}
	}


	def private void transformEventGroups(
		SomeipEventDeployment evDepl,
		List<Integer> someIpEventGroups,
		SomeipServiceInterfaceDeployment sid
	) {
		if (someIpEventGroups!==null) {
			for (id : someIpEventGroups) {
				sid.getEventGroup(id).events.add(evDepl)
			}
		}
	}
	
	def private create fac.createSomeipEventGroup getEventGroup(SomeipServiceInterfaceDeployment sid, long id) {
		shortName = "EventGroup_" + id
		eventGroupId = id
		sid.eventGroups.add(it)
	}


	def private deploy(FInterface fSI, (InterfacePropertyAccessor) => void func) {
		val ipa = someipFrancaDeploymentData.lookupAccessor(fSI)
		if (ipa!==null) {
			func.apply(ipa)
		} else {
			// no InterfacePropertyAccessor, silently ignore
		}
	}		

	def private getDeploymentPackage() {
		if (deployPackage===null) {
			deployPackage =
				createPackageWithName("ServiceInterfaceDeployment",
					createSeparateDeploymentFile ?
						createDeploymentRootPackage("ServiceInterfaces") :
						createRootPackage("ServiceInterfaces")
				)
		}
		deployPackage
	}
}
