package org.genivi.faracon.tests.aspects_on_structs.f2a

import javax.inject.Inject
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FStructType
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Before
import org.genivi.faracon.franca2ara.ARAPrimitiveTypesCreator

abstract class AbstractFranca2AraStructTest extends Franca2ARATestBase{
	@Inject
	var ARAPrimitiveTypesCreator primitiveTypes

	@Before
	def void beforeTest(){
		primitiveTypes.loadPrimitiveTypes
	}
	
	protected def FStructType createFStruct(String structName, String subElementName, FStructType baseStruct) {
		createFStructType =>[
			it.name = structName
			if(baseStruct !== null){
				it.base = baseStruct				
			}
			it.elements += createFField =>[
				it.name = subElementName
				it.type = createFTypeRef =>[
					it.predefined = FBasicTypeId.UINT32
				]
			]
		]
	}
}