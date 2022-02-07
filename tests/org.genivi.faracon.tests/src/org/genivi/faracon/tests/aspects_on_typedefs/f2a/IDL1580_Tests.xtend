package org.genivi.faracon.tests.aspects_on_typedefs.f2a

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertTrue

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

/**
 * Test transformation of Franca typedef to Autosar implementation data type with category 
 * TYPE_REF. Also tests IDL1590.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1580_Tests extends Franca2ARATestBase {

	@Test
	def void testFrancaTypeDefToAutosar() {
		// given
		val testTypedefName = "TestTypedef"
		val fTypedef = createFTypeDef => [
			name = testTypedefName
			it.actualType = createFTypeRef => [
				it.predefined = FBasicTypeId.UINT8
			]
		]

		// when
		val resultAutosarDatatype = fTypedef.getDataType

		// then
		val implementationType = resultAutosarDatatype.assertIsInstanceOf(ImplementationDataType).assertName(
			testTypedefName)
		implementationType.assertCategory("TYPE_REFERENCE")
		val subElement = implementationType.subElements.assertOneElement
		subElement.assertCategory("TYPE_REFERENCE")
	}

	@Test
	def void testTypeDefToAutosarTransformation() {
		transformAndCheck(testPath, "typeDefUsage", testPath + "typeDefUsage.arxml")
	}

}
