package org.genivi.faracon.util

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FTypeCollection

import static extension org.franca.core.FrancaModelExtensions.*

class FrancaUtil {
	private new() {
	}

	static def String getFrancaNamespaceName(EObject element) {
		var currentElement = element.eContainer
		var partialNamespaceName = ""
		while (currentElement !== null && !(currentElement instanceof FModel)) {
			if (currentElement instanceof FModelElement) {
				if (!currentElement.name.nullOrEmpty) {
					if (!partialNamespaceName.empty) {
						partialNamespaceName = "." + partialNamespaceName
					}
					partialNamespaceName = currentElement.name + partialNamespaceName
				}
			}
			currentElement = currentElement.eContainer
		}
		if (currentElement !== null) {
			if (!partialNamespaceName.empty) {
				partialNamespaceName = "." + partialNamespaceName
			}
			partialNamespaceName = (currentElement as FModel).name + partialNamespaceName
		}
		partialNamespaceName
	}

	static def String getFrancaFullyQualifiedName(FTypeCollection fTypeCollection) {
		val FModel model = fTypeCollection.getModel;
		val modelPart = if(model !== null && !model.name.nullOrEmpty) model.name + "." else ""
		val interfacePart = if(fTypeCollection !== null && !fTypeCollection.name.nullOrEmpty) fTypeCollection.name else ""
		return modelPart + interfacePart
	}

}
