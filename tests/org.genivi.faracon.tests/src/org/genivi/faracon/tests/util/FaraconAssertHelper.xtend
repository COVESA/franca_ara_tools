package org.genivi.faracon.tests.util

import java.util.Collection
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.core.franca.FModel

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertTrue
import static org.junit.Assert.fail

/**
 * Assertion helper for the faracon test, which contains all general 
 * assertions that can be used for both directions: ara 2 franca and franca to ara.
 */
class FaraconAssertHelper {

	private new() {
	}

	def static void assertFrancaModelsAreEqual(Collection<FModel> francaModels,
		Collection<FModel> expectedFrancaModel) {
		assertEquals("Expected collection and actual collection of franca models need to have the same size.",
			expectedFrancaModel.size, francaModels.size)
		val sortedActual = francaModels.sortBy[it.name]
		val sortedExpected = expectedFrancaModel.sortBy[it.name]
		for (var i = 0; i < sortedExpected.size; i++) {
			assertModelsAreEqual(sortedActual.get(i), sortedExpected.get(i))
		}
	}

	def static void assertModelsAreEqual(EObject actualModel, EObject expectedModel) {
		if (!EcoreUtil.equals(actualModel, expectedModel)) {
			val difference = findFirstDifference(actualModel, expectedModel)
			fail("The expected model does not equal the actual model. First difference: " + System.lineSeparator +
				difference)
		}
	}

	def private static String findFirstDifference(EObject actualEObject, EObject expectedEObject) {
		val actualContents = actualEObject.eContents
		val expectedContents = expectedEObject.eContents
		if (actualContents.size != expectedContents.size) {
			return '''The number of contents of the actual EObject "«actualEObject»" differ from the contents in the expected EObject "«expectedEObject»". 
			Actual is «actualContents.size», expected was «expectedContents.size»
			Actual content is: «actualContents.map[toString].join(System.lineSeparator)»
			
			Expected content was «expectedContents.map[toString].join(System.lineSeparator)»'''
		}
		for (var i = 0; i < actualContents.size; i++) {
			val currentActual = actualContents.get(i)
			val currentExpected = expectedContents.get(i)
			if (!EcoreUtil.equals(currentActual, currentExpected)) {
				return '''The actual EObject "«currentActual»" does not equal the expected EObject "«currentExpected»".«System.lineSeparator»	Reason: «findFirstDifference(currentActual, currentExpected)»'''
			}
		}
		return '''The actual EObject "«actualEObject»" does not equal the expected EObject "«expectedEObject»".«System.lineSeparator»'''
	}

	def static <T> T assertOneElement(Collection<T> elements) {
		return elements.assertElements(1).get(0)
	}

	def static <T> Collection<T> assertElements(Collection<T> elements, int expectedElements) {
		assertEquals("Wrong number of expected elements in collection " + elements, expectedElements, elements.size)
		return elements
	}

	def static <T> T assertIsInstanceOf(Object element, Class<T> classInstance) {
		assertTrue("The element " + element + " is not an instance of " + classInstance + ", but an instance of " +
			element?.class, classInstance.isInstance(element))
		return classInstance.cast(element)

	}
}
