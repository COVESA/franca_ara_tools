package org.franca.connectors.ara.franca2ara

import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import java.util.HashMap
import javax.inject.Singleton
import org.apache.log4j.Logger
import org.franca.connectors.ara.ARAConnector
import org.franca.connectors.ara.Franca2ARABase
import org.franca.core.franca.FBasicTypeId

@Singleton
class ARAPrimitveTypesCreator extends Franca2ARABase {

	private static final Logger logger = Logger.getLogger(ARAPrimitveTypesCreator.name)
	
	//todo: use a more reliable path
	val static String PATH_TO_STD_ARXML_FILES = "../../plugins/org.franca.connectors.ara/models/stdtypes.arxml"

	val nameToType = new HashMap<String, ImplementationDataType>()

	def ARPackage createPrimitiveTypesPackage() {
		val primitiveTypeModel = ARAConnector.loadAraModel(PATH_TO_STD_ARXML_FILES)
		val topLevelPackage = primitiveTypeModel.arPackages.get(0)
		primitiveTypeModel.eAllContents.filter(ImplementationDataType).forEach[
			nameToType.put(it.shortName,it)
		]
		return topLevelPackage
	}

	def getBaseTypeForReference(FBasicTypeId fBasicTypeId) {
		if(!this.nameToType.containsKey(fBasicTypeId.getName)){
			logger.error("Can not find an Autosar simple type for the FBasicType: " + fBasicTypeId?.getName)
		}
		this.nameToType.get(fBasicTypeId.getName)
	}
}
