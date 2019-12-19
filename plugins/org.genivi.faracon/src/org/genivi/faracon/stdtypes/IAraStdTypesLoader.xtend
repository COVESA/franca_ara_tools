package org.genivi.faracon.stdtypes

import org.genivi.faracon.ARAResourceSet

interface IAraStdTypesLoader {
	def AraStandardTypes loadStdTypes(ARAResourceSet resourceSet)
}
