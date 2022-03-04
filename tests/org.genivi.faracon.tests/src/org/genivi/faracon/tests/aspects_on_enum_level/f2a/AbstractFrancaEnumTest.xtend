package org.genivi.faracon.tests.aspects_on_enum_level.f2a

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.varianthandling.attributevaluevariationpoints.LimitValueVariationPoint
import autosar40.genericstructure.generaltemplateclasses.primitivetypes.IntervalTypeEnum
import autosar40.swcomponent.datatype.computationmethod.CompuScale
import autosar40.swcomponent.datatype.computationmethod.CompuScales
import autosar40.swcomponent.datatype.datatypes.AutosarDataType
import com.google.inject.Inject
import org.genivi.faracon.franca2ara.types.ARATypeCreator
import org.genivi.faracon.tests.util.Franca2ARATestBase

import static org.junit.Assert.assertEquals
import static org.junit.Assert.assertNotNull
import static org.junit.Assert.assertNull

import static extension org.genivi.faracon.tests.util.AutosarAssertHelper.*
import static extension org.genivi.faracon.tests.util.FaraconAssertHelper.*

abstract class AbstractFrancaEnumTest extends Franca2ARATestBase {
	@Inject
	var protected extension ARATypeCreator araTypeCreator
	
	def protected void assertCompuScale(CompuScale compuScale, String expectedSymbol, String limit){
		assertEquals("CompuScale " + compuScale + " has an unexpected name", expectedSymbol, compuScale.symbol)
		if(limit === null ){
			assertNull("No lower limit expected for CompuScale " + expectedSymbol, compuScale.lowerLimit)	
			assertNull("No upper limit expected for CompuScale " + expectedSymbol, compuScale.upperLimit)	
		}else{
			val lowerLimitVal = compuScale.lowerLimit.getLimitFromLimitValueVariationPoint()
			val upperLimitVal = compuScale.upperLimit.getLimitFromLimitValueVariationPoint()
			assertEquals("Lower and upper limit are not equal", lowerLimitVal, upperLimitVal)
			assertEquals("Limit does not equal the expected limit", limit, lowerLimitVal)
		}
	} 
	
	private def String getLimitFromLimitValueVariationPoint(LimitValueVariationPoint limitValueVariationPoint){
		assertNotNull("LimitValueVariationPoint was null, i.e., no limit found", limitValueVariationPoint)
		assertEquals("Only closed intervals expected for LimitVariationPoints.", IntervalTypeEnum.CLOSED, limitValueVariationPoint.intervalType)
		val value = limitValueVariationPoint.mixed.get(0).value.toString
		assertNotNull("No limit found for LimitValueVariationPoint " + limitValueVariationPoint, value)
		return value
	}
	
	protected def assertEnumAndGetCompuScales(AutosarDataType result, String expectedEnumName, int expectedEnumSize){
		val implementationDataType = result.assertIsInstanceOf(ImplementationDataType)
		implementationDataType.assertName(expectedEnumName)
		implementationDataType.assertCategory("TYPE_REFERENCE")
		val compuMethod = implementationDataType?.swDataDefProps?.swDataDefPropsVariants.get(0)?.compuMethod
		assertNotNull("No compu method found", compuMethod)
		compuMethod.assertCategory("TEXTTABLE")
		compuMethod.assertName(expectedEnumName + "_CompuMethod")
		val compuScales = compuMethod?.compuInternalToPhys?.compuContent.assertIsInstanceOf(CompuScales)
		assertNotNull("No compuScales found", compuScales)
		val actualCompuScales = compuScales.compuScales.assertElements(expectedEnumSize).sortBy[symbol]
		return actualCompuScales
	}
}