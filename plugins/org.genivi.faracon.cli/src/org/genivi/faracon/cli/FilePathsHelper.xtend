package org.genivi.faracon.cli

import java.nio.file.FileVisitResult
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.SimpleFileVisitor
import java.nio.file.attribute.BasicFileAttributes
import java.util.Collection
import org.eclipse.emf.common.util.URI
import org.genivi.faracon.InputFile

class FilePathsHelper {

	new() {
	}

	def static Collection<InputFile> findInputFiles(String[] filePaths, String fileExtension) {
		val files = newHashSet()
		if(null === filePaths){
			return files
		}
		filePaths.forEach [
			val basePath = Paths.get(it).toFile.canonicalFile.toPath
			val basePathLength = basePath.calculateBasePathLength
			val fileVisitor = new SimpleFileVisitor<Path>() {
				override visitFile(Path path, BasicFileAttributes attrs) {
					if (attrs.isRegularFile && path.fileName.toString.endsWith("." + fileExtension)) {
						files.add(new InputFile(path.toString, basePathLength))
					}
					return FileVisitResult.CONTINUE
				}
			}
			Files.walkFileTree(basePath, fileVisitor)
		]
		return files
	}

	def static int calculateBasePathLength(Path basePath) {
		if (basePath.toFile.directory) {
			basePath.toString.length
		} else {
			URI.createFileURI(basePath.toString).trimSegments(1).toFileString.length
		}
	}

}
