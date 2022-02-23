package org.genivi.faracon.franca2ara.types

import autosar40.autosartoplevelstructure.AUTOSAR
import autosar40.commonstructure.implementationdatatypes.ImplementationDataType
import autosar40.genericstructure.generaltemplateclasses.arpackage.ARPackage
import com.google.inject.Inject
import java.util.Map
import javax.inject.Singleton
import org.franca.core.franca.FBasicTypeId
import org.genivi.faracon.ARAResourceSet
import org.genivi.faracon.Franca2ARABase
import org.genivi.faracon.preferences.Preferences
import org.genivi.faracon.util.AutosarUtil
import autosar40.commonstructure.basetypes.SwBaseType
import autosar40.genericstructure.generaltemplateclasses.identifiable.Identifiable

@Singleton
class ARAPrimitiveTypesCreator extends Franca2ARABase {

	@Inject
	var extension AutosarUtil

	var Map<String, SwBaseType> nameToBaseType = null

	var Map<String, ImplementationDataType> nameToImplType = null
	var Map<String, ImplementationDataType> nameToImplVectorType = null

	new() {
		Preferences.instance.registerARAPrimitiveTypesCreator(this)
	}

	def loadPrimitiveTypes() {
		if (nameToImplType === null) {
			explicitlyLoadPrimitiveTypes
		}
	}

	def explicitlyLoadPrimitiveTypes() {
		nameToBaseType = newHashMap
		nameToImplType = newHashMap
		nameToImplVectorType = newHashMap

		val ARAResourceSet araResourceSet = new ARAResourceSet()
		val AUTOSAR primitiveTypesModel = araResourceSet.araStandardTypeDefinitionsModel.standardTypeDefinitionsModel
		primitiveTypesModel.eAllContents.filter(SwBaseType).forEach[
			nameToBaseType.put(it.nameForIndex, it)
		]
		primitiveTypesModel.eAllContents.filter(ImplementationDataType).forEach[
			nameToImplType.put(it.nameForIndex, it)
		]

		val AUTOSAR primitiveTypesVectorsModel = araResourceSet.araStandardTypeDefinitionsModel.standardVectorTypeDefinitionsModel
		primitiveTypesVectorsModel.eAllContents.filter(ImplementationDataType).forEach[
			nameToImplVectorType.put(it.shortName, it)
		]
	}
	
	def private String getNameForIndex(Identifiable id) {
		// first check annotation with "IndexTypeName"
		if (!id.annotations.empty) {
			val index = id.annotations.findFirst[a |
				!a.label.l4s.empty && a.label.l4s.head.mixedText == "IndexTypeName"
			]
			if (index!==null) {
				val verbs = index.annotationText.verbatims
				if (!verbs.empty && !verbs.head.l5s.empty) {
					val l5 = verbs.head.l5s.head
					//println("INDEX for " + id.shortName + " is " + l5.mixedText)
					return l5.mixedText
				}
			}			
		}
		
		// default: use shortName for indexing
		id.shortName
	}
	
	def getBaseTypeForReference(FBasicTypeId fBasicTypeId) {
		loadPrimitiveTypes		
		val name = 
			switch (fBasicTypeId) {
				case FBasicTypeId.INT8: "std_int8_t"
				case FBasicTypeId.INT16: "std_int16_t"
				case FBasicTypeId.INT32: "std_int32_t"
				case FBasicTypeId.INT64: "std_int64_t"
				case FBasicTypeId.UINT8: "std_uint8_t"
				case FBasicTypeId.UINT16: "std_uint16_t"
				case FBasicTypeId.UINT32: "std_uint32_t"
				case FBasicTypeId.UINT64: "std_uint64_t"
				case FBasicTypeId.BOOLEAN: "cpp_bool"
				case FBasicTypeId.FLOAT: "cpp_float"
				case FBasicTypeId.DOUBLE: "cpp_double"
				default: null
			}
		if (name===null) {
			return null
		}
		if(!this.nameToBaseType.containsKey(name)){
			getLogger.logError("Cannot find an AUTOSAR basetype for the FBasicTypeId: " + fBasicTypeId?.getName + "!")
		}
		this.nameToBaseType.get(name)
	}
	
	def getStringBaseType() {
		getBaseTypeForReference(FBasicTypeId.UINT8)
	}

	def getStdTypeForReference(FBasicTypeId fBasicTypeId, TypeContext tc) {
		loadPrimitiveTypes		
		if(!this.nameToImplType.containsKey(fBasicTypeId.getName)){
			getLogger.logError("Cannot find an AUTOSAR simple type for the FBasicTypeId: " + fBasicTypeId?.getName + "! (IDL2620)")
		}
		if (fBasicTypeId == FBasicTypeId.BYTE_BUFFER){
			val n = tc!==null ? "'" + tc.typedElementName + "' in '" + tc.namespaceName + "'" : "(unknown location)"
			logger.logWarning(
				"The CommonAPI and AUTOSAR serialization formats of the Franca ByteBuffer " + n +
				" are equivalent only if the ARA::COM system configuration defines array sizes to be encoded with 4 Bytes."
			)
		}
		this.nameToImplType.get(fBasicTypeId.getName)
	}

	def getStdTypeVectorForReference(FBasicTypeId fBasicTypeId, TypeContext tc) {
		loadPrimitiveTypes
		val basicTypeVectorName = fBasicTypeId.getName + "Vector"
		if(!this.nameToImplVectorType.containsKey(basicTypeVectorName)){
			getLogger.logError("Cannot find an AUTOSAR vector type for the FBasicTypeId: " + fBasicTypeId?.getName + "! (IDL2620)")
		}
		if(fBasicTypeId == FBasicTypeId.BYTE_BUFFER){
			logger.logWarning(
				'''The CommonAPI and AUTOSAR serialization formats of the Franca ByteBuffers in the array '«tc.typedElementName»' in '«tc.namespaceName»' are equivalent only if the ARA::COM system configuration defines array sizes to be encoded with 4 Bytes.''')
		}
		this.nameToImplVectorType.get(basicTypeVectorName)
	}
	
	def isPrimitiveType(ImplementationDataType implementationDataType) {
		val lookupImplementationDataType = nameToImplType.get(implementationDataType.shortName)
		return lookupImplementationDataType !== null && lookupImplementationDataType === implementationDataType
	}


	var AUTOSAR primitiveTypesAnonymousArraysModel
	var ARPackage primitiveTypesAnonymousArraysMainPackage

	def clearPrimitiveTypesAnonymousArrays() {
		primitiveTypesAnonymousArraysModel = null
		primitiveTypesAnonymousArraysMainPackage = null
	}

	def createPrimitiveTypesAnonymousArraysModel() {
		primitiveTypesAnonymousArraysModel = fac.createAUTOSAR
		if (nameToImplType !== null) {
			val packagePath = AutosarUtil.collectPackagePath(nameToImplType.values.head.ARPackage)
			primitiveTypesAnonymousArraysMainPackage =
				primitiveTypesAnonymousArraysModel.ensurePackagesExistence(packagePath)
		}
	}

	def getPrimitiveTypesAnonymousArraysModel() {
		primitiveTypesAnonymousArraysModel
	}
	
	def getOrCreatePrimitiveTypesAnonymousArraysMainPackage() {
		if (primitiveTypesAnonymousArraysMainPackage === null) {
			createPrimitiveTypesAnonymousArraysModel
		}
		primitiveTypesAnonymousArraysMainPackage
	}

}
