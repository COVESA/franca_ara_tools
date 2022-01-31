/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.genivi.faracon;

import org.franca.core.framework.IModelContainer;
import org.genivi.faracon.stdtypes.AraStandardTypeDefinitionsModel;

import autosar40.autosartoplevelstructure.AUTOSAR;

public class ARAModelContainer implements IModelContainer {

	private AraStandardTypeDefinitionsModel araStandardTypeDefinitionsModel = null;
	private AUTOSAR model = null;
	private AUTOSAR deploymentModel = null;
	
	public ARAModelContainer(
			AUTOSAR model,
			AraStandardTypeDefinitionsModel araStandardTypeDefinitionsModel
	) {
		this(model, null, araStandardTypeDefinitionsModel);
	}

	public ARAModelContainer(
		AUTOSAR model,
		AUTOSAR deploymentModel,
		AraStandardTypeDefinitionsModel araStandardTypeDefinitionsModel
	) {
		this.model = model;
		this.deploymentModel = deploymentModel;
		this.araStandardTypeDefinitionsModel = araStandardTypeDefinitionsModel;
	}
	
	public AraStandardTypeDefinitionsModel araStandardTypeDefinitionsModel() {
		return araStandardTypeDefinitionsModel;
	}
	
	public AUTOSAR model() {
		return model;
	}

	public AUTOSAR deploymentModel() {
		return deploymentModel;
	}
	
}
