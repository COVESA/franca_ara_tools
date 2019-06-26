/*******************************************************************************
 * Copyright (c) 2013 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.ara;

import org.franca.core.framework.TransformationLogger;

import com.google.inject.AbstractModule;
import com.google.inject.Singleton;

public class ARAConnectorModule extends AbstractModule {

	@Override
	protected void configure() {
		bind(TransformationLogger.class).in(Singleton.class);
	}
}
