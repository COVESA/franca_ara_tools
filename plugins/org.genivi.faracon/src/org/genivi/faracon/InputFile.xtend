package org.genivi.faracon

import org.eclipse.xtend.lib.annotations.Data

@Data
class InputFile {
	val String absolutePath
	val int basePathLength
}
