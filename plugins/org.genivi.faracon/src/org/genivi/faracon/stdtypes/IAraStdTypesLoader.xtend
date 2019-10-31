package org.genivi.faracon.stdtypes

import org.eclipse.emf.ecore.resource.ResourceSet

interface IAraStdTypesLoader {
	def AraStandardTypes loadStdTypes(ResourceSet resourceSet)
}
