package org.genivi.faracon;

import java.io.IOException;
import java.net.URL;
import java.util.Collections;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.sphinx.emf.ecore.proxymanagement.IProxyResolverService;
import org.eclipse.sphinx.emf.metamodel.IMetaModelDescriptor;
import org.eclipse.sphinx.emf.metamodel.MetaModelDescriptorRegistry;
import org.eclipse.sphinx.emf.resource.ExtendedResourceSetImpl;

import autosar40.autosartoplevelstructure.AUTOSAR;
import autosar40.util.Autosar40Package;
import autosar40.util.Autosar40ReleaseDescriptor;
import autosar40.util.Autosar40ResourceFactoryImpl;

public class ARAResourceSet extends ExtendedResourceSetImpl {

	protected static String PATH_TO_STD_ARXML_FILE = "stdtypes.arxml";

	protected AUTOSAR standardTypeDefinitionsModel;

	public ARAResourceSet() {
		configure();
		loadStandardTypeDefinitions();
	}

	public ARAResourceSet(AUTOSAR standardTypeDefinitionsModel) {
		configure();
		this.standardTypeDefinitionsModel = standardTypeDefinitionsModel;
	}

	protected void configure() {
		// next line needs to stay because side effects.
		Autosar40Package autosar40Package = Autosar40Package.eINSTANCE;
//		EPackage.Registry.INSTANCE.put(autosar40Package.eNS_URI, autosar40Package);

		// register the appropriate resource factory to handle all file extensions for Dbus
//		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xml", new DbusxmlResourceFactoryImpl());
//		resourceSet.getPackageRegistry().put(DbusxmlPackage.eNS_URI, DbusxmlPackage.eINSTANCE);

		if (MetaModelDescriptorRegistry.INSTANCE.getDescriptors(Autosar40ReleaseDescriptor.INSTANCE.getIdentifier()).isEmpty())
			MetaModelDescriptorRegistry.INSTANCE.addDescriptor(Autosar40ReleaseDescriptor.INSTANCE);

		if (!Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().containsKey(
						Autosar40ReleaseDescriptor.ARXML_DEFAULT_FILE_EXTENSION)) {
			Resource.Factory arFactory = new Autosar40ResourceFactoryImpl();
			Resource.Factory.Registry.INSTANCE.getExtensionToFactoryMap().put(
				Autosar40ReleaseDescriptor.ARXML_DEFAULT_FILE_EXTENSION,
				arFactory
			);

			getResourceFactoryRegistry().getExtensionToFactoryMap().put(
				Autosar40ReleaseDescriptor.ARXML_DEFAULT_FILE_EXTENSION,
				arFactory);
		}
	}

	protected void loadStandardTypeDefinitions() {
		standardTypeDefinitionsModel = loadARAModelFromPluginResource(PATH_TO_STD_ARXML_FILE);
	}

	public AUTOSAR getStandardTypeDefinitionsModel() {
		return standardTypeDefinitionsModel;
	}

	public AUTOSAR loadARAModelFromPluginResource(String fileName) {
		URL url = getClass().getResource("/" + fileName);
		URI logicalURI = URI.createFileURI(fileName);
		try {
			Resource resource = loadResource(url, logicalURI);
			return (AUTOSAR)resource.getContents().get(0);
		} catch (IOException e) {
			//TODO: error handling
			return null;
		}
	}

	protected Resource loadResource(URL url, URI uri) throws IOException {
		Resource resource = createResource(uri);
		resource.load(url.openStream(), Collections.EMPTY_MAP);
		return resource;
	}

	@Override
	protected IProxyResolverService getProxyResolverService(IMetaModelDescriptor descriptor) {
		return null;
	}

}
