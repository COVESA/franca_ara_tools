package org.genivi.faracon.stdtypes

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ArraySizeSemanticsEnum
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.util.Autosar40Factory
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.genivi.faracon.ARAConnector
import org.genivi.faracon.ARAModelContainer
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.util.AutosarUtil
import org.eclipse.emf.common.util.URI

@FinalFieldsConstructor
class AraStdTypesFromFileLoader implements IAraStdTypesLoader {

	val extension Autosar40Factory autosar40Factory = Autosar40Factory.eINSTANCE 

	val String customAraStdTypesPath

	@Data
	private static class ImplementationDataTypeWithPackagePath {
		val List<String> packagePath
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
		val stdVectorTypesUri = stdTypesUri.trimFileExtension.toFileString + "Vector." + fileExtension 
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

	def private ARPackage ensurePackagesExistence(AUTOSAR autosar, List<String> packagePath) {
		var currentPackage = createTopLevelPackage(autosar, packagePath.head)
		for(packageName : packagePath.tail) {
			currentPackage = currentPackage.createArPackageInPackage(packageName)
		}
		return currentPackage
	}

	def private create createARPackage createTopLevelPackage(AUTOSAR autosar, String packageName) {
		it.shortName = packageName
		autosar.arPackages += it
	}

	def private create createARPackage createArPackageInPackage(ARPackage parentPackage, String packageName) {
		it.shortName = packageName
		parentPackage.arPackages += it
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
		val packagePath = AutosarUtil.collectPackageHierarchy(stdType.ARPackage).map[it.shortName].toList
		return new ImplementationDataTypeWithPackagePath(packagePath, vectorType)
	}

}