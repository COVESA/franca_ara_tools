package org.genivi.faracon.tests.util;

import org.eclipse.xtext.util.Modules2;
import org.franca.core.dsl.FrancaIDLTestsModule;
import org.franca.core.dsl.FrancaIDLTestsStandaloneSetup;
import org.genivi.faracon.cli.ConverterCliModule;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class FaraconTestsStandaloneSetup extends FrancaIDLTestsStandaloneSetup {
    @Override
    public Injector createInjector() {
        return Guice.createInjector(Modules2.mixin(new ConverterCliModule(), new FrancaIDLTestsModule()));
    }
}
