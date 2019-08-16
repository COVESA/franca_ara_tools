package org.genivi.faracon.tests.aspects_on_enum_level.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * transformation from franca enum type to autosar compu method
 * The tests also covers IDL1740, IDL1710   
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1730_Tests extends AbstractFrancaEnumTest {

	@Test
	def void testUnitCreateEnumeration() {
		// given
		val enumName = "TestEnum"
		val fENumeration = createFEnumerationType =>[
			 it.name = enumName
			 it.enumerators += createFEnumerator =>[it.name = "enumerator1"] 
			 it.enumerators += createFEnumerator =>[it.name = "enumerator2"] 
		]
		
		// when
		val result = araTypeCreator.getDataTypeForReference(fENumeration)

		// then
		val compuScales = assertEnumAndGetCompuScales(result, enumName)
		compuScales.get(0).assertCompuScale("enumerator1", null)
		compuScales.get(1).assertCompuScale("enumerator2", null)
	}
	
	@Test
	def void testCreateEnumerationTypeFromImplementationDataType() {
		this.transformAndCheck(correspondingAutosar2FrancaTestPath, "compuMethod2Enumeration",
			correspondingAutosar2FrancaTestPath + "compuMethod2Enumeration.arxml")
	}

}
