package org.genivi.faracon.tests.aspects_on_fields.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Unit tests Franca readonly flag to Autosar has setter flag 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1420_Tests extends FrancaAttributeTestsBaseClass{
	
	@Test
	def void testReadOnlyFieldFalse(){
		testReadOnlyField(false)
	}
	
	@Test
	def void testReadOnlyFieldTrue(){
		testReadOnlyField(true)
	}
	
	private def testReadOnlyField(boolean isReadOnly){
		//given
		val fieldName = "TestField"
		val francaAttribute = createFrancaAttribute(fieldName, isReadOnly, false, true)

		//when 
		val result = transform(francaAttribute, null)
		
		//then
		// is readOnly means: we always have a getter, but only a setter if readonly == false
		val expectSetter = !isReadOnly
		assertAutosarField(result, fieldName, true, expectSetter, false)
	}
}