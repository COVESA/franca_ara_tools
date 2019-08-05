package org.genivi.faracon.tests.util

import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement

import static org.junit.Assert.assertEquals
import static org.junit.Assert.fail

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static org.junit.Assert.assertNull

class FrancaAssertHelper {
	private new() {
	}

	def static void assertNamespace(FModel francaModel, String expectedNamesapce) {
		assertEquals("Wrong namespace created for franca model " + francaModel, expectedNamesapce, francaModel.name)
	}

	def static void assertName(FModelElement namedElement, String expectedName) {
		assertEquals("Wrong name created for the franca model element " + namedElement, expectedName, namedElement.name)
	}

	def static <T> T assertType(FType fType, Class<T> expectedType, String expectedName) {
		fType.assertName(expectedName)
		return fType.assertIsInstanceOf(expectedType)
	}

	def static void assertFTypedElement(FTypedElement fTypedElement, Class<?> expectedType, String expectedName, boolean isArray,
		boolean isDerivedExpected, FBasicTypeId expectedFBasicTypeId) {
		fTypedElement.assertIsInstanceOf(expectedType)
		fTypedElement.assertName(expectedName)
		fTypedElement.type.assertFTypeRef(isDerivedExpected, expectedFBasicTypeId)
	}

	def static void assertFTypeRef(FTypeRef fTypeRef, boolean isDerivedExpected, FBasicTypeId expectedFBasicTypeId) {
		if (isDerivedExpected) {
			assertNull("A derived type was expected, but a predefined has been derived: " + fTypeRef.predefined, fTypeRef.predefined)
			fail("Assertion for derived types not implemented yet.")
		} else {
			assertNull("A predefined type was expected, but a predefined has been derived: " + fTypeRef.derived, fTypeRef.derived)
			assertEquals("Wrong predefined type set", expectedFBasicTypeId, fTypeRef.predefined)
		}
	}
}
