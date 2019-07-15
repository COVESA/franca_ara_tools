package org.genivi.faracon.cli;

import org.eclipse.xtext.service.CompoundModule;
import org.franca.core.dsl.FrancaIDLRuntimeModule;
import org.genivi.faracon.ARAConnectorModule;

public class ConverterCliModule extends CompoundModule {

	public ConverterCliModule() {
		add(new ARAConnectorModule());
		add(new FrancaIDLRuntimeModule());
	}
}
