package org.genivi.faracon.tests.aspects_on_fields.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Unit tests Autosar has setter flag to noRead flag 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1430_Tests extends FieldTestsBaseClass{
	
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
		val hasGetter = !isNoRead
		val arField = createArField(fieldName, hasGetter, true, false)

		//when 
		val result = ara2FrancaTransformation.transform(arField)
		
		//then
		assertField(result, fieldName, false, isNoRead, true)
	}
}