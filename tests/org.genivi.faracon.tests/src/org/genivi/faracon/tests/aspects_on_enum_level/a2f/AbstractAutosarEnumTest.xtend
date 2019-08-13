package org.genivi.faracon.tests.aspects_on_enum_level.a2f

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.IntervalTypeEnum
import java.util.Optional
import javax.inject.Inject
import org.genivi.faracon.ara2franca.FrancaTypeCreator
import org.genivi.faracon.tests.util.ARA2FrancaTestBase
import org.eclipse.emf.ecore.EcoreFactory
import org.eclipse.emf.ecore.util.BasicFeatureMap

abstract class AbstractAutosarEnumTest extends ARA2FrancaTestBase {

	@Inject
	var protected FrancaTypeCreator fTypeCreator

	protected def ImplementationDataType createArEnum(Optional<String>... enumValues) {
		createImplementationDataType => [
			it.category = "TYPE_REFERENCE"
			it.shortName = "TestEnum"
			it.swDataDefProps = createSwDataDefProps => [
				swDataDefPropsVariants += createSwDataDefPropsConditional => [
					compuMethod = createCompuMethod => [
						shortName = "TestCompuMethod"
						it.category = "TEXTTABLE"
						it.compuInternalToPhys = createCompu => [ compuMethod |
							compuMethod.compuContent = createCompuScales => [ compuScales |
								val enumeratorBaseName = "enumerator"
								enumValues.forEach [ enumValue |
									compuScales.compuScales += createCompuScale => [ compuScale |
										compuScale.symbol = enumeratorBaseName + (enumValues.indexOf(enumValue) + 1)
										enumValue.ifPresent [
											compuScale.lowerLimit = it.createLimit
											compuScale.upperLimit = it.createLimit
										]
									]
								]
							]
						]
					]
				]
			]
		]
	}

	private def createLimit(String value) {
		val ecoreFactory = EcoreFactory.eINSTANCE
		createLimitValueVariationPoint => [
			it.intervalType = IntervalTypeEnum.CLOSED
			val basicFeatureMap = it.mixed as BasicFeatureMap
			basicFeatureMap.addUnique(ecoreFactory.createEAttribute =>[name = "text"], value )
		]
	}
}
