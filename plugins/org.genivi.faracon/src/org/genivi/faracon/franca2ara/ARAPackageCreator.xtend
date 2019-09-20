package org.genivi.faracon.franca2ara

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.util.Autosar40Factory
import java.util.Map
import java.util.regex.Pattern
import javax.inject.Singleton
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FTypeCollection
import org.genivi.faracon.Franca2ARABase

@Singleton
class ARAPackageCreator extends Franca2ARABase {

	val Map<FModel, ARPackage> fModel2arPackage = newHashMap()
	val Map<FTypeCollection, ARPackage> fTypeCollection2arPackage = newHashMap()

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
		
		// Create AUTOSAR subpackages for all Franca interface definitions with content that has to be transformed into package content.
		for (interface : fModel.interfaces) {
			if (!interface.types.nullOrEmpty || !interface.constants.nullOrEmpty) {
				fTypeCollection2arPackage.put(interface, createPackageWithName(interface.name, elementPackage))
			}
		}
		// Create AUTOSAR subpackages for all named Franca type collections.
		for (typeCollection : fModel.typeCollections) {
			if (!typeCollection.name.nullOrEmpty) {
				fTypeCollection2arPackage.put(typeCollection, createPackageWithName(typeCollection.name, elementPackage))
			}
		}
		
		fModel2arPackage.put(fModel, elementPackage)
		return elementPackage
	}

	def getAccordingArPackage(FTypeCollection fTypeCollection) {
		val accordingArPackage = fTypeCollection2arPackage.get(fTypeCollection)
		if (accordingArPackage !== null) {
			accordingArPackage
		} else {
			fModel2arPackage.get(fTypeCollection.eContainer as FModel)
		}
	}

	def private createPackageWithName(String name, ARPackage parent) {
		val ARPackage newPackage = fac.createARPackage
		newPackage.shortName = name
		parent?.arPackages?.add(newPackage)
		newPackage
	}

}
