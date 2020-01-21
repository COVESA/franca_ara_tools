package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import javax.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.genivi.faracon.ara2franca.FrancaConstantsCreator
import org.genivi.faracon.ara2franca.FrancaEnumCreator
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

/**
 * Test mapping of Autosar-Elements to Franca-Elements.
 * As the AUTOSAR metamodel contains lots of Referrable elements, 
 * we only instantiate the ones that are transformed to a Franca FModelElement.
 * 
 * Hierarchy of Franca metaclasses below 'FModelElement':
 *    FModelElement            {abstract}
 *       FBroadcast
 *       FEvaluableElement     {abstract}
 *          FEnumerator
 *          FTypedElement      {abstract}
 *             FArgument
 *             FAttribute
 *             FConstantDef
 *             FDeclaration    {IGNORE (A20)}
 *             FField
 *             FVariable       {IGNORE}
 *       FMethod
 *       FState                {IGNORE (A20)}
 *       FType                 {abstract}
 *          FArrayType
 *          FCompoundType      {abstract}
 *             FStructType
 *             FUnionType
 *          FEnumerationType
 *          FIntegerInterval   {ERROR}
 *          FMapType
 *          FTypeDef
 *       FTypeCollection
 *          FInterface
 *
 * But not all subclasses of 'FModelElement' are appropriate for such tests:
 *  - Abstract subclasses cannot be instantiated.
 *  - Metaclasses which are specified to be ignored will never have an according conversion implementation.
 *  - Metaclasses which are specified to cause an error can be tested with tests that expect an exception to be thrown.
 *
 * Also tests IDL1600, IDL1610, and IDL 1630.
 */
@RunWith(XtextRunner2_Franca) 
@InjectWith(FaraconTestsInjectorProvider) 
class IDL1460_Tests extends ARA2FrancaTestBase {
	
	@Inject
	var extension FrancaTypeCreator francaTypeCreator

	@Inject
	var extension FrancaEnumCreator francaEnumCreator

	@Inject
	var extension FrancaConstantsCreator francaConstantsCreator

	@Test
	def void broadcastConversion() {
		// given
		val event = createVariableDataPrototype
		ara2FrancaTransformation.logger.enableContinueOnErrors(true)
		
		//when
		val result = ara2FrancaTransformation.transform(event)
		
		//then
		assertNotNullAndInstanceOfFModelElement(result)
	}
	
	@Test
	def void enumeratorConversion() {
		//given
		val aEnumerationType = createImplementationDataType => [
			it.category = "TYPE_REFERENCE"
			it.swDataDefProps = createSwDataDefProps => [
				it.swDataDefPropsVariants += createSwDataDefPropsConditional => [
					compuMethod = createCompuMethod => [
						it.category = "TEXTTABLE"
						it.compuInternalToPhys = createCompu => [
							it.compuContent = createCompuScales => [
								it.compuScales += createCompuScale
							]
						]
					]
				]
			]
		]

		//when
		val result = francaEnumCreator.transformEnumeration(aEnumerationType)

		//then
		result.enumerators.assertOneElement.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void argumentConversion() {
		//given
		val aArgument = createArgumentDataPrototype => [
			it.type = createImplementationDataType => [
				it.category = "VALUE"
				it.shortName = "UInt32"
			]
		]

		//when
		val result = ara2FrancaTransformation.transform(aArgument)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void attributeConversion() {
		//given
		val aAttribute = createField => [
			it.type = createImplementationDataType => [
				it.category = "VALUE"
				it.shortName = "UInt32"
			]
		]

		//when
		val result = ara2FrancaTransformation.transform(aAttribute)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void constantDefConversion() {
		//given
		val aConstantDef = createConstantSpecification => [
			it.valueSpec = createNumericalValueSpecification => [
				it.value = createNumericalValueVariationPoint => [
					it.mixedText = "123"
				]
			]
		]

		//when
		val result = francaConstantsCreator.transform(aConstantDef, null)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void fieldConversion() {
		//given
		val aStructType = createImplementationDataType => [
			it.category = "STRUCTURE"
			it.subElements += createImplementationDataTypeElement => [
				it.category = "TYPE_REFERENCE"
				it.swDataDefProps = createSwDataDefProps => [
					it.swDataDefPropsVariants += createSwDataDefPropsConditional => [
						it.implementationDataType = createImplementationDataType => [
							it.category = "VALUE"
							it.shortName = "UInt32"
						]
					]
				]
			]
		]

		//when
		val result = francaTypeCreator.transform(aStructType)

		//then
		(result as FStructType).elements.assertOneElement.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void methodConversion() {
		//given
		val clientServerOperation = createClientServerOperation

		//when
		val result = ara2FrancaTransformation.transform(clientServerOperation)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}


	@Test
	def void arrayConversion() {
		//given
		val aArrayType = createImplementationDataType => [
			it.category = "VECTOR"
			it.subElements += createImplementationDataTypeElement => [
				it.category = "TYPE_REFERENCE"
				swDataDefProps = createSwDataDefProps => [
					swDataDefPropsVariants += createSwDataDefPropsConditional => [
						implementationDataType = createImplementationDataType => [
							it.category = "VALUE"
							it.shortName = "UInt32"
						]
					]
				]
			]
		]

		//when
		val result = francaTypeCreator.transform(aArrayType)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void structConversion() {
		//given
		val aStructType = createImplementationDataType => [
			it.category = "STRUCTURE"
		]

		//when
		val result = francaTypeCreator.transform(aStructType)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void unionConversion() {
		//given
		val aUnionType = createImplementationDataType => [
			it.category = "UNION"
		]

		//when
		val result = francaTypeCreator.transform(aUnionType)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void enumerationConversion() {
		//given
		val aEnumerationType = createImplementationDataType => [
			it.category = "TYPE_REFERENCE"
			it.swDataDefProps = createSwDataDefProps => [
				it.swDataDefPropsVariants += createSwDataDefPropsConditional => [
					compuMethod = createCompuMethod => [
						it.category = "TEXTTABLE"
						it.compuInternalToPhys = createCompu => [
							it.compuContent = createCompuScales => [
								it.compuScales += createCompuScale
							]
						]
					]
				]
			]
		]

		//when
		val result = francaEnumCreator.transformEnumeration(aEnumerationType)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void mapConversion() {
		//given
		val aPrimitiveType = createImplementationDataType => [
			it.category = "VALUE"
			it.shortName = "UInt32"
		]
		val aMapType = createImplementationDataType => [
			it.category = "ASSOCIATIVE_MAP"
			it.subElements += createImplementationDataTypeElement => [
				it.category = "TYPE_REFERENCE"
				it.swDataDefProps = createSwDataDefProps => [
					swDataDefPropsVariants += createSwDataDefPropsConditional => [
						implementationDataType = aPrimitiveType
					]
				]
			]
			it.subElements += createImplementationDataTypeElement => [
				it.category = "TYPE_REFERENCE"
				it.swDataDefProps = createSwDataDefProps => [
					swDataDefPropsVariants += createSwDataDefPropsConditional => [
						implementationDataType = aPrimitiveType
					]
				]
			]
		]

		//when
		val result = francaTypeCreator.transform(aMapType)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void typeDefConversion() {
		//given
		val aPrimitiveType = createImplementationDataType => [
			it.category = "VALUE"
			it.shortName = "UInt32"
		]
		val aTypeDef = createImplementationDataType => [
			it.category = "TYPE_REF"
			it.subElements += createImplementationDataTypeElement => [
				it.category = "TYPE_REFERENCE"
				swDataDefProps = createSwDataDefProps => [
					swDataDefPropsVariants += createSwDataDefPropsConditional => [
						implementationDataType = aPrimitiveType
					]
				]
			]
		]

		//when
		val result = francaTypeCreator.transform(aTypeDef)

		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void typeCollectionConversion() {
		//given
		val aTypeCollection = createARPackage => [
			it.elements += createImplementationDataType => [
				it.category = "STRUCTURE"
			]
		]
		
		//when
		val result = ara2FrancaTransformation.transform(aTypeCollection)
		
		//then
		result.typeCollections.assertOneElement.assertNotNullAndInstanceOfFModelElement
	}

	@Test
	def void interfaceConversion() {
		//given
		val aInterface = createServiceInterface
		
		//when
		val result = ara2FrancaTransformation.transform(aInterface)
		
		//then
		result.assertNotNullAndInstanceOfFModelElement
	}

	private def assertNotNullAndInstanceOfFModelElement(Object fObject){
		fObject.assertNotNull()
		fObject.assertIsInstanceOf(FModelElement)
	}

}
