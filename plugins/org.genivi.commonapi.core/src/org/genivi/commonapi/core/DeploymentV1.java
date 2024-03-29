/*******************************************************************************
* This file has been generated by Franca's FDeployGenerator.
* Source: deployment specification 'org.genivi.commonapi.core.deployment'
*******************************************************************************/
package org.genivi.commonapi.core;

import java.util.List;
import java.util.Map;

import org.franca.core.franca.FArgument;
import org.franca.core.franca.FArrayType;
import org.franca.core.franca.FAttribute;
import org.franca.core.franca.FBroadcast;
import org.franca.core.franca.FEnumerationType;
import org.franca.core.franca.FEnumerator;
import org.franca.core.franca.FField;
import org.franca.core.franca.FInterface;
import org.franca.core.franca.FMethod;
import org.franca.core.franca.FModelElement;
import org.franca.deploymodel.core.FDeployedInterface;
import org.franca.deploymodel.core.FDeployedRootElement;
import org.franca.deploymodel.core.FDeployedTypeCollection;
import org.franca.deploymodel.core.MappingGenericPropertyAccessor;
import org.franca.deploymodel.dsl.fDeploy.FDCompoundOverwrites;
import org.franca.deploymodel.dsl.fDeploy.FDEnumValue;
import org.franca.deploymodel.dsl.fDeploy.FDEnumerationOverwrites;
import org.franca.deploymodel.dsl.fDeploy.FDExtensionElement;
import org.franca.deploymodel.dsl.fDeploy.FDExtensionRoot;
import org.franca.deploymodel.dsl.fDeploy.FDField;
import org.franca.deploymodel.dsl.fDeploy.FDOverwriteElement;
import org.franca.deploymodel.dsl.fDeploy.FDTypeOverwrites;

import com.google.common.collect.Maps;

/**
 * This is a collection of all interfaces and classes needed for
 * accessing deployment properties according to deployment specification
 * 'org.genivi.commonapi.core.deployment'.
 */
public class DeploymentV1 {

	/**
	 * Enumerations for deployment specification org.genivi.commonapi.core.deployment.
	 */
	public interface Enums
	{
		public enum DefaultEnumBackingType {
			UInt8, UInt16, UInt32, UInt64, Int8, Int16, Int32, Int64
		}
		 
		public enum EnumBackingType {
			UInt8, UInt16, UInt32, UInt64, Int8, Int16, Int32, Int64
		}
		 
		public enum ErrorType {
			Error, Warning, Info, NoError
		}
		 
		public enum BroadcastType {
			signal, error
		}
		 
	}

	/**
	 * Interface for data deployment properties for 'org.genivi.commonapi.core.deployment' specification
	 * 
	 * This is the data types related part only.
	 */
	public interface IDataPropertyAccessor
		extends Enums
	{
		// host 'enumerations'
		public EnumBackingType getEnumBackingType(FEnumerationType obj);
		public ErrorType getErrorType(FEnumerationType obj);
			
		
		/**
		 * Get an overwrite-aware accessor for deployment properties.</p>
		 *
		 * This accessor will return overwritten property values in the context 
		 * of a Franca FField object. I.e., the FField obj has a datatype
		 * which can be overwritten in the deployment definition (e.g., Franca array,
		 * struct, union or enumeration). The accessor will return the overwritten values.
		 * If the deployment definition didn't overwrite the value, this accessor will
		 * delegate to its parent accessor.</p>
		 *
		 * @param obj a Franca FField which is the context for the accessor
		 * @return the overwrite-aware accessor
		 */
		public IDataPropertyAccessor getOverwriteAccessor(FField obj);
	
		/**
		 * Get an overwrite-aware accessor for deployment properties.</p>
		 *
		 * This accessor will return overwritten property values in the context 
		 * of a Franca FArrayType object. I.e., the FArrayType obj has a datatype
		 * which can be overwritten in the deployment definition (e.g., Franca array,
		 * struct, union or enumeration). The accessor will return the overwritten values.
		 * If the deployment definition didn't overwrite the value, this accessor will
		 * delegate to its parent accessor.</p>
		 *
		 * @param obj a Franca FArrayType which is the context for the accessor
		 * @return the overwrite-aware accessor
		 */
		public IDataPropertyAccessor getOverwriteAccessor(FArrayType obj);
	}

	/**
	 * Helper class for data-related property accessors.
	 */		
	public static class DataPropertyAccessorHelper implements Enums
	{
		final private MappingGenericPropertyAccessor target;
		final private IDataPropertyAccessor owner;
		
		public DataPropertyAccessorHelper(
			MappingGenericPropertyAccessor target,
			IDataPropertyAccessor owner
		) {
			this.target = target;
			this.owner = owner;
		}
	
		public static DefaultEnumBackingType convertDefaultEnumBackingType(String val) {
			if (val.equals("UInt8"))
				return DefaultEnumBackingType.UInt8; else 
			if (val.equals("UInt16"))
				return DefaultEnumBackingType.UInt16; else 
			if (val.equals("UInt32"))
				return DefaultEnumBackingType.UInt32; else 
			if (val.equals("UInt64"))
				return DefaultEnumBackingType.UInt64; else 
			if (val.equals("Int8"))
				return DefaultEnumBackingType.Int8; else 
			if (val.equals("Int16"))
				return DefaultEnumBackingType.Int16; else 
			if (val.equals("Int32"))
				return DefaultEnumBackingType.Int32; else 
			if (val.equals("Int64"))
				return DefaultEnumBackingType.Int64;
			return null;
		}
		
		public static EnumBackingType convertEnumBackingType(String val) {
			if (val.equals("UInt8"))
				return EnumBackingType.UInt8; else 
			if (val.equals("UInt16"))
				return EnumBackingType.UInt16; else 
			if (val.equals("UInt32"))
				return EnumBackingType.UInt32; else 
			if (val.equals("UInt64"))
				return EnumBackingType.UInt64; else 
			if (val.equals("Int8"))
				return EnumBackingType.Int8; else 
			if (val.equals("Int16"))
				return EnumBackingType.Int16; else 
			if (val.equals("Int32"))
				return EnumBackingType.Int32; else 
			if (val.equals("Int64"))
				return EnumBackingType.Int64;
			return null;
		}
		
		public static ErrorType convertErrorType(String val) {
			if (val.equals("Error"))
				return ErrorType.Error; else 
			if (val.equals("Warning"))
				return ErrorType.Warning; else 
			if (val.equals("Info"))
				return ErrorType.Info; else 
			if (val.equals("NoError"))
				return ErrorType.NoError;
			return null;
		}
		
		public static BroadcastType convertBroadcastType(String val) {
			if (val.equals("signal"))
				return BroadcastType.signal; else 
			if (val.equals("error"))
				return BroadcastType.error;
			return null;
		}
		
		
		protected IDataPropertyAccessor getOverwriteAccessorAux(FModelElement obj) {
			FDOverwriteElement fd = (FDOverwriteElement)target.getFDElement(obj);
			FDTypeOverwrites overwrites = fd.getOverwrites();
			if (overwrites==null)
				return owner;
			else
				return new OverwriteAccessor(overwrites, owner, target);
		}
	}

	/**
	 * Accessor for deployment properties for Franca type collections according
	 * to deployment specification 'org.genivi.commonapi.core.deployment'.
	 */		
	public static class TypeCollectionPropertyAccessor
		implements IDataPropertyAccessor
	{
		private final MappingGenericPropertyAccessor target;
		private final DataPropertyAccessorHelper helper;
	
		public TypeCollectionPropertyAccessor(FDeployedTypeCollection target) {
			this.target = target;
			this.helper = new DataPropertyAccessorHelper(target, this);
		}
		
		// host 'enumerations'
		@Override
		public EnumBackingType getEnumBackingType(FEnumerationType obj) {
			String e = target.getEnum(obj, "EnumBackingType");
			if (e==null) return null;
			return DataPropertyAccessorHelper.convertEnumBackingType(e);
		}
		@Override
		public ErrorType getErrorType(FEnumerationType obj) {
			String e = target.getEnum(obj, "ErrorType");
			if (e==null) return null;
			return DataPropertyAccessorHelper.convertErrorType(e);
		}
			
		
		@Override
		public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	
		@Override
		public IDataPropertyAccessor getOverwriteAccessor(FArrayType obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	}

	/**
	 * Accessor for deployment properties for Franca interfaces according to
	 * deployment specification 'org.genivi.commonapi.core.deployment'.
	 */
	public static class InterfacePropertyAccessor
		implements IDataPropertyAccessor
	{
		private final MappingGenericPropertyAccessor target;
		private final DataPropertyAccessorHelper helper;
	
		public InterfacePropertyAccessor(FDeployedInterface target) {
			this.target = target;
			this.helper = new DataPropertyAccessorHelper(target, this);
		}
		
		// host 'interfaces'
		public DefaultEnumBackingType getDefaultEnumBackingType(FInterface obj) {
			String e = target.getEnum(obj, "DefaultEnumBackingType");
			if (e==null) return null;
			return DataPropertyAccessorHelper.convertDefaultEnumBackingType(e);
		}
			
		// host 'methods'
		public Integer getTimeout(FMethod obj) {
			return target.getInteger(obj, "Timeout");
		}
		public List<String> getErrors(FMethod obj) {
			return target.getStringArray(obj, "Errors");
		}
			
		// host 'attributes'
		public Integer getTimeout(FAttribute obj) {
			return target.getInteger(obj, "Timeout");
		}
			
		// host 'enumerations'
		@Override
		public EnumBackingType getEnumBackingType(FEnumerationType obj) {
			String e = target.getEnum(obj, "EnumBackingType");
			if (e==null) return null;
			return DataPropertyAccessorHelper.convertEnumBackingType(e);
		}
		@Override
		public ErrorType getErrorType(FEnumerationType obj) {
			String e = target.getEnum(obj, "ErrorType");
			if (e==null) return null;
			return DataPropertyAccessorHelper.convertErrorType(e);
		}
			
		// host 'broadcasts'
		public BroadcastType getBroadcastType(FBroadcast obj) {
			String e = target.getEnum(obj, "BroadcastType");
			if (e==null) return null;
			return DataPropertyAccessorHelper.convertBroadcastType(e);
		}
		public String getErrorName(FBroadcast obj) {
			return target.getString(obj, "ErrorName");
		}
			
		
		/**
		 * Get an overwrite-aware accessor for deployment properties.</p>
		 *
		 * This accessor will return overwritten property values in the context 
		 * of a Franca FAttribute object. I.e., the FAttribute obj has a datatype
		 * which can be overwritten in the deployment definition (e.g., Franca array,
		 * struct, union or enumeration). The accessor will return the overwritten values.
		 * If the deployment definition didn't overwrite the value, this accessor will
		 * delegate to its parent accessor.</p>
		 *
		 * @param obj a Franca FAttribute which is the context for the accessor
		 * @return the overwrite-aware accessor
		 */
		public IDataPropertyAccessor getOverwriteAccessor(FAttribute obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	
		/**
		 * Get an overwrite-aware accessor for deployment properties.</p>
		 *
		 * This accessor will return overwritten property values in the context 
		 * of a Franca FArgument object. I.e., the FArgument obj has a datatype
		 * which can be overwritten in the deployment definition (e.g., Franca array,
		 * struct, union or enumeration). The accessor will return the overwritten values.
		 * If the deployment definition didn't overwrite the value, this accessor will
		 * delegate to its parent accessor.</p>
		 *
		 * @param obj a Franca FArgument which is the context for the accessor
		 * @return the overwrite-aware accessor
		 */
		public IDataPropertyAccessor getOverwriteAccessor(FArgument obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	
		@Override
		public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	
		@Override
		public IDataPropertyAccessor getOverwriteAccessor(FArrayType obj) {
			return helper.getOverwriteAccessorAux(obj);
		}
	}

	/**
	 * Accessor for deployment properties for 'provider' roots
	 * (which are defined by the 'providers and instances' extension)
	 * according to the 'org.genivi.commonapi.core.deployment' specification.
	 */
	public static class ProviderPropertyAccessor
		implements Enums
	{
		final private FDeployedRootElement<FDExtensionRoot> target;
	
		public ProviderPropertyAccessor(FDeployedRootElement<FDExtensionRoot> target) {
			this.target = target;
		}
		
		// host 'providers'
		public List<FDExtensionElement> getClientInstanceReferences(FDExtensionRoot obj) {
			return target.getGenericReferenceArray(obj, FDExtensionElement.class, "ClientInstanceReferences");
		}
		public List<String> getProjectVariants(FDExtensionRoot obj) {
			return target.getStringArray(obj, "ProjectVariants");
		}
		
		// host 'instances'
		public String getDomain(FDExtensionElement obj) {
			return target.getString(obj, "Domain");
		}
		public String getInstanceId(FDExtensionElement obj) {
			return target.getString(obj, "InstanceId");
		}
		public Integer getDefaultTimeout(FDExtensionElement obj) {
			return target.getInteger(obj, "DefaultTimeout");
		}
		public List<String> getPreregisteredProperties(FDExtensionElement obj) {
			return target.getStringArray(obj, "PreregisteredProperties");
		}
		public String getCodeArtifactName(FDExtensionElement obj) {
			return target.getString(obj, "CodeArtifactName");
		}
		
	}
	
	/**
	 * Accessor for getting overwritten property values.
	 */		
	public static class OverwriteAccessor
		implements IDataPropertyAccessor
	{
		private final MappingGenericPropertyAccessor target;
		private final IDataPropertyAccessor delegate;
		
		private final FDTypeOverwrites overwrites;
		private final Map<FField, FDField> mappedFields;
		private final Map<FEnumerator, FDEnumValue> mappedEnumerators;
	
		public OverwriteAccessor(
				FDTypeOverwrites overwrites,
				IDataPropertyAccessor delegate,
				MappingGenericPropertyAccessor genericAccessor)
		{
			this.target = genericAccessor;
			this.delegate = delegate;
	
			this.overwrites = overwrites;
			this.mappedFields = Maps.newHashMap();
			this.mappedEnumerators = Maps.newHashMap();
			if (overwrites!=null) {
				if (overwrites instanceof FDCompoundOverwrites) {
					// build mapping for compound fields
					for(FDField f : ((FDCompoundOverwrites)overwrites).getFields()) {
						this.mappedFields.put(f.getTarget(), f);
					}
				}
				if (overwrites instanceof FDEnumerationOverwrites) {
					// build mapping for enumerators
					for(FDEnumValue e : ((FDEnumerationOverwrites)overwrites).getEnumerators()) {
						this.mappedEnumerators.put(e.getTarget(), e);
					}
				}
			}
		}
		
		// host 'enumerations'
		@Override
		public EnumBackingType getEnumBackingType(FEnumerationType obj) {
			if (overwrites!=null) {
				String e = target.getEnum(overwrites, "EnumBackingType");
				if (e!=null) {
					return DataPropertyAccessorHelper.convertEnumBackingType(e);
				}
			}
			return delegate.getEnumBackingType(obj);
		}
		@Override
		public ErrorType getErrorType(FEnumerationType obj) {
			if (overwrites!=null) {
				String e = target.getEnum(overwrites, "ErrorType");
				if (e!=null) {
					return DataPropertyAccessorHelper.convertErrorType(e);
				}
			}
			return delegate.getErrorType(obj);
		}
			
		
		@Override
		public IDataPropertyAccessor getOverwriteAccessor(FField obj) {
			// check if this field is overwritten
			if (mappedFields.containsKey(obj)) {
				FDField fo = mappedFields.get(obj);
				FDTypeOverwrites overwrites = fo.getOverwrites();
				if (overwrites==null)
					return this; // TODO: correct?
				else
					// TODO: this or delegate?
					return new OverwriteAccessor(overwrites, this, target);
				
			}
			return delegate.getOverwriteAccessor(obj);
		}
	
		@Override
		public IDataPropertyAccessor getOverwriteAccessor(FArrayType obj) {
			// check if this array is overwritten
			if (overwrites!=null) {
				// TODO: this or delegate?
				return new OverwriteAccessor(overwrites, this, target);
			}
			return delegate.getOverwriteAccessor(obj);
		}
	}
}
	
