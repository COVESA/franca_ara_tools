package org.genivi.faracon

import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.languagedatamodel.LEnum
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.languagedatamodel.XmlSpaceEnum
import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import autosar40.swcomponent.datatype.datatypes.ApplicationDataType
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
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
import org.genivi.faracon.franca2ara.ARAConstantsCreator
import org.genivi.faracon.franca2ara.ARAModelSkeletonCreator
import org.genivi.faracon.franca2ara.ARANamespaceCreator
import org.genivi.faracon.franca2ara.AutosarAnnotator
import org.genivi.faracon.franca2ara.AutosarSpecialDataGroupCreator
import org.genivi.faracon.names.NamesHierarchy

import org.genivi.faracon.franca2ara.types.ARATypeCreator
import org.genivi.faracon.franca2ara.types.ApplDataTypeManager
import org.genivi.faracon.franca2ara.types.ARAPrimitiveTypesCreator
import org.genivi.faracon.franca2ara.types.ARAImplDataTypeCreator
import org.genivi.faracon.franca2ara.config.Franca2ARAConfigProvider
import org.genivi.faracon.franca2ara.ARADeploymentGenerator

import static org.franca.core.framework.FrancaHelpers.*

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.genivi.faracon.util.FrancaUtil.*
import org.franca.core.franca.FModelElement
import org.genivi.faracon.franca2ara.ARATransformationPropsGenerator
import org.franca.core.franca.FTypedElement

@Singleton
class Franca2ARATransformation extends Franca2ARABase {

	@Inject
	var extension ARAPrimitiveTypesCreator aRAPrimitveTypesCreator
	@Inject
	var extension ARATypeCreator araTypeCreator
	@Inject
	var extension ARAImplDataTypeCreator araImplDataTypeCreator
	@Inject
	var extension ApplDataTypeManager applDataTypeMgr
	@Inject
	var extension ARAConstantsCreator araConstantsCreator
	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator
	@Inject
	var extension ARADeploymentGenerator araDeploymentGenerator
    @Inject
	var extension ARANamespaceCreator
	@Inject
	var extension AutosarAnnotator
	@Inject
	var extension AutosarSpecialDataGroupCreator
	@Inject
	var extension ARATransformationPropsGenerator trafoPropsGenerator
	@Inject
	var extension Franca2ARAConfigProvider

	@Inject
	NamesHierarchy namesHierarchy

	var Set<FType> allNonPrimitiveElementTypesOfAnonymousArrays

	static final String ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE = "OriginalParentInterface"
	static final String ANNOTATION_LABEL_ARTIFICIAL_EVENT_DATA_STRUCT_TYPE = "ArtificialEventDataStructType"

	def setAllNonPrimitiveElementTypesOfAnonymousArrays(Set<FType> allNonPrimitiveElementTypesOfAnonymousArrays) {
		this.allNonPrimitiveElementTypesOfAnonymousArrays = allNonPrimitiveElementTypesOfAnonymousArrays
	}
	
	def initializeTransformation() {
		applDataTypeMgr.initialize
		araImplDataTypeCreator.initialize
		trafoPropsGenerator.initialize
		araDeploymentGenerator.initialize
		araModelSkeletonCreator.initialize	
	}

	def AUTOSAR transform(FModel src) {
		val res = transformWithDeployment(src)
		res.key
	}
	
	def Pair<AUTOSAR, AUTOSAR> transformWithDeployment(FModel src) {
		// init seed for UUID generation
		seedForUUID = src.interfaces.isEmpty ? src.name : src.name + "__" + src.interfaces.head.name 

		// prepare primitive types
		loadPrimitiveTypes
		
		// we are intentionally not adding the primitive types to the AUTOSAR target model
		val AUTOSAR aModel = src.createAutosarModelSkeleton
		
		val AUTOSAR aDeploymentModel = createSeparateDeploymentFile ? src.createAutosarDeploymentModelSkeleton : null		
		
		// create global AdminData
		if (generateAdminDataLanguage) {
			aModel.initAdminData
			if (aDeploymentModel!==null) {
				aDeploymentModel.initAdminData
			}
		}
		
		src.interfaces.forEach[transform()]
		src.typeCollections.forEach[it.transform]

		// return a pair of models: normal AUTOSAR data, deployment data
		// (Note: if !createSeparateDeploymentFile, the second model will be null
		aModel -> aDeploymentModel
	}
	
	def private initAdminData(AUTOSAR aModel) {
		aModel.adminData = fac.createAdminData => [
			language = LEnum.EN
			usedLanguages = fac().createMultiLanguagePlainText => [
				l10s.add(fac.createLPlainText => [
					l = LEnum.EN
					xmlSpace = XmlSpaceEnum.DEFAULT
				])
			]			
		]
	}
	
	def create fac.createServiceInterface transform(FInterface src) {
		if (!src.managedInterfaces.empty) {
			getLogger.logError("The manages-relation(s) of interface " + src.name + " cannot be converted! (IDL1280)")
		}
		shortName = src.name
		it.initUUID(src) 
		it.addSdgForFrancaElement(src)

		val interfacePackage = src.accordingInterfacePackage
		it.ARPackage = interfacePackage
		
		// create SOME/IP-deployment for service interface
		if (generateDeployment) {
			it.getServiceInterfaceDeployment(src)
		}
	
		namespaces.addAll(interfacePackage.createNamespaceForPackage)
		events.addAll(getAllBroadcasts(src).map[b | b.transform(it, src, interfacePackage)])
		fields.addAll(getAllAttributes(src).map[a | a.transform(it, src)])
		methods.addAll(getAllMethods(src).map[m | m.transform(it, src)])
		
		//transformEventGroups(null, ipa, ipa.getSomeIpEventGroups(src), sid)

		// Ensure that all local type definitions of the interface definition are translated
		// even if they are not referenced.
		transform(src as FTypeCollection)
		
		if (generateADTs) {
			genInterfaceToMapping
		}
	}

	def void transform(FTypeCollection fTypeCollection) {
		val types = fTypeCollection.types.map[getDataType]
		val constants = fTypeCollection.constants.map[transform]
		val accordingArPackage = fTypeCollection.accordingArPackage

		// Add the conversions of all Franca types that are defined in this type collection.
		if (storeADTsLocally)
			accordingArPackage?.elements?.addAll(types.filter(ApplicationDataType))
		if (storeIDTsLocally)
			accordingArPackage?.elements?.addAll(types.filter(ImplementationDataType))
		accordingArPackage?.elements?.addAll(constants)

		// Add the according CompuMethods for all Franca enumeration types of this type collection.
		val enumCompuMethods = fTypeCollection.types.filter(FEnumerationType).map[createCompuMethod]
		if (storeIDTsLocally)
			accordingArPackage?.elements?.addAll(enumCompuMethods)

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
	def create fac.createClientServerOperation transform(FMethod src, ServiceInterface si, FInterface parentInterface) {
		shortName = src.name
		it.initUUID(src)
		
		it.addSdgForFrancaElement(src)

		// The flag that indicates a fire&forget method is an optional member in AUTOSAR models.
		// It can have the values {true, false, undefined}.
		if (src.fireAndForget) {
			fireAndForget = true
		} else {
			if (genAlwaysFireAndForget) {
				fireAndForget = false
			}
		}

		// create SOME/IP-deployment for method
		if (generateDeployment && si!==null) {
			val md = it.getMethodDeployment(src, parentInterface)
			val sid = si.getServiceInterfaceDeployment(parentInterface)
			sid.methodDeployments.add(md)
		}
		
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
	
	// The parameter 'parentInterface' is important in case of emulation of interface inheritance.
	// As methods are copied to derived interfaces multiple copies of the method arguments are needed as well.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createArgumentDataPrototype transform(FArgument arg, boolean isIn, FInterface parentInterface) {
		shortName = arg.name
		initUUID((arg.eContainer as FModelElement).name + "_" + arg.name)

		addSdgForFrancaElement(arg)
		// category = xxx
		type = createDataTypeReference(arg.type, arg)
		direction = if(isIn) ArgumentDirectionEnum.IN else ArgumentDirectionEnum.OUT
	}

	
	// Beside the original parent interface check, the parameter 'parentInterface' is important
	// in case of emulation of interface inheritance.
	// As attributes are copied to derived interfaces multiple copies of them are needed.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createField transform(FAttribute src, ServiceInterface si, FInterface parentInterface) {
		shortName = src.name
		initUUID(src)
		
		it.addSdgForFrancaElement(src)
		type = src.type.createDataTypeReference(src)
		hasGetter = !src.noRead
		hasNotifier = !src.noSubscriptions
		hasSetter = !src.readonly
		
		// create SOME/IP-deployment for field
		if (generateDeployment && si!==null) {
			val sid = si.getServiceInterfaceDeployment(parentInterface)
			val fd = it.getFieldDeployment(src, parentInterface, sid)
			sid.fieldDeployments.add(fd)
		}		
		
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
	
	
	// Beside the original parent interface check, the parameter 'parentInterface' is important
	// in case of emulation of interface inheritance.
	// As broadcasts are copied to derived interfaces multiple copies of them are needed.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createVariableDataPrototype transform(FBroadcast src,
		ServiceInterface si,
		FInterface parentInterface,
		ARPackage interfaceArPackage)
	{
		shortName = src.name
		it.initUUID(src)
		
		it.addSdgForFrancaElement(src)
		
		// create SOME/IP-deployment for broadcast
		if (generateDeployment && si!==null) {
			val sid = si.getServiceInterfaceDeployment(parentInterface)
			val md = it.getEventDeployment(src, parentInterface, sid)
			sid.eventDeployments.add(md)
		}
		
		type =
			if (src?.outArgs.length == 1) {
				val arg0 = src.outArgs.get(0)
				arg0.type.createDataTypeReference(arg0)
			} else {
				val ImplementationDataType artificialBroadcastStruct = fac.createImplementationDataType => [
					shortName = namesHierarchy.createAndInsertUniqueName(
						parentInterface.francaFullyQualifiedName,
						IDTPrefix + src.name.toFirstUpper + "Data",
						FType
					)
					initUUID(shortName)
					category = CAT_STRUCTURE
					subElements.addAll(src.outArgs.map[ createImplDataTypeElement(name) ])
					ARPackage = interfaceArPackage
					addAnnotation(
						ANNOTATION_LABEL_ARTIFICIAL_EVENT_DATA_STRUCT_TYPE,
						"Referencing event definition: " + src.getARFullyQualifiedName
					)
				]
				interfaceArPackage.elements += artificialBroadcastStruct

				if (generateADTs) {
					fac.createApplicationRecordDataType => [
						initApplDataTypeForCompound(src.name + "Data", src.outArgs.filter(FTypedElement), null)
						createTypeMapping(artificialBroadcastStruct, null)
					]
				} else {
					artificialBroadcastStruct
				}				
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
	

	static def String getARFullyQualifiedName(FInterface ^interface) {
		val FModel model = ^interface.getModel;
		(if(!model?.name.nullOrEmpty) "/" + model.name.replace('.', '/') else "") + "/" + ^interface?.name
	}

	static def String getARFullyQualifiedName(FBroadcast broadcast) {
		(broadcast.eContainer as FInterface).getARFullyQualifiedName + "/" + broadcast.name
	}

}
