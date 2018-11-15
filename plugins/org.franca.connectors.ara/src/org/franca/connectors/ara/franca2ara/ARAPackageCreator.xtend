package org.franca.connectors.ara.franca2ara

import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import java.util.Map
import javax.inject.Singleton
import org.apache.log4j.Logger
import org.eclipse.emf.ecore.util.EcoreUtil
import org.franca.connectors.ara.Franca2ARABase
import org.franca.core.franca.FModel
import org.franca.core.franca.FModelElement

@Singleton
class ARAPackageCreator extends Franca2ARABase {

	private static Logger logger = Logger.getLogger(ARAPackageCreator.name)

	val Map<FModel, ARPackage> fModel2Packages = newHashMap()
	
	def create fac.createARPackage createPackage(FModel fModel) {
		val segments = fModel.name.split("\\.")
		shortName = (if(segments === null) segments.get(0) else fModel.name)
		fModel2Packages.put(fModel, it)
	}

	def ARPackage findArPackageForFrancaElement(FModelElement fModelElement) {
		val rootFrancaModel = EcoreUtil.getRootContainer(fModelElement)
		if (!fModel2Packages.containsKey(rootFrancaModel)) {
			val reason = if(rootFrancaModel ===
					null) "No root element for franca element found" else "No package created for franca root " +
					rootFrancaModel
			logger.warn('''No package can be found for the Franca element "«fModelElement». ". Reason: «reason»''')
		}
		return fModel2Packages.get(rootFrancaModel)
	}
}
