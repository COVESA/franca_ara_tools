/*******************************************************************************
 * Copyright (c) 2018 itemis AG (http://www.itemis.de).
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.franca.connectors.ara;

import java.util.Set;

import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl;
import org.franca.core.framework.AbstractFrancaConnector;
import org.franca.core.framework.FrancaModelContainer;
import org.franca.core.framework.IModelContainer;
import org.franca.core.framework.TransformationIssue;
import org.franca.core.franca.FModel;
import org.franca.core.utils.IntegerTypeConverter;

import com.google.inject.Guice;
import com.google.inject.Injector;

public class ARAConnector extends AbstractFrancaConnector {

	private Injector injector;

	private String fileExtension = "arxml";

	private Set<TransformationIssue> lastTransformationIssues = null;

	/** constructor */
	public ARAConnector () {
		injector = Guice.createInjector(new ARAConnectorModule());
	}

	@Override
	public IModelContainer loadModel (String filename) {
//		NodeType model = loadARAModel(createConfiguredResourceSet(), filename);
//		if (model==null) {
//			out.println("Error: Could not load DBus interface from file " + filename);
//		} else {
//			out.println("Loaded DBus interface " + model.getName());
//		}
		return new ARAModelContainer(); //(model);
	}

	@Override
	public boolean saveModel (IModelContainer model, String filename) {
		if (! (model instanceof ARAModelContainer)) {
			return false;
		}

		String fn = filename;
		if (! filename.endsWith("." + fileExtension)) {
			fn += "." + fileExtension;
		}
		
		ARAModelContainer mc = (ARAModelContainer) model;
		return false;//saveARAModel(createConfiguredResourceSet(), mc.model()/*, mc.getComments()*/, fn);
	}

	
	@Override
	public FrancaModelContainer toFranca (IModelContainer model) {
		if (! (model instanceof ARAModelContainer)) {
			return null;
		}
		
		ARA2FrancaTransformation trafo = injector.getInstance(ARA2FrancaTransformation.class);
		ARAModelContainer dbus = (ARAModelContainer)model;
		FModel fmodel = null;//trafo.transform(dbus.model());
		
//		lastTransformationIssues = trafo.getTransformationIssues();
//		out.println(IssueReporter.getReportString(lastTransformationIssues));

		return new FrancaModelContainer(fmodel);
	}

	@Override
	public IModelContainer fromFranca (FModel fmodel) {
		// ranged integer conversion from Franca to D-Bus as a preprocessing step
		IntegerTypeConverter.removeRangedIntegers(fmodel, true);

		// do the actual transformation
		Franca2ARATransformation trafo = injector.getInstance(Franca2ARATransformation.class);
//		NodeType dbus = trafo.transform(fmodel);
		
		// report issues
//		lastTransformationIssues = trafo.getTransformationIssues();
//		out.println(IssueReporter.getReportString(lastTransformationIssues));

		// create the model container and add some comments to the model
		ARAModelContainer mc = new ARAModelContainer(/*ara*/);
		return mc;
	}
	
	public Set<TransformationIssue> getLastTransformationIssues() {
		return lastTransformationIssues;
	}
	
	private ResourceSet createConfiguredResourceSet() {
		// create new resource set
		ResourceSet resourceSet = new ResourceSetImpl();
		
		// register the appropriate resource factory to handle all file extensions for Dbus
//		resourceSet.getResourceFactoryRegistry().getExtensionToFactoryMap().put("xml", new DbusxmlResourceFactoryImpl());
//		resourceSet.getPackageRegistry().put(DbusxmlPackage.eNS_URI, DbusxmlPackage.eINSTANCE);
		
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
	
//	private static NodeType loadARAModel (ResourceSet resourceSet, String fileName) {
//		URI uri = FileHelper.createURI(fileName);
////		URI uri = null;
////		// try creating file URI first
////		try {
////			uri = URI.createFileURI(fileName);
////		} catch (IllegalArgumentException e) {
////			// didn't work out, try generic URI
////			uri = URI.createURI(fileName);
////		}
//		Resource resource = resourceSet.createResource(uri);
//
//		HashMap<String,Object> options = new HashMap<String,Object>();
//		options.put(XMLResource.OPTION_EXTENDED_META_DATA, Boolean.TRUE);
//		options.put(XMLResource.OPTION_SCHEMA_LOCATION, "introspect.xsd");
//		options.put(XMLResource.OPTION_URI_HANDLER, new DBusURIHandler());
//		try {
//			resource.load(options);
//		} catch (IOException e) {
//			e.printStackTrace();
//			//return null;
//		}
//
//		if (resource.getContents().isEmpty())
//			return null;
//
//		return ((DocumentRoot)resource.getContents().get(0)).getNode();
//	}


//	private boolean saveARAModel (ResourceSet resourceSet, NodeType model, Iterable<String> comments, String fileName) {
//		URI fileUri = URI.createFileURI(new File(fileName).getAbsolutePath());
//		ArxmlResourceImpl res = (ArxmlResourceImpl) resourceSet.createResource(fileUri);
//		res.setEncoding("UTF-8");
//				
//		res.getContents().add(model);
//		try {
//			res.save(Collections.EMPTY_MAP);
//	        out.println("Created DBus Introspection file " + fileName);
//	        
//	        List<String> additionalLines = Lists.newArrayList();
//	        
//	        // add "xml-stylesheet" tag to output xml file
//	        additionalLines.add("<?xml-stylesheet type=\"text/xsl\" href=\"introspect.xsl\"?>");
//
//	        // add comment lines
//	        for(String c : comments)
//	        	additionalLines.add(c);
//
//	        addLinesToXML(new File(fileName), additionalLines);
//	        
//		} catch (IOException e) {
//			e.printStackTrace();
//			return false;
//		}
//
//		return true;
//	}
	
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

