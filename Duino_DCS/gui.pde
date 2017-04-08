/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

public void panel1_Click1(GPanel source, GEvent event) { //_CODE_:panel1:581571:
  println("panel1 - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:panel1:581571:

public void txtfld2Sensor2_change1(GTextField source, GEvent event) { //_CODE_:txtfld2Sensor2:425212:
  println("textfieldRpm - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:txtfld2Sensor2:425212:

public void txtfld2Sensor1_change2(GTextField source, GEvent event) { //_CODE_:txtfld2Sensor1:366685:
  println("textfieldCycles - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:txtfld2Sensor1:366685:

public void textfield1_change3(GTextField source, GEvent event) { //_CODE_:textfieldTimer:548376:
  println("textfieldTimer - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:textfieldTimer:548376:

public void txtfld2Sensor3_change(GTextField source, GEvent event) { //_CODE_:txtfld2Sensor3:212194:
  println("textfield1 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:txtfld2Sensor3:212194:

public void txtfld2Sensor4_change1(GTextField source, GEvent event) { //_CODE_:txtfld2Sensor4:486690:
  println("txtfld2Sensor4 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:txtfld2Sensor4:486690:

public void txtfld2Sensor5_change2(GTextField source, GEvent event) { //_CODE_:txtfld2Sensor5:874777:
  println("txtfld2Sensor5 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:txtfld2Sensor5:874777:

public void txtfld2Sensor6_change2(GTextField source, GEvent event) { //_CODE_:txtfld2Sensor6:217148:
  println("txtfld2Sensor6 - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:txtfld2Sensor6:217148:

public void panel2_Click1(GPanel source, GEvent event) { //_CODE_:panel2:219168:
  println("panel2 - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:panel2:219168:

public void textarea1_change1(GTextArea source, GEvent event) { //_CODE_:textLog:413206:
  println("textLog - GTextArea event occured " + System.currentTimeMillis()%10000000 );
  textLog.forceBufferUpdate();
} //_CODE_:textLog:413206:

public void panel3_Click1(GPanel source, GEvent event) { //_CODE_:Menu:834107:
  println("Menu - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:Menu:834107:

public void bttnOpen_click(GButton source, GEvent event) { //_CODE_:bttnOpen:860705:
  println("button1 - GButton event occured " + System.currentTimeMillis()%10000000 );
  if (!Activated)
    openFile();
} //_CODE_:bttnOpen:860705:

public void bttnSave_click(GButton source, GEvent event) { //_CODE_:bttnSave:885756:
  println("button2 - GButton event occured " + System.currentTimeMillis()%10000000 );
  if (!Activated)
    saveLog();
} //_CODE_:bttnSave:885756:

public void bttnNew_click(GButton source, GEvent event) { //_CODE_:bttnNew:420285:
  println("button3 - GButton event occured " + System.currentTimeMillis()%10000000 );
  if (!Activated)
    newLog();
} //_CODE_:bttnNew:420285:

public void bttnDelete_click1(GButton source, GEvent event) { //_CODE_:bttnDelete:464433:
  println("button4 - GButton event occured " + System.currentTimeMillis()%10000000 );
  if (!Activated)
    deleteLog();
} //_CODE_:bttnDelete:464433:

public void bttnConnect_click(GButton source, GEvent event) { //_CODE_:bttnConnect:821683:
  println("bttnConnect - GButton event occured " + System.currentTimeMillis()%10000000 );
  resetUSB();
} //_CODE_:bttnConnect:821683:

public void bttnShowgraph_click(GButton source, GEvent event) { //_CODE_:bttnShowgraph:339679:
  println("bttnShowgraph - GButton event occured " + System.currentTimeMillis()%10000000 );

  showGraph();
} //_CODE_:bttnShowgraph:339679:

public void bttnExcel_click(GButton source, GEvent event) { //_CODE_:bttnExcel:292525:
  println("bttnExcel - GButton event occured " + System.currentTimeMillis()%10000000 );
  if (!Activated)
    open(fname);
} //_CODE_:bttnExcel:292525:

public void bttnAbout_click(GButton source, GEvent event) { //_CODE_:bttnAbout:555494:
  println("button1 - GButton event occured " + System.currentTimeMillis()%10000000 );

  about();
} //_CODE_:bttnAbout:555494:

public void bttnUpdate_click(GButton source, GEvent event) { //_CODE_:bttnUpdate:436568:
  println("bttnUpdate - GButton event occured " + System.currentTimeMillis()%10000000 );

  updateLog();
} //_CODE_:bttnUpdate:436568:

public void panel4_Click1(GPanel source, GEvent event) { //_CODE_:properties:295555:
  println("panel4 - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:properties:295555:

public void txtfldSValue1_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue1:233262:
  println("textfield1 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue1.getText().compareTo(" ") < 1){
    Sensor1SValue = false;
    fieldEdit = true;
  }else{
    Sensor1SValue = true;
    fieldEdit = false;
  }
  updateLabel();
} //_CODE_:txtfldSValue1:233262:

public void txtfldSValue3_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue3:378274:
  println("textfield2 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue3.getText() .compareTo(" ") < 1 ){
    Sensor3SValue = false;
    fieldEdit = true;
  }else{
    Sensor3SValue = true;
    fieldEdit = false;
  }
  updateLabel();
} //_CODE_:txtfldSValue3:378274:

public void txtfldSValue2_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue2:774609:
  println("textfield3 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue2.getText() .compareTo(" ") < 1 ){
    Sensor2SValue = false;
    fieldEdit = true;
  }else{
    Sensor2SValue = true;
    fieldEdit = false;
  }
  updateLabel();
} //_CODE_:txtfldSValue2:774609:

public void option1_clicked1(GOption source, GEvent event) { //_CODE_:option1:810704:
  println("option1 - GOption event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:option1:810704:

public void option2_clicked1(GOption source, GEvent event) { //_CODE_:option2:693902:
  println("option2 - GOption event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:option2:693902:

public void option3_clicked1(GOption source, GEvent event) { //_CODE_:option3:498561:
  println("option3 - GOption event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:option3:498561:

public void option4_clicked1(GOption source, GEvent event) { //_CODE_:option4:639658:
  println("option4 - GOption event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:option4:639658:

public void option5_clicked1(GOption source, GEvent event) { //_CODE_:option5:368559:
  println("option5 - GOption event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:option5:368559:

public void option6_clicked1(GOption source, GEvent event) { //_CODE_:option6:460484:
  println("option6 - GOption event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:option6:460484:

public void option7_clicked1(GOption source, GEvent event) { //_CODE_:option7:366940:
  println("option7 - GOption event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:option7:366940:

public void dataType1_click1(GDropList source, GEvent event) { //_CODE_:dataType1:295427:
  println("dataType - GDropList event occured " + System.currentTimeMillis()%10000000 );
  if (logtable.getRowCount() >2)
    displayRecord();
} //_CODE_:dataType1:295427:

public void txtfldSensor0_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor0:943591:
  println("textfield1 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  updateLabel();
} //_CODE_:txtfldSensor0:943591:

public void checkbox2_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox2:519786:
  println("checkbox2 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:checkbox2:519786:

public void checkbox3_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox3:959938:
  println("checkbox3 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:checkbox3:959938:

public void checkbox4_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox4:213151:
  println("checkbox4 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:checkbox4:213151:

public void checkbox6_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox6:611576:
  println("checkbox5 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:checkbox6:611576:

public void checkbox7_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox7:638228:
  println("checkbox6 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:checkbox7:638228:

public void checkbox5_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox5:483634:
  println("checkbox7 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
  selectDataSet();
} //_CODE_:checkbox5:483634:

public void txtfldSensor1_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor1:503979:
  println("txtfldSensor1 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor1.getText() .compareTo(" ") < 1 ){
    Sensor1Txt = false;
    fieldEdit = true;
  }else{
    fieldEdit = false;
    Sensor1Txt = true;
  }
} //_CODE_:txtfldSensor1:503979:

public void txtfldSensor2_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor2:799399:
  println("txtfldSensor2 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor2.getText() .compareTo(" ") < 1 ){
    Sensor2Txt = false;
    fieldEdit = true;
  }else{
    fieldEdit = false;
    Sensor2Txt = true;
  }
} //_CODE_:txtfldSensor2:799399:

public void txtfldSensor3_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor3:939079:
  println("txtfldSensor3 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor3.getText() .compareTo(" ") < 1 ){
    Sensor3Txt = false;
    fieldEdit = true;
  }else{
    fieldEdit = false;
    Sensor3Txt = true;
  }
} //_CODE_:txtfldSensor3:939079:

public void txtfldSensor4_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor4:435714:
  println("txtfldSensor4 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor4.getText() .compareTo(" ") < 1 ){
    Sensor4Txt = false;
    fieldEdit = true;
  }else{
    fieldEdit = false;
    Sensor4Txt = true;
  }
} //_CODE_:txtfldSensor4:435714:

public void txtfldSensor5_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor5:283009:
  println("txtfldSensor5 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor5.getText() .compareTo(" ") < 1 ){
    Sensor5Txt = false;
    fieldEdit = true;
  }else{
    fieldEdit = false;
    Sensor5Txt = true;
  }
} //_CODE_:txtfldSensor5:283009:

public void txtfldSensor6_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor6:645507:
  println("txtfldSensor6 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor6.getText() .compareTo(" ") < 1 ){
    Sensor6Txt = false;
    fieldEdit = true;
  }else{
    Sensor6Txt = true;
    fieldEdit = false;
  }
} //_CODE_:txtfldSensor6:645507:

public void txtfldSValue4_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue4:572591:
  println("txtfldSValue4 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue4.getText() .compareTo(" ") < 1 ){
    Sensor4SValue = false;
    fieldEdit = true;
  }else{
    fieldEdit = false;
    Sensor4SValue = true;
  }
  updateLabel();
} //_CODE_:txtfldSValue4:572591:

public void txtfldSValue5_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue5:875329:
  println("txtfldSValue5 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue5.getText() .compareTo(" ") < 1 ){
    Sensor5SValue = false;
    fieldEdit = true;
  }else{
    fieldEdit = false;
    Sensor5SValue = true;
  } 
  updateLabel();
} //_CODE_:txtfldSValue5:875329:

public void txtfldSValue6_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue6:268716:
  println("txtfldSValue6 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue6.getText() .compareTo(" ") < 1 ){
    Sensor6SValue = false;
    fieldEdit = true;
  }else{
    Sensor6SValue = true;
   fieldEdit = false; 
  }
  updateLabel();
} //_CODE_:txtfldSValue6:268716:

public void dataType2_click1(GDropList source, GEvent event) { //_CODE_:dataType2:564542:
  println("dataType2 - GDropList event occured " + System.currentTimeMillis()%10000000 );
  if (logtable.getRowCount() >2)
    displayRecord();
} //_CODE_:dataType2:564542:

public void dataType3_click1(GDropList source, GEvent event) { //_CODE_:dataType3:206029:
  println("dataType3 - GDropList event occured " + System.currentTimeMillis()%10000000 );
  if (logtable.getRowCount() >2)
    displayRecord();
} //_CODE_:dataType3:206029:

public void dataType4_click1(GDropList source, GEvent event) { //_CODE_:dataType4:677697:
  println("dataType4 - GDropList event occured " + System.currentTimeMillis()%10000000 );
  if (logtable.getRowCount() >2)
    displayRecord();
} //_CODE_:dataType4:677697:

public void dataType5_click1(GDropList source, GEvent event) { //_CODE_:dataType5:825657:
  println("dataType5 - GDropList event occured " + System.currentTimeMillis()%10000000 );
  if (logtable.getRowCount() >2)
    displayRecord();
} //_CODE_:dataType5:825657:

public void dataType6_click2(GDropList source, GEvent event) { //_CODE_:dataType6:664981:
  println("dataType6 - GDropList event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:dataType6:664981:

public void panel6_Click1(GPanel source, GEvent event) { //_CODE_:settings:279691:
  println("panel6 - GPanel event occured " + System.currentTimeMillis()%10000000 );

  if (Activated)
    errorLog.setVisible(false);
  else
    errorLog.setVisible(true);
} //_CODE_:settings:279691:

public void dataCaptureList_click(GDropList source, GEvent event) { //_CODE_:dataCaptureList:769263:
  println("dropList1 - GDropList event occured " + System.currentTimeMillis()%10000000 );

  setInterval();
} //_CODE_:dataCaptureList:769263:

public void plotType_click1(GDropList source, GEvent event) { //_CODE_:plotType:978664:
  println("plotType - GDropList event occured " + System.currentTimeMillis()%10000000 );
  graphSelect();
} //_CODE_:plotType:978664:

public void baudRateSelect_click1(GDropList source, GEvent event) { //_CODE_:baudRateSelect:632417:
  println("baudRateSelect - GDropList event occured " + System.currentTimeMillis()%10000000 );
  try {
    baudRate = int(baudRateSelect.getSelectedText());
    initSerial();
  }
  catch(RuntimeException e) {
    println("BaudRateSelect Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
  }
} //_CODE_:baudRateSelect:632417:

public void endTime_click1(GDropList source, GEvent event) { //_CODE_:endTime:772762:
  println("endTime - GDropList event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:endTime:772762:

public void sensorMax_click2(GDropList source, GEvent event) { //_CODE_:sensorMax:297382:
  println("sensorMax - GDropList event occured " + System.currentTimeMillis()%10000000 );
  sensorMaxSelector();
} //_CODE_:sensorMax:297382:

public void serialList_click3(GDropList source, GEvent event) { //_CODE_:serialList:812839:
  println("settingsRestore - GDropList event occured " + System.currentTimeMillis()%10000000 );
  setSerialPort(serialList.getSelectedText());
} //_CODE_:serialList:812839:

public void panel3_Click2(GPanel source, GEvent event) { //_CODE_:panel3:369307:
  println("panel3 - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:panel3:369307:

public void panel5_Click1(GPanel source, GEvent event) { //_CODE_:panel5:586707:
  println("panel5 - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:panel5:586707:

public void buttonShowmain_click(GButton source, GEvent event) { //_CODE_:bttnShowmain:600995:
  println("bttnShowmain - GButton event occured " + System.currentTimeMillis()%10000000 );
  showMain();
} //_CODE_:bttnShowmain:600995:

public void bttnPicture_click(GButton source, GEvent event) { //_CODE_:bttnPicture:473421:
  println("bttnPicture - GButton event occured " + System.currentTimeMillis()%10000000 );
  pictureSave();
} //_CODE_:bttnPicture:473421:

public void buttonPDF_click(GButton source, GEvent event) { //_CODE_:bttnPDF:566960:
  println("bttnPDF - GButton event occured " + System.currentTimeMillis()%10000000 );
  pdfSave();
} //_CODE_:bttnPDF:566960:

public void bttnGraphOpen_click1(GButton source, GEvent event) { //_CODE_:bttnGraphOpen:379243:
  println("bttnGraphOpen - GButton event occured " + System.currentTimeMillis()%10000000 );

  openFile();
  if (!Activated) {
    g.generateTrace(g.addTrace(trace1));
    graphdraw=true;
  }
} //_CODE_:bttnGraphOpen:379243:

public void zoomTool_Click(GPanel source, GEvent event) { //_CODE_:zoomTool:508275:
  println("zoomTool - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:zoomTool:508275:

public void zoomList_click(GDropList source, GEvent event) { //_CODE_:zoomList:844090:
  println("zoomList - GDropList event occured " + System.currentTimeMillis()%10000000 );
  zoomSelector();
} //_CODE_:zoomList:844090:

public void zoom_slider1_change1(GCustomSlider source, GEvent event) { //_CODE_:zoom_slider:430300:
  println("zoom_slider - GCustomSlider event occured " + System.currentTimeMillis()%10000000 );
  XAxisdwn = 0;
  XAxisUp = 0;
  thread("zoom");
} //_CODE_:zoom_slider:430300:

public void bttnDown_click1(GButton source, GEvent event) { //_CODE_:bttnDown:262369:
  println("bttnDown - GButton event occured " + System.currentTimeMillis()%10000000 );

  zoomDwn();
} //_CODE_:bttnDown:262369:

public void bttnUp_click(GButton source, GEvent event) { //_CODE_:bttnUp:402633:
  println("button1 - GButton event occured " + System.currentTimeMillis()%10000000 );

  zoomUp();
} //_CODE_:bttnUp:402633:

public void effectList_click(GDropList source, GEvent event) { //_CODE_:effectList:549633:
  println("effectList - GDropList event occured " + System.currentTimeMillis()%10000000 );
  g.generateTrace(g.addTrace(trace1));
} //_CODE_:effectList:549633:

public void timerAutosave_Action1(GTimer source) { //_CODE_:timerAutosave:872300:
  println("timerAutosave - GTimer event occured " + System.currentTimeMillis()%10000000 );

  try {
    if (Activated) {
      thread("saveLog");
    }
  }
  catch(RuntimeException e) 
  {
    println(e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
  }
} //_CODE_:timerAutosave:872300:

public void timerLog_Action1(GTimer source) { //_CODE_:timerLog:439472:
  println("timerLog - GTimer event occured " + System.currentTimeMillis()%10000000 );

  logTimer();
} //_CODE_:timerLog:439472:

synchronized public void controlPanel_draw1(GWinApplet appc, GWinData data) { //_CODE_:controlPanel:752210:
  appc.background(255);
} //_CODE_:controlPanel:752210:

public void panel4_Click2(GPanel source, GEvent event) { //_CODE_:panel4:615021:
  println("panel4 - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:panel4:615021:

public void panel6_Click2(GPanel source, GEvent event) { //_CODE_:panel6:413922:
  println("panel6 - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:panel6:413922:

public void errorLog_change2(GTextArea source, GEvent event) { //_CODE_:errorLog:436906:
  println("textarea1 - GTextArea event occured " + System.currentTimeMillis()%10000000 );

  if (!error.isEmpty())
    errorLog.appendText(error.removeFirst());
} //_CODE_:errorLog:436906:

public void bttnStartTest_click1(GButton source, GEvent event) { //_CODE_:bttnStartTest:772940:
  println("bttnStartTest - GButton event occured " + System.currentTimeMillis()%10000000 );

  startCapture();
} //_CODE_:bttnStartTest:772940:

public void bttnAbortTest_click1(GButton source, GEvent event) { //_CODE_:bttnAbortTest:289247:
  println("bttnAbortTest - GButton event occured " + System.currentTimeMillis()%10000000 );

  endCapture();
} //_CODE_:bttnAbortTest:289247:

public void bttnReset_click1(GButton source, GEvent event) { //_CODE_:bttnReset:621187:
  println("bttnReset - GButton event occured " + System.currentTimeMillis()%10000000 );

  resetArduino();
} //_CODE_:bttnReset:621187:

public void txtfldSerial_change1(GTextField source, GEvent event) { //_CODE_:txtfldSerial:528742:
  println("txtfldSerial - GTextField event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:txtfldSerial:528742:

public void bttnSend_click1(GButton source, GEvent event) { //_CODE_:bttnSend:316166:
  println("bttnSend - GButton event occured " + System.currentTimeMillis()%10000000 );
  serialSend();
} //_CODE_:bttnSend:316166:

public void serialPanel_Click1(GPanel source, GEvent event) { //_CODE_:serialPanel:938908:
  println("serialPanel - GPanel event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:serialPanel:938908:

public void serialtxt_change2(GTextArea source, GEvent event) { //_CODE_:serialtxt:676475:
  println("serialtxt - GTextArea event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:serialtxt:676475:

public void variableTimer_Action1(GTimer source) { //_CODE_:variableTimer:739500:
  println("variableTimer - GTimer event occured " + System.currentTimeMillis()%10000000 );
  vTimer();
} //_CODE_:variableTimer:739500:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  if(frame != null)
    frame.setTitle("Duino Data Capture Software V0.1 x64 - beta release");
  panel1 = new GPanel(this, 10, 10, 760, 100, "Sensor Stats Panel");
  panel1.setCollapsible(false);
  panel1.setDraggable(false);
  panel1.setText("Sensor Stats Panel");
  panel1.setTextBold();
  panel1.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  panel1.setOpaque(true);
  panel1.addEventHandler(this, "panel1_Click1");
  labelSensor2 = new GLabel(this, 346, 29, 90, 20);
  labelSensor2.setText("-");
  labelSensor2.setTextBold();
  labelSensor2.setOpaque(true);
  txtfld2Sensor2 = new GTextField(this, 437, 29, 90, 20, G4P.SCROLLBARS_NONE);
  txtfld2Sensor2.setText("0");
  txtfld2Sensor2.setDefaultText("0");
  txtfld2Sensor2.setOpaque(true);
  txtfld2Sensor2.addEventHandler(this, "txtfld2Sensor2_change1");
  labelSensor1 = new GLabel(this, 144, 29, 90, 20);
  labelSensor1.setText("-");
  labelSensor1.setTextBold();
  labelSensor1.setOpaque(true);
  txtfld2Sensor1 = new GTextField(this, 234, 29, 90, 20, G4P.SCROLLBARS_NONE);
  txtfld2Sensor1.setText("0");
  txtfld2Sensor1.setDefaultText("0");
  txtfld2Sensor1.setOpaque(true);
  txtfld2Sensor1.addEventHandler(this, "txtfld2Sensor1_change2");
  label4 = new GLabel(this, 10, 44, 41, 20);
  label4.setText("Time:");
  label4.setTextBold();
  label4.setOpaque(false);
  textfieldTimer = new GTextField(this, 53, 44, 60, 20, G4P.SCROLLBARS_NONE);
  textfieldTimer.setDefaultText("00:00:00");
  textfieldTimer.setOpaque(true);
  textfieldTimer.addEventHandler(this, "textfield1_change3");
  label11 = new GLabel(this, 54, 30, 60, 13);
  label11.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label11.setText("hh:mm:ss");
  label11.setOpaque(false);
  labelSensor3 = new GLabel(this, 552, 30, 90, 20);
  labelSensor3.setText("-");
  labelSensor3.setTextBold();
  labelSensor3.setOpaque(true);
  txtfld2Sensor3 = new GTextField(this, 643, 30, 90, 20, G4P.SCROLLBARS_NONE);
  txtfld2Sensor3.setText("0");
  txtfld2Sensor3.setDefaultText("0");
  txtfld2Sensor3.setOpaque(true);
  txtfld2Sensor3.addEventHandler(this, "txtfld2Sensor3_change");
  labelSensor4 = new GLabel(this, 143, 70, 90, 20);
  labelSensor4.setText("-");
  labelSensor4.setTextBold();
  labelSensor4.setOpaque(true);
  txtfld2Sensor4 = new GTextField(this, 234, 70, 90, 20, G4P.SCROLLBARS_NONE);
  txtfld2Sensor4.setText("0");
  txtfld2Sensor4.setDefaultText("0");
  txtfld2Sensor4.setOpaque(true);
  txtfld2Sensor4.addEventHandler(this, "txtfld2Sensor4_change1");
  labelSensor5 = new GLabel(this, 346, 69, 90, 20);
  labelSensor5.setText("-");
  labelSensor5.setTextBold();
  labelSensor5.setOpaque(true);
  txtfld2Sensor5 = new GTextField(this, 437, 69, 90, 20, G4P.SCROLLBARS_NONE);
  txtfld2Sensor5.setText("0");
  txtfld2Sensor5.setDefaultText("0");
  txtfld2Sensor5.setOpaque(true);
  txtfld2Sensor5.addEventHandler(this, "txtfld2Sensor5_change2");
  labelSensor6 = new GLabel(this, 552, 68, 90, 20);
  labelSensor6.setText("-");
  labelSensor6.setTextBold();
  labelSensor6.setOpaque(true);
  txtfld2Sensor6 = new GTextField(this, 643, 68, 90, 20, G4P.SCROLLBARS_NONE);
  txtfld2Sensor6.setText("0");
  txtfld2Sensor6.setDefaultText("0");
  txtfld2Sensor6.setOpaque(true);
  txtfld2Sensor6.addEventHandler(this, "txtfld2Sensor6_change2");
  panel1.addControl(labelSensor2);
  panel1.addControl(txtfld2Sensor2);
  panel1.addControl(labelSensor1);
  panel1.addControl(txtfld2Sensor1);
  panel1.addControl(label4);
  panel1.addControl(textfieldTimer);
  panel1.addControl(label11);
  panel1.addControl(labelSensor3);
  panel1.addControl(txtfld2Sensor3);
  panel1.addControl(labelSensor4);
  panel1.addControl(txtfld2Sensor4);
  panel1.addControl(labelSensor5);
  panel1.addControl(txtfld2Sensor5);
  panel1.addControl(labelSensor6);
  panel1.addControl(txtfld2Sensor6);
  panel2 = new GPanel(this, 10, 113, 760, 515, "Log Panel");
  panel2.setCollapsible(false);
  panel2.setDraggable(false);
  panel2.setText("Log Panel");
  panel2.setTextBold();
  panel2.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  panel2.setOpaque(true);
  panel2.addEventHandler(this, "panel2_Click1");
  textLog = new GTextArea(this, 24, 70, 480, 218, G4P.SCROLLBARS_VERTICAL_ONLY | G4P.SCROLLBARS_AUTOHIDE);
  textLog.setOpaque(true);
  textLog.addEventHandler(this, "textarea1_change1");
  Menu = new GPanel(this, 520, 40, 220, 200, " >| Main Menu  ");
  Menu.setCollapsible(false);
  Menu.setDraggable(false);
  Menu.setText(" >| Main Menu  ");
  Menu.setTextBold();
  Menu.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  Menu.setOpaque(true);
  Menu.addEventHandler(this, "panel3_Click1");
  bttnOpen = new GButton(this, 10, 40, 80, 30);
  bttnOpen.setText("Open");
  bttnOpen.setTextBold();
  bttnOpen.addEventHandler(this, "bttnOpen_click");
  bttnSave = new GButton(this, 130, 40, 80, 30);
  bttnSave.setText("Save");
  bttnSave.setTextBold();
  bttnSave.addEventHandler(this, "bttnSave_click");
  bttnNew = new GButton(this, 10, 80, 80, 30);
  bttnNew.setText("New");
  bttnNew.setTextBold();
  bttnNew.addEventHandler(this, "bttnNew_click");
  bttnDelete = new GButton(this, 130, 80, 80, 30);
  bttnDelete.setText("Delete");
  bttnDelete.setTextBold();
  bttnDelete.addEventHandler(this, "bttnDelete_click1");
  bttnConnect = new GButton(this, 10, 120, 80, 30);
  bttnConnect.setText("Reset USB");
  bttnConnect.setTextBold();
  bttnConnect.addEventHandler(this, "bttnConnect_click");
  bttnShowgraph = new GButton(this, 10, 160, 80, 30);
  bttnShowgraph.setText("Show Graph");
  bttnShowgraph.setTextBold();
  bttnShowgraph.addEventHandler(this, "bttnShowgraph_click");
  bttnExcel = new GButton(this, 130, 120, 80, 30);
  bttnExcel.setText("Open in Excel");
  bttnExcel.setTextBold();
  bttnExcel.addEventHandler(this, "bttnExcel_click");
  bttnAbout = new GButton(this, 130, 160, 80, 30);
  bttnAbout.setText("About");
  bttnAbout.setTextBold();
  bttnAbout.addEventHandler(this, "bttnAbout_click");
  Menu.addControl(bttnOpen);
  Menu.addControl(bttnSave);
  Menu.addControl(bttnNew);
  Menu.addControl(bttnDelete);
  Menu.addControl(bttnConnect);
  Menu.addControl(bttnShowgraph);
  Menu.addControl(bttnExcel);
  Menu.addControl(bttnAbout);
  label5 = new GLabel(this, 56, 25, 62, 45);
  label5.setText("Timer:");
  label5.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  label5.setOpaque(true);
  label8 = new GLabel(this, 366, 25, 62, 45);
  label8.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  label8.setOpaque(true);
  bttnUpdate = new GButton(this, 676, 5, 80, 30);
  bttnUpdate.setText("Update Log");
  bttnUpdate.setTextBold();
  bttnUpdate.addEventHandler(this, "bttnUpdate_click");
  label3 = new GLabel(this, 304, 25, 62, 45);
  label3.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  label3.setOpaque(true);
  label13 = new GLabel(this, 428, 25, 60, 45);
  label13.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  label13.setOpaque(true);
  properties = new GPanel(this, 24, 308, 480, 200, " >| Data Properties");
  properties.setCollapsible(false);
  properties.setDraggable(false);
  properties.setText(" >| Data Properties");
  properties.setTextBold();
  properties.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  properties.setOpaque(true);
  properties.addEventHandler(this, "panel4_Click1");
  txtfldSValue1 = new GTextField(this, 219, 68, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue1.setText("-");
  txtfldSValue1.setLocalColorScheme(GCScheme.RED_SCHEME);
  txtfldSValue1.setOpaque(true);
  txtfldSValue1.addEventHandler(this, "txtfldSValue1_change");
  txtfldSValue3 = new GTextField(this, 219, 108, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue3.setText("-");
  txtfldSValue3.setLocalColorScheme(GCScheme.YELLOW_SCHEME);
  txtfldSValue3.setOpaque(true);
  txtfldSValue3.addEventHandler(this, "txtfldSValue3_change");
  txtfldSValue2 = new GTextField(this, 219, 88, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue2.setText("-");
  txtfldSValue2.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  txtfldSValue2.setOpaque(true);
  txtfldSValue2.addEventHandler(this, "txtfldSValue2_change");
  label12 = new GLabel(this, 10, 26, 200, 20);
  label12.setText("Data Series");
  label12.setTextBold();
  label12.setOpaque(false);
  label14 = new GLabel(this, 219, 25, 100, 20);
  label14.setText("Serial Identifer");
  label14.setTextBold();
  label14.setOpaque(false);
  label15 = new GLabel(this, 392, 70, 14, 20);
  label15.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label15.setText(" -");
  label15.setOpaque(false);
  label16 = new GLabel(this, 320, 25, 69, 20);
  label16.setText("Data Type");
  label16.setTextBold();
  label16.setOpaque(false);
  label17 = new GLabel(this, 396, 25, 60, 24);
  label17.setText("Plot Axis     X     Y");
  label17.setTextBold();
  label17.setOpaque(false);
  togGroup1 = new GToggleGroup();
  option1 = new GOption(this, 409, 50, 20, 20);
  option1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  option1.setOpaque(false);
  option1.addEventHandler(this, "option1_clicked1");
  option2 = new GOption(this, 409, 70, 20, 20);
  option2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  option2.setOpaque(false);
  option2.addEventHandler(this, "option2_clicked1");
  option3 = new GOption(this, 409, 90, 20, 20);
  option3.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  option3.setOpaque(false);
  option3.addEventHandler(this, "option3_clicked1");
  option4 = new GOption(this, 409, 110, 20, 20);
  option4.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  option4.setOpaque(false);
  option4.addEventHandler(this, "option4_clicked1");
  option5 = new GOption(this, 409, 130, 20, 20);
  option5.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  option5.setOpaque(false);
  option5.addEventHandler(this, "option5_clicked1");
  option6 = new GOption(this, 409, 150, 20, 20);
  option6.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  option6.setOpaque(false);
  option6.addEventHandler(this, "option6_clicked1");
  option7 = new GOption(this, 409, 170, 20, 20);
  option7.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  option7.setOpaque(false);
  option7.addEventHandler(this, "option7_clicked1");
  togGroup1.addControl(option1);
  option1.setSelected(true);
  properties.addControl(option1);
  togGroup1.addControl(option2);
  properties.addControl(option2);
  togGroup1.addControl(option3);
  properties.addControl(option3);
  togGroup1.addControl(option4);
  properties.addControl(option4);
  togGroup1.addControl(option5);
  properties.addControl(option5);
  togGroup1.addControl(option6);
  properties.addControl(option6);
  togGroup1.addControl(option7);
  properties.addControl(option7);
  dataType1 = new GDropList(this, 324, 69, 60, 66, 3);
  dataType1.setItems(loadStrings("list_295427"), 0);
  dataType1.addEventHandler(this, "dataType1_click1");
  txtfldSensor0 = new GTextField(this, 10, 48, 200, 20, G4P.SCROLLBARS_NONE);
  txtfldSensor0.setText("Time");
  txtfldSensor0.setDefaultText("Time (Sec)");
  txtfldSensor0.setOpaque(true);
  txtfldSensor0.addEventHandler(this, "txtfldSensor0_change");
  checkbox2 = new GCheckbox(this, 431, 71, 30, 20);
  checkbox2.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  checkbox2.setOpaque(false);
  checkbox2.addEventHandler(this, "checkbox2_clicked1");
  checkbox2.setSelected(true);
  checkbox3 = new GCheckbox(this, 431, 92, 30, 20);
  checkbox3.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  checkbox3.setOpaque(false);
  checkbox3.addEventHandler(this, "checkbox3_clicked1");
  checkbox4 = new GCheckbox(this, 431, 111, 30, 20);
  checkbox4.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  checkbox4.setOpaque(false);
  checkbox4.addEventHandler(this, "checkbox4_clicked1");
  checkbox6 = new GCheckbox(this, 431, 149, 30, 20);
  checkbox6.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  checkbox6.setOpaque(false);
  checkbox6.addEventHandler(this, "checkbox6_clicked1");
  checkbox7 = new GCheckbox(this, 431, 170, 30, 20);
  checkbox7.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  checkbox7.setOpaque(false);
  checkbox7.addEventHandler(this, "checkbox7_clicked1");
  checkbox5 = new GCheckbox(this, 431, 130, 30, 20);
  checkbox5.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  checkbox5.setOpaque(false);
  checkbox5.addEventHandler(this, "checkbox5_clicked1");
  txtfldSensor1 = new GTextField(this, 10, 68, 200, 20, G4P.SCROLLBARS_NONE);
  txtfldSensor1.setText("Temperature (deg)");
  txtfldSensor1.setDefaultText("Enter Sensor1 Name");
  txtfldSensor1.setOpaque(true);
  txtfldSensor1.addEventHandler(this, "txtfldSensor1_change");
  txtfldSensor2 = new GTextField(this, 10, 88, 200, 20, G4P.SCROLLBARS_NONE);
  txtfldSensor2.setDefaultText("Enter Sensor2 Name");
  txtfldSensor2.setOpaque(true);
  txtfldSensor2.addEventHandler(this, "txtfldSensor2_change");
  txtfldSensor3 = new GTextField(this, 10, 108, 200, 20, G4P.SCROLLBARS_NONE);
  txtfldSensor3.setDefaultText("Enter Sensor3 Name");
  txtfldSensor3.setOpaque(true);
  txtfldSensor3.addEventHandler(this, "txtfldSensor3_change");
  txtfldSensor4 = new GTextField(this, 10, 128, 200, 20, G4P.SCROLLBARS_NONE);
  txtfldSensor4.setDefaultText("Enter Sensor4 Name");
  txtfldSensor4.setOpaque(true);
  txtfldSensor4.addEventHandler(this, "txtfldSensor4_change");
  txtfldSensor5 = new GTextField(this, 10, 148, 200, 20, G4P.SCROLLBARS_NONE);
  txtfldSensor5.setDefaultText("Enter Sensor5 Name");
  txtfldSensor5.setOpaque(true);
  txtfldSensor5.addEventHandler(this, "txtfldSensor5_change");
  txtfldSensor6 = new GTextField(this, 10, 168, 200, 20, G4P.SCROLLBARS_NONE);
  txtfldSensor6.setDefaultText("Enter Sensor6 Name");
  txtfldSensor6.setOpaque(true);
  txtfldSensor6.addEventHandler(this, "txtfldSensor6_change");
  txtfldSValue4 = new GTextField(this, 219, 128, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue4.setText("-");
  txtfldSValue4.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  txtfldSValue4.setOpaque(true);
  txtfldSValue4.addEventHandler(this, "txtfldSValue4_change");
  txtfldSValue5 = new GTextField(this, 219, 148, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue5.setText("-");
  txtfldSValue5.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  txtfldSValue5.setOpaque(true);
  txtfldSValue5.addEventHandler(this, "txtfldSValue5_change");
  txtfldSValue6 = new GTextField(this, 219, 168, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue6.setText("-");
  txtfldSValue6.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  txtfldSValue6.setOpaque(true);
  txtfldSValue6.addEventHandler(this, "txtfldSValue6_change");
  labelRate = new GLabel(this, 219, 46, 170, 20);
  labelRate.setText("----");
  labelRate.setOpaque(true);
  dataType2 = new GDropList(this, 324, 89, 60, 66, 3);
  dataType2.setItems(loadStrings("list_564542"), 0);
  dataType2.addEventHandler(this, "dataType2_click1");
  dataType3 = new GDropList(this, 324, 109, 60, 66, 3);
  dataType3.setItems(loadStrings("list_206029"), 0);
  dataType3.addEventHandler(this, "dataType3_click1");
  dataType4 = new GDropList(this, 324, 129, 60, 66, 3);
  dataType4.setItems(loadStrings("list_677697"), 0);
  dataType4.addEventHandler(this, "dataType4_click1");
  dataType5 = new GDropList(this, 324, 148, 60, 66, 3);
  dataType5.setItems(loadStrings("list_825657"), 0);
  dataType5.addEventHandler(this, "dataType5_click1");
  dataType6 = new GDropList(this, 324, 168, 60, 66, 3);
  dataType6.setItems(loadStrings("list_664981"), 0);
  dataType6.addEventHandler(this, "dataType6_click2");
  properties.addControl(txtfldSValue1);
  properties.addControl(txtfldSValue3);
  properties.addControl(txtfldSValue2);
  properties.addControl(label12);
  properties.addControl(label14);
  properties.addControl(label15);
  properties.addControl(label16);
  properties.addControl(label17);
  properties.addControl(dataType1);
  properties.addControl(txtfldSensor0);
  properties.addControl(checkbox2);
  properties.addControl(checkbox3);
  properties.addControl(checkbox4);
  properties.addControl(checkbox6);
  properties.addControl(checkbox7);
  properties.addControl(checkbox5);
  properties.addControl(txtfldSensor1);
  properties.addControl(txtfldSensor2);
  properties.addControl(txtfldSensor3);
  properties.addControl(txtfldSensor4);
  properties.addControl(txtfldSensor5);
  properties.addControl(txtfldSensor6);
  properties.addControl(txtfldSValue4);
  properties.addControl(txtfldSValue5);
  properties.addControl(txtfldSValue6);
  properties.addControl(labelRate);
  properties.addControl(dataType2);
  properties.addControl(dataType3);
  properties.addControl(dataType4);
  properties.addControl(dataType5);
  properties.addControl(dataType6);
  settings = new GPanel(this, 520, 255, 220, 202, "  >| Settings  ");
  settings.setCollapsible(false);
  settings.setDraggable(false);
  settings.setText("  >| Settings  ");
  settings.setTextBold();
  settings.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  settings.setOpaque(true);
  settings.addEventHandler(this, "panel6_Click1");
  label20 = new GLabel(this, 16, 30, 110, 35);
  label20.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label20.setText("Select Data Capture Rate (sec):");
  label20.setTextItalic();
  label20.setOpaque(false);
  dataCaptureList = new GDropList(this, 125, 45, 90, 220, 10);
  dataCaptureList.setItems(loadStrings("list_769263"), 4);
  dataCaptureList.addEventHandler(this, "dataCaptureList_click");
  plotType = new GDropList(this, 125, 70, 90, 220, 10);
  plotType.setItems(loadStrings("list_978664"), 0);
  plotType.addEventHandler(this, "plotType_click1");
  label23 = new GLabel(this, 16, 68, 110, 20);
  label23.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label23.setText("Select Graph Type");
  label23.setTextItalic();
  label23.setOpaque(false);
  labelBRate = new GLabel(this, 15, 92, 110, 20);
  labelBRate.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  labelBRate.setText("Select Baud Rate");
  labelBRate.setTextItalic();
  labelBRate.setOpaque(false);
  baudRateSelect = new GDropList(this, 125, 94, 90, 176, 8);
  baudRateSelect.setItems(loadStrings("list_632417"), 8);
  baudRateSelect.addEventHandler(this, "baudRateSelect_click1");
  labelEndTime = new GLabel(this, 16, 174, 110, 20);
  labelEndTime.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  labelEndTime.setText("Select Time Period");
  labelEndTime.setTextItalic();
  labelEndTime.setOpaque(false);
  endTime = new GDropList(this, 125, 174, 90, 154, 7);
  endTime.setItems(loadStrings("list_772762"), 0);
  endTime.addEventHandler(this, "endTime_click1");
  sensorMax = new GDropList(this, 125, 144, 90, 220, 10);
  sensorMax.setItems(loadStrings("list_297382"), 0);
  sensorMax.addEventHandler(this, "sensorMax_click2");
  label6 = new GLabel(this, 15, 142, 110, 20);
  label6.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label6.setText("Total Sensor Input");
  label6.setTextItalic();
  label6.setOpaque(false);
  label9 = new GLabel(this, 15, 118, 110, 20);
  label9.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label9.setText("Set Serial Port");
  label9.setTextItalic();
  label9.setOpaque(false);
  serialList = new GDropList(this, 125, 119, 90, 220, 10);
  serialList.setItems(loadStrings("list_812839"), 0);
  serialList.addEventHandler(this, "serialList_click3");
  settings.addControl(label20);
  settings.addControl(dataCaptureList);
  settings.addControl(plotType);
  settings.addControl(label23);
  settings.addControl(labelBRate);
  settings.addControl(baudRateSelect);
  settings.addControl(labelEndTime);
  settings.addControl(endTime);
  settings.addControl(sensorMax);
  settings.addControl(label6);
  settings.addControl(label9);
  settings.addControl(serialList);
  label10 = new GLabel(this, 118, 25, 62, 45);
  label10.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  label10.setOpaque(true);
  label21 = new GLabel(this, 180, 25, 62, 45);
  label21.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  label21.setOpaque(true);
  label22 = new GLabel(this, 242, 25, 62, 45);
  label22.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  label22.setOpaque(true);
  labelfile = new GLabel(this, 24, 288, 480, 15);
  labelfile.setOpaque(true);
  panel2.addControl(textLog);
  panel2.addControl(Menu);
  panel2.addControl(label5);
  panel2.addControl(label8);
  panel2.addControl(bttnUpdate);
  panel2.addControl(label3);
  panel2.addControl(label13);
  panel2.addControl(properties);
  panel2.addControl(settings);
  panel2.addControl(label10);
  panel2.addControl(label21);
  panel2.addControl(label22);
  panel2.addControl(labelfile);
  panel3 = new GPanel(this, 10, 632, 760, 60, "System Status");
  panel3.setCollapsible(false);
  panel3.setDraggable(false);
  panel3.setText("System Status");
  panel3.setTextBold();
  panel3.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  panel3.setOpaque(true);
  panel3.addEventHandler(this, "panel3_Click2");
  labelStatus = new GLabel(this, 20, 31, 180, 20);
  labelStatus.setText("System Error Restart!!");
  labelStatus.setTextBold();
  labelStatus.setOpaque(true);
  labelDate = new GLabel(this, 624, 31, 120, 20);
  labelDate.setText("Date");
  labelDate.setOpaque(true);
  labelPort = new GLabel(this, 210, 31, 150, 20);
  labelPort.setText("Port");
  labelPort.setOpaque(true);
  labelInfo = new GLabel(this, 375, 31, 240, 20);
  labelInfo.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  labelInfo.setOpaque(true);
  panel3.addControl(labelStatus);
  panel3.addControl(labelDate);
  panel3.addControl(labelPort);
  panel3.addControl(labelInfo);
  panel5 = new GPanel(this, 7, 638, 760, 60, "Graph Menu");
  panel5.setCollapsible(false);
  panel5.setDraggable(false);
  panel5.setText("Graph Menu");
  panel5.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  panel5.setOpaque(false);
  panel5.addEventHandler(this, "panel5_Click1");
  bttnShowmain = new GButton(this, 10, 25, 90, 30);
  bttnShowmain.setText(" <<=| (Back)");
  bttnShowmain.setTextBold();
  bttnShowmain.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  bttnShowmain.addEventHandler(this, "buttonShowmain_click");
  bttnPicture = new GButton(this, 169, 25, 60, 30);
  bttnPicture.setText("Save as Picture");
  bttnPicture.setTextBold();
  bttnPicture.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  bttnPicture.addEventHandler(this, "bttnPicture_click");
  bttnPDF = new GButton(this, 232, 25, 60, 30);
  bttnPDF.setText("Save as PDF");
  bttnPDF.setTextBold();
  bttnPDF.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  bttnPDF.addEventHandler(this, "buttonPDF_click");
  bttnGraphOpen = new GButton(this, 106, 25, 60, 30);
  bttnGraphOpen.setText("Open");
  bttnGraphOpen.setTextBold();
  bttnGraphOpen.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  bttnGraphOpen.addEventHandler(this, "bttnGraphOpen_click1");
  panel5.addControl(bttnShowmain);
  panel5.addControl(bttnPicture);
  panel5.addControl(bttnPDF);
  panel5.addControl(bttnGraphOpen);
  zoomTool = new GPanel(this, 543, 662, 340, 180, "  <<-| Zoom Tool |->>  ");
  zoomTool.setCollapsed(true);
  zoomTool.setText("  <<-| Zoom Tool |->>  ");
  zoomTool.setTextBold();
  zoomTool.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  zoomTool.setOpaque(true);
  zoomTool.addEventHandler(this, "zoomTool_Click");
  zoomList = new GDropList(this, 190, 30, 130, 88, 4);
  zoomList.setItems(loadStrings("list_844090"), 0);
  zoomList.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  zoomList.addEventHandler(this, "zoomList_click");
  label7 = new GLabel(this, 20, 30, 167, 22);
  label7.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label7.setText("Select Area of Graph to Zoom");
  label7.setOpaque(true);
  zoom_slider = new GCustomSlider(this, 55, 102, 234, 60, "grey_blue");
  zoom_slider.setShowValue(true);
  zoom_slider.setLimits(1.0, 1.0, 1.0);
  zoom_slider.setNbrTicks(50);
  zoom_slider.setStickToTicks(true);
  zoom_slider.setShowTicks(true);
  zoom_slider.setNumberFormat(G4P.DECIMAL, 2);
  zoom_slider.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  zoom_slider.setOpaque(true);
  zoom_slider.addEventHandler(this, "zoom_slider1_change1");
  bttnDown = new GButton(this, 24, 102, 30, 60);
  bttnDown.setText("<<=");
  bttnDown.setTextBold();
  bttnDown.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  bttnDown.addEventHandler(this, "bttnDown_click1");
  bttnUp = new GButton(this, 290, 102, 30, 60);
  bttnUp.setText("=>>");
  bttnUp.setTextBold();
  bttnUp.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  bttnUp.addEventHandler(this, "bttnUp_click");
  labelGrapheffects = new GLabel(this, 20, 56, 167, 22);
  labelGrapheffects.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  labelGrapheffects.setText("Select Graph Effect");
  labelGrapheffects.setOpaque(true);
  effectList = new GDropList(this, 190, 57, 130, 44, 2);
  effectList.setItems(loadStrings("list_549633"), 0);
  effectList.addEventHandler(this, "effectList_click");
  zoomTool.addControl(zoomList);
  zoomTool.addControl(label7);
  zoomTool.addControl(zoom_slider);
  zoomTool.addControl(bttnDown);
  zoomTool.addControl(bttnUp);
  zoomTool.addControl(labelGrapheffects);
  zoomTool.addControl(effectList);
  timerAutosave = new GTimer(this, this, "timerAutosave_Action1", 3125);
  timerAutosave.setInitialDelay(1);
  timerLog = new GTimer(this, this, "timerLog_Action1", 2000);
  timerLog.setInitialDelay(1);
  controlPanel = new GWindow(this, "Control Panel", 0, 0, 400, 400, false, JAVA2D);
  controlPanel.addDrawHandler(this, "controlPanel_draw1");
  panel4 = new GPanel(controlPanel.papplet, 9, 8, 390, 390, "");
  panel4.setCollapsible(false);
  panel4.setDraggable(false);
  panel4.setLocalColorScheme(GCScheme.YELLOW_SCHEME);
  panel4.setOpaque(true);
  panel4.addEventHandler(this, "panel4_Click2");
  panel6 = new GPanel(controlPanel.papplet, 0, 363, 390, 207, " >| System Log   [-] |");
  panel6.setCollapsed(true);
  panel6.setDraggable(false);
  panel6.setText(" >| System Log   [-] |");
  panel6.setTextBold();
  panel6.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  panel6.setOpaque(true);
  panel6.addEventHandler(this, "panel6_Click2");
  errorLog = new GTextArea(controlPanel.papplet, 2, 24, 387, 185, G4P.SCROLLBARS_VERTICAL_ONLY | G4P.SCROLLBARS_AUTOHIDE);
  errorLog.setOpaque(true);
  errorLog.addEventHandler(this, "errorLog_change2");
  panel6.addControl(errorLog);
  bttnStartTest = new GButton(controlPanel.papplet, 12, 50, 160, 84);
  bttnStartTest.setText("START CAPTURE");
  bttnStartTest.setTextBold();
  bttnStartTest.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  bttnStartTest.addEventHandler(this, "bttnStartTest_click1");
  bttnAbortTest = new GButton(controlPanel.papplet, 220, 50, 160, 84);
  bttnAbortTest.setText("STOP CAPTURE");
  bttnAbortTest.setTextBold();
  bttnAbortTest.setLocalColorScheme(GCScheme.RED_SCHEME);
  bttnAbortTest.addEventHandler(this, "bttnAbortTest_click1");
  bttnReset = new GButton(controlPanel.papplet, 327, 352, 50, 28);
  bttnReset.setText("RESET");
  bttnReset.setTextBold();
  bttnReset.addEventHandler(this, "bttnReset_click1");
  txtfldSerial = new GTextField(controlPanel.papplet, 16, 221, 265, 30, G4P.SCROLLBARS_NONE);
  txtfldSerial.setDefaultText("Input Serial Command");
  txtfldSerial.setOpaque(true);
  txtfldSerial.addEventHandler(this, "txtfldSerial_change1");
  bttnSend = new GButton(controlPanel.papplet, 286, 221, 80, 30);
  bttnSend.setText("Send");
  bttnSend.setTextBold();
  bttnSend.addEventHandler(this, "bttnSend_click1");
  serialPanel = new GPanel(controlPanel.papplet, 2, 154, 387, 228, ">| Serial Monitor  [-] |");
  serialPanel.setCollapsed(true);
  serialPanel.setDraggable(false);
  serialPanel.setText(">| Serial Monitor  [-] |");
  serialPanel.setTextBold();
  serialPanel.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  serialPanel.setOpaque(true);
  serialPanel.addEventHandler(this, "serialPanel_Click1");
  serialtxt = new GTextArea(controlPanel.papplet, 1, 25, 384, 200, G4P.SCROLLBARS_VERTICAL_ONLY | G4P.SCROLLBARS_AUTOHIDE);
  serialtxt.setOpaque(false);
  serialtxt.addEventHandler(this, "serialtxt_change2");
  serialPanel.addControl(serialtxt);
  panel4.addControl(panel6);
  panel4.addControl(bttnStartTest);
  panel4.addControl(bttnAbortTest);
  panel4.addControl(bttnReset);
  panel4.addControl(txtfldSerial);
  panel4.addControl(bttnSend);
  panel4.addControl(serialPanel);
  variableTimer = new GTimer(this, this, "variableTimer_Action1", 1);
}

// Variable declarations 
// autogenerated do not edit
GPanel panel1; 
GLabel labelSensor2; 
GTextField txtfld2Sensor2; 
GLabel labelSensor1; 
GTextField txtfld2Sensor1; 
GLabel label4; 
GTextField textfieldTimer; 
GLabel label11; 
GLabel labelSensor3; 
GTextField txtfld2Sensor3; 
GLabel labelSensor4; 
GTextField txtfld2Sensor4; 
GLabel labelSensor5; 
GTextField txtfld2Sensor5; 
GLabel labelSensor6; 
GTextField txtfld2Sensor6; 
GPanel panel2; 
GTextArea textLog; 
GPanel Menu; 
GButton bttnOpen; 
GButton bttnSave; 
GButton bttnNew; 
GButton bttnDelete; 
GButton bttnConnect; 
GButton bttnShowgraph; 
GButton bttnExcel; 
GButton bttnAbout; 
GLabel label5; 
GLabel label8; 
GButton bttnUpdate; 
GLabel label3; 
GLabel label13; 
GPanel properties; 
GTextField txtfldSValue1; 
GTextField txtfldSValue3; 
GTextField txtfldSValue2; 
GLabel label12; 
GLabel label14; 
GLabel label15; 
GLabel label16; 
GLabel label17; 
GToggleGroup togGroup1; 
GOption option1; 
GOption option2; 
GOption option3; 
GOption option4; 
GOption option5; 
GOption option6; 
GOption option7; 
GDropList dataType1; 
GTextField txtfldSensor0; 
GCheckbox checkbox2; 
GCheckbox checkbox3; 
GCheckbox checkbox4; 
GCheckbox checkbox6; 
GCheckbox checkbox7; 
GCheckbox checkbox5; 
GTextField txtfldSensor1; 
GTextField txtfldSensor2; 
GTextField txtfldSensor3; 
GTextField txtfldSensor4; 
GTextField txtfldSensor5; 
GTextField txtfldSensor6; 
GTextField txtfldSValue4; 
GTextField txtfldSValue5; 
GTextField txtfldSValue6; 
GLabel labelRate; 
GDropList dataType2; 
GDropList dataType3; 
GDropList dataType4; 
GDropList dataType5; 
GDropList dataType6; 
GPanel settings; 
GLabel label20; 
GDropList dataCaptureList; 
GDropList plotType; 
GLabel label23; 
GLabel labelBRate; 
GDropList baudRateSelect; 
GLabel labelEndTime; 
GDropList endTime; 
GDropList sensorMax; 
GLabel label6; 
GLabel label9; 
GDropList serialList; 
GLabel label10; 
GLabel label21; 
GLabel label22; 
GLabel labelfile; 
GPanel panel3; 
GLabel labelStatus; 
GLabel labelDate; 
GLabel labelPort; 
GLabel labelInfo; 
GPanel panel5; 
GButton bttnShowmain; 
GButton bttnPicture; 
GButton bttnPDF; 
GButton bttnGraphOpen; 
GPanel zoomTool; 
GDropList zoomList; 
GLabel label7; 
GCustomSlider zoom_slider; 
GButton bttnDown; 
GButton bttnUp; 
GLabel labelGrapheffects; 
GDropList effectList; 
GTimer timerAutosave; 
GTimer timerLog; 
GWindow controlPanel;
GPanel panel4; 
GPanel panel6; 
GTextArea errorLog; 
GButton bttnStartTest; 
GButton bttnAbortTest; 
GButton bttnReset; 
GTextField txtfldSerial; 
GButton bttnSend; 
GPanel serialPanel; 
GTextArea serialtxt; 
GTimer variableTimer; 

