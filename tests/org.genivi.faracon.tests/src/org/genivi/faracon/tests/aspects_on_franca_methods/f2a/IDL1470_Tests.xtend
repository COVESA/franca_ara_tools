package org.genivi.faracon.tests.aspects_on_franca_methods.f2a

import autosar40.adaptiveplatform.applicationdesign.portinterface.Field
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.commonstructure.constants.ConstantSpecification
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable
import autosar40.swcomponent.datatype.computationmethod.CompuMethod
import autosar40.swcomponent.datatype.computationmethod.CompuScale
import autosar40.swcomponent.datatype.computationmethod.CompuScales
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import autosar40.swcomponent.portinterface.ArgumentDataPrototype
import autosar40.swcomponent.portinterface.ClientServerOperation
import com.google.inject.Inject
import java.math.BigInteger
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FArgument
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FIntegerInterval
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMapType
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeCollection
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FUnionType
import org.genivi.faracon.Franca2ARATransformation
import org.genivi.faracon.franca2ara.ARAConstantsCreator
import org.genivi.faracon.franca2ara.ARAModelSkeletonCreator
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.logging.AbstractLogger
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertTrue

/**
 * The mapping of this feature is tested by instantiating concrete subclasses of 'FModelElement', 
 * converting these instances, and checking if the conversion results have the same name as the input model elements.
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
 * Also tests IDL1600, IDL1610, IDL1630, IDL2590, IDL2600, and IDL2610.
 */
@RunWith(XtextRunner2_Franca)
@InjectWith(FaraconTestsInjectorProvider)
class IDL1470_Tests extends Franca2ARATestBase {

	static final String MODEL_ELEMENT_NAME = "ModelElementName"

	@Inject
	var Franca2ARATransformation franca2ARATransformation

	@Inject
	var ARATypeCreator araTypeCreator

	@Inject
	var ARAConstantsCreator araConstantsCreator

	@Inject
	var extension ARAModelSkeletonCreator araModelSkeletonCreator

	@Test
	def void broadcastConversion() {
		val FBroadcast fBroadcast = francaFac.createFBroadcast => [
			name = MODEL_ELEMENT_NAME
		]
		val FInterface fParentInterface = francaFac.createFInterface => [
			broadcasts += fBroadcast
		]
		val ARPackage arInterfacePackage = araFac.createARPackage
		val VariableDataPrototype variableDataPrototype = franca2ARATransformation.transform(fBroadcast, fParentInterface, arInterfacePackage)
		checkNamesEquality(fBroadcast, variableDataPrototype)
	}

	@Test
	def void enumeratorConversion() {
		val FEnumerator fEnumerator = francaFac.createFEnumerator => [
			name = MODEL_ELEMENT_NAME
		]
		val FEnumerationType fEnumerationType = francaFac.createFEnumerationType => [
			enumerators += fEnumerator
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fEnumerationType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fEnumerationType)
		val CompuMethod enumCompuMethod = autosarDataType.swDataDefProps.swDataDefPropsVariants.head.compuMethod
		for(enumeratorCompuScale : (enumCompuMethod.compuInternalToPhys.compuContent as CompuScales).compuScales) {
			checkNamesEquality(fEnumerator, enumeratorCompuScale)
		}
	}

	@Test
	def void argumentConversion() {
		val FArgument fArgument = francaFac.createFArgument => [
			name = MODEL_ELEMENT_NAME
			type = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FInterface fParentInterface = francaFac.createFInterface
		val ArgumentDataPrototype argumentDataPrototype = franca2ARATransformation.transform(fArgument, true, fParentInterface)
		checkNamesEquality(fArgument, argumentDataPrototype)
	}

	@Test
	def void attributeConversion() {
		val FAttribute fAttribute = francaFac.createFAttribute => [
			name = MODEL_ELEMENT_NAME
			type = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FInterface fParentInterface = francaFac.createFInterface => [
			attributes += fAttribute
		]
		val Field field = franca2ARATransformation.transform(fAttribute, fParentInterface)
		checkNamesEquality(fAttribute, field)
	}

	@Test
	def void constantDefConversion() {
		val FConstantDef fConstantDef = francaFac.createFConstantDef => [
			it.name = MODEL_ELEMENT_NAME
			it.type = francaFac.createFTypeRef => [
				it.predefined = FBasicTypeId.DOUBLE
			]
			it.rhs = francaFac.createFDoubleConstant => [
				it.^val = 12.456
			]
		]
		val ConstantSpecification constantSpecification = araConstantsCreator.transform(fConstantDef)
		checkNamesEquality(fConstantDef, constantSpecification)
	}

	@Test
	def void fieldConversion() {
		val FField fField = francaFac.createFField => [
			name = MODEL_ELEMENT_NAME
			type = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			] 				
		]
		val FStructType fStructType = francaFac.createFStructType => [
			elements += fField
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fStructType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fStructType)
		for(subElement : (autosarDataType as ImplementationDataType).subElements) {
			checkNamesEquality(fField, subElement)
		}
	}

	@Test
	def void methodConversion() {
		val FMethod fMethod = francaFac.createFMethod => [
			name = MODEL_ELEMENT_NAME
		]
		val FInterface fParentInterface = francaFac.createFInterface => [
			methods += fMethod
		]
		val ClientServerOperation clientServerOperation = franca2ARATransformation.transform(fMethod, fParentInterface)
		checkNamesEquality(fMethod, clientServerOperation)
	}

	@Test
	def void arrayConversion() {
		val FArrayType fArrayType = francaFac.createFArrayType => [
			name = MODEL_ELEMENT_NAME
			elementType = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fArrayType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fArrayType)
		checkNamesEquality(fArrayType, autosarDataType)
	}

	@Test
	def void structConversion() {
		val FStructType fStructType = francaFac.createFStructType => [
			name = MODEL_ELEMENT_NAME
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fStructType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fStructType)
		checkNamesEquality(fStructType, autosarDataType)
	}

	@Test
	def void unionConversion() {
		val FUnionType fUnionType = francaFac.createFUnionType => [
			name = MODEL_ELEMENT_NAME
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fUnionType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fUnionType)
		checkNamesEquality(fUnionType, autosarDataType)
	}

	@Test
	def void enumerationConversion() {
		val FEnumerationType fEnumerationType = francaFac.createFEnumerationType => [
			name = MODEL_ELEMENT_NAME
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fEnumerationType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fEnumerationType)
		checkNamesEquality(fEnumerationType, autosarDataType)
	}

	@Test(expected = AbstractLogger.StopOnErrorException)
	def void integerIntervalConversion() {
		val FIntegerInterval fIntegerInterval = francaFac.createFIntegerInterval => [
			name = MODEL_ELEMENT_NAME
			lowerBound = new BigInteger("-19")
			upperBound = new BigInteger("972")
		]
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fIntegerInterval)
		checkNamesEquality(fIntegerInterval, autosarDataType)
	}

	@Test
	def void mapConversion() {
		val FMapType fMapType = francaFac.createFMapType => [
			name = MODEL_ELEMENT_NAME
			keyType = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
			valueType = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fMapType
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fMapType)
		checkNamesEquality(fMapType, autosarDataType)
	}

	@Test
	def void typeDefConversion() {
		val FTypeDef fTypeDef = francaFac.createFTypeDef => [
			name = MODEL_ELEMENT_NAME
			actualType = francaFac.createFTypeRef => [
				predefined = FBasicTypeId.UINT32
			]
		]
		val FModel fModel = francaFac.createFModel => [
			name = "a1.b2.c3"
			interfaces += francaFac.createFInterface => [
				types += fTypeDef
			]
		]
		fModel.createAutosarModelSkeleton
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fTypeDef)
		checkNamesEquality(fTypeDef, autosarDataType)
	}

	@Test
	def void typeCollectionConversion() {
		val FTypeCollection fTypeCollection = francaFac.createFTypeCollection => [
			name = MODEL_ELEMENT_NAME
		]
		// Create a FModel and add the type collection to it as type collections need to be contained in a FModel.
		val FModel fModel = francaFac.createFModel => [
			it.name = "a1.b2.c3"
			it.typeCollections += fTypeCollection
		]
		fModel.createAutosarModelSkeleton
		franca2ARATransformation.transform(fTypeCollection)
		val accordingArPackage = fTypeCollection.accordingArPackage
		checkNamesEquality(fTypeCollection, accordingArPackage)
	}

	@Test
	def void interfaceConversion() {
		val FInterface fInterface = francaFac.createFInterface => [
			name = MODEL_ELEMENT_NAME
		]
		// Create a FModel and add the interface to it as interfaces need to be contained in a FModel.
		createFModel => [
			it.name = "a1.b2.c3"
			it.interfaces += fInterface
		]
		val ServiceInterface serviceInterface = franca2ARATransformation.transform(fInterface)
		checkNamesEquality(fInterface, serviceInterface)
	}

	dispatch def void checkNamesEquality(FModelElement fModelElement, Referrable referrable) {
		assertTrue(fModelElement.name == referrable.shortName && referrable.shortName == MODEL_ELEMENT_NAME)
	}

	dispatch def void checkNamesEquality(FModelElement fModelElement, CompuScale compuScale) {
		assertTrue(fModelElement.name == compuScale.symbol && compuScale.symbol == MODEL_ELEMENT_NAME)
	}

}
