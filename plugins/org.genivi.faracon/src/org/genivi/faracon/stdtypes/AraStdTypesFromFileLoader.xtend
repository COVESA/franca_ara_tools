package org.genivi.faracon.stdtypes

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ArraySizeSemanticsEnum
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.util.Autosar40Factory
import java.util.Collection
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.util.AutosarUtil

@FinalFieldsConstructor
class AraStdTypesFromFileLoader implements IAraStdTypesLoader {

	val extension Autosar40Factory autosar40Factory = Autosar40Factory.eINSTANCE 
	val extension AutosarUtil = new AutosarUtil

	val String customAraStdTypesPath

	@Data
	private static class ImplementationDataTypeWithPackagePath {
		val Collection<String> packagePath
		val ImplementationDataType implementationDataType
	}

	override loadStdTypes(ARAResourceSet resourceSet) {
		val araConnector = new ARAConnector
		val autosarModel = araConnector.loadModel(resourceSet, customAraStdTypesPath) as ARAModelContainer
		val stdTypes = autosarModel.model
		val stdVectorTypes = stdTypes.createStdVectorTypes
		
		// add std vector types to resource
		val stdTypesUri = stdTypes.eResource.URI
		val fileExtension = stdTypesUri.fileExtension
		val stdVectorTypesUri = stdTypesUri.trimFileExtension.toFileString + "_vectors." + fileExtension 
		val resource = resourceSet.createResource(URI.createFileURI(stdVectorTypesUri))
		resource.contents.add(stdVectorTypes)
		
		return new AraStandardTypes(stdTypes, stdVectorTypes)
	}

	def private AUTOSAR createStdVectorTypes(AUTOSAR autosar) {
		val vectorTypesWithPackagePaths = autosar.eAllContents.filter(ImplementationDataType).map[createVectorTypeForStdType]
		val stdVectorModel = createAUTOSAR
		vectorTypesWithPackagePaths.forEach[
			val arPackage = stdVectorModel.ensurePackagesExistence(it.packagePath)
			arPackage.elements += it.implementationDataType
		]
		return stdVectorModel
	}

	private def ImplementationDataTypeWithPackagePath createVectorTypeForStdType(ImplementationDataType stdType) {
		val vectorType = createImplementationDataType => [
			it.shortName = stdType.shortName + "Vector"
			it.category = "VECTOR"
			it.subElements += createImplementationDataTypeElement => [
				it.shortName = stdType.shortName + "Ref"
				it.category = "TYPE_REFERENCE"
				it.arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
				it.swDataDefProps = createSwDataDefProps => [
					it.swDataDefPropsVariants += createSwDataDefPropsConditional => [
						it.implementationDataType = stdType
					]
				] 
			]
		]
		val packagePath = AutosarUtil.collectPackagePath(stdType.ARPackage)
		return new ImplementationDataTypeWithPackagePath(packagePath, vectorType)
	}

}