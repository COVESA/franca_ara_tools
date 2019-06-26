package org.genivi.faracon.cli;

import org.eclipse.core.runtime.Plugin;
import org.osgi.framework.BundleContext;

/**
 * The activator class controls the plug-in life cycle
 */
public class Activator extends Plugin
{
    // The plug-in ID
    public static final String PLUGIN_ID = "org.genivi.faracon.cli"; //$NON-NLS-1$

    // The shared instance
    private static Activator   plugin;

    /**
     * The constructor
     */
    public Activator()
    {
        System.out.println("org.genivi.faracon.cli.Activator()");
        System.err.println("org.genivi.faracon.cli.Activator() err");
    }

    /**
     * Returns the shared instance
     *
     * @return the shared instance
     */
    public static Activator getDefault()
    {
        return plugin;
    }

    /*
     * (non-Javadoc)
     *
     * @see org.osgi.framework.BundleActivator#start(org.osgi.framework.BundleContext)
     */
    public void start(BundleContext bundleContext) throws Exception
    {
        System.out.println("org.genivi.faracon.cli.Activator.start()");
        System.err.println("org.genivi.faracon.cli.Activator.start() err");
        
        super.start(bundleContext);
        plugin = this;
    }

    /*
     * (non-Javadoc)
     *
     * @see org.osgi.framework.BundleActivator#stop(org.osgi.framework.BundleContext)
     */
    public void stop(BundleContext bundleContext) throws Exception
    {
        plugin = null;
        super.stop(bundleContext);
    }
}
