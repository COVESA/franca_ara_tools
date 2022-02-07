package org.genivi.faracon.tests.util

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable
import autosar40.genericstructure.generaltemplateclasses.identifiable.Referrable
import java.nio.file.Files
import java.nio.file.Paths
import java.util.Collection

import static org.junit.Assert.assertEquals
import static org.junit.Assert.fail
import java.util.List

class AutosarAssertHelper {
	new() {
	}

	def static <T extends Referrable> T assertName(T arReferrable, String expectedName) {
		assertEquals("Wrong autosar name created", expectedName, arReferrable.shortName)
		return arReferrable
	}

	def static <T extends Identifiable> T assertCategory(T identifiable, String expectedCategory) {
		assertEquals("Wrong category created", expectedCategory, identifiable.category)
		return identifiable
	}

	def static void assertAutosarFilesAreEqual(Collection<String> actualAutosarFiles,
		Collection<String> expectedFilePaths) {
		assertEquals(
			"Wrong number of Autosar files created expected following files " + expectedFilePaths.join(", ") +
				" but was " + actualAutosarFiles.join(", "), expectedFilePaths.size, actualAutosarFiles.size)
		val actualIterator = actualAutosarFiles.sort.iterator
		val expectedIterator = expectedFilePaths.sort.iterator
		while (actualIterator.hasNext) {
			assertAutosarFilesAreEqual(actualIterator.next, expectedIterator.next)
		}
	}

	/**
	 * For Autosar models, we compare the actual output files, but ignore the first two lines (which is the Autosar header)
	 */
	def static void assertAutosarFilesAreEqual(String actualFileName, String expectedFileName) {
		var actualContent = Files.readAllLines(Paths.get(actualFileName)).drop(2).toList
		var expectedContent = Files.readAllLines(Paths.get(expectedFileName)).drop(2).toList
		actualContent = actualContent.map[it.trim]
		expectedContent = expectedContent.map[it.trim]
		var firstDiffingLine = getFirstDiffLine(actualContent, expectedContent)
		if (!actualContent.equals(expectedContent)) {
			val actualContentStr = actualContent.join(System.lineSeparator)
			val expectedContentStr = expectedContent.join(System.lineSeparator)
			var diffLine = ""
			if (firstDiffingLine>=0) {
				diffLine += "First diffing line: " + (firstDiffingLine+3) + " ("
				if (firstDiffingLine<actualContent.size)
					diffLine += "actual: '" + actualContent.get(firstDiffingLine) + "'"
				if (firstDiffingLine<expectedContent.size)
					diffLine += " expected: '" + expectedContent.get(firstDiffingLine) + "'"
				diffLine += ")" + System.lineSeparator
			}
			fail(
				"Actual file: " + actualFileName + " does not equal expected file " + expectedFileName + System.lineSeparator +
				diffLine +
				"Actual content is: " + actualContentStr + System.lineSeparator +
				"Expected content was: " + expectedContentStr + System.lineSeparator
			)
		}
	}
	
	def static private int getFirstDiffLine(List<String> first, List<String> second) {
		var n = Integer.min(first.size, second.size)
		for(var i=0; i<n; i++) {
			if (! first.get(i).equals(second.get(i))) {
				return i
			}
		}
		return first.size==second.size ? -1 : n
	}

	def static void setUuidsTo0(AUTOSAR model) {
		model.eAllContents.filter(Identifiable).forEach [
			uuid = "0"
		]
	}

}
