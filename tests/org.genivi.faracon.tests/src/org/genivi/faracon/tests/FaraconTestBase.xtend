package org.genivi.faracon.tests

import autosar40.util.Autosar40Factory
import javax.inject.Inject
import org.eclipse.emf.ecore.xml.namespace.XMLNamespacePackage
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.core.franca.FrancaFactory
import org.genivi.faracon.ARAConnector
import org.junit.BeforeClass
import org.genivi.faracon.cli.FilePathsHelper

/**
 * This is the abstract base class for all tests in the Faracon tool.
 * It contains common members and methods, which are needed for the tests. 
 */
abstract class FaraconTestBase {
		
	/**
	 * This is just a workaround to solve strange test errors during the Maven build on the CI server.
	 */
	@BeforeClass
	def static beforeClass(){
		val x = XMLNamespacePackage.eINSTANCE
	}

	@Inject
	protected FrancaPersistenceManager loader

	@Inject
	protected ARAConnector araConnector;

	/**
	 * The Franca Factory as extension, which can be used to create expected tests
	 * models in derived classes.
	 */
	protected static extension val FrancaFactory francaFactory = FrancaFactory.eINSTANCE

	/**
	 * The Autosar Factory as extension, which can be used to create expected tests
	 * models in derived classes.
	 */
	protected static extension val Autosar40Factory arFactory = Autosar40Factory.eINSTANCE
	
	def protected francaFac() {
		return francaFactory
	}

	def protected araFac() {
		return arFactory
	}
	
	/**
	 * Returns the path to the test class, which can be used to load files, which are stored next to the 
	 * class itself. 
	 */
	def protected getTestPath() {
		return "src/" + (this.class.package.name + ".").replace(".", "/")
	}
	
	def protected findFiles(String inputFilePath, String fileExtension){
		val inputFiles = FilePathsHelper.findInputFiles(#[inputFilePath], fileExtension)
		inputFiles.map[it.absolutePath].toSet
	}
}