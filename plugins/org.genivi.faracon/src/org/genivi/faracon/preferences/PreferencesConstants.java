package org.genivi.faracon.preferences;

public interface PreferencesConstants
{
    public static final String SCOPE                 	= "org.genivi.faracon.ui";
    public static final String PROJECT_PAGEID        	= "org.genivi.faracon.ui.preferences.CommonAPIDBusPreferencePage";


    // preference keys
    public static final String P_LICENSE          		= "licenseHeader";
    public static final String P_OUTPUT_PROXIES   		= "outputDirProxies";
    public static final String P_OUTPUT_STUBS     		= "outputDirStubs";
	public static final String P_OUTPUT_COMMON    		= "outputDirCommon";
	public static final String P_OUTPUT_SKELETON  		= "outputDirSkeleton";
	public static final String P_OUTPUT_DEFAULT   		= "outputDirDefault";
	public static final String P_OUTPUT_SUBDIRS   		= "outputSubdirs";
	public static final String P_GENERATE_COMMON  		= "generatecommon";
    public static final String P_GENERATE_PROXY    		= "generateproxy";
    public static final String P_GENERATE_STUB     		= "generatestub";
    public static final String P_GENERATE_SKELETON 		= "generateskeleton";
	public static final String P_LOGOUTPUT        		= "logoutput";
	public static final String P_ENUMPREFIX       		= "enumprefix";
	public static final String P_SKELETONPOSTFIX  		= "skeletonpostfix";
	public static final String P_USEPROJECTSETTINGS 	= "useProjectSettings";
	public static final String P_GENERATE_CODE    		= "generateCode";
	public static final String P_GENERATE_DEPENDENCIES 	= "generateDependencies";
	public static final String P_GENERATE_SYNC_CALLS 	= "generateSyncCalls";
    public static final String P_ENABLE_CORE_VALIDATOR 	= "enableCoreValidator";

	// preference values
    public static final String DEFAULT_OUTPUT     = "./src-gen/";
	public static final String LOGLEVEL_QUIET     = "quiet";
	public static final String LOGLEVEL_VERBOSE   = "verbose";
    public static final String DEFAULT_LICENSE    = "This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.\n"
                                                   + "If a copy of the MPL was not distributed with this file, You can obtain one at\n"
                                                   + "http://mozilla.org/MPL/2.0/.";
	public static final String DEFAULT_SKELETONPOSTFIX = "Default";
	public static final String NO_CODE            = "";


	// preference keys
    public static final String P_LICENSE_DBUS        	= P_LICENSE;
    public static final String P_OUTPUT_PROXIES_DBUS 	= P_OUTPUT_PROXIES;
    public static final String P_OUTPUT_STUBS_DBUS   	= P_OUTPUT_STUBS;
	public static final String P_OUTPUT_COMMON_DBUS     = P_OUTPUT_COMMON;
	public static final String P_OUTPUT_DEFAULT_DBUS	= P_OUTPUT_DEFAULT;
	public static final String P_OUTPUT_SUBDIRS_DBUS	= P_OUTPUT_SUBDIRS;
    public static final String P_GENERATE_COMMON_DBUS	= P_GENERATE_COMMON;
    public static final String P_GENERATE_PROXY_DBUS	= P_GENERATE_PROXY;
    public static final String P_GENERATE_STUB_DBUS     = P_GENERATE_STUB;
	public static final String P_LOGOUTPUT_DBUS        	= P_LOGOUTPUT;
	public static final String P_USEPROJECTSETTINGS_DBUS= P_USEPROJECTSETTINGS;
	public static final String P_GENERATE_CODE_DBUS     = P_GENERATE_CODE;
	public static final String P_GENERATE_DEPENDENCIES_DBUS = P_GENERATE_DEPENDENCIES;
	public static final String P_GENERATE_SYNC_CALLS_DBUS = P_GENERATE_SYNC_CALLS;
	public static final String P_ENABLE_DBUS_VALIDATOR  = "enableDBusValidator";
}
