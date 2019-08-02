package org.genivi.faracon.tests.aspects_on_fields.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Unit tests Autosar has notifier flag to noSubsrciptions 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1440_Tests extends FieldTestsBaseClass{
	
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
		val hasNotifier = !noSubsrciption
		val arField = createArField(fieldName, true, true, hasNotifier)

		//when 
		val result = ara2FrancaTransformation.transform(arField)
		
		//then
		assertField(result, fieldName, false, false, noSubsrciption)
	}
}