package org.genivi.faracon.eclipse.ui

import org.eclipse.jface.action.IAction

class Ara2FrancaTransformation extends AbstractTransformationAction {

	new() {
		super("arxml")
	}

	override void run(IAction action) {
		val filePaths = initConverterAndFindFile
		converter.convertARAFiles(filePaths)
	}
}
