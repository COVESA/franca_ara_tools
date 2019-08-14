package org.genivi.faracon.cli

import java.io.File

class ConverterHelper {
	new(){
		
	}
	
	def static String normalize(String _path) {
		val itsFile = new File(_path);
		return itsFile.getAbsolutePath();
	}
}