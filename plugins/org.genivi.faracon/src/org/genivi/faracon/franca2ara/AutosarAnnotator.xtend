package org.genivi.faracon.franca2ara

import autosar40.genericstructure.generaltemplateclasses.documentation.annotation.Annotation
import autosar40.genericstructure.generaltemplateclasses.documentation.blockelements.DocumentationBlock
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.languagedatamodel.LLongName
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.languagedatamodel.LVerbatim
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.multilanguagedata.MultiLanguageVerbatim
import autosar40.genericstructure.generaltemplateclasses.documentation.textmodel.multilanguagedata.MultilanguageLongName
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import org.genivi.faracon.Franca2ARABase
import javax.inject.Singleton

@Singleton
class AutosarAnnotator extends Franca2ARABase {

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

}
