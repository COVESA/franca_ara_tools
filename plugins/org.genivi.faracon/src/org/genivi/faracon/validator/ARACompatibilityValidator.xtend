/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.genivi.faracon.validator

import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtend.typesystem.emf.EcoreUtil2
import org.eclipse.xtext.validation.ValidationMessageAcceptor
import org.franca.core.dsl.validation.IFrancaExternalValidator
import org.franca.core.franca.FBroadcast
import org.franca.core.franca.FInterface
import org.franca.core.franca.FModel
import org.franca.core.franca.FUnionType

import static org.franca.core.franca.FrancaPackage.Literals.*

/**
 * External Franca IDL validator for compatibility with AUTOSAR Adaptive.
 * 
 * <p>This validator checks all features which can not be implemented by
 * AUTOSAR Adaptive. If it has to be enforced to be compatible with ARA
 * in a specific development environment, the warningsAsErrors flag should
 * be set.</p>
 * 
 * <p>Note: Some features will be "emulated" by additional ARA interactions.</p>
 */
class ARACompatibilityValidator implements IFrancaExternalValidator {

	val MESSAGE_PREFIX = "ARA compatibility: "
	val MESSAGE_POSTFIX = " in AUTOSAR Adaptive"

	static var active = true
	static var warningsAsErrors = false

	/** Deactivate this validator. */
	def static setActive(boolean flag) {
		active = flag
	}	

	/** Report errors instead of warnings. */
	def static setWarningsAsErrors(boolean flag) {
		warningsAsErrors = flag
	}	

	override validateModel(FModel model, ValidationMessageAcceptor issues) {
		if (!active)
			return

		val all = EcoreUtil2.allContents(model)
//		all.filter(typeof(FTypeRef)).check(issues)
//		all.filter(typeof(FEnumerator)).check(issues)
//		all.filter(typeof(FMapType)).check(issues)
//		all.filter(typeof(FStructType)).check(issues)
		all.filter(typeof(FUnionType)).check(issues)
		all.filter(typeof(FInterface)).check(issues)
//		all.filter(typeof(FAttribute)).check(issues)
//		all.filter(typeof(FMethod)).check(issues)
		all.filter(typeof(FBroadcast)).check(issues)
	}

	def private check(Iterable<? extends EObject> items, ValidationMessageAcceptor issues) {
		for(i : items)
			i.checkItem(issues)
	}


	def private dispatch checkItem(FUnionType item, ValidationMessageAcceptor issues) {
		issues.warning(
			"Union types are not supported by AUTOSAR Adaptive before the R18-10 release",
			item, FMODEL_ELEMENT__NAME)
			
//		if (item.base!==null) {
//			issues.warning(
//				"Inheritance for unions is not supported by ARA",
//				item, FUNION_TYPE__BASE)
//		}
	}

	def private dispatch checkItem(FInterface item, ValidationMessageAcceptor issues) {
		if (item.base!==null) {
			issues.warning(
				"Inheritance for interfaces is not supported" + MESSAGE_POSTFIX,
				item, FINTERFACE__BASE)
		}

		if (item.managedInterfaces!==null && item.managedInterfaces.size>0) {
			issues.warning(
				"Managed interfaces are not supported" + MESSAGE_POSTFIX,
				item, FINTERFACE__MANAGED_INTERFACES)
		}

		if (item.contract!==null) {
			issues.info(
				"Interface contracts are not supported" + MESSAGE_POSTFIX,
				item, FINTERFACE__CONTRACT)
		}
	}

	def private dispatch checkItem (FBroadcast item, ValidationMessageAcceptor issues) {
		if (item.selective) {
			issues.warning(
				"Selective broadcasts are not supported" + MESSAGE_POSTFIX,
				item, FBROADCAST__SELECTIVE)
		}
	}

	def private dispatch checkItem(EObject item, ValidationMessageAcceptor issues) {
		throw new RuntimeException("Invalid object type in validator: " + item.class.toString)
	}

	
	def private warning(ValidationMessageAcceptor messageAcceptor,
		String txt, EObject object, EStructuralFeature feature
	) {
		val message = MESSAGE_PREFIX + txt + "."
		if (warningsAsErrors) {
			messageAcceptor.acceptError(
				message, object, feature,
				ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
				null
			)
		} else {
			messageAcceptor.acceptWarning(
				message, object, feature,
				ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
				null
			)
		}
	}
	
//	def private error(ValidationMessageAcceptor messageAcceptor,
//		String txt, EObject object, EStructuralFeature feature
//	) {
//		val message = MESSAGE_PREFIX + txt + "."
//		messageAcceptor.acceptError(
//			message, object, feature,
//			ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
//			null
//		)
//	}

	def private info(ValidationMessageAcceptor messageAcceptor,
		String txt, EObject object, EStructuralFeature feature
	) {
		val message = MESSAGE_PREFIX + txt + "."
		messageAcceptor.acceptInfo(
			message, object, feature,
			ValidationMessageAcceptor.INSIGNIFICANT_INDEX,
			null
		)
	}
}
