package org.genivi.faracon.tests.aspects_on_fields.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Unit tests Autosar field to Franca attribute 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1410_Tests extends FrancaAttributeTestsBaseClass {
	
	@Test
	def void testUnitSingleAttributeToField(){
		//given
		val fieldName = "TestField"
		val fAttribute = createFrancaAttribute(fieldName, true, true, true)

		//when 
		val result = transform(fAttribute, null, null)
		
		//then
		assertAutosarField(result, fieldName, false, false, false)
	}
	
}