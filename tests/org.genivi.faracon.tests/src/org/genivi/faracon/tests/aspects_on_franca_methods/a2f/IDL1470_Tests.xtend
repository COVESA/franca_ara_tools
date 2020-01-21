package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.commonstructure.constants.ConstantSpecification
import autosar40.commonstructure.serviceneeds.ServiceProviderEnum
import autosar40.genericstructure.generaltemplateclasses.arpackage.PackageableElement
import autosar40.util.Autosar40Factory
import com.google.inject.Inject
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FInterface
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.genivi.faracon.ara2franca.FrancaConstantsCreator
import org.genivi.faracon.ara2franca.FrancaEnumCreator
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*

/**
 * Test name transformation of Autosar elements to franca elements 
 * Hierarchy of Franca metaclasses below 'FModelElement':
 *
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
class IDL1470_Tests extends ARA2FrancaTestBase {

	static final String MODEL_ELEMENT_NAME = "ModelElementName"

	@Inject
	var extension FrancaTypeCreator francaTypeCreator

	@Inject
	var extension FrancaEnumCreator francaEnumCreator

	@Inject
	var extension FrancaConstantsCreator francaConstantsCreator

	@Test
	def void broadcastConversion() {
		// given
		val event = createVariableDataPrototype => [
			it.shortName = MODEL_ELEMENT_NAME
		]
		ara2FrancaTransformation.logger.enableContinueOnErrors(true)
		
		//when
		val result = ara2FrancaTransformation.transform(event)
		
		//then
		result.assertName(MODEL_ELEMENT_NAME)
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
								it.compuScales += createCompuScale => [
									it.symbol = MODEL_ELEMENT_NAME
								]
							]
						]
					]
				]
			]
		]

		//when
		val result = francaEnumCreator.transformEnumeration(aEnumerationType)

		//then
		result.enumerators.assertOneElement.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void argumentConversion() {
		//given
		val aArgument = createArgumentDataPrototype => [
			it.shortName = MODEL_ELEMENT_NAME
			it.type = createImplementationDataType => [
				it.category = "VALUE"
				it.shortName = "UInt32"
			]
		]

		//when
		val result = ara2FrancaTransformation.transform(aArgument)

		//then
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void attributeConversion() {
		//given
		val aAttribute = createField => [
			it.shortName = MODEL_ELEMENT_NAME
			it.type = createImplementationDataType => [
				it.category = "VALUE"
				it.shortName = "UInt32"
			]
		]

		//when
		val result = ara2FrancaTransformation.transform(aAttribute)

		//then
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void constantDefConversion() {
		//given
		val aConstantDef = createConstantSpecification => [
			it.shortName = MODEL_ELEMENT_NAME
			it.valueSpec = createNumericalValueSpecification => [
				it.value = createNumericalValueVariationPoint => [
					it.mixedText = "123"
				]
			]
		]

		//when
		val result = francaConstantsCreator.transform(aConstantDef, null)

		//then
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void fieldConversion() {
		//given
		val aStructType = createImplementationDataType => [
			it.category = "STRUCTURE"
			it.subElements += createImplementationDataTypeElement => [
				it.shortName = MODEL_ELEMENT_NAME
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
		(result as FStructType).elements.assertOneElement.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void methodConversion() {
		//given
		val clientServerOperation = createClientServerOperation => [
			it.shortName = MODEL_ELEMENT_NAME
		]

		//when
		val result = ara2FrancaTransformation.transform(clientServerOperation)

		//then
		result.assertName(MODEL_ELEMENT_NAME)
	}


	@Test
	def void arrayConversion() {
		//given
		val aArrayType = createImplementationDataType => [
			it.shortName = MODEL_ELEMENT_NAME
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
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void structConversion() {
		//given
		val aStructType = createImplementationDataType => [
			it.shortName = MODEL_ELEMENT_NAME
			it.category = "STRUCTURE"
		]

		//when
		val result = francaTypeCreator.transform(aStructType)

		//then
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void unionConversion() {
		//given
		val aUnionType = createImplementationDataType => [
			it.shortName = MODEL_ELEMENT_NAME
			it.category = "UNION"
		]

		//when
		val result = francaTypeCreator.transform(aUnionType)

		//then
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void enumerationConversion() {
		//given
		val aEnumerationType = createImplementationDataType => [
			it.shortName = MODEL_ELEMENT_NAME
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
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void mapConversion() {
		//given
		val aPrimitiveType = createImplementationDataType => [
			it.category = "VALUE"
			it.shortName = "UInt32"
		]
		val aMapType = createImplementationDataType => [
			it.shortName = MODEL_ELEMENT_NAME
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
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void typeDefConversion() {
		//given
		val aPrimitiveType = createImplementationDataType => [
			it.category = "VALUE"
			it.shortName = "UInt32"
		]
		val aTypeDef = createImplementationDataType => [
			it.shortName = MODEL_ELEMENT_NAME
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
		result.assertName(MODEL_ELEMENT_NAME)
	}

	@Test
	def void typeCollectionConversion() {
		//given
		val aTypeCollection = createARPackage => [
			it.shortName = MODEL_ELEMENT_NAME
			it.elements += createImplementationDataType => [
				it.category = "STRUCTURE"
			]
		]
		
		//when
		val result = ara2FrancaTransformation.transform(aTypeCollection)
		
		//then
		result.assertNamespace(MODEL_ELEMENT_NAME)
	}

	@Test
	def void interfaceConversion() {
		//given
		val aInterface = createServiceInterface => [
			it.shortName = MODEL_ELEMENT_NAME
		]
		
		//when
		val result = ara2FrancaTransformation.transform(aInterface)
		
		//then
		result.assertName(MODEL_ELEMENT_NAME)
	}

	/**
	 * Test all AUTOSAR PackageableElements and check whether the transformation succeeds or not.
	 * The only PackageableElements, we currently transform are the ServiceInterface and ConstantSpecification.
	 * I.e., only for these PackageableElements, we check whether the name of the created conversion result is the same.
	 * For all other elements, we check that no element has been created and that no error (Exception) occurs.
	 */
	@Test
	def void testTransformationOfPackageableElements() {
		// given: list of packageable elements each contained in a package
		val packagesWithPackagableElements = packageableElementInstances.map [ packElement |
			val arTestPackage = createARPackage => [
				shortName = "ModelElementPackage"
				elements += packElement
			]
			return packElement -> arTestPackage
		]

		// when: all packages are tranformed to franca
		val results = packagesWithPackagableElements.map [
			it.key -> ara2FrancaTransformation.transform(it.value)
		]

		// then: no exception and for a service interface and for a constant specification, we expect some specific conversion result
		results.assertElements(packagesWithPackagableElements.size)
		results.forEach [ result |
			if (result.key instanceof ServiceInterface) {
				// for service interfaces we expect a Franca Interface
				val francaInterface = result.value.eContents.assertOneElement.assertIsInstanceOf(FInterface)
				francaInterface.assertName(MODEL_ELEMENT_NAME)
			} else if (result.key instanceof ConstantSpecification) {
				// for an AUTOSAR constant specification we expect a Franca constant definition in a Franca type collection
				val fTypeCollection = result.value.eContents.assertOneElement.assertIsInstanceOf(FTypeCollection)
				val fConstantDef = fTypeCollection.constants.assertOneElement.assertIsInstanceOf(FConstantDef)
				fConstantDef.assertName(MODEL_ELEMENT_NAME)
			} else {
				// we do not expecte any model elements to be created, but the code not to crash 
				assertEquals('''No element was expected to be created for element "«result.key»" but created the following elements "«result.value.eContents.join(", ")»".''',
					0, result.value.eContents.size )
			}
		]
	}

	@Test
	def void testTransformationOfServiceInterfaceContent() {
		// given: a interface with all elements set
		ara2FrancaTransformation.logger.enableContinueOnErrors(true)
		val serviceInterface = createServiceInterface => [
			shortName = MODEL_ELEMENT_NAME
			setIsService = true
			namespaces += createSymbolProps => [it.shortName = "namespace"]
			serviceKind = ServiceProviderEnum.ANY_STANDARDIZED
			events += createVariableDataPrototype => [shortName = MODEL_ELEMENT_NAME]
			fields += createField => [shortName = MODEL_ELEMENT_NAME]
			methods += createClientServerOperation => [shortName = MODEL_ELEMENT_NAME]
		]

		// when
		val result = ara2FrancaTransformation.transform(serviceInterface)

		// then
		result.assertName(MODEL_ELEMENT_NAME)
		result.broadcasts.assertOneElement.assertName(MODEL_ELEMENT_NAME)
		result.methods.assertOneElement.assertName(MODEL_ELEMENT_NAME)
		result.attributes.assertOneElement.assertName(MODEL_ELEMENT_NAME)
	}

	/**
	 * Initializes all subclasses of PackageableElement and returns instances with the name
	 * MODEL_ELEMENT_NAME.
	 */
	def private getPackageableElementInstances() {
		val arClassifiers = Autosar40Factory.eINSTANCE.EPackage.EClassifiers
		val packageableElementEClasses = arClassifiers.filter(EClass).filter [
			PackageableElement.isAssignableFrom(it.instanceClass) && !it.abstract
		]
		val packageableElements = packageableElementEClasses.map [
			val PackageableElement element = arFactory.create(it) as PackageableElement
			element.shortName = MODEL_ELEMENT_NAME
			return element
		].toList
		return packageableElements
	}

}
