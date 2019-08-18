package org.genivi.faracon.tests.aspects_on_fields.f2a

import autosar40.adaptiveplatform.applicationdesign.portinterface.Field
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.tests.util.Franca2ARATestBase

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*

abstract class FrancaAttributeTestsBaseClass extends Franca2ARATestBase {

	protected def FAttribute createFrancaAttribute(String fieldName, boolean readonly, boolean isNoRead,
		boolean noSubscriptions) {
		val testAttribute = createFAttribute => [
			it.name = fieldName
			it.readonly = readonly
			it.setNoRead = isNoRead
			it.setNoSubscriptions = noSubscriptions
			it.type = createFTypeRef => [
				predefined = FBasicTypeId.UINT8
			]
		]
		return testAttribute
	}

	protected def void assertAutosarField(Field result, String fieldName, boolean hasGetter, boolean hasSetter,
		boolean hasNotifier) {
		assertNotNull("Resulting attribute should not be null ", result)
		result.assertName(fieldName)
		assertNotNull("The resulting type must not be null", result.type)
		result.type.assertCategory("VALUE")
		assertEquals("Field " + result + " has the wrong getter flag value", hasGetter, result.hasGetter)
		assertEquals("Field " + result + " has the wrong setter flag value", hasSetter, result.hasSetter)
		assertEquals("Field " + result + " has the wrong notifier flag value", hasNotifier,
			result.hasNotifier)
	}

}
