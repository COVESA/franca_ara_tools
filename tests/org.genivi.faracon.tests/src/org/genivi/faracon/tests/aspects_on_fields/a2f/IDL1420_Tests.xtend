package org.genivi.faracon.tests.aspects_on_fields.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Unit tests Autosar has setter flag to readonly flag 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1420_Tests extends FieldTestsBaseClass{
	
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
		val hasSetter = !isReadOnly
		val arField = createArField(fieldName, false, hasSetter, false)

		//when 
		val result = ara2FrancaTransformation.transform(arField)
		
		//then
		assertField(result, fieldName, isReadOnly, true, true)
	}
}