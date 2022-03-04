package org.genivi.faracon.franca2ara.types

import org.franca.core.franca.FTypedElement

import static extension org.genivi.faracon.util.FrancaUtil.*

class TypeContext {

	// either we have a FTypedElement ...
	var FTypedElement typedElem = null
	
	// ... or only its name and a namespace
	var String typedElemName = null
	var String namespaceName = null
	
	new(FTypedElement te) {
		this.typedElem = te
	}
	
	new (String typedElemName, String namespaceName) {
		this.typedElemName = typedElemName
		this.namespaceName = namespaceName
	}
	
	def String getTypedElementName() {
		if (typedElem!==null) {
			typedElem.name
		} else {
			typedElemName
		}
	}

	def String getNamespaceName() {
		if (typedElem!==null) {
			typedElem.francaNamespaceName
		} else {
			namespaceName
		}
	}
	
	def boolean hasTypedElement() {
		typedElem!==null
	}
	
	def FTypedElement getTypedElement() {
		typedElem
	}
}
