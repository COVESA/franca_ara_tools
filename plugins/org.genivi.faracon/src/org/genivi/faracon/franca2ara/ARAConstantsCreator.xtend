package org.genivi.faracon.franca2ara

import autosar40.commonstructure.constants.ValueSpecification
import com.google.inject.Inject
import java.math.BigInteger
import javax.inject.Singleton
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FBracketInitializer
import org.franca.core.franca.FCompoundInitializer
import org.franca.core.franca.FCompoundType
import org.franca.core.franca.FConstantDef
import org.franca.core.franca.FDoubleConstant
import org.franca.core.franca.FEnumerationType
import org.franca.core.franca.FEnumerator
import org.franca.core.franca.FFloatConstant
import org.franca.core.franca.FInitializerExpression
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FMapType
import org.franca.core.franca.FOperator
import org.franca.core.franca.FQualifiedElementRef
import org.franca.core.franca.FStringConstant
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.franca.core.franca.FUnaryOperation
import org.franca.core.franca.FUnionType
import org.genivi.faracon.Franca2ARABase

import static extension org.genivi.faracon.franca2ara.ARATypeHelper.*
import static org.franca.core.framework.FrancaHelpers.*

@Singleton
class ARAConstantsCreator extends Franca2ARABase {

	@Inject
	var extension AutosarAnnotator
	@Inject
	var extension AutosarSpecialDataGroupCreator

	static final String ANNOTATION_LABEL_ORIGINAL_LITERAL_VALUE_TYPE = "OriginalLiteralValueType"

	def create fac.createConstantSpecification transform(FConstantDef fConstantDef) {
		shortName = fConstantDef.name		
		it.addSdgForFrancaElement(fConstantDef)
		it.valueSpec = fConstantDef.rhs.createValueSpecification(fConstantDef)

		val typeString = getTypeString(fConstantDef, fConstantDef.rhs)
		if (typeString !== null) {
			it.addAnnotation(
				ANNOTATION_LABEL_ORIGINAL_LITERAL_VALUE_TYPE,
				typeString
			)
		}
	}

	private def ValueSpecification createValueSpecification(FInitializerExpression fInitializerExpression, FConstantDef fConstantDef) {
		fInitializerExpression.createValueSpecification(fConstantDef, 1)
	}

	private dispatch def ValueSpecification createValueSpecification(FInitializerExpression fInitializerExpression, FConstantDef fConstantDef, int negationFactor) {
		getLogger.
			logWarning('''Cannot properly create an AUTOSAR literal for the constant definition «fConstantDef.ARFullyQualifiedName» because the Franca literal metaclass «fInitializerExpression.eClass.name» is not yet supported.''')
		return null
	}

	private dispatch def ValueSpecification createValueSpecification(FUnaryOperation fUnaryOperation, FConstantDef fConstantDef, int negationFactor) {
		if (fUnaryOperation.op == FOperator.SUBTRACTION) {
			fUnaryOperation.operand.createValueSpecification(fConstantDef, -negationFactor)
		} else {
		getLogger.
			logWarning('''Cannot properly create an AUTOSAR literal for the constant definition «fConstantDef.ARFullyQualifiedName» because the unary Franca operator "«fUnaryOperation.op.literal»" is not yet supported.''')
		return null
		}
	}

	private dispatch def ValueSpecification create fac.createNumericalValueSpecification createValueSpecification(FIntegerConstant fIntegerConstant, FConstantDef fConstantDef, int negationFactor) {
		val BigInteger literalValue = BigInteger.valueOf(negationFactor) * fIntegerConstant.^val
		it.value = fac.createNumericalValueVariationPoint => [
			it.mixedText = literalValue.toString
		]
	}

	private dispatch def ValueSpecification create fac.createNumericalValueSpecification createValueSpecification(FDoubleConstant fDoubleConstant, FConstantDef fConstantDef, int negationFactor) {
		val double literalValue = negationFactor * fDoubleConstant.^val
		it.value = fac.createNumericalValueVariationPoint => [
			it.mixedText = literalValue.toString
		]
	}

	private dispatch def ValueSpecification create fac.createNumericalValueSpecification createValueSpecification(FFloatConstant fFloatConstant, FConstantDef fConstantDef, int negationFactor) {
		val float literalValue = negationFactor * fFloatConstant.^val
		it.value = fac.createNumericalValueVariationPoint => [
			it.mixedText = literalValue.toString
		]
	}

	// Because it is unclear how to represent a string type literal we use 'TextValueSpecification' for this purpose
	// although the AUTOSAR specification "AUTOSAR_TPS_SoftwareComponentTemplate.pdf" says:
	// "It’s important to understand that although the name of the meta-class TextValue-
	//  Specification suggests that it is the preferred way for the definition of an invalidValue
	//  or initValue of a VariableDataPrototype/ParameterDataPrototype
	//  typed by an ApplicationPrimitiveDataType of category STRING the
	//  TextValueSpecification actually has a different purpose (as defined by [constr_
	//  1284]).
	//  [constr_1284] Limitation of the use of TextValueSpecification d TextValueSpecification
	//  shall only be used in the context of an AutosarDataType that
	//  references a CompuMethod in the role ImplementationDataType.swDataDef-
	//  Props.compuMethod of category TEXTTABLE and BITFIELD_TEXTTABLE. c()
	//  In other words, the purpose of TextValueSpecification is to define the labels that
	//  correspond to enumeration values. The constraints [constr_1225] and [constr_1284]
	//  correspond to each other such that [constr_1225] demands the usage of TextValueSpecification
	//  for the definition of labels for enumeration values while [constr_
	//  1284] says that the definition of labels for enumeration values is the only use case
	//  for TextValueSpecification."
	private dispatch def ValueSpecification create fac.createTextValueSpecification createValueSpecification(FStringConstant fStringConstant, FConstantDef fConstantDef, int negationFactor) {
		val String literalValue = fStringConstant.^val
		it.value = literalValue
	}

	// Because there seems to be no direct representation for boolean type literals in AUTOSAR we use a string type literal instead.
	// Notice that this violates the limitation given for 'TextValueSpecification' in the same way as described above
	// for the regular string type literals!
	private dispatch def ValueSpecification create fac.createTextValueSpecification createValueSpecification(FBooleanConstant fBooleanConstant, FConstantDef fConstantDef, int negationFactor) {
		val boolean literalValue = fBooleanConstant.^val
		it.value = literalValue.toString
	}

	// Because there seems to be no better way to refer to enumerators in AUTOSAR we use a string type literal instead.
	// Notice that this violates the limitation given for 'TextValueSpecification' in the same way as described above
	// for the regular string type literals!
	private dispatch def ValueSpecification create fac.createTextValueSpecification createValueSpecification(FQualifiedElementRef fQualifiedElementRef, FConstantDef fConstantDef, int negationFactor) {
		it.value = fQualifiedElementRef.element.ARFullyQualifiedName
	}

	// For array, byte buffer, and map literals.
	private dispatch def ValueSpecification create fac.createArrayValueSpecification createValueSpecification(FBracketInitializer fBracketInitializer, FConstantDef fConstantDef, int negationFactor) {
		it.elements += fBracketInitializer.elements.map[element |
			if (element.second !== null) {
				fac.createRecordValueSpecification => [
					fields += element.first.createValueSpecification(fConstantDef)
					fields += element.second.createValueSpecification(fConstantDef)
				]
			} else {
				element.first.createValueSpecification(fConstantDef)
			}
		]
	}

	// For record and union literals.
	private dispatch def ValueSpecification create fac.createRecordValueSpecification createValueSpecification(FCompoundInitializer fCompoundInitializer, FConstantDef fConstantDef, int negationFactor) {
		it.fields += fCompoundInitializer.elements.map[it.value.createValueSpecification(fConstantDef)]
	}


	private dispatch def String getTypeString(FTypedElement fTypedElement, FInitializerExpression fInitializerExpression) {
		if (fTypedElement.array && fInitializerExpression instanceof FBracketInitializer) {
			val fBracketInitializer = fInitializerExpression as FBracketInitializer
			getArrayTypeString(fTypedElement.type, fBracketInitializer)
		} else {
			getTypeString(fTypedElement.type, fInitializerExpression)
		}
	}

	private dispatch def String getTypeString(FTypeRef fTypeRef, FInitializerExpression fInitializerExpression) {
		val fBasicTypeId = getActualPredefined(fTypeRef)
		if (fBasicTypeId !== null) {
			return fBasicTypeId.literal
		}
		
		val fType = getActualDerived(fTypeRef)
		if (fType !== null) {
			return getTypeString(fType, fInitializerExpression)
		}

		return null
	}

	private dispatch def String getTypeString(FType fType, FInitializerExpression fInitializerExpression) {
		null
	}

	private dispatch def String getTypeString(FArrayType fArrayType, FBracketInitializer fBracketInitializer) {
		getArrayTypeString(fArrayType.elementType, fBracketInitializer)
	}

	private def String getArrayTypeString(FTypeRef fArrayElementTypeRef, FBracketInitializer fBracketInitializer) {
		val elementsString = fBracketInitializer.elements.map[fElementInitializer|
			getTypeString(fArrayElementTypeRef, fElementInitializer.first)
		].reduce[s1, s2|s1 + ", " + s2]
		"array [" + (elementsString !== null ? elementsString : "") + "]"
	}

	private dispatch def String getTypeString(FMapType fMapType, FBracketInitializer fBracketInitializer) {
		val elementsString = fBracketInitializer.elements.map[fElementInitializer|
			getTypeString(fMapType.keyType, fElementInitializer.first) +
			" => " +
			getTypeString(fMapType.valueType, fElementInitializer.second)
		].reduce[s1, s2|s1 + ", " + s2]
		"map [" + (elementsString !== null ? elementsString : "") + "]"
	}

	private dispatch def String getTypeString(FStructType fStructType, FCompoundInitializer fCompoundInitializer) {
		"struct " + getCompoundTypeString(fStructType, fCompoundInitializer)
	}

	private dispatch def String getTypeString(FUnionType fUnionType, FCompoundInitializer fCompoundInitializer) {
		"union " + getCompoundTypeString(fUnionType, fCompoundInitializer)
	}

	private def String getCompoundTypeString(FCompoundType fCompoundType, FCompoundInitializer fCompoundInitializer) {
		val elementsString = fCompoundInitializer.elements.map[fFieldInitializer|
			fFieldInitializer.element.name + " : " + getTypeString(fFieldInitializer.element, fFieldInitializer.value)
		].reduce[s1, s2|s1 + ", " + s2]
		"{" + (elementsString !== null ? elementsString : "") + "}"
	}

	private dispatch def String getTypeString(FEnumerationType fEnumerationType, FInitializerExpression fInitializerExpression) {
		"enumeration " + fEnumerationType.name
	}

}
