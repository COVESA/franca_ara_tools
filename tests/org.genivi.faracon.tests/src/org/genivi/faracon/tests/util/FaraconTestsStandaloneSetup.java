package org.genivi.faracon.tests.util;

import org.eclipse.xtext.util.Modules2;
import org.franca.core.dsl.FrancaIDLTestsModule;
import org.franca.core.dsl.FrancaIDLTestsStandaloneSetup;
import org.franca.deploymodel.ext.providers.ProviderExtension;
import org.franca.deploymodel.extensions.ExtensionRegistry;
import org.genivi.faracon.cli.ConverterCliModule;
import org.genivi.faracon.console.ConsoleLogger;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class FaraconTestsStandaloneSetup extends FrancaIDLTestsStandaloneSetup {
	@Override
    public Injector createInjector() {
		// load Franca provider extension
		ExtensionRegistry.addExtension(new ProviderExtension());

        return Guice.createInjector(Modules2.mixin(new ConverterCliModule(ConsoleLogger.class), new FrancaIDLTestsModule()));
    }

}
