package org.genivi.faracon.preferences;

public interface PreferencesConstants
{
    public static final String SCOPE                 	= "org.genivi.faracon.ui";
    public static final String PROJECT_PAGEID        	= "org.genivi.faracon.ui.preferences.CommonAPIDBusPreferencePage";


    // preference keys
    public static final String P_LICENSE          		   = "licenseHeader";
    public static final String P_OUTPUT_DIRECTORY_PATH	   = "outputDirectoryPath";
	public static final String P_LOGOUTPUT        		   = "logOutput";
	public static final String P_WARNINGS_AS_ERRORS 	   = "warningsAsErrors";
	public static final String P_CONTINUE_ON_ERRORS 	   = "continueOnErrors";
	public static final String P_ENUMPREFIX       		   = "enumprefix";
	public static final String P_USEPROJECTSETTINGS 	   = "useProjectSettings";
    public static final String P_ENABLE_CORE_VALIDATOR 	   = "enableCoreValidator";
    public static final String P_ARA_CUSTOM_STD_TYPES_PATH = "araStdTypesPath";
    public static final String P_USE_CUSTOM_ARA_STD_TYPES  = "useStdAraTypes"; 

	// preference values
    public static final String DEFAULT_OUTPUT     = "";
	public static final String LOGLEVEL_QUIET     = "quiet";
	public static final String LOGLEVEL_VERBOSE   = "verbose";
    public static final String DEFAULT_LICENSE    = "This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.\n"
                                                   + "If a copy of the MPL was not distributed with this file, You can obtain one at\n"
                                                   + "http://mozilla.org/MPL/2.0/.";
	public static final String DEFAULT_SKELETONPOSTFIX = "Default";
	public static final String NO_CODE            = "";


	// preference keys
	public static final String P_USEPROJECTSETTINGS_DBUS= P_USEPROJECTSETTINGS;
	public static final String P_ENABLE_DBUS_VALIDATOR  = "enableDBusValidator";
}
