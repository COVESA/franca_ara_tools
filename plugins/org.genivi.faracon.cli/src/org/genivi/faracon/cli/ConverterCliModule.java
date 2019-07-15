package org.genivi.faracon.cli;

import org.eclipse.xtext.service.CompoundModule;
import org.franca.core.dsl.FrancaIDLRuntimeModule;
import org.genivi.faracon.ARAConnectorModule;
import org.genivi.faracon.console.ConsoleLogger;
import org.genivi.faracon.logging.ILogger;

import com.google.inject.Binder;
import com.google.inject.Singleton;

public class ConverterCliModule extends CompoundModule {

	public ConverterCliModule() {
		add(new ARAConnectorModule());
		add(new FrancaIDLRuntimeModule());
	}

	@Override
	public void configure(Binder binder) {
		binder.bind(ILogger.class).to(ConsoleLogger.class).in(Singleton.class);
		super.configure(binder);
	}
	
}
