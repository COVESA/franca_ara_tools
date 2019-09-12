package org.genivi.faracon.cli

import org.eclipse.emf.common.util.URI
import org.franca.core.framework.FrancaModelContainer

import static org.genivi.faracon.ara2franca.Ara2FrancaUtil.*

class OutputFileHelper {
	private new() {
	}

	def static calculateFrancaOutputUri(URI araModelUri, FrancaModelContainer francaModelContainer) {
		val francaFileName = calculateFrancaFileNameFromAutosarUri(araModelUri, francaModelContainer.model())
		var transformedModelUri = araModelUri.trimFileExtension();
		transformedModelUri = transformedModelUri.trimSegments(1).appendSegment(francaFileName);
		return transformedModelUri;
	}

	
}
