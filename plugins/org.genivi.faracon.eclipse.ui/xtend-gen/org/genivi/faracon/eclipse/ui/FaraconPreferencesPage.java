package org.genivi.faracon.eclipse.ui;

import java.io.File;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.BooleanFieldEditor;
import org.eclipse.jface.preference.DirectoryFieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.jface.preference.RadioGroupFieldEditor;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;
import org.eclipse.ui.preferences.ScopedPreferenceStore;
import org.genivi.faracon.preferences.PreferencesConstants;

@SuppressWarnings("all")
public class FaraconPreferencesPage extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {
  private static final String PREFERENCES_ID = "org.genivi.faracon.eclipse.ui.faraconpreferencespage.id";
  
  private IProject project;
  
  public FaraconPreferencesPage() {
    super(FieldEditorPreferencePage.GRID);
  }
  
  @Override
  public void init(final IWorkbench workbench) {
    ScopedPreferenceStore _scopedPreferenceStore = new ScopedPreferenceStore(InstanceScope.INSTANCE, FaraconPreferencesPage.PREFERENCES_ID);
    this.setPreferenceStore(_scopedPreferenceStore);
  }
  
  @Override
  protected void createFieldEditors() {
    Composite _fieldEditorParent = this.getFieldEditorParent();
    final DirectoryFieldEditor outDir = new DirectoryFieldEditor(PreferencesConstants.P_OUTPUT_DIRECTORY_PATH, "Transformation Output Folder", _fieldEditorParent);
    IPath _location = null;
    if (this.project!=null) {
      _location=this.project.getLocation();
    }
    File _file = null;
    if (_location!=null) {
      _file=_location.toFile();
    }
    outDir.setFilterPath(_file);
    this.addField(outDir);
    Composite _fieldEditorParent_1 = this.getFieldEditorParent();
    BooleanFieldEditor _booleanFieldEditor = new BooleanFieldEditor(PreferencesConstants.P_CONTINUE_ON_ERRORS, "Continue on Error", _fieldEditorParent_1);
    this.addField(_booleanFieldEditor);
    Composite _fieldEditorParent_2 = this.getFieldEditorParent();
    BooleanFieldEditor _booleanFieldEditor_1 = new BooleanFieldEditor(PreferencesConstants.P_WARNINGS_AS_ERRORS, "Warnings as Errors", _fieldEditorParent_2);
    this.addField(_booleanFieldEditor_1);
    final String[][] possibleLogLevels = { new String[] { "Verbose", PreferencesConstants.LOGLEVEL_VERBOSE }, new String[] { "Quiet", PreferencesConstants.LOGLEVEL_QUIET } };
    final boolean useGroup = true;
    Composite _fieldEditorParent_3 = this.getFieldEditorParent();
    final RadioGroupFieldEditor logLevelRadioGroup = new RadioGroupFieldEditor(PreferencesConstants.P_LOGOUTPUT, "Logger setting", 1, possibleLogLevels, _fieldEditorParent_3, useGroup);
    this.addField(logLevelRadioGroup);
  }
  
  public static IEclipsePreferences getInstancePreferences() {
    return InstanceScope.INSTANCE.getNode(FaraconPreferencesPage.PREFERENCES_ID);
  }
}
