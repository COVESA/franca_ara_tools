package org.genivi.faracon

import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.languagedatamodel.LEnum
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.languagedatamodel.XmlSpaceEnum
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinstancedeployment.TransportLayerProtocolEnum
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinterfacedeployment.ServiceInterfaceDeployment
import autosar40.adaptiveplatform.serviceinstancemanifest.serviceinterfacedeployment.SomeipServiceInterfaceDeployment
import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import autosar40.swcomponent.portinterface.ClientServerOperation
import java.util.List
import java.util.Set
import javax.inject.Inject
import javax.inject.Singleton
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.genivi.commonapi.someip.Deployment.InterfacePropertyAccessor
import org.genivi.faracon.franca2ara.ARAConstantsCreator
import org.genivi.faracon.franca2ara.ARAModelSkeletonCreator
import org.genivi.faracon.franca2ara.ARANamespaceCreator
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.franca2ara.AutosarAnnotator
import org.genivi.faracon.franca2ara.AutosarSpecialDataGroupCreator
import org.genivi.faracon.franca2ara.SomeipFrancaDeploymentData
import org.genivi.faracon.names.NamesHierarchy

import static org.franca.core.framework.FrancaHelpers.*

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.genivi.faracon.util.FrancaUtil.*
import org.genivi.faracon.franca2ara.ARAPrimitiveTypesCreator

@Singleton
class Franca2ARATransformation extends Franca2ARABase {

	@Inject
	var extension ARAPrimitiveTypesCreator aRAPrimitveTypesCreator
	@Inject
	var extension ARATypeCreator araTypeCreator
	@Inject
	var extension ARAConstantsCreator araConstantsCreator
	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
    @Inject
	var extension ARANamespaceCreator
	@Inject
	var extension AutosarAnnotator
	@Inject
	var extension AutosarSpecialDataGroupCreator

	@Inject
	var SomeipFrancaDeploymentData someipFrancaDeploymentData

	@Inject
	NamesHierarchy namesHierarchy

	var Set<FType> allNonPrimitiveElementTypesOfAnonymousArrays

	static final String ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE = "OriginalParentInterface"
	static final String ANNOTATION_LABEL_ARTIFICIAL_EVENT_DATA_STRUCT_TYPE = "ArtificialEventDataStructType"

	def setAllNonPrimitiveElementTypesOfAnonymousArrays(Set<FType> allNonPrimitiveElementTypesOfAnonymousArrays) {
		this.allNonPrimitiveElementTypesOfAnonymousArrays = allNonPrimitiveElementTypesOfAnonymousArrays
	}

	def AUTOSAR transform(FModel src) {
		// Process the conversion.
		loadPrimitiveTypes
		
		// we are intentionally not adding the primitive types to the AUTOSAR target model
		val AUTOSAR aModel = src.createAutosarModelSkeleton		
		
		// create global AdminData
		aModel.adminData = fac().createAdminData => [
			it.language = LEnum.EN
			it.usedLanguages = fac().createMultiLanguagePlainText => [
				it.l10s.add(fac.createLPlainText => [
					it.l = LEnum.EN
					it.xmlSpace = XmlSpaceEnum.DEFAULT
				])
			]
		]
		src.interfaces.forEach[transform()]
		src.typeCollections.forEach[it.transform]

		aModel
	}
	
	def create fac.createServiceInterface transform(FInterface src) {
		if (!src.managedInterfaces.empty) {
			getLogger.logError("The manages relation(s) of interface " + src.name + " cannot be converted! (IDL1280)")
		}
		shortName = src.name
		it.initUUID(src) 
		it.addSdgForFrancaElement(src)

		val interfacePackage = src.accordingInterfacePackage
		it.ARPackage = interfacePackage
		
		// experimental code for creating SOME/IP-deployment data structures
		val ipa = someipFrancaDeploymentData.lookupAccessor(src) 
		val dp = fac.createARPackage
		dp.shortName = "THE-DEPLOYMENT"
		interfacePackage.arPackages.add(dp)
		
		val sid = fac.createSomeipServiceInterfaceDeployment
		sid.serviceInterfaceId = ipa.getSomeIpServiceID(src) as long
		dp.elements.add(sid)
		

		namespaces.addAll(interfacePackage.createNamespaceForPackage)
		events.addAll(getAllBroadcasts(src).map[it.transform(src, interfacePackage, ipa, sid)])
		fields.addAll(getAllAttributes(src).map[it.transform(src, ipa, sid)])
		methods.addAll(getAllMethods(src).map[it.transform(src, ipa, sid)])
		
		//transformEventGroups(null, ipa, ipa.getSomeIpEventGroups(src), sid)
		// Ensure that all local type definitions of the interface definition are translated
		// even if they are not referenced.
		transform(src as FTypeCollection)
	}

	def void transform(FTypeCollection fTypeCollection) {
		val types = fTypeCollection.types.map[dataTypeForReference]
		val constants = fTypeCollection.constants.map[transform]
		val accordingArPackage = fTypeCollection.accordingArPackage

		// Add the conversions of all Franca types that are defined in this type collection.
		accordingArPackage?.elements?.addAll(types)
		accordingArPackage?.elements?.addAll(constants)

		// Add the according CompuMethods for all Franca enumeration types of this type collection.
		accordingArPackage?.elements?.addAll(
			fTypeCollection.types.filter(FEnumerationType).map[createCompuMethod]
		)

		// Add artificial vector type definitions for all types of this type collection
		// which are used as element type of an anonymous array anywhere in the Franca input model.
		accordingArPackage?.elements?.addAll(
			fTypeCollection.types.filter[allNonPrimitiveElementTypesOfAnonymousArrays?.contains(it)].map [ fType |
				createArtificialVectorType(fType)
			]
		)
		if(!(fTypeCollection instanceof FInterface)){
			// in case the type collection is actually an interface the sdgs have been added already to the interface
			accordingArPackage?.addSdgForFrancaElement(fTypeCollection)
		}
	}

	// Beside the original parent interface check, the parameter 'parentInterface' is important
	// in case of emulation of interface inheritance.
	// As methods are copied to derived interfaces multiple copies of them are needed.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createClientServerOperation transform(FMethod src, FInterface parentInterface, InterfacePropertyAccessor ipa, ServiceInterfaceDeployment sid) {
		shortName = src.name
		
		it.addSdgForFrancaElement(src)

		// The flag that indicates a fire&forget method is an optional member in AUTOSAR models.
		// It can have the values {true, false, undefined}. We encode non-fire&forget methods with 'undefined'.
		// An additional command line option might give the user the choice between encoding 
		// with 'false' or 'undefined' in this case.
		if (src.fireAndForget) {
			fireAndForget = true
		}

		
		trasnformMethodDeployment(sid, it, ipa, src)

		arguments.addAll(src.inArgs.map[transform(true, parentInterface)])
		arguments.addAll(src.outArgs.map[transform(false, parentInterface)])

		// The Franca specific mechanism for the handling of method errors cannot be translated
		// because it is not compatible with the method errors mechanism of AUTOSAR,
		// at least in the serialization format of the method reply messages.
		if (src.errors !== null || src.errorEnum !== null) {
			getLogger.logError(
				"The error enumeration of the method '" + src.name + "' in the namespace '" + src.model.name + '.' +
					src.interface + "' cannot be translated into an AUTOSAR representation. " +
					"At least the SOME/IP serialization formats would be incompatible. " +
					"Implement your method error reporting based on user defined types instead!")
		}

		// If the method is not a direct member of the current interface definition but is inherited from
		// a direct or indirect base interface the original interface where it comes from is annotated.
		// As interface inheritance cannot be directly mapped to an AUTOSAR representation
		// this annotation provides the required information to reconstruct the original Franca model
		// uniquely from the AUTOSAR model.
		val FInterface originalParentInterface = src.getInterface
		if (parentInterface !== originalParentInterface) {
			it.addAnnotation(ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE,
				originalParentInterface.getARFullyQualifiedName)
		}
	}
	
	protected def void trasnformMethodDeployment(ServiceInterfaceDeployment sid, ClientServerOperation it, InterfacePropertyAccessor ipa, FMethod src) {
		val md = fac.createSomeipMethodDeployment
		sid.methodDeployments.add(md)
		md.method = it
		md.methodId = ipa.getSomeIpMethodID(src) as long
		md.transportProtocol = ipa.getSomeIpReliable(src) == Boolean.TRUE ? TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
	}

	// The parameter 'parentInterface' is important in case of emulation of interface inheritance.
	// As methods are copied to derived interfaces multiple copies of the method arguments are needed as well.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createArgumentDataPrototype transform(FArgument arg, boolean isIn, FInterface parentInterface) {
		shortName = arg.name
		it.addSdgForFrancaElement(arg)
		// category = xxx
		type = createDataTypeReference(arg.type, arg)
		direction = if(isIn) ArgumentDirectionEnum.IN else ArgumentDirectionEnum.OUT
	}

	// Beside the original parent interface check, the parameter 'parentInterface' is important
	// in case of emulation of interface inheritance.
	// As attributes are copied to derived interfaces multiple copies of them are needed.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createField transform(FAttribute src, FInterface parentInterface, InterfacePropertyAccessor ipa, ServiceInterfaceDeployment sid) {
		shortName = src.name
		it.addSdgForFrancaElement(src)
		type = src.type.createDataTypeReference(src)
		hasGetter = !src.noRead
		hasNotifier = !src.noSubscriptions
		hasSetter = !src.readonly
		
		// Converting Field deployment data
		transformAttrFieldDeployment(sid, src, ipa)	
		transformEventGroups(src, ipa, sid)
		
		
		// If the attribute is not a direct member of the current interface definition but is inherited from
		// a direct or indirect base interface the original interface where it comes from is annotated.
		// As interface inheritance cannot be directly mapped to an AUTOSAR representation
		// this annotation provides the required information to reconstruct the original Franca model
		// uniquely from the AUTOSAR model.
		val FInterface originalParentInterface = src.interface
		if (parentInterface !== originalParentInterface) {
			it.addAnnotation(ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE,
				originalParentInterface.getARFullyQualifiedName)
		}
	}
	
	protected def void transformAttrFieldDeployment(ServiceInterfaceDeployment sid, FAttribute src, InterfacePropertyAccessor ipa) {
		val fieldDeployment = fac.createSomeipFieldDeployment
		sid.fieldDeployments.add(fieldDeployment)
		fieldDeployment.shortName = src.name
		val getterID = ipa.getSomeIpGetterID(src) 
		val notifierID = ipa.getSomeIpNotifierID(src) 
		val setterID = ipa.getSomeIpSetterID(src)
		
		if(null !== getterID){
		val getMethod = fac.createSomeipMethodDeployment
		getMethod.shortName = 'getter'
		getMethod.methodId = getterID as long
		getMethod.transportProtocol = ipa.getSomeIpGetterReliable(src) == Boolean.TRUE ? TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
		fieldDeployment.get = getMethod
		}
		
		if(null !== notifierID){
		val notifierMethod = fac.createSomeipEventDeployment
		notifierMethod.shortName = 'notifier'
		notifierMethod.eventId = notifierID as long
		notifierMethod.transportProtocol = ipa.getSomeIpNotifierReliable(src) == Boolean.TRUE ? TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
		fieldDeployment.notifier = notifierMethod
		}
		
		if(null !== setterID){
		val setMethod = fac.createSomeipMethodDeployment
		setMethod.shortName = 'setter'
		setMethod.methodId = setterID as long
		setMethod.transportProtocol = ipa.getSomeIpSetterReliable(src) == Boolean.TRUE ? TransportLayerProtocolEnum.TCP : TransportLayerProtocolEnum.UDP
		fieldDeployment.set = setMethod
		}
	}

	// Beside the original parent interface check, the parameter 'parentInterface' is important
	// in case of emulation of interface inheritance.
	// As broadcasts are copied to derived interfaces multiple copies of them are needed.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createVariableDataPrototype transform(FBroadcast src, FInterface parentInterface,
		ARPackage interfaceArPackage, InterfacePropertyAccessor ipa, ServiceInterfaceDeployment sid) {
		shortName = src.name
		it.initUUID(src)
		
		it.addSdgForFrancaElement(src)
		
		// Converting Field deployment data
		val eventDeployment = fac.createSomeipEventDeployment
		sid.eventDeployments.add(eventDeployment)
		eventDeployment.shortName = src.name + '_Event'
		eventDeployment.eventId = ipa.getSomeIpEventID(src) as long
		
		transformEventGroups(src, ipa, sid)
		
		
		type = if (src?.outArgs.length == 1) {
			src.outArgs.get(0).type.createDataTypeReference(src.outArgs.get(0))
		} else {
			val ImplementationDataType artificialBroadcastStruct = fac.createImplementationDataType
			artificialBroadcastStruct.shortName = namesHierarchy.createAndInsertUniqueName(
				parentInterface.francaFullyQualifiedName,
				src.name.toFirstUpper + "Data",
				FType
			)
			artificialBroadcastStruct.category = "STRUCTURE"
			val typeRefs = src.outArgs.map [
				it.createImplementationDataTypeElement(null)
			]
			artificialBroadcastStruct.subElements.addAll(typeRefs)
			artificialBroadcastStruct.ARPackage = interfaceArPackage
			artificialBroadcastStruct.addAnnotation(
				ANNOTATION_LABEL_ARTIFICIAL_EVENT_DATA_STRUCT_TYPE,
				"Referencing event definition: " + src.getARFullyQualifiedName
			)
			interfaceArPackage.elements += artificialBroadcastStruct
			artificialBroadcastStruct
		}

		// If the broadcast is not a direct member of the current interface definition but is inherited from
		// a direct or indirect base interface the original interface where it comes from is annotated.
		// As interface inheritance cannot be directly mapped to an AUTOSAR representation
		// this annotation provides the required information to reconstruct the original Franca model
		// uniquely from the AUTOSAR model.
		val FInterface originalParentInterface = src.interface
		if (parentInterface !== originalParentInterface) {
			it.addAnnotation(ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE,
				originalParentInterface.getARFullyQualifiedName)
		}

		// Selective broadcasts are not representable in an AUTOSAR model.
		if (src.selective) {
			getLogger.logError("The broadcast '" + originalParentInterface.name + "." + src.name +
				"' cannot be properly converted because selective broadcasts are not representable in an AUTOSAR model! (IDL1390)")
		}

		// Broadcast selectors are not representable in an AUTOSAR model.
		if (!src.selector.isNullOrEmpty) {
			getLogger.logError("The broadcast '" + originalParentInterface.name + "." + src.name +
				"' cannot be properly converted because broadcast selectors are not representable in an AUTOSAR model! (IDL1400)")
		}
	}
	
	protected def void transformEventGroups(FBroadcast src, InterfacePropertyAccessor ipa, ServiceInterfaceDeployment sid) {
		val someIpEventGroups = ipa.getSomeIpEventGroups(src)
		if(null !== someIpEventGroups)
		handleEVProperties(someIpEventGroups, sid)
	}
	
	protected def void transformEventGroups(FAttribute src, InterfacePropertyAccessor ipa, ServiceInterfaceDeployment sid) {
		val someIpEventGroups = ipa.getSomeIpEventGroups(src)
		if(null !== someIpEventGroups)
		handleEVProperties(someIpEventGroups, sid)
	}
	
	protected def void handleEVProperties(List<Integer> someIpEventGroups, ServiceInterfaceDeployment sid) {
		for (element : someIpEventGroups) {
			var eg = fac.createSomeipEventGroup()
			eg.eventGroupId = element as long
			(sid as SomeipServiceInterfaceDeployment).eventGroups.add(eg)
		}
	}

	static def String getARFullyQualifiedName(FInterface ^interface) {
		val FModel model = ^interface.getModel;
		(if(!model?.name.nullOrEmpty) "/" + model.name.replace('.', '/') else "") + "/" + ^interface?.name
	}

	static def String getARFullyQualifiedName(FBroadcast broadcast) {
		(broadcast.eContainer as FInterface).getARFullyQualifiedName + "/" + broadcast.name
	}

}
