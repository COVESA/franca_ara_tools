package org.genivi.faracon.tests.aspects_on_typedefs.a2f

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FTypeDef
import org.genivi.faracon.ara2franca.FrancaImportCreator
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*

/**
 * Test transformation of Autosar implementation data type with category 
 * TYPE_REF to franca typedef.
 * Also tests IDL1590 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1580_Tests extends ARA2FrancaTestBase {

	@Inject
	var FrancaTypeCreator francaTypeCreator
	@Inject
	var FrancaImportCreator francaImportCreator
	

	@Test
	def void testTypeDef() {
		// given
		val testTypedefName = "TestArTypedef"
		val autosarTypedef = createImplementationDataType => [
			shortName = testTypedefName
			category = "TYPE_REF"
			subElements += createImplementationDataTypeElement => [
				shortName = "MyUInt16"
				category = "TYPE_REFERENCE"
				swDataDefProps = createSwDataDefProps => [
					swDataDefPropsVariants += createSwDataDefPropsConditional => [
						it.implementationDataType = createImplementationDataType => [
							it.category = "VALUE"
							it.shortName = "UInt16"
						]
					]
				]
			]
		]
		val String testModelName = "TestModel"
		createARPackage => [
			shortName = testModelName
			elements += autosarTypedef
		]
		val targetFModel = createFModel =>[
			name = testModelName
		]
		francaImportCreator.currentModel = targetFModel

		// when
		val result = francaTypeCreator.transform(autosarTypedef)

		// then
		val fTypdef = result.assertIsInstanceOf(FTypeDef)
		fTypdef.assertName(testTypedefName)
		fTypdef.actualType.assertFTypeRef(false, FBasicTypeId.UINT16)

	}

	@Test
	def void testTypeDefTransformation() {
		transformAndCheck(testPath + "typeDefUsage.arxml",
			testPath + "typeDefUsage.fidl")
	}

}
