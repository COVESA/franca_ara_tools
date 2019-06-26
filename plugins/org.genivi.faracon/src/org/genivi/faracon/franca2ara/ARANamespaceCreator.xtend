package org.genivi.faracon.franca2ara

import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.arpackage.PackageableElement
import autosar40.swcomponent.components.SymbolProps
import java.util.Collection
import org.genivi.faracon.Franca2ARABase

class ARANamespaceCreator extends Franca2ARABase {
	
	def Collection<SymbolProps> createNamespaceForElement(PackageableElement packableElement){
		return packableElement.ARPackage.createNamespaceForPackage
	}
	
	def Collection<SymbolProps> createNamespaceForPackage(ARPackage arPackage){
		val symbolProps = collectPackageHierarchy(arPackage).map[createSymbolProps].toList
		return symbolProps
	}
	
	def private createSymbolProps(ARPackage arPackage){
		return fac.createSymbolProps => [
			it.shortName = arPackage.shortName
			it.symbol = arPackage.shortName
		]
	}
	
	def private Collection<ARPackage> collectPackageHierarchy(ARPackage arPackage){
		val parentContainer = arPackage.eContainer
		if(parentContainer instanceof ARPackage){
			val arPackages = collectPackageHierarchy(parentContainer)
			arPackages.add(arPackage)
			return arPackages
		}else{
			return newArrayList(arPackage)
		}
	}
	
}