package org.genivi.faracon.cli;

import org.eclipse.xtext.service.CompoundModule;
import org.franca.core.dsl.FrancaIDLRuntimeModule;
import org.franca.deploymodel.dsl.FDeployRuntimeModule;
import org.genivi.faracon.ARAConnectorModule;
import org.genivi.faracon.logging.ILogger;

import com.google.inject.Binder;
import com.google.inject.Singleton;

public class ConverterCliModule extends CompoundModule {

	
	private Class<? extends ILogger> loggerInstance;

	public ConverterCliModule(Class<? extends ILogger> loggerInstance) {
		this.loggerInstance = loggerInstance;
		add(new ARAConnectorModule());
		add(new FrancaIDLRuntimeModule());
//		add(new FDeployRuntimeModule());
	}

	@Override
	public void configure(Binder binder) {
		binder.bind(ILogger.class).to(loggerInstance).in(Singleton.class);
		super.configure(binder);
	}
	
}
