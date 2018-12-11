/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.ara;

import org.franca.core.framework.IModelContainer;
import autosar40.autosartoplevelstructure.AUTOSAR;

public class ARAModelContainer implements IModelContainer {

	private AUTOSAR primitiveTypesModel = null;
	private AUTOSAR model = null;
	
	public ARAModelContainer(AUTOSAR model, AUTOSAR primitiveTypesModel) {
		this.primitiveTypesModel = primitiveTypesModel;
		this.model = model;
	}
	
	public AUTOSAR primitiveTypesModel() {
		return primitiveTypesModel;
	}
	
	public AUTOSAR model() {
		return model;
	}
	
}
