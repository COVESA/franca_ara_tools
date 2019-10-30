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
		executeFilePathHelperTest(#[path], #["/multipleStructTest.fidl"])
	}

	@Test
	def void testFilePathHelperWithDirectory() {
		val path = "src/org/genivi/faracon/tests/aspects_on_franca_methods/a2f/"
		executeFilePathHelperTest(#[path],
			#["/broadcastArgumentExpected.fidl", "/multipleMethodInputArgumentsExpected.fidl", "/inOutExpected.fidl",
				"/multipleMethodReturnValuesExpected.fidl"])
	}

	@Test
	def void testFilePathHelperRecursievly() {
		val path = "src/org/genivi/faracon/tests/aspects_on_franca_methods/"
		executeFilePathHelperTest(#[path],
			#["/a2f/broadcastArgumentExpected.fidl", "/a2f/multipleMethodInputArgumentsExpected.fidl",
				"/a2f/inOutExpected.fidl", "/a2f/multipleMethodReturnValuesExpected.fidl",
				"/f2a/arrayMethodInputArgument.fidl", "/f2a/broadcastArgument.fidl", "/f2a/fireAndForgetMethod.fidl",
				"/f2a/methodWithInAndOutArguments.fidl", "/f2a/multipleMethodInputArguments.fidl",
				"/f2a/multipleMethodReturnValues.fidl", "/f2a/oneMethodInputArgument.fidl",
				"/f2a/oneMethodReturnValue.fidl"])
	}

	@Test
	def void testFilePathHelperDuplicateFilesInInput() {
		val path = "src/org/genivi/faracon/tests/aspects_on_franca_methods/"
		val childPath = "src/org/genivi/faracon/tests/aspects_on_franca_methods/a2f"
		val childFile = "src/org/genivi/faracon/tests/aspects_on_franca_methods/a2f/broadcastArgumentExpected.fidl"
		executeFilePathHelperTest(#[childFile, childPath, path],
			#["/a2f/broadcastArgumentExpected.fidl", "/broadcastArgumentExpected.fidl",
				"/a2f/multipleMethodInputArgumentsExpected.fidl", "/a2f/inOutExpected.fidl",
				"/a2f/multipleMethodReturnValuesExpected.fidl", "/f2a/arrayMethodInputArgument.fidl",
				"/f2a/broadcastArgument.fidl", "/f2a/fireAndForgetMethod.fidl", "/f2a/methodWithInAndOutArguments.fidl",
				"/f2a/multipleMethodInputArguments.fidl", "/f2a/multipleMethodReturnValues.fidl",
				"/f2a/oneMethodInputArgument.fidl", "/f2a/oneMethodReturnValue.fidl", "/inOutExpected.fidl",
				"/multipleMethodInputArgumentsExpected.fidl", "/multipleMethodReturnValuesExpected.fidl"])
	}

	@Test
	def void testIdentivalFilePathAsInput() {
		val path = "src/org/genivi/faracon/tests/aspects_on_franca_methods/"
		val identicalPath = "src/org/genivi/faracon/tests/aspects_on_franca_methods/"
		executeFilePathHelperTest(#[path, identicalPath],
			#["/a2f/broadcastArgumentExpected.fidl", "/a2f/multipleMethodInputArgumentsExpected.fidl",
				"/a2f/inOutExpected.fidl", "/a2f/multipleMethodReturnValuesExpected.fidl",
				"/f2a/arrayMethodInputArgument.fidl", "/f2a/broadcastArgument.fidl", "/f2a/fireAndForgetMethod.fidl",
				"/f2a/methodWithInAndOutArguments.fidl", "/f2a/multipleMethodInputArguments.fidl",
				"/f2a/multipleMethodReturnValues.fidl", "/f2a/oneMethodInputArgument.fidl",
				"/f2a/oneMethodReturnValue.fidl"])
	}

	def private void executeFilePathHelperTest(String[] paths, Collection<String> expectedResult) {
		// given: the path
		// when
		val foundFilePaths = FilePathsHelper.findInputFiles(paths, "fidl")

		var relativeFilePaths = foundFilePaths.map[it.absolutePath.substring(it.basePathLength)]
		// replace platform separator with "/" in order to ensure that the assert works on all platforms
		relativeFilePaths = relativeFilePaths.map[it.replaceAll(Pattern.quote(File.separator), "/")].toList

		// then
		assertEquals("Found wrong file paths", expectedResult.sortBy[it], relativeFilePaths.sortBy[it])

	}
}
