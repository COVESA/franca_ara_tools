package org.genivi.faracon.tests.aspects_for_unions.f2a

import javax.inject.Inject
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FUnionType
import org.genivi.faracon.franca2ara.ARAPrimitveTypesCreator
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Before

abstract class AbstractFranca2AraUnionTest extends Franca2ARATestBase{
	@Inject
	var ARAPrimitveTypesCreator primitiveTypes

	@Before
	def void beforeTest(){
		primitiveTypes.createPrimitiveTypesPackage(null)
	}
	
	protected def FUnionType createFUnion(String unionName, String subElementName, FUnionType baseUnion) {
		createFUnionType =>[
			it.name = unionName
			if(baseUnion !== null){
				it.base = baseUnion				
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