package org.genivi.faracon.tests.aspects_on_fields.a2f

import autosar40.adaptiveplatform.applicationdesign.portinterface.Field
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.tests.util.ARA2FrancaTestBase

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull
import static org.junit.Assert.assertNull

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*

abstract class FieldTestsBaseClass extends ARA2FrancaTestBase{
	
	protected def Field createArField(String fieldName, boolean hasGetter, boolean hasSetter, boolean hasNotifier){ 
		val testType = createImplementationDataType() =>[
			shortName = "UInt8"
			category = "VALUE"
		]
		val arField = createField => [
			it.shortName = fieldName
			it.type = testType
			it.hasGetter = hasGetter 
			it.hasSetter = hasSetter 
			it.hasNotifier = hasNotifier
		]
		return arField
	}
	
	protected def void assertField(FAttribute result, String fieldName, boolean readonly, boolean isNoRead, boolean noSubscriptions) {
		assertNotNull("Resulting attribute should not be null ", result)
		result.assertIsInstanceOf(FAttribute)
		result.assertName(fieldName)
		assertNotNull("The resulting type must not be null", result.type)
		assertNotNull("The resulting type must be a predefined type", result.type.predefined)
		assertNull("The resulting type must not be a derived type", result.type.derived)
		assertEquals("Resulting type is wrong.", FBasicTypeId.UINT8, result.type.predefined)
		assertEquals("Field " + result + " has the wrong readonly flag value", readonly, result.readonly)
		assertEquals("Field " + result + " has the wrong isNoRead flag value", isNoRead, result.isNoRead)
		assertEquals("Field " + result + " has the wrong noSubscriptions flag value", noSubscriptions, result.noSubscriptions)
	}
	
}