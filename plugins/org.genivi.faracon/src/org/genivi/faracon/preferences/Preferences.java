package org.genivi.faracon.preferences;

import java.util.HashMap;
import java.util.Map;
import java.io.File;

import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.OutputConfiguration;
import org.franca.core.franca.FModel;
import org.genivi.faracon.preferences.PreferencesConstants;

public class Preferences {

	   private static Preferences instance = null;
	    private Map<String, String> preferences = null;

	    public Map<String, String> getPreferences() {
			return preferences;
		}

		private Preferences() {
	        preferences = new HashMap<String, String>();
	        clidefPreferences();
	    }

	    public void resetPreferences(){
	        preferences.clear();
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
	        if (!preferences.containsKey(PreferencesConstants.P_GENERATE_COMMON_DBUS)) {
	            preferences.put(PreferencesConstants.P_GENERATE_COMMON_DBUS, "true");
	        }
	        if (!preferences.containsKey(PreferencesConstants.P_GENERATE_STUB_DBUS)) {
	            preferences.put(PreferencesConstants.P_GENERATE_STUB_DBUS, "true");
	        }
	        if (!preferences.containsKey(PreferencesConstants.P_GENERATE_PROXY_DBUS)) {
	            preferences.put(PreferencesConstants.P_GENERATE_PROXY_DBUS, "true");
	        }
	        if (!preferences.containsKey(PreferencesConstants.P_LOGOUTPUT)) {
	            preferences.put(PreferencesConstants.P_LOGOUTPUT, "true");
	        }	        
	    }

	    public String getPreference(String preferencename, String defaultValue) {
	    	
	    	if (preferences.containsKey(preferencename)) {
	    		return preferences.get(preferencename);
	    	}
	    	System.err.println("Unknown preference " + preferencename);
	        return "";
	    }

	    public void setPreference(String name, String value) {
	        if(preferences != null) {
	        	preferences.put(name, value);
	        }
	    }

	    public String getModelPath(FModel model) {
	        String ret = model.eResource().getURI().toString();
	        return ret;
	    }
	    
}
