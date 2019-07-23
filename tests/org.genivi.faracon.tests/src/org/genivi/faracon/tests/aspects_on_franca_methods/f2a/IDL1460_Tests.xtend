package org.genivi.faracon.tests.aspects_on_franca_methods.f2a

import autosar40.adaptiveplatform.applicationdesign.portinterface.Field
import autosar40.adaptiveplatform.applicationdesign.portinterface.ServiceInterface
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable
import autosar40.swcomponent.datatype.dataprototypes.VariableDataPrototype
import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import autosar40.swcomponent.portinterface.ArgumentDataPrototype
import autosar40.swcomponent.portinterface.ClientServerOperation
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.franca.core.dsl.tests.util.XtextRunner2_Franca
import org.franca.core.franca.FArgument
import org.franca.core.franca.FAttribute
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FField
import org.franca.core.franca.FInterface
import org.franca.core.franca.FMethod
import org.franca.core.franca.FModelElement
import org.franca.core.franca.FStructType
import org.franca.core.franca.FTypeRef
import org.genivi.faracon.Franca2ARATransformation
import org.genivi.faracon.franca2ara.ARAPrimitveTypesCreator
import org.genivi.faracon.franca2ara.ARATypeCreator
import org.genivi.faracon.tests.util.FaraconTestsInjectorProvider
import org.genivi.faracon.tests.util.Franca2ARATestBase
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.assertTrue

/**
 * Hierarchy of Franca meta classes below 'FModelElement':
 *    FModelElement            {abstract}
 *       FBroadcast
 *       FEvaluableElement     {abstract}
 *          FEnumerator
 *          FTypedElement      {abstract}
 *             FArgument
 *             FAttribute
 *             FConstantDef    {IGNORE (A18)}
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
 *          FIntegerInterval
 *          FMapType
 *          FTypeDef
 *       FTypeCollection
 *          FInterface
 * 
 */
@RunWith(typeof(XtextRunner2_Franca))
@InjectWith(typeof(FaraconTestsInjectorProvider))
class IDL1460_Tests extends Franca2ARATestBase {

	@Inject
	var Franca2ARATransformation franca2ARATransformation

	@Inject
	var ARATypeCreator araTypeCreator

	@Inject
	var ARAPrimitveTypesCreator araPrimitveTypesCreator

	@Test
	def void broadcastConversion() {
		val FBroadcast fBroadcast = francaFac.createFBroadcast
		val FInterface fParentInterface = francaFac.createFInterface
		fParentInterface.broadcasts.add(fBroadcast)
		val VariableDataPrototype variableDataPrototype = franca2ARATransformation.transform(fBroadcast, fParentInterface)
		checkAbstractBaseClasses(fBroadcast, variableDataPrototype)
	}

	@Test
	def void enumeratorConversion() {
		val FEnumerator fEnumerator = francaFac.createFEnumerator
		//TODO: Transform enumerator (transformation not implemented yet) and check abstract base classes.
		//testAbstractBaseClasses(fEnumerator, )
	}

	@Test
	def void argumentConversion() {
		araPrimitveTypesCreator.createPrimitiveTypesPackage(null)
		val FArgument fArgument = francaFac.createFArgument
		val FTypeRef fTypeRef = francaFac.createFTypeRef
		fTypeRef.predefined = FBasicTypeId.UINT32
		fArgument.type = fTypeRef
		val FInterface fParentInterface = francaFac.createFInterface
		val ArgumentDataPrototype argumentDataPrototype = franca2ARATransformation.transform(fArgument, true, fParentInterface)
		checkAbstractBaseClasses(fArgument, argumentDataPrototype)
	}

	@Test
	def void attributeConversion() {
		araPrimitveTypesCreator.createPrimitiveTypesPackage(null)
		val FAttribute fAttribute = francaFac.createFAttribute
		val FTypeRef fTypeRef = francaFac.createFTypeRef
		fTypeRef.predefined = FBasicTypeId.UINT32
		fAttribute.type = fTypeRef
		val FInterface fParentInterface = francaFac.createFInterface
		fParentInterface.attributes.add(fAttribute)
		val Field field = franca2ARATransformation.transform(fAttribute, fParentInterface)
		checkAbstractBaseClasses(fAttribute, field)
	}

	@Test
	def void fieldConversion() {
		araPrimitveTypesCreator.createPrimitiveTypesPackage(null)
		val FStructType fStructType = francaFac.createFStructType
		val FField fField = francaFac.createFField
		val FTypeRef fTypeRef = francaFac.createFTypeRef
		fTypeRef.predefined = FBasicTypeId.UINT32
		fField.type = fTypeRef
		fStructType.elements.add(fField)
		val AutosarDataType autosarDataType = araTypeCreator.getDataTypeForReference(fStructType)
		for(subElement : (autosarDataType as ImplementationDataType).subElements) {
			checkAbstractBaseClasses(fField, subElement)
		}
	}

	@Test
	def void methodConversion() {
		val FMethod fMethod = francaFac.createFMethod
		val FInterface fParentInterface = francaFac.createFInterface
		fParentInterface.methods.add(fMethod)
		val ClientServerOperation clientServerOperation = franca2ARATransformation.transform(fMethod, fParentInterface)
		checkAbstractBaseClasses(fMethod, clientServerOperation)
	}





	@Test
	def void interfaceConversion() {
		val FInterface fInterface = francaFac.createFInterface
		val ARPackage arPackage = araFac.createARPackage
		val ServiceInterface serviceInterface = franca2ARATransformation.transform(fInterface, arPackage)
		checkAbstractBaseClasses(fInterface, serviceInterface)
	}





	def void checkAbstractBaseClasses(FModelElement fModelElement, Referrable referrable) {
		assertTrue((fModelElement === null && referrable === null) || (fModelElement !== null && referrable !== null))
	}
}
