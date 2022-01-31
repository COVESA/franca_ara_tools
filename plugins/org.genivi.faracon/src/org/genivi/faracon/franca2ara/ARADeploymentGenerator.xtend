package org.genivi.faracon.franca2ara

import javax.inject.Singleton
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import javax.inject.Inject
import org.genivi.faracon.Franca2ARABase
import org.franca.core.franca.FInterface
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import org.franca.core.franca.FMethod
import autosar40.swcomponent.portinterface.ClientServerOperation
import org.genivi.commonapi.someip.Deployment.InterfacePropertyAccessor
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinstancedeployment.TransportLayerProtocolEnum
import org.franca.core.franca.FBroadcast
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinterfacedeployment.ServiceInterfaceDeployment
import org.franca.core.franca.FAttribute
import java.util.List
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinterfacedeployment.SomeipServiceInterfaceDeployment
import autosar40.adaptiveplatform.applicationdesign.portinterface.Field

@Singleton
class ARADeploymentGenerator extends Franca2ARABase {

	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var SomeipFrancaDeploymentData someipFrancaDeploymentData
	@Inject
	var extension Franca2ARAConfigProvider

	var ARPackage deployPackage = null
		
	def create fac.createSomeipServiceInterfaceDeployment getServiceInterfaceDeployment(ServiceInterface aSI, FInterface fSI) {
		serviceInterface = aSI
		fSI.deploy[ipa |
			serviceInterfaceId = ipa.getSomeIpServiceID(fSI) as long
			ARPackage = storeDeploymentLocally ? fSI.accordingInterfacePackage : getDeploymentPackage
		]
	}

	def create fac.createSomeipMethodDeployment getMethodDeployment(ClientServerOperation aOp, FMethod fMethod, FInterface fSI) {
		method = aOp
		fSI.deploy[ipa |
			methodId = ipa.getSomeIpMethodID(fMethod) as long
			transportProtocol = ipa.getSomeIpReliable(fMethod) == true ?
					 TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
		]
	}

	def create fac.createSomeipEventDeployment getEventDeployment(
		VariableDataPrototype aVDP, FBroadcast fBroadcast,
		FInterface fSI,
		ServiceInterfaceDeployment sid
	) {
		shortName = fBroadcast.name + '_Event'
		event = aVDP
		fSI.deploy[ipa |
			eventId = ipa.getSomeIpEventID(fBroadcast) as long
			transformEventGroups(fBroadcast, ipa, sid)			
		]
	}

	def create fac.createSomeipFieldDeployment getFieldDeployment(
		Field aField, FAttribute fAttribute,
		FInterface fSI,
		ServiceInterfaceDeployment sid
	) {
		shortName = fAttribute.name
		field = aField
		fSI.deploy[ipa |
			val getterID = ipa.getSomeIpGetterID(fAttribute) 
			val notifierID = ipa.getSomeIpNotifierID(fAttribute) 
			val setterID = ipa.getSomeIpSetterID(fAttribute)
			
			if (null !== getterID) {
				val getMethod = fac.createSomeipMethodDeployment
				getMethod.shortName = 'getter'
				getMethod.methodId = getterID as long
				getMethod.transportProtocol = ipa.getSomeIpGetterReliable(fAttribute) == true ? TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
				it.get = getMethod
			}
			
			if (null !== notifierID) {
				val notifierMethod = fac.createSomeipEventDeployment
				notifierMethod.shortName = 'notifier'
				notifierMethod.eventId = notifierID as long
				notifierMethod.transportProtocol = ipa.getSomeIpNotifierReliable(fAttribute) == true ? TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
				it.notifier = notifierMethod
			}
			
			if (null !== setterID) {
				val setMethod = fac.createSomeipMethodDeployment
				setMethod.shortName = 'setter'
				setMethod.methodId = setterID as long
				setMethod.transportProtocol = ipa.getSomeIpSetterReliable(fAttribute) == true ? TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
				it.set = setMethod
			}
//			eventId = ipa.getSomeIpEventID(fBroadcast) as long
			transformEventGroups(fAttribute, ipa, sid)			
		]
	}


	def private void transformEventGroups(FBroadcast src, InterfacePropertyAccessor ipa, ServiceInterfaceDeployment sid) {
		val someIpEventGroups = ipa.getSomeIpEventGroups(src)
		if (null !== someIpEventGroups)
			handleEVProperties(someIpEventGroups, sid)
	}
	
	def private void transformEventGroups(FAttribute src, InterfacePropertyAccessor ipa, ServiceInterfaceDeployment sid) {
		val someIpEventGroups = ipa.getSomeIpEventGroups(src)
		if (null !== someIpEventGroups)
			handleEVProperties(someIpEventGroups, sid)
	}
	
	def private void handleEVProperties(List<Integer> someIpEventGroups, ServiceInterfaceDeployment sid) {
		for (element : someIpEventGroups) {
			var eg = fac.createSomeipEventGroup()
			eg.eventGroupId = element as long
			(sid as SomeipServiceInterfaceDeployment).eventGroups.add(eg)
		}
	}


	def private deploy(FInterface fSI, (InterfacePropertyAccessor) => void func) {
		val ipa = someipFrancaDeploymentData.lookupAccessor(fSI)
		if (ipa!==null) {
			func.apply(ipa)
		} else {
			//getLogger.logError("Cannot get deployment property accessor for " + fSI.name + "!")
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
