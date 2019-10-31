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
	
	val String filePath
	
	@Data
	private static class PackageHierarchyImplementationDataType{
		val List<String> packageHierarchy
		val ImplementationDataType implementationDataType
	}
	
	override loadStdTypes(ARAResourceSet resourceSet) {
		val araConnector = new ARAConnector
		val autosarModel = araConnector.loadModel(resourceSet, filePath) as ARAModelContainer
		val stdTypes = autosarModel.model
		val stdVectorTypes = stdTypes.createStdVectorTypes
		
		// add std vector types to resource
		val stdTypesUri = stdTypes.eResource.URI
		val fileExtension = stdTypesUri.fileExtension
		val stdVectorUri = stdTypes.eResource.URI.trimFileExtension.toFileString + "Vector." + fileExtension 
		val resource = resourceSet.createResource(URI.createFileURI(stdVectorUri))
		resource.contents.add(stdVectorTypes)
		
		return new AraStandardTypes(stdTypes, stdVectorTypes)
	}
	
	def private AUTOSAR createStdVectorTypes(AUTOSAR autosar){
		val vectorTypesWithHierarchy = autosar.eAllContents.filter(ImplementationDataType).map[createVectorTypeForStdType]
		val stdVectorModel = createAUTOSAR
		vectorTypesWithHierarchy.forEach[
			val arPackage = stdVectorModel.ensureTypesPackageHierarchy(it.packageHierarchy)
			arPackage.elements += it.implementationDataType
		]
		return stdVectorModel
	}
	
	def private ARPackage ensureTypesPackageHierarchy(AUTOSAR autosar, List<String> packageHierarchy){
		var currentPackage = createTopLevelPackage(autosar, packageHierarchy.head)
		for(packageName : packageHierarchy.tail){
			currentPackage = currentPackage.createArPackageInPackage(packageName)
		}
		return currentPackage
	}
	
	def private create createARPackage createTopLevelPackage(AUTOSAR autosar, String packageName){
		it.shortName = packageName
		autosar.arPackages += it
	}
	
	def private create createARPackage createArPackageInPackage(ARPackage arPackage, String packageName){
		it.shortName = packageName
		arPackage.arPackages += it
	}
	
	private def PackageHierarchyImplementationDataType createVectorTypeForStdType(ImplementationDataType stdType) {
		val vectorType = createImplementationDataType =>[
			it.shortName = stdType.shortName + "Vector"
			it.category = "VECTOR"
			it.subElements += createImplementationDataTypeElement =>[
				it.shortName = stdType.shortName + "Ref"
				it.category = "TYPE_REFERENCE"
				it.arraySizeSemantics = ArraySizeSemanticsEnum.VARIABLE_SIZE
				it.swDataDefProps = createSwDataDefProps =>[
					it.swDataDefPropsVariants += createSwDataDefPropsConditional =>[
						it.implementationDataType = stdType
					]
				] 
			]
		]
		val packageHierarcy = AutosarUtil.collectPackageHierarchy(stdType.ARPackage).map[it.shortName].toList
		return new PackageHierarchyImplementationDataType(packageHierarcy, vectorType)
	}
	
}