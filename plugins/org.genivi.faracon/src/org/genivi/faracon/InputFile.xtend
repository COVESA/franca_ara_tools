package org.genivi.faracon

import java.nio.file.Path
import java.nio.file.Paths
import org.eclipse.emf.common.util.URI

class InputFile {
	new(String absolutePath, int basePathLength) {
		this.absolutePath = absolutePath
		this.basePathLength = basePathLength
	}

	def String getAbsolutePath() {
		this.absolutePath
	}

	def int getBasePathLength() {
		this.basePathLength
	}

	def String getAccordingOutputPath(String outputBasePath, String outputFileExtension) {
		URI.createFileURI(Paths.get(outputBasePath, this.absolutePath.substring(this.basePathLength)).toString)
			.trimFileExtension
			.appendFileExtension(outputFileExtension)
			.toFileString
	}

	String absolutePath
	int basePathLength
}
