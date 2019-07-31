package org.genivi.faracon.tests.aspects_on_enum_level.a2f

import javax.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FEnumerationType
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertNull

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*

/**
 * transformation from autosar compu-method to franca enumeration types
 * The tests also covers IDL1740, IDL1710, and IDL1720   
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1730_Tests extends ARA2FrancaTestBase {

	@Inject
	var FrancaTypeCreator fTypeCreator

	@Test
	def void testUnitCreateImplementationTypeWithTypeRef() {
		// given
		val implementationDataType = createImplementationDataType => [
			it.category = "TYPE_REFERENCE"
			it.shortName = "TestEnum"
			it.swDataDefProps = createSwDataDefProps => [
				swDataDefPropsVariants += createSwDataDefPropsConditional => [
					compuMethod = createCompuMethod => [
						shortName = "TestCompuMethod"
						it.category = "TEXTTABLE"
						it.compuInternalToPhys = createCompu => [
							it.compuContent = createCompuScales => [
								it.compuScales += createCompuScale => [
									it.symbol = "enumerator1"
								]
								it.compuScales += createCompuScale => [
									it.symbol = "enumerator2"
								]
							]
						]
					]
				]
			]
		]

		// when
		val result = fTypeCreator.transform(implementationDataType)

		// then
		val enumType = result.assertIsInstanceOf(FEnumerationType)
		enumType.assertName("TestEnum")
		assertNull("No base type expected", enumType.base)
		val enumerators = enumType.enumerators.assertElements(2).sortBy[name]
		enumerators.get(0).assertName("enumerator1")
		enumerators.get(1).assertName("enumerator2")
	}

	@Test
	def void testCreateEnumerationTypeFromImplementationDataType() {
		this.transformAndCheck(testPath + "compuMethod2Enumeration.arxml", testPath + "compuMethod2Enumeration.fidl")
	}

}
