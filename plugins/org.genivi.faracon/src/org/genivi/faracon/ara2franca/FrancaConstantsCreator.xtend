package org.genivi.faracon.ara2franca

import autosar40.commonstructure.constants.ArrayValueSpecification
import autosar40.commonstructure.constants.CompositeValueSpecification
import autosar40.commonstructure.constants.ConstantSpecification
import autosar40.commonstructure.constants.NumericalValueSpecification
import autosar40.commonstructure.constants.RecordValueSpecification
import autosar40.commonstructure.constants.TextValueSpecification
import autosar40.commonstructure.constants.ValueSpecification
import com.google.inject.Inject
import com.google.inject.Singleton
import org.franca.core.franca.FArrayType
import org.franca.core.franca.FBasicTypeId
import org.franca.core.franca.FInitializerExpression
import org.franca.core.franca.FModel
import org.franca.core.franca.FStructType
import org.franca.core.franca.FType
import org.franca.core.franca.FTypeDef
import org.franca.core.franca.FTypeRef
import org.franca.core.franca.FTypedElement
import org.genivi.faracon.ARA2FrancaBase

import static org.franca.core.framework.FrancaHelpers.*

@Singleton
class FrancaConstantsCreator extends ARA2FrancaBase {
	
	@Inject
	var extension FrancaTypeCreator francaTypeCreator


	var nextFreeArrayTypeIndex = 1
	var nextFreeStructTypeIndex = 1

	def resetArtificialTypesIndices() {
		nextFreeArrayTypeIndex = 1
		nextFreeStructTypeIndex = 1
	}

	def create fac.createFConstantDef transform(ConstantSpecification src, FModel fModel) {
		it.name = src.shortName
		it.type = src.valueSpec.getConstantType(it, fModel)
		it.rhs = src.valueSpec.createInitializerExpressionForFTypedElement(it)
	}

	private def FInitializerExpression createInitializerExpressionForFTypedElement(ValueSpecification aValueSpecification, FTypedElement fTypedElement) {
		if (fTypedElement.array) {
			if (aValueSpecification instanceof ArrayValueSpecification) {
				return fac.createFBracketInitializer => [
					it.elements += aValueSpecification.elements.map[element |
						fac.createFElementInitializer => [
							it.first = element.createInitializerExpressionForFTypeRef(fTypedElement.type)
						]
					]
				]
			}
		}
		aValueSpecification.createInitializerExpressionForFTypeRef(fTypedElement.type)
	}

	private def FInitializerExpression createInitializerExpressionForFTypeRef(ValueSpecification aValueSpecification, FTypeRef fTypeRef) {
		val fActualDerivedType = getActualDerived(fTypeRef)
		if (fActualDerivedType !== null) {
			// Handle derived types.
			createInitializerExpressionForFType(aValueSpecification as CompositeValueSpecification, fActualDerivedType)
		} else {
			// Handle predefined primitive types.
			createPrimitiveInitializerExpression(aValueSpecification)
		}
	}

	private dispatch def FInitializerExpression create fac.createFBracketInitializer createInitializerExpressionForFType(ArrayValueSpecification aArrayValueSpecification, FArrayType fArrayType) {
		it.elements += aArrayValueSpecification.elements.map[element |
			fac.createFElementInitializer => [
				it.first = element.createInitializerExpressionForFTypeRef(fArrayType.elementType)
			]
		]
	}

	private dispatch def FInitializerExpression create fac.createFCompoundInitializer createInitializerExpressionForFType(RecordValueSpecification aRecordValueSpecification, FStructType fStructType) {
		for (var fieldIndex = 0; fieldIndex < aRecordValueSpecification.fields.size; fieldIndex++) {
			val _fieldIndex = fieldIndex
			it.elements += fac.createFFieldInitializer => [
				val fField = fStructType.elements.get(_fieldIndex)
				it.element = fField
				it.value = aRecordValueSpecification.fields.get(_fieldIndex).createInitializerExpressionForFTypedElement(fField)
			]
		}
	}

	private dispatch def FInitializerExpression create fac.createFStringConstant createPrimitiveInitializerExpression(ValueSpecification aValueSpecification) {
		it.^val = "<unknown value>"
	}

	private dispatch def FInitializerExpression create fac.createFDoubleConstant createPrimitiveInitializerExpression(NumericalValueSpecification aNumericalValueSpecification) {
		it.^val = Double.parseDouble(aNumericalValueSpecification.value.mixedText)
	}

	private dispatch def FInitializerExpression create fac.createFStringConstant createPrimitiveInitializerExpression(TextValueSpecification aTextValueSpecification) {
		it.^val = aTextValueSpecification.value
	}


	private dispatch def FTypeRef create fac.createFTypeRef getConstantType(ValueSpecification aValueSpecification, FTypedElement fTypedElement, FModel fModel) {
		it.predefined = FBasicTypeId.UINT8
	}

	private dispatch def FTypeRef create fac.createFTypeRef getConstantType(NumericalValueSpecification aNumericalValueSpecification, FTypedElement fTypedElement, FModel fModel) {
		it.predefined = FBasicTypeId.DOUBLE
	}

	private dispatch def FTypeRef create fac.createFTypeRef getConstantType(TextValueSpecification aTextValueSpecification, FTypedElement fTypedElement, FModel fModel) {
		it.predefined = FBasicTypeId.STRING
	}

	private dispatch def FTypeRef getConstantType(ArrayValueSpecification aArrayValueSpecification, FTypedElement fTypedElement, FModel fModel) {
		val firstArrayElementValue = aArrayValueSpecification.elements.head
		if (fTypedElement !== null) {
			// Create an anonymous array.
			fTypedElement.array = true
			if (firstArrayElementValue !== null) {
				firstArrayElementValue.getConstantType(null, fModel)
			} else {
				fac.createFTypeRef => [
					it.predefined = FBasicTypeId.UINT8
				]
			}
		} else {
			// Use a named array type.
			var fArrayType = searchMatchingActualTypeDefinition(aArrayValueSpecification, fModel) as FArrayType
			if (fArrayType === null) {
				// If no appropriate array type is yet available in the current Franca model
				// create a new definition of an artificial array type.
				fArrayType = fac.createFArrayType => [
					it.elementType = if (firstArrayElementValue !== null) {
						firstArrayElementValue.getConstantType(null, fModel)
					} else {
						fac.createFTypeRef => [
							it.predefined = FBasicTypeId.UINT8
						]
					}
					it.name = "ArtificalArray_" + nextFreeArrayTypeIndex
					nextFreeArrayTypeIndex++
				]
				fModel.addTypeToModel(fArrayType)
			}
			val _fArrayType = fArrayType
			return fac.createFTypeRef => [
				it.derived = _fArrayType
			]
		}
	}

	private dispatch def FTypeRef create fac.createFTypeRef getConstantType(RecordValueSpecification aRecordValueSpecification, FTypedElement fTypedElement, FModel fModel) {
		var fStructType = searchMatchingActualTypeDefinition(aRecordValueSpecification, fModel) as FStructType
		if (fStructType === null) {
			fStructType = fac.createFStructType => [
				it.name = "ArtificalStruct_" + nextFreeStructTypeIndex
				nextFreeStructTypeIndex++
				for (var fieldIndex = 0; fieldIndex < aRecordValueSpecification.fields.size; fieldIndex++) {
					val _fieldIndex = fieldIndex
					it.elements += fac.createFField => [
						it.name = "f_" + (_fieldIndex + 1)
						it.type = aRecordValueSpecification.fields.get(_fieldIndex).getConstantType(it, fModel)
					]
				}
			]
			fModel.addTypeToModel(fStructType)
		}
		it.derived = fStructType
	}


	private def searchMatchingActualTypeDefinition(ValueSpecification aValueSpecification, FModel fModel) {
		val fMatchingTypeDefinition = searchMatchingTypeDefinition(aValueSpecification, fModel)
		if (fMatchingTypeDefinition instanceof FTypeDef) {
			getActualDerived(fMatchingTypeDefinition.actualType)
		} else {
			fMatchingTypeDefinition
		}
	}

	private def searchMatchingTypeDefinition(ValueSpecification aValueSpecification, FModel fModel) {
		for (fTypeCollection : fModel.typeCollections) {
			for (fType : fTypeCollection.types) {
				if (matchesFType(aValueSpecification, fType)) {
					return fType
				}
			}
		}
		for (fInterface : fModel.interfaces) {
			for (fType : fInterface.types) {
				if (matchesFType(aValueSpecification, fType)) {
					return fType
				}
			}
		}
		return null
	}

	private dispatch def boolean matchesFType(ValueSpecification aValueSpecification, FType fType) {
		return false
	}

	private dispatch def boolean matchesFType(ValueSpecification aValueSpecification, FTypeDef fTypeDef) {
		matchesFTypeRef(aValueSpecification, fTypeDef.actualType)
	}

	private dispatch def boolean matchesFType(ArrayValueSpecification aArrayValueSpecification, FArrayType fArrayType) {
		val firstArrayElementValue = aArrayValueSpecification.elements.head
		if (firstArrayElementValue !== null) {
			matchesFTypeRef(firstArrayElementValue, fArrayType.elementType)
		} else {
			true
		}
	}

	private dispatch def boolean matchesFType(RecordValueSpecification aRecordValueSpecification, FStructType fStructType) {
		if (aRecordValueSpecification.fields.size != fStructType.elements.size) {
			return false
		}
		for (var fieldIndex = 0; fieldIndex < aRecordValueSpecification.fields.size; fieldIndex++) {
			val _fieldIndex = fieldIndex
			if (!matchesFTypedElement(aRecordValueSpecification.fields.get(_fieldIndex), fStructType.elements.get(_fieldIndex))) {
				return false
			}
		}
		return true
	}

	private def boolean matchesFTypeRef(ValueSpecification aValueSpecification, FTypeRef fTypeRef) {
		// Handle derived types.
		val fActualDerivedType = getActualDerived(fTypeRef)
		if (fActualDerivedType !== null) {
			return matchesFType(aValueSpecification, fActualDerivedType)
		}

		// Handle predefined primitive types.
		val fActualPredefined = getActualPredefined(fTypeRef)
		if (aValueSpecification instanceof NumericalValueSpecification && fActualPredefined == FBasicTypeId.DOUBLE) {
			return true
		}
		if (aValueSpecification instanceof TextValueSpecification && fActualPredefined == FBasicTypeId.STRING) {
			return true
		}

		return false
	}

	private def boolean matchesFTypedElement(ValueSpecification aValueSpecification, FTypedElement fTypedElement) {
		if (fTypedElement.array) {
			if (aValueSpecification instanceof ArrayValueSpecification) {
				// Deal with anonymous arrays.
				val firstArrayElementValue = aValueSpecification.elements.head
				if (firstArrayElementValue !== null) {
					return matchesFTypeRef(firstArrayElementValue, fTypedElement.type)
				} else {
					return true
				}
			}
		}
		matchesFTypeRef(aValueSpecification, fTypedElement.type)
	}

}
