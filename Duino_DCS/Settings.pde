



public void about() {
  G4P.showMessage(this, "This program was created with Processing to enable data \n"+ 
    "capturing and visualization from microcontrollers."+
    "\n \nCode contributation from the following open source\n"+
    "libraries: \n"+
    " - Processing \n"+
    " - Gwoptics processing library \n"+
    " - Grafica processing library \n"+
    " - G4P processing library \n\n"+
    "(C) 2015 Vernel Young", 
  "About", G4P.PLAIN);
}// End of Function


public void resetUSB() {
  if (!Activated) {
    G4P.showMessage(this, "Please unplug USB, press OK then replug your \n"+ 
      "USB cable to RESET Serial Connection", "Information", G4P.INFO);
    port.clear();
    port.stop();
    serialCheck();
    thread("initSerial");
  }
}// End of Function


public void showGraph() {
  try {
    if (logtable.getRowCount() >= 0) {
      panel1.setVisible(false);
      panel2.setVisible(false);
      panel3.setVisible(false);
      panel5.setVisible(true);
      zoomTool.setVisible(true);

      if (!error.isEmpty())
        errorLog.appendText(error.removeFirst());

      selectDataSet();  
      refreshPoints();

      graphdraw = true;

      println("X-Axis: "+XAxisDataSet);
    } else G4P.showMessage(this, "No Data to Display", "Error", G4P.ERROR);
  }
  catch(RuntimeException e) {
    println("Show graph Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Show graph Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function

public void selectDataSet() {
  g.removeTrace(trace1); 
  g.removeTrace(trace2);
  g.removeTrace(trace3); 
  g.removeTrace(trace4);  
  g.removeTrace(trace5);
  g.removeTrace(trace6);

  if (option1.isSelected()) {
    option = 0;
    XAxisDataSet = trim(txtfldSensor0.getText());
  }
  if (option2.isSelected()) {
    option = 1;
    XAxisDataSet = trim(txtfldSensor1.getText());
  }
  if (option3.isSelected()) {
    option = 2;
    XAxisDataSet = trim(txtfldSensor2.getText());
  }
  if (option4.isSelected()) {
    option = 3;
    XAxisDataSet = trim(txtfldSensor3.getText());
  }
  if (option5.isSelected()) {
    option = 4;
    XAxisDataSet = trim(txtfldSensor4.getText());
  }
  if (option6.isSelected()) {
    option = 5;
    XAxisDataSet = trim(txtfldSensor5.getText());
  }
  if (option7.isSelected()) {
    option = 6;
    XAxisDataSet = trim(txtfldSensor6.getText());
  }
}// End of Function


public void showMain() {
  if (Complete) {
    displayRecord();
    updatedisplay();
  }

  if (!error.isEmpty())
    errorLog.appendText(error.removeFirst());

  Ymin = 0;
  Ymax = 0;
  //Ymin1 = 0;
  //Ymax1 = 0;
  g.setYAxisMax(0);
  g.setYAxisMin(0);

  zoomSliderControl = false;
  graphdraw=false;
  zoomList.setSelected(0);
}// End of Function


public void setInterval() {
  if (!Activated) {
    if (dataCaptureList.getSelectedText()=="Variable") {
      timerLog.stop();
      interval = 0;
      Tsync = 1;
      timeInt = 1;
    } else {
      timerLog.setInterval((int(dataCaptureList.getSelectedText())*1000));
      interval = int(dataCaptureList.getSelectedText());
    }
  }
}// End of Function


public void graphSelect() {
  if (!Activated) {
    timerLog.setInterval((int(dataCaptureList.getSelectedText())*1000));

    switch(plotType.getSelectedIndex()) {
    case 0:
      bttnUpdate.setVisible(false);
      bttnShowgraph.setVisible(true);
      break;
    case 1:
      //G4P.showMessage(this, "This feature only works in data capture mode.", "Info", G4P.INFO);
      //bttnShowgraph.setVisible(false);
      //bttnUpdate.setVisible(true);
      break;
    case 2:
      // G4P.showMessage(this, "This feature is not implemented.", "Info", G4P.INFO);
      //bttnShowgraph.setVisible(false);
      // bttnUpdate.setVisible(true);
      break;
    default:
      break;
    }
  }
}// End of Function


public void zoomSelector() {
  XAxisdwn = 0;
  XAxisUp = 0;

  //User selected Beginning of graph as option
  if (zoomList.getSelectedIndex() == 1) {
    //g.generateTrace(g.addTrace(trace1));
    int totalcount = logtable.getRowCount()-1;
    int firstHalf = floor(totalcount/2);
    zoom_slider.setLimits(firstHalf, firstHalf, 2);  //Zoom from center of graph to beginning
    Xfirstrow = 1;

    zoomSliderControl = true;
    graphEnd = false;

    thread("zoom");
    //g.generateTrace(g.addTrace(trace1));
  }

  //User selected End of graph as option
  if (zoomList.getSelectedIndex() == 2)
  {
    //g.generateTrace(g.addTrace(trace1)); 
    int totalcount = logtable.getRowCount()-1;
    int firstHalf = floor(totalcount/2);
    zoom_slider.setLimits(totalcount, totalcount, firstHalf+(firstHalf/5));  //Zoom form end of graph to center

    Xfirstrow = firstHalf;

    zoomSliderControl = true;
    graphEnd = true;
    thread("zoom");
    //g.generateTrace(g.addTrace(trace1));
  }

  //User selected none as option
  if (zoomList.getSelectedIndex() == 0)
  {
    //g.generateTrace(g.addTrace(trace1));
    zoom_slider.setLimits(1, 1, 1);
    zoomSliderControl = false;
    graphEnd = false;
    Xfirstrow = 1;

    //Calculates XAccuracy
    Xlastrow = logtable.getRowCount()-1;
    String num = str(Xlastrow);
    int num1 = num.length();
    XAccuracy = ceil(num1);

    //Calculates X-axis min value and X-axis max value
    TableRow XlastCycle = logtable.findRow(str(Xlastrow), "id");
    TableRow XfirstCycle = logtable.findRow(str(Xfirstrow), "id");
    Xmax = XlastCycle.getInt(YAxisDataSet1);
    Xmin = XfirstCycle.getInt(YAxisDataSet1);

    zoomSliderControl = false;
    g.setXAxisMin(0);
    g.generateTrace(g.addTrace(trace1));
  }
}// End of Function


public void zoomUp() {
  if (!Activated) { 
    if (spacingX < 10)
      spacingX = 10;
    XAxisUp += spacingX; 
    XUp = true;
    thread("zoom");
  }
}// End of Function


public void zoomDwn() {
  if (!Activated) { 
    if (spacingX < 10)
      spacingX = 10;
    XAxisdwn += spacingX;
    XDwn = true;
    thread("zoom");
  }
}// End of Function


public void startCapture() {
  int reply = G4P.selectOption(this, "Do you want to begin Capture?"+
    "\nPress YES to Continue or No to Cancel", "Warning", G4P.WARNING, G4P.YES_NO);
  switch(reply) {

  case G4P.YES:
    Activated = true;

    if (Activated)
    {
      i = 0;
      timer = 0;
      Tsync = 0;
      logtable.clearRows();
      buffer1.clear();
      thread("updateLog");
      timerAutosave.start();

      if (dataCaptureList.getSelectedText().equals("Variable")) {
        Complete = false;
        variableTimer.start();
        interval = 0;
        timeInt = 1;
        Tsync = 2;
      } else {

        timerLog.start();
      }
      timeInt = Tsync;
    }

    break;
  }
}// End of Function


public void endCapture() {
  int reply = G4P.selectOption(this, "Do you want to Stop Capture?"+
    "\nPress YES to Continue or No to Cancel", "Warning", G4P.WARNING, G4P.YES_NO);
  switch(reply) {
  case G4P.YES:
    if (Activated) {
      //port.write('B');
      timerLog.stop();
      timerAutosave.stop();
      variableTimer.stop();
      Activated = false;
      Complete = true;
      timeInt = 0;
      Tsync = 0;

      if (dataCaptureList.getSelectedText().equals("Variable")) {
        open(fname);
      }
    }
    break;
  }
}// End of Function


public void resetArduino() {
  if (!Activated) {
    int reply = G4P.selectOption(this, "Do you want to Rest Unit?"+
      "\nPress YES to Continue or No to Cancel", "Warning", G4P.WARNING, G4P.YES_NO);
    switch(reply) {
    case G4P.YES:

      port.write('R');
      break;
    }
  } else {
    G4P.showMessage(this, "You cannot Reset while test is running.", "Info", G4P.INFO);
  }
}// End of Function


public void updateLabel() {

  switch(sensorSelected) {

  case 1:
    labelSensor1.setText(txtfldSValue1.getText());
    labelSensor2.setText("-");
    labelSensor3.setText("-");
    labelSensor4.setText("-");
    labelSensor5.setText("-");
    labelSensor6.setText("-");

    label10.setText(txtfldSValue1.getText());
    label21.setText(txtfldSValue2.getText());
    label22.setText("");
    label3.setText("");
    label8.setText("");
    label13.setText("");
    break;

  case 2:
    labelSensor1.setText(txtfldSValue1.getText());
    labelSensor2.setText(txtfldSValue2.getText());
    labelSensor3.setText("-");
    labelSensor4.setText("-");
    labelSensor5.setText("-");
    labelSensor6.setText("-");

    label10.setText(txtfldSValue1.getText());
    label21.setText(txtfldSValue2.getText());
    label22.setText("");
    label3.setText("");
    label8.setText("");
    label13.setText("");
    break;

  case 3:
    labelSensor1.setText(txtfldSValue1.getText());
    labelSensor2.setText(txtfldSValue2.getText());
    labelSensor3.setText(txtfldSValue3.getText());
    labelSensor4.setText("-");
    labelSensor5.setText("-");
    labelSensor6.setText("-");

    label10.setText(txtfldSValue1.getText());
    label21.setText(txtfldSValue2.getText());
    label22.setText(txtfldSValue3.getText());
    label3.setText("");
    label8.setText("");
    label13.setText("");
    break;

  case 4:
    labelSensor1.setText(txtfldSValue1.getText());
    labelSensor2.setText(txtfldSValue2.getText());
    labelSensor3.setText(txtfldSValue3.getText());
    labelSensor4.setText(txtfldSValue4.getText());
    labelSensor5.setText("-");
    labelSensor6.setText("-");

    label10.setText(txtfldSValue1.getText());
    label21.setText(txtfldSValue2.getText());
    label22.setText(txtfldSValue3.getText());
    label3.setText(txtfldSValue4.getText());
    label8.setText("");
    label13.setText("");
    break;

  case 5:
    labelSensor1.setText(txtfldSValue1.getText());
    labelSensor2.setText(txtfldSValue2.getText());
    labelSensor3.setText(txtfldSValue3.getText());
    labelSensor4.setText(txtfldSValue4.getText());
    labelSensor5.setText(txtfldSValue5.getText());
    labelSensor6.setText("-");

    label10.setText(txtfldSValue1.getText());
    label21.setText(txtfldSValue2.getText());
    label22.setText(txtfldSValue3.getText());
    label3.setText(txtfldSValue4.getText());
    label8.setText(txtfldSValue5.getText());
    label13.setText("");
    break;

  case 6:
    labelSensor1.setText(txtfldSValue1.getText());
    labelSensor2.setText(txtfldSValue2.getText());
    labelSensor3.setText(txtfldSValue3.getText());
    labelSensor4.setText(txtfldSValue4.getText());
    labelSensor5.setText(txtfldSValue5.getText());
    labelSensor6.setText(txtfldSValue6.getText());

    label10.setText(txtfldSValue1.getText());
    label21.setText(txtfldSValue2.getText());
    label22.setText(txtfldSValue3.getText());
    label3.setText(txtfldSValue4.getText());
    label8.setText(txtfldSValue5.getText());
    label13.setText(txtfldSValue6.getText());
    break;
  }
}// End of Function


public void sensorMaxSelector() {

  sensorSelected = int (sensorMax.getSelectedText ());
  boolean visible2 = false;
  boolean visible3 = false;
  boolean visible4 = false;
  boolean visible5 = false;
  boolean visible6 = false;

  switch(sensorSelected) {

  case 2:
    visible2 = true;
    visible3 = false;
    visible4 = false;
    visible5 = false;
    visible6 = false;
    break;

  case 3:
    visible2 = true;
    visible3 = true;
    visible4 = false;
    visible5 = false;
    visible6 = false;
    break;

  case 4:
    visible2 = true;
    visible3 = true;
    visible4 = true;
    visible5 = false;
    visible6 = false;
    break;

  case 5:
    visible2 = true;
    visible3 = true;
    visible4 = true;
    visible5 = true;
    visible6 = false;
    break;

  case 6:
    visible2 = true;
    visible3 = true;
    visible4 = true;
    visible5 = true;
    visible6 = true;
    break;
  }

  txtfldSensor2.setVisible(visible2); 
  txtfldSensor3.setVisible(visible3); 
  txtfldSensor4.setVisible(visible4); 
  txtfldSensor5.setVisible(visible5); 
  txtfldSensor6.setVisible(visible6);

  txtfldSValue2.setVisible(visible2);
  txtfldSValue3.setVisible(visible3);
  txtfldSValue4.setVisible(visible4);
  txtfldSValue5.setVisible(visible5);
  txtfldSValue6.setVisible(visible6);

  txtfld2Sensor2.setVisible(visible2);
  txtfld2Sensor3.setVisible(visible3);
  txtfld2Sensor4.setVisible(visible4);
  txtfld2Sensor5.setVisible(visible5);
  txtfld2Sensor6.setVisible(visible6);

  dataType2.setVisible(visible2);
  dataType3.setVisible(visible3);
  dataType4.setVisible(visible4);
  dataType5.setVisible(visible5);
  dataType6.setVisible(visible6);

  option3.setVisible(visible2);
  option4.setVisible(visible3);
  option5.setVisible(visible4);
  option6.setVisible(visible5);
  option7.setVisible(visible6);

  checkbox3.setVisible(visible2);
  checkbox4.setVisible(visible3);
  checkbox5.setVisible(visible4);
  checkbox6.setVisible(visible5);
  checkbox7.setVisible(visible6);

  label21.setVisible(visible2);
  label22.setVisible(visible3);
  label3.setVisible(visible4);
  label8.setVisible(visible5);
  label13.setVisible(visible6);

  labelSensor2.setVisible(visible2);
  labelSensor3.setVisible(visible3);
  labelSensor4.setVisible(visible4);
  labelSensor5.setVisible(visible5);
  labelSensor6.setVisible(visible6);
}// End of Function


public void vTimer() {
  try {
    _Tsync ++; 
    timer = _Tsync;
    long _timeInt = _Tsync/1000;

    long elapsedTime = _Tsync/1000;
    long elapsedHours = (elapsedTime / 3600L);
    long elapsedMinutes = ((elapsedTime % 3600L) / 60L);
    long elapsedSeconds = ((elapsedTime % 3600L) % 60L);

    thread("updateLog");

    if (Activated && (_Tsync - _timeInt) >= (2)) {
      //thread("updateGraph");
      timerdisplay();
      thread("saveLog");
      Timer.addLast(str(timer/1000));
      Timer2.addLast(elapsedHours+":"+elapsedMinutes+":"+elapsedSeconds);
      //textfieldTimer.setText(elapsedHours+":"+elapsedMinutes+":"+elapsedSeconds);
    }

    if (editEnabled) {  // Disables the specimen properties fields
      txtfldSensor1.setTextEditEnabled(false);
      txtfldSensor2.setTextEditEnabled(false);
      txtfldSensor3.setTextEditEnabled(false);
      txtfldSensor4.setTextEditEnabled(false);
      txtfldSensor5.setTextEditEnabled(false);
      txtfldSensor6.setTextEditEnabled(false);

      editEnabled = false;
    }
  }
  catch(RuntimeException e) {
    println("Variable Timer Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
  }
}// End of Function

public void logTimer() {
  try {

    Tsync ++;
    thread("TSync");

    long elapsedTime = _Tsync/1000;
    long elapsedHours = (elapsedTime / 3600L);
    long elapsedMinutes = ((elapsedTime % 3600L) / 60L);
    long elapsedSeconds = ((elapsedTime % 3600L) % 60L);
    Timer2.addLast(elapsedHours+":"+elapsedMinutes+":"+elapsedSeconds);
  }
  catch(RuntimeException e) {
    println(e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
  }
}// End of Function

