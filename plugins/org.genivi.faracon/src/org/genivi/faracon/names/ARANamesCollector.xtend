package org.genivi.faracon.names

import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.genericstructure.generaltemplateclasses.arpackage.PackageableElement
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable
import org.eclipse.emf.ecore.EObject

class ARANamesCollector {

	def fillNamesHierarchy(AUTOSAR aModel, NamesHierarchy namesHierarchy) {
		for (arPackage : aModel.arPackages) {
			arPackage.processElement("", namesHierarchy)
		}
	}

	protected def void processElement(EObject arbitraryElement, String namespace, NamesHierarchy namesHierarchy) {
		val String localName = arbitraryElement.localName
		var innerNamespace = namespace
		if (!localName.nullOrEmpty) {
			if (!innerNamespace.empty) {
				innerNamespace += "."
			}
			innerNamespace += localName
			namesHierarchy.insertFullyQualifiedName(innerNamespace, arbitraryElement.metaclassGroup, false)
		}
		val finalInnerNamespace = innerNamespace
		arbitraryElement.eContents.forEach[processElement(finalInnerNamespace, namesHierarchy)]
	}

	protected dispatch def Class<?> getMetaclassGroup(EObject arbitraryElement) {
		null
	}
	protected dispatch def Class<?> getMetaclassGroup(ServiceInterface aServiceInterface) {
		ServiceInterface
	}
	protected dispatch def Class<?> getMetaclassGroup(Package aPackage) {
		Package
	}
	protected dispatch def Class<?> getMetaclassGroup(PackageableElement aPackageableElement) {
		PackageableElement
	}
	protected dispatch def Class<?> getMetaclassGroup(Referrable aReferrable) {
		Referrable
	}

	protected dispatch def getLocalName(EObject arbitraryElement) {
		null
	}
	protected dispatch def getLocalName(Referrable aReferrable) {
		aReferrable.shortName
	}

}
