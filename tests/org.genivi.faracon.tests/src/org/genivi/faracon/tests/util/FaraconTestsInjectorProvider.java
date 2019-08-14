package org.genivi.faracon.tests.util;

import org.franca.core.dsl.FrancaIDLTestsInjectorProvider;

import com.google.inject.Injector;

public class FaraconTestsInjectorProvider extends FrancaIDLTestsInjectorProvider {

	@Override
	protected Injector internalCreateInjector() {
	    Injector faraconInjector = new FaraconTestsStandaloneSetup().createInjectorAndDoEMFRegistration();
		return faraconInjector;
	}

}
