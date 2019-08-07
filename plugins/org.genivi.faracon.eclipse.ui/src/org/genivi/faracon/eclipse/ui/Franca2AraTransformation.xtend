package org.genivi.faracon.eclipse.ui

import org.eclipse.jface.action.IAction

class Franca2AraTransformation extends AbstractTransformationAction {

	new() {
		super("fidl")
	}

	override void run(IAction action) {
		val filePaths = initConverterAndFindFile
		converter.convertFrancaFiles(filePaths)
	}
}
