package org.genivi.faracon.util

import org.eclipse.emf.ecore.EObject
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement

class FrancaUtil {
	private new() {
	}

	static def String getFrancaNamespaceName(EObject element) {
		var currentElement = element.eContainer
		var partialNamespaceName = ""
		while (currentElement !== null && !(currentElement instanceof FModel)) {
			if (currentElement instanceof FModelElement) {
				if (!currentElement.name.nullOrEmpty) {
					partialNamespaceName += "." + currentElement.name
				}
			}
			currentElement = currentElement.eContainer
		}
		if (currentElement !== null) {
			(currentElement as FModel).name + partialNamespaceName
		} else {
			partialNamespaceName
		}
	}

}
