package org.genivi.faracon.stdtypes

import autosar40.autosartoplevelstructure.AUTOSAR
import java.io.IOException
import java.net.URL
import java.util.Collections
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.resource.ResourceSet
import org.genivi.faracon.ARAResourceSet

class AraStdTypesFromPluginLoader implements IAraStdTypesLoader {
	val static String PATH_TO_STD_ARXML_FILE = "stdtypes.arxml";
	val static String PATH_TO_STD_VECTOR_ARXML_FILE = "stdtypes_vectors.arxml";

	override loadStdTypes(ARAResourceSet resourceSet) {
		val standardTypeDefinitionsModel = loadARAModelFromPluginResource(PATH_TO_STD_ARXML_FILE, resourceSet);
		val standardVectorTypeDefinitionsModel = loadARAModelFromPluginResource(PATH_TO_STD_VECTOR_ARXML_FILE,
			resourceSet);
		return new AraStandardTypes(standardTypeDefinitionsModel, standardVectorTypeDefinitionsModel)
	}

	def private AUTOSAR loadARAModelFromPluginResource(String fileName, ResourceSet resourceSet) {
		val url = getClass().getResource("/" + fileName);
		val logicalURI = URI.createFileURI(fileName);
		try {
			val resource = loadResource(url, logicalURI, resourceSet);
			return resource.getContents().get(0) as AUTOSAR
		} catch (IOException e) {
			// TODO: error handling
			return null;
		}
	}

	def private Resource loadResource(URL url, URI uri, ResourceSet resourceSet) throws IOException {
		val resource = resourceSet.createResource(uri);
		resource.load(url.openStream(), Collections.EMPTY_MAP);
		return resource;
	}

}
