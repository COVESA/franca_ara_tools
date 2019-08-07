package org.genivi.faracon.eclipse.ui;

import java.util.Set;
import org.eclipse.jface.action.IAction;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.genivi.faracon.eclipse.ui.AbstractTransformationAction;

@SuppressWarnings("all")
public class Franca2AraTransformation extends AbstractTransformationAction {
  public Franca2AraTransformation() {
    super("fidl");
  }
  
  @Override
  public void run(final IAction action) {
    final Set<String> filePaths = this.initConverterAndFindFile();
    this.converter.convertFrancaFiles(((String[])Conversions.unwrapArray(filePaths, String.class)));
  }
}
