package org.genivi.faracon.tests.aspects_on_franca_methods.a2f

import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.commonstructure.serviceneeds.ServiceProviderEnum
import autosar40.genericstructure.generaltemplateclasses.arpackage.PackageableElement
import autosar40.util.Autosar40Factory
import org.eclipse.emf.ecore.EClass
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FInterface
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertEquals

import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*
import static extension org.genivi.faracon.tests.util.FrancaAssertHelper.*
import org.franca.core.franca.FTypeCollection
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType

/**
 * Test name transformation of Autosar elements to franca elements 
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1470_Tests extends ARA2FrancaTestBase {

	static final String MODEL_ELEMENT_NAME = "ModelElementName"

	/**
	 * Test all AUTOSAR PackageableElements and check whether the transformation suceeds or not.
	 * The only PackageableElement, we currently transform is the ServiceInterface, i.e.
	 * only for the ServiceInterface, we check whether the name of the created Franca interface is the same.
	 * For all other elements, we check that no element has been created and that no error (Exception) occurs.
	 */
	@Test
	def void testTransformationOfPackageableElements() {
		// given: list of packageable elements eacht contained in a package
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

		// then: no exception and for service interface, we expect that a FInterface has been created
		results.assertElements(packagesWithPackagableElements.size)
		results.forEach [ result |
			if (result.key instanceof ServiceInterface) {
				// for service interfaces we expect a Franca Interface
				val francaInterface = result.value.eContents.assertOneElement.assertIsInstanceOf(FInterface)
				francaInterface.assertName(MODEL_ELEMENT_NAME)
			} else {
				// we do not expecte any model elements to be created, but the code not to crash 
				assertEquals('''No element was expected to be created for elememnt "«result.key»" but created the following elements "«result.value.eContents.join(", ")»".''',
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
