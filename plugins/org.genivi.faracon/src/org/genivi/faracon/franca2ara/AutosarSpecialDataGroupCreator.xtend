package org.genivi.faracon.franca2ara

import autosar40.genericstructure.generaltemplateclasses.admindata.AdminData
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import javax.inject.Singleton
import org.franca.core.franca.FAnnotation
import org.franca.core.franca.FModelElement
import org.genivi.faracon.Franca2ARABase

@Singleton
class AutosarSpecialDataGroupCreator extends Franca2ARABase {

	val FARACON_SDG_GID = "faracon"

	def void addSdgForFrancaElement(Identifiable identifiable, FModelElement fModelElement){
		val annotationBlock = fModelElement?.comment
		if(annotationBlock === null){
			return
		}
		annotationBlock.elements.forEach[
			identifiable.addSdgForFrancaAnnotation(it)
		]
	}

	def private void addSdgForFrancaAnnotation(Identifiable identifiable, FAnnotation fAnnotation) {
		identifiable.addSdg(fAnnotation.type?.getName, fAnnotation.comment)
	}

	def private void addSdg(Identifiable identifiable, String sdgType, String sdgValue) {
		val sdg = fac.createSdg => [
			gid = FARACON_SDG_GID
			sdgCaption = fac.createSdgCaption => [
				it.desc = fac.createMultiLanguageOverviewParagraph => [
					it.l2s += fac.createLOverviewParagraph => [
						it.mixedText = sdgType
					]
				]
			]
			sdgContentsType = fac.createSdgContents => [
				it.sds += fac.createSd => [
					it.value = sdgValue
				]
			]
		]
		identifiable.ensureAdminData.sdgs += sdg

	}

	def private AdminData ensureAdminData(Identifiable identifiable) {
		if (identifiable.adminData === null) {
			identifiable.adminData = fac.createAdminData
		}
		return identifiable.adminData
	}

}
