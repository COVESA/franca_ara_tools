package org.genivi.faracon.ara2franca

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import javax.inject.Singleton
import org.eclipse.xtend.lib.annotations.Accessors
import org.franca.core.franca.FModel
import org.genivi.faracon.ARA2FrancaBase

import static extension org.genivi.faracon.util.AutosarUtil.*

@Singleton
class FrancaImportCreator extends ARA2FrancaBase {

	@Accessors
	var FModel currentModel

	def createImportIfNecessary(ImplementationDataType src) {
		if (currentModel === null) {
			logger.
				logError('''Cannot create import for type "�src?.shortName�". Reason: internal error: no franca model is set to be create''')
			return
		}
		val datatypePackage = src?.ARPackage?.packageNamespace
		if (datatypePackage != currentModel.name) {
			// create import
			createAndAddImportToCurrentModel(datatypePackage, src)
		}

	}

	def private create createImport createAndAddImportToCurrentModel(String packageNameToImport,
		ImplementationDataType src) {
		val autosarModelUri = src?.eResource?.URI
		if (autosarModelUri === null) {
			logger.
				logError('''Cannot create an import from model "�currentModel?.name�" to package "�packageNameToImport�". Reason: Source file for implementation data type "�src�" cannot be found.''')
			return
		}
		val francaFileToImport = Ara2FrancaUtil.
			calculateFrancaFileNameFromAutosarUri(autosarModelUri, packageNameToImport)
		it.importURI = francaFileToImport
		currentModel.imports += it
	}

}
