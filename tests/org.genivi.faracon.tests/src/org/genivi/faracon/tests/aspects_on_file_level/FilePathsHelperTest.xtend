package org.genivi.faracon.tests.aspects_on_file_level

import java.util.Collection
import org.junit.Test
import org.genivi.faracon.cli.FilePathsHelper
import static org.junit.Assert.assertEquals
import java.io.File
import java.util.regex.Pattern

class FilePathsHelperTest {

	@Test
	def void testFilePathHelperWithSingleFidlFile() {
		val path = "src/org/genivi/faracon/tests/aspects_on_structs/a2f/multipleStructTest.fidl"
		executeFilePathHelperTest(#[path], #[path])
	}

	@Test
	def void testFilePathHelperWithDirectory() {
		val path = "src/org/genivi/faracon/tests/aspects_on_franca_methods/a2f/"
		executeFilePathHelperTest(#[path],
			#[path + "broadcastArgumentExpected.fidl", path + "multipleMethodInputArgumentsExpected.fidl",
				path + "inOutExpected.fidl", path + "multipleMethodReturnValuesExpected.fidl"])
	}

	@Test
	def void testFilePathHelperRecursievly() {
		val path = "src/org/genivi/faracon/tests/aspects_on_franca_methods/"
		executeFilePathHelperTest(#[path],
			#[path + "a2f/broadcastArgumentExpected.fidl", path + "a2f/multipleMethodInputArgumentsExpected.fidl",
				path + "a2f/inOutExpected.fidl", path + "a2f/multipleMethodReturnValuesExpected.fidl",
				path + "f2a/arrayMethodInputArgument.fidl", path + "f2a/broadcastArgument.fidl",
				path + "f2a/fireAndForgetMethod.fidl", path + "f2a/methodWithInAndOutArguments.fidl",
				path + "f2a/multipleMethodInputArguments.fidl", path + "f2a/multipleMethodReturnValues.fidl",
				path + "f2a/oneMethodInputArgument.fidl", path + "f2a/oneMethodReturnValue.fidl"])
	}

	@Test
	def void testFilePathHelperDuplicateFilesInInput() {
		val path = "src/org/genivi/faracon/tests/aspects_on_franca_methods/"
		val childPath = "src/org/genivi/faracon/tests/aspects_on_franca_methods/a2f"
		val childFile = "src/org/genivi/faracon/tests/aspects_on_franca_methods/a2f/broadcastArgumentExpected.fidl"
		executeFilePathHelperTest(#[childFile, childPath, path],
			#[path + "a2f/broadcastArgumentExpected.fidl", path + "a2f/multipleMethodInputArgumentsExpected.fidl",
				path + "a2f/inOutExpected.fidl", path + "a2f/multipleMethodReturnValuesExpected.fidl",
				path + "f2a/arrayMethodInputArgument.fidl", path + "f2a/broadcastArgument.fidl",
				path + "f2a/fireAndForgetMethod.fidl", path + "f2a/methodWithInAndOutArguments.fidl",
				path + "f2a/multipleMethodInputArguments.fidl", path + "f2a/multipleMethodReturnValues.fidl",
				path + "f2a/oneMethodInputArgument.fidl", path + "f2a/oneMethodReturnValue.fidl"])
	}

	def private void executeFilePathHelperTest(String[] paths, Collection<String> expectedResult) {
		// given: the path
		// when
		var foundFilePaths = FilePathsHelper.findFiles(paths, "fidl")

		// replace platform separator with "/" in order to ensure that the assert works on all platforms
		foundFilePaths = foundFilePaths.map[it.replaceAll(Pattern.quote(File.separator), "/")].toList

		// then
		assertEquals("Found wrong file paths", expectedResult.sortBy[it], foundFilePaths.sortBy[it])

	}
}
