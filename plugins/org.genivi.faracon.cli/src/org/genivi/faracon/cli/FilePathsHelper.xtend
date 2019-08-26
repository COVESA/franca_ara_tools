package org.genivi.faracon.cli

import java.nio.file.FileVisitResult
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.SimpleFileVisitor
import java.nio.file.attribute.BasicFileAttributes
import java.util.Collection

class FilePathsHelper {

	new() {
	}

	def static Collection<String> findFiles(String[] filePaths, String fileExtension) {
		val files = newHashSet()
		if(null === filePaths){
			return files
		}
		filePaths.forEach [
			val fileVisitor = new SimpleFileVisitor<Path>() {
				override visitFile(Path path, BasicFileAttributes attrs) {
					if (attrs.isRegularFile && path.fileName.toString.endsWith("." + fileExtension)) {
						files.add(path.toString)
					}
					return FileVisitResult.CONTINUE
				}
			}
			val path = Paths.get(it)
			Files.walkFileTree(path, fileVisitor)
		]
		return files
	}
}
