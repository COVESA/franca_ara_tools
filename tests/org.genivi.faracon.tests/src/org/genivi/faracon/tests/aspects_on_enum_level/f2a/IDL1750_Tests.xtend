package org.genivi.faracon.tests.aspects_on_enum_level.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Transformation from franca enum types with enum inheritance to autosar enums
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1750_Tests extends AbstractFrancaEnumTest {

	@Test
	def void testUnitCreateEnumerationWithBaseEnum() {
		// given
		val enumName = "TestEnum"
		val baseEnumeration = createFEnumerationType =>[
			 it.name = enumName
			 it.enumerators += createFEnumerator =>[it.name = "enumeratorBase"] 
		]
		val fENumeration = createFEnumerationType =>[
			 it.name = enumName
			 it.enumerators += createFEnumerator =>[it.name = "enumerator1"] 
			 it.enumerators += createFEnumerator =>[it.name = "enumerator2"]
			 it.base = baseEnumeration 
		]
		 
		
		// when
		val result = araTypeCreator.getDataTypeForReference(fENumeration)

		// then
		val compuScales = assertEnumAndGetCompuScales(result, enumName, 3)
		compuScales.get(0).assertCompuScale("enumerator1", null)
		compuScales.get(1).assertCompuScale("enumerator2", null)
		compuScales.get(2).assertCompuScale("enumeratorBase", null)
	}
	
}
