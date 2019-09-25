package org.genivi.faracon.tests.aspects_on_annotations.f2a

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FAnnotationType
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

/**
 * Test cases for Franca Annotations to Autosar SDGs
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1480_Tests extends Franca2ARATestBase {

	@Test
	def void testUnitFrancaAnnotation() {
		// given
		val testInterfaceName = "TestInterface"
		val fInterface = createFInterface =>[
			it.name = testInterfaceName
			it.comment = createFAnnotationBlock =>[
				it.elements += createFAnnotation =>[
					it.type = FAnnotationType.AUTHOR
					it.comment = "Test comment"
				]
			] 
		]
		val parentPackage = createARPackage => [it.shortName = "TestParentPackage"] 
		
		// when
		val serviceInterface = fInterface.transform(parentPackage)

		// then
		serviceInterface.assertName(testInterfaceName)
		val createdSdg = serviceInterface.adminData.assertNotNull.sdgs.assertOneElement
		assertEquals("Wrong id for the following sdg created " + createdSdg, "FARACON", createdSdg.gid)
		val l2 = createdSdg.sdgCaption.assertNotNull.desc.assertNotNull.l2s.assertOneElement
		assertEquals("The annotation has the wrong type", "author", l2.mixedText)
		val sd = createdSdg.sdgContentsType.assertNotNull.sds.assertOneElement
		assertEquals("The annotation has the wrong comment", "Test comment", sd.value)
	}

	@Test
	def void testTypeCollectionUsageWithVersion() {
		transformAndCheck(testPath, "francaAnnotation", testPath + "francaAnnotation.arxml")
	}

}
