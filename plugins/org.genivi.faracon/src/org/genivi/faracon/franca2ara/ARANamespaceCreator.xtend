package org.genivi.faracon.franca2ara

import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.arpackage.PackageableElement
import autosar40.swcomponent.components.SymbolProps
import java.util.Collection
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.util.AutosarUtil

class ARANamespaceCreator extends Franca2ARABase {
	
	def Collection<SymbolProps> createNamespaceForElement(PackageableElement packableElement){
		return packableElement.ARPackage.createNamespaceForPackage
	}
	
	def Collection<SymbolProps> createNamespaceForPackage(ARPackage arPackage){
		val symbolProps = AutosarUtil.collectPackageHierarchy(arPackage).map[createSymbolProps].toList
		return symbolProps
	}
	
	def private createSymbolProps(ARPackage arPackage){
		return fac.createSymbolProps => [
			it.shortName = arPackage.shortName
			it.symbol = arPackage.shortName
		]
	}
	
}