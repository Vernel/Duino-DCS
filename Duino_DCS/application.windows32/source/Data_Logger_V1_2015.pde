
//
// Software: Arduino Data Logger V2.2015
// Programmer: Vernel Young
// Date of last edit: 3/26/2015
// Released to the public domain
//

/*
Todo:
 1 - Implement time period control
 2 - Improve Zooming
 3 - Improve graph axis auto calculation
 4 - Implement Multiple graphs
 */

////////////  External Libraries  /////////////////////////////////////
import grafica.*;
import g4p_controls.*;
import org.qscript.eventsonfire.*;
import org.qscript.events.*;
import org.qscript.editor.*;
import org.qscript.*;
import org.qscript.operator.*;
import org.qscript.errors.*;
import java.util.*;
import processing.pdf.*;
import processing.serial.*;
import processing.opengl.*;
import org.gwoptics.graphics.*;
import org.gwoptics.graphics.graph2D.*;
import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.LabelPos;
import org.gwoptics.graphics.graph2D.traces.Line2DTrace;
import org.gwoptics.graphics.graph2D.traces.ILine2DEquation;
import org.gwoptics.graphics.graph2D.traces.RollingLine2DTrace;
import org.gwoptics.graphics.graph2D.backgrounds.*;
import org.philhosoft.p8g.svg.P8gGraphicsSVG;
///////////////////////////////////////////////////////////////////////

//////////////// Gobal Application Properties  ////////////////////////

///  Serial Properties
boolean  line, Complete, Activated, Aborted;
int      j, i;
long     Tsync = 0;
long     _Tsync = 0;
long     timer = 0;
long     timeInt = 0;
int      interval = 0;
int      baudRate = 115200;
//////////////////////////////////////////////////////////////

/// Properties to control general application state
String    fname;
boolean  available = true;
boolean  inputAvailable = true;
boolean  largefile = false;
boolean  clearTextArea = false;
boolean  editEnabled = true;
boolean  menuVisible = true;
boolean  updateDisplay = false;
int      bufferSize;
String   buffer = "", data;
/////////////////////////////////////////////////////////////

/// Graph Properties  //////////////////////////////////////
int      Xmax = 104;
int      Xmin = 0;
int      XAccuracy = 2;
int      Xfirstrow = 1;
int      Xlastrow = 1;
int      XAxisUp = 0;
int      XAxisdwn = 0;
float   spacingX = 0;
double   OldXvalue = 0;
double   NewXvalue = 0;
String   XAxisDataSet = "Time (Sec)";

TableRow lastRow;
TableRow XlastCycle;
TableRow XfirstCycle;
int      spacingY=0;

double   Ymin = 0;
double   Ymax = 0;
float    Ymin1 = 0;
float    Ymax1 = 0;
int      YAccuracy = 2;
int      Yfirstrow = 0;
int      Ylastrow = 1;
double   OldYvalue = 0;
double   NewYvalue = 0;
String   YAxisDataSet1 = "Temperature (deg)"; 
String   YAxisDataSet2, 
YAxisDataSet3, YAxisDataSet4, 
YAxisDataSet5, YAxisDataSet6;

double   Y_Axis_Value = 0;
double   intLoad = 0;

// Graph state control properties
boolean  zoomSliderControl = false;
boolean  graphEnd = false;
boolean  graphdraw = false;
boolean  XUp = false;
boolean  XDwn = false;

// Graph objects
Graph2D                  g, g2D;
GridBackground           gb;
Line2DTrace              trace1 = new Line2DTrace(new eq1());
Line2DTrace              trace2 = new Line2DTrace(new eq2());
Line2DTrace              trace3 = new Line2DTrace(new eq3());
Line2DTrace              trace4 = new Line2DTrace(new eq4());
Line2DTrace              trace5 = new Line2DTrace(new eq5());
Line2DTrace              trace6 = new Line2DTrace(new eq6());

RollingLine2DTrace       r2D1 = new RollingLine2DTrace(new eq2D1(), 500, 0.01f);
RollingLine2DTrace       r2D2 = new RollingLine2DTrace(new eq2D2(), 500, 0.01f);
RollingLine2DTrace       r2D3 = new RollingLine2DTrace(new eq2D3(), 500, 0.01f);
RollingLine2DTrace       r2D4 = new RollingLine2DTrace(new eq2D4(), 500, 0.01f);
RollingLine2DTrace       r2D5 = new RollingLine2DTrace(new eq2D5(), 500, 0.01f);
RollingLine2DTrace       r2D6 = new RollingLine2DTrace(new eq2D6(), 500, 0.01f);
/////////////////////////////////////////////////////////////

// Gobal objects types  /////////////////////////////////////
Serial                   port;
Table                    logtable;
LinkedList<String>       buffer1 = new LinkedList<String>();
LinkedList<String>       error = new LinkedList<String>();
////////////////////////////////////////////////////////////

// OTHERS  /////////////////////////////////////////////////
int     sensorSelected;
boolean Sensor1Txt = false;
boolean Sensor2Txt = false;
boolean Sensor3Txt = false;
boolean Sensor4Txt = false;
boolean Sensor5Txt = false;
boolean Sensor6Txt = false;

boolean Sensor1SValue = false;
boolean Sensor2SValue = false;
boolean Sensor3SValue = false;
boolean Sensor4SValue = false;
boolean Sensor5SValue = false;
boolean Sensor6SValue = false;

/// Grafica ////////////////////////////////////////////////
float[][] dataPlotArray;
int nPoints = 21;

GWindow[] window;

GPlot plot, plot1, plot2, plot3, plot4, plot5, plot6;

GPointsArray points, points1, points2, points3, points4, points5, points6;

GraficaPlot gPlot    = new GraficaPlot();

////////////////////////////////////////////////////////////

///////////// MAIN APPLICATION CONTROLL CODE  /////////////

// Setup program before running main code
public void setup() {
  try {

    size(780, 700);
    frameRate(240);

    // init gui
    createGUI();
    //controlPanel.setVisible(false);
    sensorMaxSelector();

    // setup serial connection
    thread("initSerial");

    //init variables
    Complete = false;
    Activated = false;

    //set various properties
    //controlPanel.setOnTop(false);
    controlPanel.setResizable(false);

    zoomTool.setVisible(false);

    logtable = loadTable("Test1.csv", "header");  //loads sample graph data
    labelDate.setText("Date: "+str(month())+"-"+str(day())+"-"+str(year()));
    bttnUpdate.setVisible(false);
    interval = int(dataCaptureList.getSelectedText());

    //setup graph
    graphSetup();
    selectDataSet();
  } 
  catch(RuntimeException e) {
    println("Program Setup Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Program Setup Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


// Main Control Loop
public void draw() {
  try {
    //frame.setResizable(true);
    background(255);

    displayGraph();

    // controls the rate at which the log display window is refreshed
    if (buffer1.isEmpty()&& Activated)
    {
      j++;
    }

    if (!updateDisplay) {
      thread("updatedisplay");
    }
    thread("timerdisplay");

    if (!line) { //If serial connection is broken try to reconnect
      initSerial();
    }
  }
  catch(RuntimeException e) {
    println("Method -> draw() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> draw() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}
//End of Main loop


// Method -> to run the auto save timer as a thread
public void autoSaveTimer() {
  timerAutosave.start();
}// End of Function


// Method -> run as a timer to update the displaying of logged data during live capture
public void timerdisplay() {
  try {

    if (buffer1.isEmpty() && Activated && (j >= 100)) {
      j =0;
      displayRecord();
    }
  }
  catch(RuntimeException e) {
    println("Method -> timerdisplay() Error:"+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> timerdisplay() Error "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


//  Method -> run as a timer to auto update capture data in the table object
public void TSync() {
  try {
    if (Activated && (Tsync - timeInt) >= (interval))
    {
      timeInt = Tsync;
      timer = Tsync;


      labelRate.setText(str(Tsync));
      thread("updateLog");
      thread("updateGraph");
      thread("timerdisplay");

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
  }
  catch(RuntimeException e) {
    println("Method -> TSync() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> TSync() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


// Method -> allows g.generateTrace() to run as a thread during live data capture
public void updateGraph() {
  try {
    int t = 0;

    if (Activated && !Complete && available ) {
      refreshPoints();
    }
  }
  catch(RuntimeException e) {
    println("Method -> updateGraph() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> updateGraph() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


// Method -> to update the displaying of the live capture date to the screen
public void updatedisplay() {

  updateDisplay = !updateDisplay;
  try {

    while (available && !buffer1.isEmpty ()) {//Display loop
      if (clearTextArea) {
        textLog.setText("");
        clearTextArea = false;
      }

      if (!error.isEmpty() && available)
        errorLog.appendText(error.removeFirst());

      if (available && !buffer1.isEmpty() && !zoomSliderControl) {
        available = false;
        textLog.appendText(buffer1.removeFirst());
        bufferSize = buffer1.size();
        labelInfo.setText("Total Records in File: "+logtable.getRowCount());
        available = true;
      }

      if (!Activated && !editEnabled) {
        i ++;
        delay(250);
        updateLog();
        if (i >= 4) {
          Activated = false;
          i = 0;
          G4P.showMessage(this, "Test is Complete", "Info", G4P.INFO);
          buffer1.clear();
          updateLog();
          timerdisplay();
          timerLog.stop();
          timerAutosave.stop();
          g.generateTrace(g.addTrace(trace1));

          if (!editEnabled) {
            txtfldSensor1.setTextEditEnabled(true);
            txtfldSensor2.setTextEditEnabled(true);
            txtfldSensor3.setTextEditEnabled(true);
            txtfldSensor4.setTextEditEnabled(true);
            txtfldSensor5.setTextEditEnabled(true);
            txtfldSensor6.setTextEditEnabled(true);

            editEnabled = true;
          }
        }
      }
      delay(200);
    }//EndWhile
    updateDisplay = !updateDisplay;
  }
  catch(RuntimeException e) {
    println("Method -> updatedisplay() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> updatedisplay() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


public void refreshPoints() {

  if (checkbox2.isSelected()) {
    YAxisDataSet1 = trim(txtfldSensor1.getText());
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot1 = new GPlot(this), 1);  
      gPlot.updatePoints(plot1, points1 = new GPointsArray(), 0, 1, XAxisDataSet, YAxisDataSet1);
    }
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace1));
  }
  if (checkbox3.isSelected()) {
    YAxisDataSet2 = trim(txtfldSensor2.getText()); 
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace2));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot1 = new GPlot(this), 2);
      gPlot.setup(plot2 = new GPlot(this), 3);
      gPlot.updatePoints(plot1, points1 = new GPointsArray(), 0, 1, XAxisDataSet, YAxisDataSet1);    
      gPlot.updatePoints(plot2, points2 = new GPointsArray(), 0, 2, XAxisDataSet, YAxisDataSet2);
    }
  } 
  if (checkbox4.isSelected()) {
    YAxisDataSet3 = trim(txtfldSensor3.getText()); 
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace3));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot1 = new GPlot(this), 2);
      gPlot.setup(plot2 = new GPlot(this), 3);
      gPlot.setup(plot3 = new GPlot(this), 4);
      gPlot.updatePoints(plot1, points1 = new GPointsArray(), 0, 1, XAxisDataSet, YAxisDataSet1);    
      gPlot.updatePoints(plot2, points2 = new GPointsArray(), 0, 2, XAxisDataSet, YAxisDataSet2);
      gPlot.updatePoints(plot3, points3 = new GPointsArray(), 0, 3, XAxisDataSet, YAxisDataSet3);
    }
  }
  if (checkbox5.isSelected()) {
    YAxisDataSet4 = trim(txtfldSensor4.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace4));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot1 = new GPlot(this), 2);
      gPlot.setup(plot2 = new GPlot(this), 3);
      gPlot.setup(plot3 = new GPlot(this), 4);
      gPlot.setup(plot4 = new GPlot(this), 5);

      gPlot.updatePoints(plot1, points1 = new GPointsArray(), 0, 1, XAxisDataSet, YAxisDataSet1);    
      gPlot.updatePoints(plot2, points2 = new GPointsArray(), 0, 2, XAxisDataSet, YAxisDataSet2);
      gPlot.updatePoints(plot3, points3 = new GPointsArray(), 0, 3, XAxisDataSet, YAxisDataSet3);
      gPlot.updatePoints(plot4, points4 = new GPointsArray(), 0, 4, XAxisDataSet, YAxisDataSet4);
    }
  }
  if (checkbox6.isSelected()) {
    YAxisDataSet5 = trim(txtfldSensor5.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace5));
  }
  if (checkbox7.isSelected()) {
    YAxisDataSet6 = trim(txtfldSensor6.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace6));
  }

  if (plotType.getSelectedText().equals("Moving 2D")) {
    switch(sensorSelected) {
    case 2:
      checkbox2.setSelected(true);
      checkbox3.setSelected(true);
      break;
    }
  }
}

public void displayGraph() {
  // Check to show graph
  if (graphdraw) {
    if (plotType.getSelectedText().equals("Single 2D"))
      g.draw();
    if (plotType.getSelectedText().equals("Moving 2D"))
      g2D.draw();
    if (plotType.getSelectedText().equals("Multi 2D")) {
      if (checkbox2.isSelected()) {
        gPlot.draw(plot1, points1);
      }
      if (checkbox3.isSelected()) {
        gPlot.draw(plot2, points2);
      }
      if (checkbox4.isSelected()) {
        gPlot.draw(plot3, points3);
      }
      if (checkbox5.isSelected()) {
        gPlot.draw(plot4, points4);
      }
      if (checkbox6.isSelected()) {
        gPlot.draw(plot5, points5);
      }
      if (checkbox7.isSelected()) {
        gPlot.draw(plot6, points6);
      }
    }
    panel5.setVisible(true);
    zoomTool.setVisible(false);
  } else {
    panel1.setVisible(true);
    panel2.setVisible(true);
    panel3.setVisible(true);
    panel5.setVisible(false);
    zoomTool.setVisible(false);
  }
}

public void delay(int delay)
{
  int time = millis();
  while (millis () - time <= delay);
}// End of Function

