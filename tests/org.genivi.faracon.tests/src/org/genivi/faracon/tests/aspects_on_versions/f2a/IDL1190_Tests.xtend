package org.genivi.faracon.tests.aspects_on_versions.f2a

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
 * Test cases for versions on Franca TypeCollections
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1190_Tests extends Franca2ARATestBase {

	@Test
	def void testUnitVersionsOnTypeCollections() {
		// given
		val typeCollection = createFTypeCollection => [
			it.version = createFVersion => [
				major = 2
				minor = 1
			]
			it.types += createFStructType => [
				it.name = "MyStruct"
				it.elements += createFField => [
					it.name = "MyTestField"
					it.type = createFTypeRef => [predefined = FBasicTypeId.UINT32]
				]
			]
		]
		val fModel = createFModel =>[
			it.name = "testModel"
			typeCollections += typeCollection
		]

		// when
		val autosar = fModel.transform

		// then
		val arPackage = autosar.arPackages.assertOneElement.assertName("testModel")
		assertTrue("No elements in parent package expected, but found " + arPackage.elements,
			arPackage.elements.isEmpty)
		val elementPackage = arPackage.arPackages.assertOneElement
		elementPackage.assertName("v_2_1")
		val implementationDataType = elementPackage.elements.assertOneElement.assertIsInstanceOf(ImplementationDataType)
		implementationDataType.assertName("MyStruct")
	}

	@Test
	def void testTypeCollectionUsageWithVersion() {
		transformAndCheck(testPath, "typeCollectionUsageWithVersion", testPath + "typeCollectionUsageWithVersion.arxml")
	}

}
