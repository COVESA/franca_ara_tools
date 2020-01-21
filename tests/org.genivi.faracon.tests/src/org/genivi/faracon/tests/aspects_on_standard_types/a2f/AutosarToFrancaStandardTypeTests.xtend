package org.genivi.faracon.tests.aspects_on_standard_types.a2f

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FArgument
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.genivi.faracon.tests.aspects_on_standard_types.StdTypesTestHelper.*
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.junit.Assert.assertNull
import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertFalse
import static org.junit.Assert.assertTrue

/**
 * Covers tests for standard types.
 * It covers the following IDLs:
 * 2620,2630,2640,2650,2660,2670,2680,2690,2700,2710,2720,2730,2740,2750,2760 
 * 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class AutosarToFrancaStandardTypeTests extends ARA2FrancaTestBase {

	@Inject
	var extension FrancaTypeCreator francaTypeCreator

	/**
	 * Test the AUTOSAR to Franca conversion of a reference to a locally defined primitive type
	 * where the AUTOSAR strandard types file "stdtypes.arxml" is not loaded. 
	 */
	@Test
	def void testPrimitiveTypeConversionWithoutStdTypesFileLoaded() {
		//given
		val implementationDataType = createImplementationDataType =>[
			category = "VALUE"
			shortName = "UInt32"
		]
		
		//when
		val result = francaTypeCreator.createFTypeRefAndImport(implementationDataType, null, null)
		
		//then
		result.assertNotNull
		assertNull("The derived element is not null, but " + result.derived, result.derived)
		result.predefined.assertIsInstanceOf(FBasicTypeId)
	}

	/**Transforms all types in the stdtypes.arxml to franca and ensures that no error occurs */
	@Test
	def void testUnitAutosarStdTypesMethodApErrors() {
		testStdTypes("stdtypes.arxml")
	}
	
	@Test
	def void testUnitCustomizedAutosarStdTypes(){
		useCustomizedAutosarStdTypes
		testStdTypes("customizedAutosarStdTypes.arxml")
	}
	
	@Test
	def void testFrancaBasicTypesInStruct() {
		transformAndCheck(testPath + "francaBasicTypes.arxml", testPath + "francaBasicTypes_a1.b2.c3.fidl")
	}
	
	@Test
	def void testCustomizedStdTypesInStruct() {
		useCustomizedAutosarStdTypes
		transformAndCheck(testPath + "francaBasicTypesCustomized.arxml", testPath + "francaBasicTypes_a1.b2.c3.fidl")
	}
	
	@Test
	def void testFrancaVectorBasicTypesInStruct() {
		transformAndCheck(testPath + "francaBasicVectorTypes.arxml", testPath + "francaBasicVectorTypes_a1.b2.c3.fidl")
	}
	
	@Test
	def void testCustomizedVectorStdTypesInStruct() {
		useCustomizedAutosarStdTypes
		transformAndCheck(testPath + "francaBasicVectorTypesCustomized.arxml", testPath + "francaBasicVectorTypes_a1.b2.c3.fidl")
	}
	
	private def void testStdTypes(String stdTypesResourceName) {
		// given
		val autosarStdTypes = getStdImplementationTypes(stdTypesResourceName)
		val autosarStdTypesContainment = autosarStdTypes.map [ stdType |
			createArgumentDataPrototype => [
				it.shortName = stdType.shortName.toFirstLower + "TestArgument"
				it.type = stdType
			]
		]
		
		// when 
		val francaPrimitivesUsages = autosarStdTypesContainment.map [
			it.transform
		].toList
		
		// then 
		assertEquals("Not all primitive types have been transformed correctly", francaPrimitivesUsages.size,
			autosarStdTypes.size)
		val francaPrimitivesMap = francaPrimitivesUsages.toMap [
			val typeName = getTypeName(it)
			it.isArray + typeName
		]
		autosarStdTypes.forEach [
			val autosarName = it.shortName
			if (autosarName == "ByteVectorType" || autosarName == "ByteBuffer" || autosarName == "ByteArray") {
				assertTrue("No franca type created for autosar type with name " + autosarName,
					francaPrimitivesMap.containsKey(false + FBasicTypeId.BYTE_BUFFER.getName))
			} else {
				assertTrue("No franca type created for autosar type with name " + autosarName + " created types are " +
					francaPrimitivesMap.values, francaPrimitivesMap.containsKey(false + autosarName))
				val francaPrimitive = francaPrimitivesMap.get(false + autosarName)
				val francaName = francaPrimitive.typeName
				assertEquals("The Franca primitive type name does not equal the Autosar primitive type name",
					francaName, autosarName)
			}
		]
	}

	private def String getTypeName(FArgument it) {
		if (it.type.derived === null) {
			return it.type.predefined.getName
		} else {
			return it.type.derived.name
		}
	}

	def private getStdImplementationTypes(String stdTypesResourceName) {
		val araResourceSet = new ARAResourceSet
		val stdTypesResource = araResourceSet.resources.get(0)
		assertTrue("Assertion error: expected to find std-Types resource, but found resource: " + stdTypesResource.URI,
			stdTypesResource.URI.toString.contains(stdTypesResourceName))
		val stdImplementationDataTypes = stdTypesResource.contents.get(0).eAllContents.filter(ImplementationDataType)
		assertFalse("Assertion error: No stdTypes found ", stdImplementationDataTypes.empty)
		return stdImplementationDataTypes.toList
	}

}
