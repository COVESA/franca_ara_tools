package org.genivi.faracon

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.documentation.annotation.Annotation
import autosar40.genericstructure.generaltemplateclasses.documentation.blockelements.DocumentationBlock
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.languagedatamodel.LLongName
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.languagedatamodel.LVerbatim
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.multilanguagedata.MultiLanguageVerbatim
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.multilanguagedata.MultilanguageLongName
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
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
import org.genivi.faracon.franca2ara.ARANamespaceCreator
import org.genivi.faracon.franca2ara.ARAPackageCreator
import org.genivi.faracon.franca2ara.ARAPrimitveTypesCreator
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.names.FrancaNamesCollector
import org.genivi.faracon.names.NamesHierarchy

import static org.franca.core.framework.FrancaHelpers.*

import static extension org.franca.core.FrancaModelExtensions.*

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
	NamesHierarchy namesHierarchy

	static final String ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE = "OriginalParentInterface"
	static final String ANNOTATION_LABEL_ARTIFICAL_EVENT_DATA_STRUCT_TYPE = "ArtificalEventDataStructType"

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

		// If the method is not a direct member of the current interface definition but is inherited from
		// a direct or indirect base interface the original interface where it comes from is annotated.
		// As interface inheritance cannot be directly mapped to an AUTOSAR representation
		// this annotation provides the required information to reconstruct the original Franca model
		// uniquely from the AUTOSAR model.
		val FInterface originalParentInterface = src.getInterface
		if (parentInterface !== originalParentInterface) {
			it.addAnnotation(ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE, originalParentInterface.getARFullyQualifiedName)
		}
	}
	
	// The parameter 'parentInterface' is important in case of emulation of interface inheritance.
	// As methods are copied to derived interfaces multiple copies of the method arguments are needed as well.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createArgumentDataPrototype transform(FArgument arg, boolean isIn, FInterface parentInterface) {
		shortName = arg.name
		//category = xxx
		type = createDataTypeReference(arg.type, arg)
		direction = if (isIn) ArgumentDirectionEnum.IN else ArgumentDirectionEnum.OUT
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
			it.addAnnotation(ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE, originalParentInterface.getARFullyQualifiedName)
		}
	}
	
	// Beside the original parent interface check, the parameter 'parentInterface' is important
	// in case of emulation of interface inheritance.
	// As broadcasts are copied to derived interfaces multiple copies of them are needed.
	// Without the parameter 'parentInterface', the memoisation mechanism of Xtend create methods would avoid this.
	def create fac.createVariableDataPrototype transform(FBroadcast src, FInterface parentInterface, ARPackage interfaceArPackage) {
		shortName = src.name

		type = 
			if (src?.outArgs.length == 1) {
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
					it.createImplementationDataTypeElement
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
			it.addAnnotation(ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE, originalParentInterface.getARFullyQualifiedName)
		}

		// Selective broadcasts are not representable in an AUTOSAR model.
		if (src.selective) {
			getLogger.logError("The broadcast '" + originalParentInterface.name + "." + src.name + "' cannot be properly converted because selective broadcasts are not representable in an AUTOSAR model! (IDL1390)")
		}

		// Broadcast selectors are not representable in an AUTOSAR model.
		if (!src.selector.isNullOrEmpty) {
			getLogger.logError("The broadcast '" + originalParentInterface.name + "." + src.name + "' cannot be properly converted because broadcast selectors are not representable in an AUTOSAR model! (IDL1400)")
		}
	}

	def addAnnotation(Identifiable objectToAnnotate, String labelText, String annotationText) {
		var LLongName lLongName = fac.createLLongName
		lLongName.mixedText = labelText
		var MultilanguageLongName multilanguageLongName = fac.createMultilanguageLongName
		multilanguageLongName.l4s.add(lLongName)

		var LVerbatim lVerbatim = fac.createLVerbatim
		lVerbatim.mixedText = annotationText
		var MultiLanguageVerbatim multiLanguageVerbatim = fac.createMultiLanguageVerbatim
		multiLanguageVerbatim.l5s.add(lVerbatim)
		var DocumentationBlock documentationBlock = fac.createDocumentationBlock
		documentationBlock.verbatims.add(multiLanguageVerbatim)

		var Annotation annotation = fac.createAnnotation
		annotation.annotationOrigin = "faracon"
		annotation.label = multilanguageLongName
		annotation.annotationText = documentationBlock
		objectToAnnotate.annotations.add(annotation)
	}

	static def String getARFullyQualifiedName(FInterface ^interface) {
		val FModel model = ^interface.getModel;
		(if (!model.name.nullOrEmpty) "/" + model.name.replace('.', '/') else "") + "/" + ^interface.name
	}

	static def String getARFullyQualifiedName(FBroadcast broadcast) {
		(broadcast.eContainer as FInterface).getARFullyQualifiedName + "/" + broadcast.name
	}

	static def String getFrancaFullyQualifiedName(FInterface ^interface) {
		val FModel model = ^interface.getModel;
		(if (!model.name.nullOrEmpty) model.name + "." else "") + ^interface.name
	}

}
