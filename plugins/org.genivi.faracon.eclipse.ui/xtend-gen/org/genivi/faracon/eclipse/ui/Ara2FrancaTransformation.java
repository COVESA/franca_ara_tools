package org.genivi.faracon.eclipse.ui;

import java.util.Set;
import org.eclipse.jface.action.IAction;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.genivi.faracon.eclipse.ui.AbstractTransformationAction;

@SuppressWarnings("all")
public class Ara2FrancaTransformation extends AbstractTransformationAction {
  public Ara2FrancaTransformation() {
    super("arxml");
  }
  
  @Override
  public void run(final IAction action) {
    final Set<String> filePaths = this.initConverterAndFindFile();
    this.converter.convertARAFiles(((String[])Conversions.unwrapArray(filePaths, String.class)));
  }
}
