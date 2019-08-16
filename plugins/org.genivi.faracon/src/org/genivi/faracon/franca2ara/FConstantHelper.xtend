package org.genivi.faracon.franca2ara

import org.franca.core.franca.FConstant
import org.franca.core.franca.FBooleanConstant
import org.franca.core.franca.FDoubleConstant
import org.franca.core.franca.FFloatConstant
import org.franca.core.franca.FIntegerConstant
import org.franca.core.franca.FStringConstant

class FConstantHelper {
	private new(){
	}
	
	def static dispatch getValueFromFConstant(FConstant fConstant){
		return null
	}
	
	def static dispatch getValueFromFConstant(FBooleanConstant fConstant){
		return String.valueOf(fConstant.^val)
	}
	
	def static dispatch getValueFromFConstant(FDoubleConstant fConstant){
		return String.valueOf(fConstant.^val)
	}
	
	def static dispatch getValueFromFConstant(FFloatConstant fConstant){
		return String.valueOf(fConstant.^val)
	}
	
	def static dispatch getValueFromFConstant(FIntegerConstant fConstant){
		return fConstant.^val.toString
	}
	
	def static dispatch getValueFromFConstant(FStringConstant fConstant){
		return fConstant.^val		
	}
	
}