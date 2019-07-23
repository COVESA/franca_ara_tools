package org.genivi.faracon.tests.aspects_on_interface_level.a2f

import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner2_Franca) 
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1240_Tests extends ARA2FrancaTestBase {
	
	@Test 
	def void testOneMethod() {
		this.transformAndCheck(testPath + "oneMethod.arxml", "src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/oneMethod.fidl" )
	}
	
	@Test
	def void testMultipleMethod(){
		this.transformAndCheck(testPath + "multipleMethods.arxml", "src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/multipleMethods.fidl" )	
	}
	
	@Test
	def void testMultipleInterfacesWithMethods(){
		this.transformAndCheck(testPath + "multipleInterfacesWithMethods.arxml", "src/org/genivi/faracon/tests/aspects_on_interface_level/f2a/multipleInterfacesWithMethods.fidl" )
	}
}
