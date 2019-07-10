/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.genivi.faracon;

import java.io.IOException;
import java.io.PrintStream;
import java.net.URL;
import java.util.Collections;
import java.util.List;
import java.util.Set;

import org.eclipse.core.runtime.Platform;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.sphinx.emf.ecore.proxymanagement.IProxyResolverService;
import org.eclipse.sphinx.emf.metamodel.IMetaModelDescriptor;
import org.eclipse.sphinx.emf.metamodel.MetaModelDescriptorRegistry;
import org.eclipse.sphinx.emf.resource.ExtendedResourceSetImpl;
import org.franca.core.framework.AbstractFrancaConnector;
import org.franca.core.framework.FrancaModelContainer;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.TransformationIssue;
import org.franca.core.franca.FModel;
import org.franca.core.utils.IntegerTypeConverter;

import com.google.inject.Guice;
import com.google.inject.Injector;

import autosar40.autosartoplevelstructure.AUTOSAR;
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage;
import autosar40.util.Autosar40Package;
import autosar40.util.Autosar40ReleaseDescriptor;
import autosar40.util.Autosar40ResourceFactoryImpl;

public class ARAConnector extends AbstractFrancaConnector {

	private Injector injector;

	private String fileExtension = "arxml";

	private static String PATH_TO_STD_ARXML_FILE = "stdtypes.arxml";

	private Set<TransformationIssue> lastTransformationIssues = null;

	/** constructor */
	public ARAConnector() {
		injector = Guice.createInjector(new ARAConnectorModule());
	}

	@Override
	public IModelContainer loadModel(String filename) {
		return loadModel(createConfiguredResourceSet(), filename);
	}

	public IModelContainer loadModel(ResourceSet resourceSet, String filename) {
		AUTOSAR primitiveTypesModel = loadARAModelFromPluginResource(resourceSet, PATH_TO_STD_ARXML_FILE);
		AUTOSAR model = loadARAModel(resourceSet, filename);
		if (model==null) {
			out.println("Error: Could not load arxml model from file " + filename);
		} else {
			List<ARPackage> packages = model.getArPackages();
//			if (packages.isEmpty())
//				out.println("Loaded arxml model (no packages)");
//			else
//				out.println("Loaded arxml model (first package " + packages.get(0).getShortName() + ")");
		}
		return new ARAModelContainer(model, primitiveTypesModel);
	}

	@Override
	public boolean saveModel(IModelContainer model, String filename) {
		if (! (model instanceof ARAModelContainer)) {
			return false;
		}

		ARAModelContainer mc = (ARAModelContainer) model;
		return saveARXML(createConfiguredResourceSet(), mc.model()/*, mc.getComments()*/, filename);
	}

	@Override
	public FrancaModelContainer toFranca(IModelContainer model) {
		if (! (model instanceof ARAModelContainer)) {
			return null;
		}

		ARA2FrancaTransformation trafo = injector.getInstance(ARA2FrancaTransformation.class);
		ARAModelContainer amodel = (ARAModelContainer)model;
		FModel fmodel = trafo.transform(amodel.model());

//		lastTransformationIssues = trafo.getTransformationIssues();
//		out.println(IssueReporter.getReportString(lastTransformationIssues));

		return new FrancaModelContainer(fmodel);
	}

	@Override
	public IModelContainer fromFranca(FModel fmodel) {
		// do ranged integer conversion as a preprocessing step
		IntegerTypeConverter.removeRangedIntegers(fmodel, true);

		// do the actual transformation
		Franca2ARATransformation trafo = injector.getInstance(Franca2ARATransformation.class);
		AUTOSAR amodel = trafo.transform(fmodel);

		// report issues
//		lastTransformationIssues = trafo.getTransformationIssues();
//		out.println(IssueReporter.getReportString(lastTransformationIssues));

		// create the model container and add some comments to the model
		ARAModelContainer mc = new ARAModelContainer(amodel, null);
		return mc;
	}

	public Set<TransformationIssue> getLastTransformationIssues() {
		return lastTransformationIssues;
	}

	private static ResourceSet createConfiguredResourceSet() {
		// create new resource set
		ResourceSet resourceSet = new ExtendedResourceSetImpl() {
			@Override
			protected IProxyResolverService getProxyResolverService(IMetaModelDescriptor descriptor) {
				return null;
			}
		};
		
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

			resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put(
					Autosar40ReleaseDescriptor.ARXML_DEFAULT_FILE_EXTENSION,
					arFactory);
		}

		return resourceSet;
	}
	

	/**
	 * We need to provide a different behavior for URI resolving during load
	 * of arxml XML files. This is because the noNamespaceSchemaLocation
	 * attribute "introspect.xsd" will be used as a key to find the corresponding
	 * EMF package name. If we load an Introspection file with an absolute path, the 
	 * resolving would destroy this key and the EMF package is no more found.  
	 */
//	private static class DBusURIHandler extends URIHandlerImpl {
//		@Override
//		public URI resolve(URI uri) {
//			// don't resolve
//			return uri;
//		}
//	}
	
	public static AUTOSAR loadARAModel(ResourceSet resourceSet, String fileName) {
		URI uri = URI.createFileURI(fileName);
		
		//ConnectorStandaloneSetup.doSetup();

		if (Platform.isRunning()) {
			// TODO
//			ModelLoadManager.INSTANCE.loadFile(getIFileFromURI(uri),
//					Autosar40ReleaseDescriptor.INSTANCE, false,
//					new NullProgressMonitor());
		}

		Resource resource = resourceSet.getResource(uri, true);
		return (AUTOSAR)resource.getContents().get(0);
	}

	public static AUTOSAR loadARAModel(String fileName) {
		ResourceSet resourceSet = createConfiguredResourceSet();
		return loadARAModel(resourceSet, fileName);
	}

	public static AUTOSAR loadARAModelFromPluginResource(ResourceSet resourceSet, String fileName) {
		URL url = resourceSet.getClass().getResource("/" + fileName);
		URI logicalURI = URI.createFileURI(fileName);
		try {
			Resource resource = loadResource(resourceSet, url, logicalURI);
			return (AUTOSAR)resource.getContents().get(0);
		} catch (IOException e) {
			//TODO: error handling
			return null;
		}
	}

	public static AUTOSAR loadARAModelFromPluginResource(String fileName) {
		ResourceSet resourceSet = createConfiguredResourceSet();
		return loadARAModelFromPluginResource(resourceSet, fileName);
	}

	public static Resource loadResource(ResourceSet set, URL url, URI uri) throws IOException {
		Resource resource = set.createResource(uri);
		resource.load(url.openStream(), Collections.EMPTY_MAP);
		return resource;
	}

	private boolean saveARXML(
		ResourceSet resourceSet,
		AUTOSAR autosar,
		URI uri,
		PrintStream out
	) throws IOException {

		Resource resource = resourceSet.createResource(uri, Autosar40ReleaseDescriptor.ARXML_CONTENT_TYPE_ID);
		if (Platform.isRunning()) {
			Resource originalResource = autosar.eResource();
			AUTOSAR copy = EcoreUtil.copy(autosar);
//			if (originalResource == null)
//				throw new IllegalStateException("Autosar resource is null");
			// if we don't unload the original model the additions will be seen in that one as well
			if (originalResource != null)
				originalResource.unload();			

			resource.getContents().add(copy);
			resource.save(Collections.EMPTY_MAP);
		} else {
			resource.getContents().add(autosar);
			resource.save(Collections.emptyMap());
		}
 
		if (out != null)
			out.println("Saved generated arxml-file as '" + uri + "'");

		return true;
	}

	public boolean saveARXML(ResourceSet resourceSet, AUTOSAR autosar, String name) {
		URI uri = URI.createFileURI(name);
		try {
			saveARXML(resourceSet, autosar, uri, System.out);
		} catch (IOException e) {
			e.printStackTrace();
			return false;
		}
		return true;
	}
	
//	/**
//	 * Add some lines to a given XML file. 
//	 * 
//	 * The lines will be inserted directly below the first line in the XML.
//	 * The first line has to be a "xml version" tag.
//	 *  
//	 * @param inFile the XML file which should be changed
//	 * @param lines the set of lines which should be inserted into the file
//	 * @throws IOException
//	 */
//	private static void addLinesToXML(File inFile, Iterable<String> lines) throws IOException {
//		// compile string which is to be inserted
//		StringBuilder sb = new StringBuilder();
//		sb.append("$1");
//		for(String l : lines) {
//			sb.append("\n" + l);
//		}
//		
//		// read the file and insert the string which we have built before
//		String content = contents(inFile);
//		content = content.replaceAll("(<\\?xml version.*\\?>)", sb.toString());
//
//		// write the file again
//		FileOutputStream fos = new FileOutputStream(inFile);
//		PrintWriter out = new PrintWriter(fos);
//		out.print(content);
//		out.flush();
//		out.close();
//	}
//
//	private static String contents (File file) throws IOException {
//		InputStream in = new FileInputStream(file);
//		byte[] b  = new byte[(int) file.length()];
//		int len = b.length;
//		int total = 0;
//
//		while (total < len) {
//		  int result = in.read(b, total, len - total);
//		  if (result == -1) {
//		    break;
//		  }
//		  total += result;
//		}
//		in.close();
//		return new String(b);
//	}
}

