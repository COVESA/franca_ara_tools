package org.genivi.faracon.tests.aspects_on_structs.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.runner.RunWith
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.commonstructure.implementationdatatypes.ImplementationDataTypeElement
import org.franca.core.franca.FBasicTypeId

/**
 * Test cases for testing the conversion of franca structs to autosar
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1650_Tests extends Franca2ARATestBase{
	
	@Test
	def void testUnitFrancaStructToAutosarStruct(){
		//given
		val structName = "TestFStruct"
		val subElementName = "MyUInt32"
		val fStruct = createFStructType =>[
			it.name = structName
			it.elements += createFField =>[
				it.name = subElementName
				it.type = createFTypeRef =>[
					it.predefined = FBasicTypeId.UINT32
				]
			]
		]
		
		//when
		val type = araTypeCreator.getDataTypeForReference(fStruct)

		//then
		val implementationDatatype = type.assertIsInstanceOf(ImplementationDataType).assertName(structName).assertCategory("STRUCTURE")
		val subElement = implementationDatatype.subElements.assertOneElement.assertIsInstanceOf(ImplementationDataTypeElement).assertName(subElementName)
		subElement.assertCategory("TYPE_REFERENCE")
	}
	
	@Test
	def void testFrancaStructToAutosarStruct(){
		val path = "src/org/genivi/faracon/tests/aspects_on_structs/a2f/"
		transformAndCheck(path, "singleStructTest", path+ "singleStructTest.arxml")
	}
	
}