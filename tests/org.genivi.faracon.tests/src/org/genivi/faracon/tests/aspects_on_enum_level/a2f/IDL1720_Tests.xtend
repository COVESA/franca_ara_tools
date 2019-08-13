package org.genivi.faracon.tests.aspects_on_enum_level.a2f

import java.util.Optional
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FEnumerationType
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertNull

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FIntegerConstant
import static org.junit.Assert.assertEquals

/**
 * transformation from autosar compu-method with limits to franca enum
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1720_Tests extends AbstractAutosarEnumTest {

	@Test
	def void testUnitEnumWithLimit() {
		// given
		val implementationDataType = createArEnum(Optional.of("1"), Optional.of("2"))

		// when
		val result = fTypeCreator.transform(implementationDataType)

		// then
		val enumType = result.assertIsInstanceOf(FEnumerationType)
		enumType.assertName("TestEnum")
		assertNull("No base type expected", enumType.base)
		val enumerators = enumType.enumerators.assertElements(2).sortBy[name]
		enumerators.get(0).assertEnumWithLimit("enumerator1", 1)
		enumerators.get(1).assertEnumWithLimit("enumerator2", 2)
	}
	
	@Test
	def void testEnumWithLimit(){
		this.transformAndCheck(testPath + "compuMethod2EnumerationWithLimit.arxml", testPath + "compuMethod2EnumerationWithLimit.fidl")
	}
	
	def private void assertEnumWithLimit(FEnumerator enumerator, String enumName, int expectedValue){
		enumerator.assertName(enumName)
		val fIntegerConstant = enumerator.value.assertIsInstanceOf(FIntegerConstant)
		assertEquals("Wrong constant for the enumerator value", fIntegerConstant.^val.intValue, expectedValue)
	}
	

}
