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

@Singleton
class ARAPackageCreator extends Franca2ARABase {

	val Map<FModel, ARPackage> fModel2Packages = newHashMap()
	
	def ARPackage createPackageHierarchyForElementPackage(FModel fModel, AUTOSAR autosar) {
		val segments = fModel.name.split(Pattern.quote("."))
		var ARPackage elementPackage = null
		if(!segments.nullOrEmpty) {
			var ARPackage currentParentPackage = null
			for(segment : segments){
				elementPackage = createPackageWithName(segment, currentParentPackage)
				if(currentParentPackage === null){
					autosar.arPackages.add(elementPackage)		
				}
				currentParentPackage = elementPackage
			}
		} else {
			elementPackage = createPackageWithName(fModel.name, null)
			autosar.arPackages.add(elementPackage)
		}
		fModel2Packages.put(fModel, elementPackage)
		return elementPackage
	}
	
	def create fac.createARPackage createPackageWithName(String name, ARPackage parent) {
		shortName = name
		parent?.arPackages?.add(it)
	}

	def ARPackage findArPackageForFrancaElement(FModelElement fModelElement) {
		val rootFrancaModel = EcoreUtil.getRootContainer(fModelElement)
		if (!fModel2Packages.containsKey(rootFrancaModel)) {
			val reason = if(rootFrancaModel ===
					null) "No root element for franca element found" else "No package created for franca root " +
					rootFrancaModel
			getLogger.logWarning('''No package can be found for the Franca element "«fModelElement». ". Reason: «reason»''')
		}
		return fModel2Packages.get(rootFrancaModel)
	}
}
