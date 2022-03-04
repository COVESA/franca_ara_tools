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
	
	val static SEP = System.lineSeparator
	
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
		val actualContent = Files.readAllLines(Paths.get(actualFileName)).drop(2).toList
		val expectedContent = Files.readAllLines(Paths.get(expectedFileName)).drop(2).toList
		val actualContentTrimmed = actualContent.map[it.trim]
		val expectedContentTrimmed = expectedContent.map[it.trim]
		var firstDiffingLine = getFirstDiffLine(actualContentTrimmed, expectedContentTrimmed)
		if (firstDiffingLine >= 0) {
			var diffLine = ""
			diffLine += "First diffing line: " + (firstDiffingLine+3) + " ("
			if (firstDiffingLine<actualContent.size)
				diffLine += "actual: '" + actualContentTrimmed.get(firstDiffingLine) + "'"
			if (firstDiffingLine<expectedContent.size)
				diffLine += " expected: '" + expectedContentTrimmed.get(firstDiffingLine) + "'"
			diffLine += ")" + SEP
			
			val actualContentStr = actualContent.join(SEP)
			val expectedContentStr = expectedContent.join(SEP)
			fail(
				"Actual file: " + actualFileName + " does not equal expected file " + expectedFileName + SEP +
				diffLine +
				"Actual content is:" + SEP + actualContentStr + SEP +
				"Expected content was:" + SEP + expectedContentStr + SEP
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
