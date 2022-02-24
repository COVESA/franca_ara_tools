package org.genivi.faracon.franca2ara

import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import org.genivi.faracon.Franca2ARABase
import javax.inject.Singleton
import javax.inject.Inject
import org.genivi.faracon.franca2ara.config.Franca2ARAConfigProvider

@Singleton
class AutosarAnnotator extends Franca2ARABase {
	@Inject
	var extension Franca2ARAConfigProvider

	def addAnnotation(Identifiable objectToAnnotate, String labelText, String annotationText) {
		if (generateAnnotations) {
			objectToAnnotate.annotations.add(
				fac.createAnnotation => [
					annotationOrigin = "faracon"
					label = fac.createMultilanguageLongName => [ 
						l4s.add(fac.createLLongName => [
							mixedText = labelText
						])
					]
					annotationText = fac.createDocumentationBlock => [
						verbatims.add(fac.createMultiLanguageVerbatim => [
							l5s.add(fac.createLVerbatim => [
								mixedText = annotationText
							])
						])
					]
				]
			)
		}
	}

}
