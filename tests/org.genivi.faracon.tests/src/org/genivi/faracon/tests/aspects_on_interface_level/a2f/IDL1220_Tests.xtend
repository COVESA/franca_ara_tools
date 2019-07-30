package org.genivi.faracon.tests.aspects_on_interface_level.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static org.junit.Assert.assertEquals

/**
 * Test transformation of interfaces from autosar to franca
 */
@RunWith(XtextRunner2_Franca) 
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1220_Tests extends ARA2FrancaTestBase {
	
	@Test 
	def void testSingleInterface() {
		//given
		val interfaceName = "ArServiceInterface"
		val arModel = createAUTOSAR => [
			arPackages += createARPackage => [
				it.shortName = "containingPackage"
				elements += createServiceInterface =>[
					it.shortName = interfaceName
				]
			]
		]
		
		//when
		val fModels = this.transformToFranca(arModel)
		
		//then
		val fModel = fModels.assertOneElement
		val singleInterface = fModel.interfaces.assertOneElement
		assertEquals(singleInterface.name, interfaceName)
	}
	
	
	@Test
	def void testMultipleInterfaces(){
		//given
		val firstInterfaceName = "ArServiceInterface"
		val secondInterfaceName = "ArServiceInterface2"		
		val arModel = createAUTOSAR => [
			arPackages += createARPackage => [
				it.shortName = "containingPackage"
				elements += createServiceInterface =>[
					it.shortName = firstInterfaceName
				]
				elements += createServiceInterface =>[
					it.shortName = secondInterfaceName
				]
			]
		]
		
		//when
		val fModels = this.transformToFranca(arModel)
		
		//then
		val fModel = fModels.assertOneElement
		val interfaces = fModel.interfaces.assertElements(2).sortBy[name]
		assertEquals(interfaces.get(0).name, firstInterfaceName)
		assertEquals(interfaces.get(1).name, secondInterfaceName)
	}
}
