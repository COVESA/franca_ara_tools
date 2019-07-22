package org.genivi.faracon

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
import org.genivi.faracon.franca2ara.ARANamespaceCreator
import org.genivi.faracon.franca2ara.ARAPackageCreator
import org.genivi.faracon.franca2ara.ARAPrimitveTypesCreator
import org.genivi.faracon.franca2ara.ARATypeCreator

import static extension org.franca.core.FrancaModelExtensions.*
import static extension org.franca.core.framework.FrancaHelpers.*

@Singleton
class Franca2ARATransformation extends Franca2ARABase {

	@Inject
	private var extension ARAPrimitveTypesCreator aRAPrimitveTypesCreator
	@Inject 
	private var extension ARATypeCreator araTypeCreator
	@Inject
	private var extension ARAPackageCreator araPackageCreator
	@Inject
	private var extension ARANamespaceCreator

	static final String ANNOTATION_LABEL_ORIGINAL_PARENT_INTERFACE = "OriginalParentInterface"

	def create fac.createAUTOSAR transform(FModel src) {
		createPrimitiveTypesPackage(null)
		// we are intentionally not adding the primitive types to the AUTOSAR target model
		// arPackages.add(createPrimitiveTypesPackage)
		val elementPackage = src.createPackageHierarchyForElementPackage(it)
		elementPackage.elements.addAll(src.interfaces.map[transform(elementPackage)])
	}
	
	def create fac.createServiceInterface transform(FInterface src, ARPackage targetPackage) {
		if (!src.managedInterfaces.empty) {
			getLogger.logError("The manages relation(s) of interface " + src.name + " cannot be converted!")
		}
		shortName = src.name
		events.addAll(getAllBroadcasts(src).map[transform(src)])
		fields.addAll(getAllAttributes(src).map[transform(src)])
		namespaces.addAll(targetPackage.createNamespaceForPackage)
		methods.addAll(getAllMethods(src).map[transform(src)])
	}
	
	def create fac.createClientServerOperation transform(FMethod src, FInterface parentInterface) {
		shortName = src.name
		arguments.addAll(src.inArgs.map[transform(true)])
		arguments.addAll(src.outArgs.map[transform(false)])

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
	
	def create fac.createArgumentDataPrototype transform(FArgument arg, boolean isIn) {
		shortName = arg.name
		//category = xxx
		type = createDataTypeReference(arg.type, arg)
		direction = if (isIn) ArgumentDirectionEnum.IN else ArgumentDirectionEnum.OUT
	}
	
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
	
	def create fac.createVariableDataPrototype transform(FBroadcast src, FInterface parentInterface) {
		shortName = src.name
		if (!src.outArgs.empty) {
			type = src.outArgs.get(0).type.createDataTypeReference(src.outArgs.get(0))
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

}
