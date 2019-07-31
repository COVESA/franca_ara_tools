package org.genivi.faracon.tests.util

import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement

import static org.junit.Assert.assertEquals

class FrancaAssertHelper {
	private new() {
	}

	def static void assertNamespace(FModel francaModel, String expectedNamesapce) {
		assertEquals("Wrong namespace created for franca model " + francaModel, expectedNamesapce, francaModel.name)
	}

	def static void assertName(FModelElement namedElement, String expectedName) {
		assertEquals("Wrong name created for the franca model element " + namedElement, expectedName, namedElement.name)
	}
}
