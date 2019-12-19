package org.genivi.faracon.util

import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable
import autosar40.util.Autosar40Factory
import java.util.Collection
import java.util.Objects
import org.eclipse.emf.ecore.EObject

class AutosarUtil {

	def static String getPackageNamespace(ARPackage arPackage) {
		val namespace = arPackage?.shortName
		if (arPackage?.eContainer instanceof ARPackage) {
			return getPackageNamespace(arPackage.eContainer as ARPackage) + "." + namespace
		}
		return namespace
	}

	/**
	 * Collects packages need to be transformed from Autosar to franca.
	 * Collects the packages that contain elements from type relevantElementsInstances or which are leaf packages.
	 * 
	 */
	static def void collectPackagesWithElementsOrLeafPackages(Collection<ARPackage> packages,
		Collection<ARPackage> packagesWithElements, Collection<Class<?>> relevantElementsInstances) {
		packages.forEach [ currentPackage |
			val hasRelevantElement = currentPackage.elements.findFirst [ packageElement |
				!relevantElementsInstances.filter[it.isInstance(packageElement)].isNullOrEmpty
			]
			val isLeafPackage = currentPackage.arPackages.isNullOrEmpty
			if (hasRelevantElement !== null || isLeafPackage) {
				// the current package has at least one interface or one ImplementationDataType --> needs to be transformed 
				packagesWithElements.add(currentPackage)
			}
			collectPackagesWithElementsOrLeafPackages(currentPackage.arPackages, packagesWithElements,
				relevantElementsInstances)
		]
	}
	
	/**
	 * Checks whether the namespace of the provided service interface matches 
	 * the namespace according to the package hierarchy.
	 */
	def static namespaceMathchesHierarchy(ServiceInterface serviceInterface) {
		val containingPackage = serviceInterface.ARPackage
		val hierarchyNamespace = containingPackage.packageNamespace
		return Objects.equals(hierarchyNamespace, serviceInterface.namespaceHierarchy)
	}
	
	
	def private static getNamespaceHierarchy(ServiceInterface serviceInterface){
		val hierarchy = serviceInterface.namespaces.map[it.shortName]
		return hierarchy.join(".")	
	} 
	
	static def String getARANamespaceName(EObject element) {
		var currentElement = element.eContainer
		var partialNamespaceName = ""
		while (currentElement !== null) {
			if (currentElement instanceof Referrable) {
				if (!currentElement.shortName.nullOrEmpty) {
					if (!partialNamespaceName.empty) {
						partialNamespaceName = "." + partialNamespaceName
					}
					partialNamespaceName = currentElement.shortName + partialNamespaceName
				}
			}
			currentElement = currentElement.eContainer
		}
		partialNamespaceName
	}

	def static Collection<ARPackage> collectPackageHierarchy(ARPackage arPackage) {
		val parentContainer = arPackage.eContainer
		if(parentContainer instanceof ARPackage){
			val arPackages = collectPackageHierarchy(parentContainer)
			arPackages.add(arPackage)
			return arPackages
		} else {
			return newArrayList(arPackage)
		}
	}

	def static Collection<String> collectPackagePath(ARPackage arPackage) {
		collectPackageHierarchy(arPackage).map[it.shortName].toList
	}


	val extension Autosar40Factory autosar40Factory = Autosar40Factory.eINSTANCE 

	def ARPackage ensurePackagesExistence(AUTOSAR autosar, Collection<String> packagePath) {
		var currentPackage = createTopLevelPackage(autosar, packagePath.head)
		for(packageName : packagePath.tail) {
			currentPackage = currentPackage.createArPackageInPackage(packageName)
		}
		return currentPackage
	}

	def private create autosar40Factory.createARPackage createTopLevelPackage(AUTOSAR autosar, String packageName) {
		it.shortName = packageName
		autosar.arPackages += it
	}

	def private create autosar40Factory.createARPackage createArPackageInPackage(ARPackage parentPackage, String packageName) {
		it.shortName = packageName
		parentPackage.arPackages += it
	}

}
