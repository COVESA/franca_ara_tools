package org.genivi.faracon.tests.aspects_on_fields.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Unit tests Franca no read flag to autosar has setter flag  
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1430_Tests extends FrancaAttributeTestsBaseClass{
	
	@Test
	def void testNoReadFieldFalse(){
		testNoReadField(false)
	}
	
	@Test
	def void testNoReadFieldTrue(){
		testNoReadField(true)
	}
	
	private def testNoReadField(boolean isNoRead){
		//given
		val fieldName = "TestField"
		val arField = this.createFrancaAttribute(fieldName, true, isNoRead, true)

		//when 
		val result = transform(arField, null)
		
		//then
		// is no read means that we do not have a getter --> if is no read is true, we do not expect a getter and vice versa
		val expectGetter = !isNoRead
		assertAutosarField(result, fieldName, expectGetter, false, false)
	}
}