package org.genivi.faracon.franca2ara

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import java.util.Map
import java.util.regex.Pattern
import javax.inject.Singleton
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.genivi.faracon.Franca2ARABase
import autosar40.util.Autosar40Factory

@Singleton
class ARAPackageCreator extends Franca2ARABase {

	val Map<FModel, ARPackage> fModel2Packages = newHashMap()

	def ARPackage createPackageHierarchyForElementPackage(FModel fModel, AUTOSAR autosar) {
		val segments = fModel.name.split(Pattern.quote("."))
		var ARPackage elementPackage = null
		if (!segments.nullOrEmpty) {
			var ARPackage currentParentPackage = null
			for (segment : segments) {
				elementPackage = createPackageWithName(segment, currentParentPackage)
				if (currentParentPackage === null) {
					autosar?.arPackages?.add(elementPackage)
				}
				currentParentPackage = elementPackage
			}
		} else {
			elementPackage = createPackageWithName(fModel.name, null)
			autosar?.arPackages?.add(elementPackage)
		}
		fModel2Packages.put(fModel, elementPackage)
		return elementPackage
	}

	def private createPackageWithName(String name, ARPackage parent) {
		val ARPackage newPackage = fac.createARPackage
		newPackage.shortName = name
		parent?.arPackages?.add(newPackage)
		newPackage
	}

	/** 
	 * Returns the package for the Franca model element. 
	 * If it has not been created yet, it creates a dummy hierarchy in order to ensure that the 
	 * package name is correct.
	 */
	def ARPackage findArPackageForFrancaElement(FModelElement fModelElement) {
		val rootFrancaModel = EcoreUtil.getRootContainer(fModelElement) as FModel
		val foundPackage = fModel2Packages.get(rootFrancaModel)
		if(foundPackage === null){
			createPackageHierarchyForElementPackage(rootFrancaModel, Autosar40Factory.eINSTANCE.createAUTOSAR)
			return fModel2Packages.get(rootFrancaModel)
		}
		return foundPackage
	}
}
