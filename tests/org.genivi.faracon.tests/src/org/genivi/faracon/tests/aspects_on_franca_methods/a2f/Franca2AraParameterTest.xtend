package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import autosar40.genericstructure.generaltemplateclasses.primitivetypes.ArgumentDirectionEnum
import org.genivi.faracon.tests.util.ARA2FrancaTestBase

import static org.junit.Assert.assertEquals
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

abstract class Franca2AraParameterTest extends ARA2FrancaTestBase{

	protected def void unitTestParameterDirection(ArgumentDirectionEnum testDirection, boolean expectedInDirection) {
		//given
		val clientServerOp = createClientServerOperation =>[
			it.shortName = "clientServerOperation"
			it.arguments += createArgumentDataPrototype =>[
				it.shortName = "testParameter"
				it.direction = testDirection
				it.type = createImplementationDataType =>[
					it.category = "VALUE"
					it.shortName = "UInt32"	
				]
				
			]
		
		]
		
		//when
		val fMethod = transform(clientServerOp)
		
		//then
		val fArgument = if(expectedInDirection)fMethod.inArgs.assertOneElement else fMethod.outArgs.assertOneElement
		assertEquals("Wrong parameter name created", "testParameter", fArgument.name)
	}
}