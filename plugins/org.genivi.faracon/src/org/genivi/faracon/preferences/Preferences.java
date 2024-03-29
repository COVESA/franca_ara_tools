package org.genivi.faracon.preferences;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.franca.core.franca.FModel;
import org.genivi.faracon.franca2ara.types.ARAPrimitiveTypesCreator;

import com.google.common.collect.Lists;

public class Preferences {

	private ARAPrimitiveTypesCreator araPrimitiveTypesCreator;

	public class UnknownPreferenceException extends Exception {
		private static final long serialVersionUID = -3576591568647428294L;

		UnknownPreferenceException(String message) {
			super(message);
		}
	}

	private static Preferences instance = null;
	private Map<String, String> preferences = null;
	
	public Map<String, String> getPreferences() {
		return preferences;
	}

	private Preferences() {
		preferences = new HashMap<String, String>();
		clidefPreferences();
	}

	public void registerARAPrimitiveTypesCreator(ARAPrimitiveTypesCreator araPrimitiveTypesCreator) {
		this.araPrimitiveTypesCreator = araPrimitiveTypesCreator;
	}

	public void resetPreferences(){
		if(preferences != null) {
			preferences.clear();

			// Ensure that the default primitive types are loaded again.
			if (araPrimitiveTypesCreator != null) {
				araPrimitiveTypesCreator.explicitlyLoadPrimitiveTypes();
			}
		}
	}

	public static Preferences getInstance() {
		if (instance == null) {
			instance = new Preferences();
		}
		return instance;
	}

	private void clidefPreferences(){
		if (!preferences.containsKey(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH)) {
			preferences.put(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, PreferencesConstants.DEFAULT_OUTPUT);
		}
		if (!preferences.containsKey(PreferencesConstants.P_LICENSE)) {
			preferences.put(PreferencesConstants.P_LICENSE, PreferencesConstants.DEFAULT_LICENSE);
		}
		if (!preferences.containsKey(PreferencesConstants.P_LOGOUTPUT)) {
			preferences.put(PreferencesConstants.P_LOGOUTPUT, "true");
		}
	}

	public String getPreference(String preferencename, String defaultValue) throws UnknownPreferenceException {
		if (preferences.containsKey(preferencename)) {
			return preferences.get(preferencename);
		}
		throw new UnknownPreferenceException("Unknown preference " + preferencename);
	}

	public boolean hasPreference(String preferenceName) {
		return preferences.containsKey(preferenceName);
	}

	public void setPreference(String name, String value) {
		if (preferences != null) {
			preferences.put(name, value);
			updateAfterPrefChange(Lists.newArrayList(name));
		}
	}

	public void setPreferences(Map<String, String> values) {
		if (preferences != null) {
			for(String name : values.keySet()) {
				preferences.put(name, values.get(name));
			}
			updateAfterPrefChange(values.keySet());
		}
	}
	
	private void updateAfterPrefChange(Collection<String> touchedNames) {
		// Ensure that other primitive types are loaded when requested by changed preferences.
		if (araPrimitiveTypesCreator != null) {
			if (
				touchedNames.contains(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_PATH) ||
				touchedNames.contains(PreferencesConstants.P_CUSTOM_ARA_STD_TYPES_USED)
			) {
				araPrimitiveTypesCreator.explicitlyLoadPrimitiveTypes();
			}
		}
	}


	public String getModelPath(FModel model) {
		String ret = model.eResource().getURI().toString();
		return ret;
	}

}
