package org.genivi.faracon.tests.aspects_on_fields.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Unit tests Franca noSubsriptions flag to Autosar has notifier flag  
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1440_Tests extends FrancaAttributeTestsBaseClass{
	
	@Test
	def void testNoReadFieldFalse(){
		testNoSubsrciptionField(false)
	}
	
	@Test
	def void testNoReadFieldTrue(){
		testNoSubsrciptionField(true)
	}
	
	private def testNoSubsrciptionField(boolean noSubsrciption){
		//given
		val fieldName = "TestField"
		val arField = createFrancaAttribute(fieldName, true, true, noSubsrciption)

		//when 
		val result = transform(arField, null)
		
		//then
		val expectdNotifier = !noSubsrciption
		assertAutosarField(result, fieldName, false, false, expectdNotifier)
	}
}