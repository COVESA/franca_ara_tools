package org.genivi.faracon.names

import com.google.inject.Singleton
import java.util.List
import org.genivi.faracon.logging.BaseWithLogger
import org.genivi.faracon.logging.ILogger

@Singleton
class NamesHierarchy extends BaseWithLogger {

	static class NameNode {
		String name
		Class<?> metaclass
		boolean artificial
		List<NameNode> children

		def NameNode insertName(String nameToInsert, Class<?> metaclassOfElement, boolean isNameOfArtificialElement) {
			if (children === null) {
				children = newArrayList
			}
			val newNameNode = new NameNode => [
				name = nameToInsert
				metaclass = metaclassOfElement
				artificial = isNameOfArtificialElement
			]
			children += newNameNode
			newNameNode
		}
		
		def void dump(ILogger logger) {
			logger.logInfo(name + " : " + metaclass?.name + (if (artificial) " [artificial]" else ""))
			logger.increaseIndentationLevel
			children?.forEach[dump(logger)]
			logger.decreaseIndentationLevel
		}
	}

	NameNode rootNode = new NameNode

	def clear() {
		rootNode = new NameNode
		rootNode.class
	}

	def dump() {
		rootNode.dump(logger)
	}

	def insertFullyQualifiedName(String fullyQualifiedName, Class<?> metaclass, boolean artificial) {
		insertFullyQualifiedName(fullyQualifiedName.split("\\."), metaclass, artificial)
	}

	def insertFullyQualifiedName(String[] fullyQualifiedNameFragments, Class<?> metaclass, boolean artificial) {
		var NameNode currentNode = rootNode
		for (name : fullyQualifiedNameFragments) {
			val NameNode matchingNameNode = currentNode.findMatchingNameNode(name)
			if (matchingNameNode !== null) {
				currentNode = matchingNameNode
			} else {
				currentNode = currentNode.insertName(name, null, artificial)
			}
		}
		currentNode.metaclass = metaclass
		currentNode.artificial = artificial
	}

	def String createAndInsertUniqueName(String fullyQualifiedNamespaceName, String desiredLocalName, Class<?> metaclass) {
		createAndInsertUniqueName(fullyQualifiedNamespaceName.split("\\."), desiredLocalName, metaclass)
	}

	def String createAndInsertUniqueName(String[] fullyQualifiedNamespaceNameFragments, String desiredLocalName, Class<?> metaclass) {
		var NameNode currentNode = rootNode
		for (name : fullyQualifiedNamespaceNameFragments) {
			val NameNode matchingNameNode = currentNode.findMatchingNameNode(name)
			if (matchingNameNode !== null) {
				currentNode = matchingNameNode
			} else {
				return null
			}
		}
		var uniqueLocalName = desiredLocalName
		while (currentNode.findMatchingNameNode(uniqueLocalName, metaclass) !== null) {
			uniqueLocalName += "_"
		}
		currentNode.insertName(uniqueLocalName, metaclass, true).name
	}

	def containsFullyQualifiedName(String fullyQualifiedName) {
		containsFullyQualifiedName(fullyQualifiedName.split("\\."))
	}

	def containsFullyQualifiedName(String[] fullyQualifiedNameFragments) {
		var NameNode currentNode = rootNode
		for (name : fullyQualifiedNameFragments) {
			val NameNode matchingNameNode = currentNode.findMatchingNameNode(name)
			if (matchingNameNode !== null) {
				currentNode = matchingNameNode
			} else {
				return false
			}
		}
		return true
	}

	protected def findMatchingNameNode(NameNode parentNode, String nameToFind) {
		if (parentNode.children.nullOrEmpty) {
			return null
		}
		for (nameNode : parentNode.children) {
			if (nameNode.name == nameToFind) {
				return nameNode
			}
		}
		return null
	}

	protected def findMatchingNameNode(NameNode parentNode, String nameToFind, Class<?> metaclass) {
		if (parentNode.children.nullOrEmpty) {
			return null
		}
		for (nameNode : parentNode.children) {
			if (nameNode.name == nameToFind && nameNode.metaclass == metaclass) {
				return nameNode
			}
		}
		return null
	}

}
