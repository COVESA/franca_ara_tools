package org.genivi.faracon.tests.aspects_on_enum_level.f2a

import java.math.BigInteger
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FExpression
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * transformation from franca enum with value to autosar compu method and compu scale
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1720_Tests extends AbstractFrancaEnumTest {

	@Test
	def void testUnitCreateEnumerationWithIntegerValue() {
		testWithExpression(createFIntegerConstant => [
			it.^val = new BigInteger("123")
		], createFIntegerConstant => [
			it.^val = new BigInteger("456")
		])
	}

	@Test
	def void testUnitCreateEnumerationWithStringValue() {
		testWithExpression(createFStringConstant => [it.^val = "123"], createFStringConstant => [it.^val = "456"])
	}


	@Test
	def void testCreateEnumerationTypeFromImplementationDataType() {
		this.transformAndCheck(correspondingAutosar2FrancaTestPath, "compuMethod2EnumerationWithLimit",
			correspondingAutosar2FrancaTestPath + "compuMethod2EnumerationWithLimit.arxml")
	}
	
	def private void testWithExpression(FExpression expression1, FExpression expression2) {
		// given
		val enumName = "TestEnum"
		val fENumeration = createFEnumerationType => [
			it.name = enumName
			it.enumerators += createFEnumerator => [
				it.name = "enumerator1"
				it.value = expression1
			]
			it.enumerators += createFEnumerator => [
				it.name = "enumerator2"
				it.value = expression2
			]
		]

		// when
		val result = araTypeCreator.getDataTypeForReference(fENumeration)

		// then
		val compuScales = assertEnumAndGetCompuScales(result, enumName)
		compuScales.get(0).assertCompuScale("enumerator1", "123")
		compuScales.get(1).assertCompuScale("enumerator2", "456")
	}

}
