package org.genivi.faracon

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import javax.inject.Inject
import javax.inject.Singleton
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeCollection
import org.genivi.faracon.franca2ara.ARANamespaceCreator
import org.genivi.faracon.franca2ara.ARAPackageCreator
import org.genivi.faracon.franca2ara.ARAPrimitveTypesCreator
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.names.FrancaNamesCollector
import org.genivi.faracon.names.NamesHierarchy
import org.genivi.faracon.util.AutosarAnnotator

import static org.franca.core.framework.FrancaHelpers.*

import static extension org.franca.core.FrancaModelExtensions.*
import java.util.Set

@Singleton
class Franca2ARATransformation extends Franca2ARABase {

	@Inject
	var extension ARAPrimitveTypesCreator aRAPrimitveTypesCreator
	@Inject
	var extension ARATypeCreator araTypeCreator
	@Inject
	var extension ARAPackageCreator araPackageCreator
	@Inject
	var extension ARANamespaceCreator
	@Inject
	var extension AutosarAnnotator

	@Inject
	NamesHierarchy namesHierarchy

	static final String ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE = "OriginalParentInterface"
	static final String ANNOTATION_LABEL_ARTIFICAL_EVENT_DATA_STRUCT_TYPE = "ArtificalEventDataStructType"

	def setAllNonPrimitiveElementTypesOfAnonymousArrays (Set<FType> allNonPrimitiveElementTypesOfAnonymousArrays) {
		araTypeCreator.allNonPrimitiveElementTypesOfAnonymousArrays = allNonPrimitiveElementTypesOfAnonymousArrays
	}

	def create fac.createAUTOSAR transform(FModel src) {
		// Fill all names of the Franca model into a hierarchy of names.
		namesHierarchy.clear();
		val FrancaNamesCollector francaNamesCollector = new FrancaNamesCollector
		francaNamesCollector.fillNamesHierarchy(src, namesHierarchy)

		// Process the conversion.
		createPrimitiveTypesPackage(null)
		// we are intentionally not adding the primitive types to the AUTOSAR target model
		// arPackages.add(createPrimitiveTypesPackage)
		val elementPackage = src.createPackageHierarchyForElementPackage(it)
		elementPackage.elements.addAll(src.interfaces.map[transform(elementPackage)])
		
		src.typeCollections.forEach[it.transform(elementPackage)]
	}

	def create fac.createServiceInterface transform(FInterface src, ARPackage targetPackage) {
		if (!src.managedInterfaces.empty) {
			getLogger.logError("The manages relation(s) of interface " + src.name + " cannot be converted! (IDL1280)")
		}
		shortName = src.name
		events.addAll(getAllBroadcasts(src).map[it.transform(src, targetPackage)])
		fields.addAll(getAllAttributes(src).map[transform(src)])
		namespaces.addAll(targetPackage.createNamespaceForPackage)
		methods.addAll(getAllMethods(src).map[transform(src)])
		
		// Ensure that all local type definitions of the interface definition are translated
		// even if they are not referenced.
		for (interfaceLocalTypeDefinition : src.types) {
			interfaceLocalTypeDefinition.getDataTypeForReference
		}
	}
	
	def void transform(FTypeCollection typeCollection, ARPackage arPackage){
		val types = typeCollection.types.map[dataTypeForReference]
		if(typeCollection.name.isNullOrEmpty){
			// types within an annonymous type collections are added to the package directly 
			arPackage.elements.addAll(types)	
		}else{
			// types within a named type collection are added to an own package
			arPackage.arPackages += fac.createARPackage =>[
				elements += types
				shortName = typeCollection.name
			] 
		}
	}
	
	// Beside the original parent interface check, the parameter 'parentInterface' is important
	// in case of emulation of interface inheritance.
	// As methods are copied to derived interfaces multiple copies of them are needed.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createClientServerOperation transform(FMethod src, FInterface parentInterface) {
		shortName = src.name

		// The flag that indicates a fire&forget method is an optional member in AUTOSAR models.
		// It can have the values {true, false, undefined}. We encode non-fire&forget methods with 'undefined'.
		// An additional command line option might give the user the choice between encoding 
		// with 'false' or 'undefined' in this case.
		if (src.fireAndForget) {
			fireAndForget = true
		}

		arguments.addAll(src.inArgs.map[transform(true, parentInterface)])
		arguments.addAll(src.outArgs.map[transform(false, parentInterface)])

		// The Franca specific mechanism for the handling of method errors cannot be translated
		// because it is not compatible with the method errors mechanism of AUTOSAR,
		// at least in the serialization format of the method reply messages.
		if (src.errors !== null || src.errorEnum !== null) {
			getLogger.logError("The error enumeration of the method '" + src.name + "' in the namespace '" + src.model.name + '.' + src.interface
				+ "' cannot be translated into an AUTOSAR representation. "
				+ "At least the SOME/IP serialization formats would be incompatible. "
				+ "Implement your method error reporting based on user defined types instead!")
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
		// category = xxx
		type = createDataTypeReference(arg.type, arg)
		direction = if(isIn) ArgumentDirectionEnum.IN else ArgumentDirectionEnum.OUT
	}

	// Beside the original parent interface check, the parameter 'parentInterface' is important
	// in case of emulation of interface inheritance.
	// As attributes are copied to derived interfaces multiple copies of them are needed.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createField transform(FAttribute src, FInterface parentInterface) {
		shortName = src.name
		type = src.type.createDataTypeReference(src)
		hasGetter = !src.noRead
		hasNotifier = !src.noSubscriptions
		hasSetter = !src.readonly

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
	def create fac.createVariableDataPrototype transform(FBroadcast src, FInterface parentInterface,
		ARPackage interfaceArPackage) {
		shortName = src.name

		type = if (src?.outArgs.length == 1) {
			src.outArgs.get(0).type.createDataTypeReference(src.outArgs.get(0))
		} else {
			val ImplementationDataType artificalBroadcastStruct = fac.createImplementationDataType
			artificalBroadcastStruct.shortName = namesHierarchy.createAndInsertUniqueName(
				parentInterface.francaFullyQualifiedName,
				src.name.toFirstUpper + "Data",
				FType
			)
			artificalBroadcastStruct.category = "STRUCTURE"
			val typeRefs = src.outArgs.map [
				it.createImplementationDataTypeElement(null)
			]
			artificalBroadcastStruct.subElements.addAll(typeRefs)
			artificalBroadcastStruct.ARPackage = interfaceArPackage
			artificalBroadcastStruct.addAnnotation(
				ANNOTATION_LABEL_ARTIFICAL_EVENT_DATA_STRUCT_TYPE,
				"Referencing event definition: " + src.getARFullyQualifiedName
			)
			interfaceArPackage.elements += artificalBroadcastStruct
			artificalBroadcastStruct
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

	static def String getFrancaFullyQualifiedName(FInterface ^interface) {
		val FModel model = ^interface.getModel;
		val modelPart = if(model !== null && !model.name.nullOrEmpty) model.name + "." else ""
		val interfacePart = if(interface !== null && !interface.name.nullOrEmpty) interface.name else ""
		return modelPart + interfacePart
	}

}
