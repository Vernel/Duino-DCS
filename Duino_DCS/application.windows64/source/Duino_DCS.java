import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Duino_DCS extends PApplet {


//
// Software: Duino Data Capture Software
// Programmer: Vernel Young
// Date of last edit: 5/24/2015
// Released to the public domain
//

String version = "V0.1.3";

/*
Todo:
 1 - Implement time period control
 2 - Improve Zooming
 3 - Improve graph axis auto calculation
 4 - Implement Multiple graphs
 */

////////////  External Libraries  /////////////////////////////////////





















///////////////////////////////////////////////////////////////////////

//////////////// Gobal Application Properties  ////////////////////////

///  Serial Properties
boolean  line, Complete, Activated, Aborted;
long     Tsync = 0, _Tsync = 0, timer = 0, timeInt = 0;
int      interval = 0, baudRate = 115200;
//////////////////////////////////////////////////////////////

/// Properties to control general application state
String   fname, buffer = "", data;
boolean  available = true, inputAvailable = true, largefile = false;
boolean  clearTextArea = false, editEnabled = true, menuVisible = true;
boolean  updateDisplay = false, fieldEdit = false;
int      bufferSize, j, i;  
/////////////////////////////////////////////////////////////

/// Graph Properties  //////////////////////////////////////
int      Xmax = 104, Xmin = 0, XAccuracy = 2, Xfirstrow = 1, Xlastrow = 1;
int      XAxisUp = 0, XAxisdwn = 0;
float    spacingX = 0;
double   OldXvalue = 0, NewXvalue = 0;
String   XAxisDataSet = ""; //"Time (Sec)";

TableRow lastRow, XlastCycle, XfirstCycle;
int      spacingY=0, YAccuracy = 2, Yfirstrow = 0, Ylastrow = 1;
float    Ymin1 = 0, Ymax1 = 0;
double   Ymin = 0, Ymax = 0, OldYvalue = 0, NewYvalue = 0;
double   Y_Axis_Value = 0, intLoad = 0;
String   YAxisDataSet1 = ""; //"Temperature (deg)"; 
String   YAxisDataSet2, YAxisDataSet3, YAxisDataSet4, 
YAxisDataSet5, YAxisDataSet6;

byte     option = 0;

// Graph state control properties
boolean  zoomSliderControl = false, graphEnd = false, graphdraw = false;
boolean  XUp = false, XDwn = false;

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

//Buffers for sensor data from the serial port
LinkedList<String>       sensor1 = new LinkedList<String>();
LinkedList<String>       sensor2 = new LinkedList<String>();
LinkedList<String>       sensor3 = new LinkedList<String>();
LinkedList<String>       sensor4 = new LinkedList<String>();
LinkedList<String>       sensor5 = new LinkedList<String>();
LinkedList<String>       sensor6 = new LinkedList<String>();

//Buffers for timer data
LinkedList<String>       Timer = new LinkedList<String>();
LinkedList<String>       Timer2 = new LinkedList<String>();

////////////////////////////////////////////////////////////

// OTHERS  /////////////////////////////////////////////////
int     sensorSelected;

//
boolean Sensor1Txt = false, Sensor2Txt = false, Sensor3Txt = false;
boolean Sensor4Txt = false, Sensor5Txt = false, Sensor6Txt = false;

boolean Sensor1SValue = false, Sensor2SValue = false, Sensor3SValue = false;
boolean Sensor4SValue = false, Sensor5SValue = false, Sensor6SValue = false;

/// Grafica ////////////////////////////////////////////////
float[][] dataPlotArray;

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

    // Create the font
    //printArray(PFont.list());
    textFont(createFont("Georgia", 12));
    //textAlign(CENTER, CENTER);

    // init gui
    createGUI();

    //Set Version
    frame.setTitle("Duino Data Capture Software "+version+" - Alpha release");
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
    interval = PApplet.parseInt(dataCaptureList.getSelectedText());

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

    //Refresh Sensor values in the GUI from serial data
    if (line ) if (port.available() <= 0)
    {
      if (sensorSelected >= 1 && !sensor1.isEmpty()) {
        txtfld2Sensor1.setText(sensor1.removeFirst());
      }

      if (sensorSelected >= 2 && !sensor2.isEmpty()) { 
        txtfld2Sensor2.setText(sensor2.removeFirst());
      }
      if (sensorSelected >= 3 && !sensor3.isEmpty()) {
        txtfld2Sensor3.setText(sensor3.removeFirst());
      }
      if (sensorSelected >= 4 && !sensor4.isEmpty()) {
        txtfld2Sensor4.setText(sensor4.removeFirst());
      }
      if (sensorSelected >= 5 && !sensor5.isEmpty()) {
        txtfld2Sensor5.setText(sensor5.removeFirst());
      }
      if (sensorSelected >= 6 && !sensor6.isEmpty()) {
        txtfld2Sensor6.setText(sensor6.removeFirst());
      }
      if (!Timer.isEmpty() && (_Tsync - timeInt) >= (500)) {
        labelRate.setText(Timer.removeFirst());
      }
      if (!Timer2.isEmpty() && (_Tsync - timeInt) >= (500)) {
        textfieldTimer.setText(Timer2.removeFirst());
      }

      //delay(500);
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
      Timer.addLast(str(Tsync));
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


// Method -> to update the displaying of the live capture data to the screen
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
      delay(500); //Run while loop every 500 millisec
    }//EndWhile

    //Display is fully updated from buffer, now enable display update check in main loop
    updateDisplay = !updateDisplay;
  }
  catch(RuntimeException e) {
    println("Method -> updatedisplay() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> updatedisplay() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


public void refreshPoints() {

  if (checkbox2.isSelected() && !checkbox3.isSelected() && !checkbox4.isSelected() && !checkbox5.isSelected() 
    && !checkbox6.isSelected()&& !checkbox7.isSelected()) {
    YAxisDataSet1 = trim(txtfldSensor1.getText());
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot1 = new GPlot(this), 1);  
      gPlot.updatePoints(plot1, points1 = new GPointsArray(), option, 1, XAxisDataSet, YAxisDataSet1);
    }
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace1));
  } else if (checkbox2.isSelected()) {
    YAxisDataSet1 = trim(txtfldSensor1.getText());
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot1 = new GPlot(this), 2);  
      gPlot.updatePoints(plot1, points1 = new GPointsArray(), option, 1, XAxisDataSet, YAxisDataSet1);
    }
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace1));
  }

  if (checkbox3.isSelected() && !checkbox2.isSelected() && !checkbox4.isSelected() && !checkbox5.isSelected() 
    && !checkbox6.isSelected()&& !checkbox7.isSelected()) {
    YAxisDataSet2 = trim(txtfldSensor2.getText()); 
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace2));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot2 = new GPlot(this), 1);
      gPlot.updatePoints(plot2, points2 = new GPointsArray(), option, 2, XAxisDataSet, YAxisDataSet2);
    }
  } else if (checkbox3.isSelected()) {
    YAxisDataSet2 = trim(txtfldSensor2.getText()); 
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace2));
    if (plotType.getSelectedText().equals("Multi 2D")) {      
      gPlot.setup(plot2 = new GPlot(this), 3);       
      gPlot.updatePoints(plot2, points2 = new GPointsArray(), option, 2, XAxisDataSet, YAxisDataSet2);
    }
  }

  if (checkbox4.isSelected() && !checkbox2.isSelected() && !checkbox3.isSelected() && !checkbox5.isSelected() 
    && !checkbox6.isSelected()&& !checkbox7.isSelected()) {
    YAxisDataSet3 = trim(txtfldSensor3.getText()); 
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace3));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot3 = new GPlot(this), 1);
      gPlot.updatePoints(plot3, points3 = new GPointsArray(), option, 3, XAxisDataSet, YAxisDataSet3);
    }
  } else if (checkbox4.isSelected()) {
    YAxisDataSet3 = trim(txtfldSensor3.getText()); 
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace3));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot3 = new GPlot(this), 4);
      gPlot.updatePoints(plot3, points3 = new GPointsArray(), option, 3, XAxisDataSet, YAxisDataSet3);
    }
  }

  if (checkbox5.isSelected() && !checkbox2.isSelected() && !checkbox3.isSelected() && !checkbox4.isSelected() 
    && !checkbox6.isSelected()&& !checkbox7.isSelected()) {
    YAxisDataSet4 = trim(txtfldSensor4.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace4));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot4 = new GPlot(this), 1);
      gPlot.updatePoints(plot4, points4 = new GPointsArray(), option, 4, XAxisDataSet, YAxisDataSet4);
    }
  } else if (checkbox5.isSelected()) {
    YAxisDataSet4 = trim(txtfldSensor4.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace4));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot4 = new GPlot(this), 5);
      gPlot.updatePoints(plot4, points4 = new GPointsArray(), option, 4, XAxisDataSet, YAxisDataSet4);
    }
  }


  if (checkbox6.isSelected( )&& !checkbox2.isSelected() && !checkbox3.isSelected() && !checkbox4.isSelected() 
    && !checkbox5.isSelected()&& !checkbox7.isSelected()) {
    YAxisDataSet5 = trim(txtfldSensor5.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace5));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot5 = new GPlot(this), 1);
      gPlot.updatePoints(plot5, points5 = new GPointsArray(), option, 5, XAxisDataSet, YAxisDataSet5);
    }
  } else if (checkbox6.isSelected()) {
    YAxisDataSet5 = trim(txtfldSensor5.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace5));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot1 = new GPlot(this), 6);
      gPlot.setup(plot2 = new GPlot(this), 7);
      gPlot.setup(plot3 = new GPlot(this), 8);
      gPlot.setup(plot4 = new GPlot(this), 4);
      gPlot.setup(plot5 = new GPlot(this), 5);

      gPlot.updatePoints(plot1, points1 = new GPointsArray(), option, 1, XAxisDataSet, YAxisDataSet1);    
      gPlot.updatePoints(plot2, points2 = new GPointsArray(), option, 2, XAxisDataSet, YAxisDataSet2);
      gPlot.updatePoints(plot3, points3 = new GPointsArray(), option, 3, XAxisDataSet, YAxisDataSet3);
      gPlot.updatePoints(plot4, points4 = new GPointsArray(), option, 4, XAxisDataSet, YAxisDataSet4);
      gPlot.updatePoints(plot5, points5 = new GPointsArray(), option, 5, XAxisDataSet, YAxisDataSet5);
    }
  }

  if (checkbox7.isSelected() && !checkbox2.isSelected() && !checkbox3.isSelected() && !checkbox4.isSelected() 
    && !checkbox5.isSelected()&& !checkbox6.isSelected()) {
    YAxisDataSet6 = trim(txtfldSensor6.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace6));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot6 = new GPlot(this), 1);
      gPlot.updatePoints(plot6, points6 = new GPointsArray(), option, 6, XAxisDataSet, YAxisDataSet6);
    }
  } else if (checkbox7.isSelected()) {
    YAxisDataSet6 = trim(txtfldSensor6.getText());
    if (plotType.getSelectedText().equals("Single 2D"))
      g.generateTrace(g.addTrace(trace6));
    if (plotType.getSelectedText().equals("Multi 2D")) {
      gPlot.setup(plot1 = new GPlot(this), 6);
      gPlot.setup(plot2 = new GPlot(this), 7);
      gPlot.setup(plot3 = new GPlot(this), 8);
      gPlot.setup(plot4 = new GPlot(this), 9);
      gPlot.setup(plot5 = new GPlot(this), 10);
      gPlot.setup(plot6 = new GPlot(this), 11);

      gPlot.updatePoints(plot1, points1 = new GPointsArray(), option, 1, XAxisDataSet, YAxisDataSet1);    
      gPlot.updatePoints(plot2, points2 = new GPointsArray(), option, 2, XAxisDataSet, YAxisDataSet2);
      gPlot.updatePoints(plot3, points3 = new GPointsArray(), option, 3, XAxisDataSet, YAxisDataSet3);
      gPlot.updatePoints(plot4, points4 = new GPointsArray(), option, 4, XAxisDataSet, YAxisDataSet4);
      gPlot.updatePoints(plot5, points5 = new GPointsArray(), option, 5, XAxisDataSet, YAxisDataSet5);
      gPlot.updatePoints(plot6, points6 = new GPointsArray(), option, 6, XAxisDataSet, YAxisDataSet6);
    }
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
  String t = "";

  if (graphdraw) {  // Check to show graph
    if (plotType.getSelectedText().equals("Single 2D")) {
      t = "Powered by gwoptics Processing Library";
      g.draw();
    }
    if (plotType.getSelectedText().equals("Moving 2D")) {
      t = "Powered by gwoptics Processing Library";
      g2D.draw();
    }
    if (plotType.getSelectedText().equals("Multi 2D")) {
      t = "Powered by grafica Processing Library";
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
    fill(50);
    text(t, 780-250, 700-10);

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
  while (millis () - time <= delay) {
  };
}// End of Function


/*
This section is workin progress
 
 */


public void setupgobalVariables() {
}

public void createWindows() {
  int col;
  window = new GWindow[3];
  for (int i = 0; i < 3; i++) {
    col = (128 << (i * 8)) | 0xff000000;
    window[i] = new GWindow(this, "Window "+i, 70+i*220, 160+i*50, 200, 200, false, JAVA2D);
    window[i].setBackground(col);
    window[i].addData(new MyWinData());
    window[i].addDrawHandler(this, "windowDraw");
    window[i].addMouseHandler(this, "windowMouse");
  }
}

/**
 * Handles mouse events for ALL GWindow objects
 *  
 * @param appc the PApplet object embeded into the frame
 * @param data the data for the GWindow being used
 * @param event the mouse event
 */
public void windowMouse(GWinApplet appc, GWinData data, MouseEvent event) {
  MyWinData data2 = (MyWinData)data;
  switch(event.getAction()) {
  case MouseEvent.PRESS:
    data2.sx = data2.ex = appc.mouseX;
    data2.sy = data2.ey = appc.mouseY;
    data2.done = false;
    break;
  case MouseEvent.RELEASE:
    data2.ex = appc.mouseX;
    data2.ey = appc.mouseY;
    data2.done = true;
    break;
  case MouseEvent.DRAG:
    data2.ex = appc.mouseX;
    data2.ey = appc.mouseY;
    break;
  }
}


/**
 * Handles drawing to the windows PApplet area
 * 
 * @param appc the PApplet object embeded into the frame
 * @param data the data for the GWindow being used
 */
public void windowDraw(GWinApplet appc, GWinData data) {
  MyWinData data2 = (MyWinData)data;
  if (!(data2.sx == data2.ex && data2.ey == data2.ey)) {
    appc.stroke(255);
    appc.strokeWeight(2);
    appc.noFill();
    if (data2.done) {
      appc.fill(128);
    }
    appc.rectMode(CORNERS);
    appc.rect(data2.sx, data2.sy, data2.ex, data2.ey);
  }
}

/**
 * Simple class that extends GWinData and holds the data 
 * that is specific to a particular window.
 * 
 * @author Peter Lager
 */
class MyWinData extends GWinData {
  int sx, sy, ex, ey;
  boolean done;
}

public void mouseClicked() {
  println("Mouse X: "+mouseX+" "+"Mouse Y: "+mouseY);
}


public class GraficaPlot {
  int oldRecord;
  float gcx, gcy, gcw;
  float zf = 1.1f, czf = 1.0f;
  boolean update;

  public void setup(GPlot plot, int pos) {
    float[] firstPlotPos = new float[] {
      0, 0
    };

    float[] panelDim = new float[] {
      160, 160
    };

    float[] panelDim1 = new float[] {
      250, 250
    };  // Fits 4 plots per window
    float[] margins = new float[] {
      60, 90, 40, 30
    }; 

    switch(pos) { // Create plots to represent the panels
    case 1:  //Single Position
      plot.setPos(firstPlotPos);
      plot.setMar(0, margins[1], margins[3], 0);
      plot.setDim(new float[] {
        620, 590
      }
      );
      break;

    case 2: // Top Left 4Position
      plot.setPos(firstPlotPos);
      //Margins: bottom,left, top, right
      plot.setMar(0, margins[1], margins[3], 0);
      plot.setDim(panelDim1);
      break;

    case 3: // Top Right 4Position
      // Pos: X, Y
      plot.setPos(450, 0);
      plot.setMar(0, 0, margins[3], margins[3]);
      plot.setDim(panelDim1);
      break;

    case 4: // Bottom Left 4Position
      plot.setPos(0, 350);
      plot.setMar(0, margins[1], 0, 0);
      plot.setDim(panelDim1);
      break;

    case 5: // Bottom Right 4Position
      plot.setPos(450, 350);
      plot.setMar(0, 0, 0, 0);
      plot.setDim(panelDim1);
      break;

      ////////////////////////////////////////
    case 6: // Top Left 6Position
      plot.setPos(0, 0);
      //Margins: bottom,left, top, right
      plot.setMar(0, margins[1], margins[3], 0);
      plot.setDim(panelDim);
      break;

    case 7: // Top Middle 6Position
      plot.setPos(250, 0);
      //Margins: bottom,left, top, right
      plot.setMar(0, margins[1], margins[3], 0);
      plot.setDim(panelDim);
      break;

    case 8: // Top Right 6Position
      plot.setPos(580, 0);
      //Margins: bottom,left, top, right
      plot.setMar(0, 0, margins[3], 0);
      plot.setDim(panelDim);
      break;

    case 9: // Bottom Left 4Position
      plot.setPos(0, 350);
      plot.setMar(0, margins[1], margins[3], 0);
      plot.setDim(panelDim);
      break;
      
    case 10: // Bottom Middle 6Position
      plot.setPos(250, 350);
      //Margins: bottom,left, top, right
      plot.setMar(0, margins[1], margins[3], 0);
      plot.setDim(panelDim);
      break; 
      
   case 11: // Bottom Right 6Position
      plot.setPos(580, 350);
      //Margins: bottom,left, top, right
      plot.setMar(0, 0, margins[3], 0);
      plot.setDim(panelDim);
      break;   
      



    default:
      plot.setPos(firstPlotPos);
      //Margins: bottom,left, top, right
      plot.setMar(0, 0, 0, 0);
      plot.setDim(new float[] {
        0, 0
      }
      );
      break;
    }    
    plot.setAxesOffset(0);
    plot.setTicksLength(-4);
    plot.getXAxis().setDrawTickLabels(true);

    // Set the points, the title and the axis labels
    //plot.setTitleText("Plot with multiple panels");
    plot.getTitle().setRelativePos(1);
    plot.getTitle().setTextAlignment(CENTER);
    plot.getYAxis().setAxisLabelText("Y-Axis");
    plot.getXAxis().setAxisLabelText("X-Axis");

    plot.setLineColor(0xffff0000);
    plot.activatePointLabels();
    plot.activatePanning();
    plot.activateZooming();
    plot.activateReset();
  }

  public void zoomOut(GPlot plot) {
    float[] idim = plot.getDim();
    float[] mar = plot.getMar();
    gcx = idim[0]/2 + mar[1];
    gcy = idim[1]/2 + mar[2];
    gcw = idim[0];
    plot.zoom(1/zf, gcx, gcy);
  }
  public void zoomIn(GPlot plot) {
    float[] idim = plot.getDim();
    float[] mar = plot.getMar();
    gcx = idim[0]/2 + mar[1];
    gcy = idim[1]/2 + mar[2];
    gcw = idim[0];
    plot.zoom(zf, gcx, gcy);
  }

  public void updatePoints(GPlot plot, GPointsArray points, int XDataSet, int YDataSet, String XAxisLabel, String YAxisLabel) {
    int records = dataPlotArray.length;  

    for (int i = 0; i < records; i++ ) {      
      points.add(dataPlotArray[i][XDataSet], dataPlotArray[i][YDataSet], String.valueOf("X:"+dataPlotArray[i][XDataSet]+" "+"Y: "+dataPlotArray[i][YDataSet]));
    }
    plot.addPoints(points);
    plot.getYAxis().setAxisLabelText(YAxisLabel);
    plot.getXAxis().setAxisLabelText(XAxisLabel);
  }

  public void draw(GPlot plot, GPointsArray points) {

    plot.beginDraw();
    plot.drawBox();
    plot.drawXAxis();
    plot.drawYAxis();
    plot.drawTopAxis();
    plot.drawRightAxis();
    plot.drawTitle();
    plot.drawGridLines(GPlot.BOTH);  
    //plot.drawPoints();
    plot.drawLines();
    plot.endDraw();
  }
}


String Xlabel = "";
String Ylabel = " ";
//int Yticks = 0;
int Xticks = 0;


// class to implement the ILine2DEquation with the custom computePoint Method 
// which allows for the plotting of Y axis values against X axis input values
public class eq1 implements ILine2DEquation {

  /*  This Method is called by graph2D. Arguement 'x' is the current x axis value, arguement 'pos'
   is the location of value 'x' position in pixels*/
  public double computePoint(double x, int pos) {
    setupXYAxis(YAxisDataSet1, x);
    return getYAxisValue(YAxisDataSet1, x);
  }
}// End of Function

public class eq2 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    setupXYAxis(YAxisDataSet2, x);
    return getYAxisValue(YAxisDataSet2, x);
  }
}// End of Function

public class eq3 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    setupXYAxis(YAxisDataSet3, x);
    return getYAxisValue(YAxisDataSet3, x);
  }
}// End of Function


public class eq4 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    setupXYAxis(YAxisDataSet4, x);
    return getYAxisValue(YAxisDataSet4, x);
  }
}// End of Function

public class eq5 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    setupXYAxis(YAxisDataSet5, x);
    return getYAxisValue(YAxisDataSet5, x);
  }
}// End of Function

public class eq6 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    setupXYAxis(YAxisDataSet6, x);
    return getYAxisValue(YAxisDataSet6, x);
  }
}// End of Function


class eq2D1 implements ILine2DEquation {
  public double computePoint(double x, int pos) { 
    calYMax2D();
    return Double.valueOf(trim(txtfld2Sensor1.getText()));
  }
}
class eq2D2 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    calYMax2D();
    return Double.valueOf(trim(txtfld2Sensor2.getText()));
  }
}
class eq2D3 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    calYMax2D();
    return Double.valueOf(trim(txtfld2Sensor3.getText()));
  }
}
class eq2D4 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    calYMax2D();
    return Double.valueOf(trim(txtfld2Sensor4.getText()));
  }
}
class eq2D5 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    calYMax2D();
    return Double.valueOf(trim(txtfld2Sensor5.getText()));
  }
}
class eq2D6 implements ILine2DEquation {
  public double computePoint(double x, int pos) {
    calYMax2D();
    return Double.valueOf(trim(txtfld2Sensor6.getText()));
  }
}

public void calYMax2D() {
  int Y = 0;

  if (sensorSelected >= 1) {
    if (Double.valueOf(txtfld2Sensor1.getText()) > Ymax)
      Ymax = Double.valueOf(txtfld2Sensor1.getText());
    if (Double.valueOf(txtfld2Sensor1.getText()) < Ymin)
      Ymin = Double.valueOf(txtfld2Sensor1.getText());
  }
  if (sensorSelected >= 2) {
    if (Double.valueOf(txtfld2Sensor2.getText()) > Ymax)
      Ymax = Double.valueOf(txtfld2Sensor2.getText());
    if (Double.valueOf(txtfld2Sensor2.getText()) < Ymin)
      Ymin = Double.valueOf(txtfld2Sensor2.getText());
  }
  if (sensorSelected >= 3) {
    if (Double.valueOf(txtfld2Sensor3.getText()) > Ymax)
      Ymax = Double.valueOf(txtfld2Sensor3.getText());
    if (Double.valueOf(txtfld2Sensor3.getText()) < Ymin)
      Ymin = Double.valueOf(txtfld2Sensor3.getText());
  }
  if (sensorSelected >= 4) {
    if (Double.valueOf(txtfld2Sensor4.getText()) > Ymax)
      Ymax = Double.valueOf(txtfld2Sensor4.getText());
    if (Double.valueOf(txtfld2Sensor4.getText()) < Ymin)
      Ymin = Double.valueOf(txtfld2Sensor4.getText());
  }
  if (sensorSelected >= 5) {
    if (Double.valueOf(txtfld2Sensor5.getText()) > Ymax)
      Ymax = Double.valueOf(txtfld2Sensor5.getText());
    if (Double.valueOf(txtfld2Sensor5.getText()) < Ymin)
      Ymin = Double.valueOf(txtfld2Sensor5.getText());
  }
  if (sensorSelected >= 6) {
    if (Double.valueOf(txtfld2Sensor6.getText()) > Ymax)
      Ymax = Double.valueOf(txtfld2Sensor6.getText());
    if (Double.valueOf(txtfld2Sensor6.getText()) < Ymin)
      Ymin = Double.valueOf(txtfld2Sensor6.getText());
  }

  g2D.setYAxisMax(Float.valueOf(String.valueOf(Ymax + 5)));
  g2D.setYAxisMin(Float.valueOf(String.valueOf(Ymin -5)));
}// End of Function



public void setupXYAxis(String YAxisDataSet, double x) {

  if (logtable.getRowCount() <= 1 || logtable == null) {
    Y_Axis_Value = 0;
  } else { 
    try {

      if (!zoomSliderControl) {  //Dont run if zooming

        //Calculates the exponent value to scale the X axis to
        Xlastrow = logtable.getRowCount()-1;
        String num = str(Xlastrow);
        int num1 = num.length();
        XAccuracy = ceil(num1) - 1; // XAxis exponent value

        //Calculates X-axis min value and X-axis max value
        XlastCycle = logtable.findRow(str(Xlastrow), "id");
        XfirstCycle = logtable.findRow(str(Xfirstrow), "id");
        Xmax = XlastCycle.getInt(XAxisDataSet);
        Xmin = XfirstCycle.getInt(XAxisDataSet);

        if (Xmax <= 100)
          XAccuracy = 1;

        if (Xmin < 1)
          Xmin = 0;

        //Calculates Y-axis max value
        Ylastrow = logtable.getRowCount();
        TableRow YmaxLoad = logtable.findRow(str(Ylastrow), "id");
        Ymax1 = YmaxLoad.getFloat(YAxisDataSet);


        TableRow IntLoad = logtable.findRow(str(1), "id");
        intLoad = IntLoad.getInt(YAxisDataSet);
      }


      //Determine the spacing between each major x axis value
      spacingX = ceil((Xmax/pow(10, XAccuracy)))/10;
      if (spacingX < 1) spacingX = 1; 

      if (x <= (1+(Xmin/pow(10, XAccuracy)))) { //limits the amount of times this section runs

        //Determine the spacing between each major y axis value
        spacingY = spacingYCal(Ymax1);

        // Determine the X axis minor tick count & label exponent value to display
        if (  (XAccuracy > 2)) { 
          if (spacingX > 3) {
            if (ceil(spacingX/(XAccuracy)) < 2)
              Xticks = 5;
            else
              Xticks = ceil(spacingX/(XAccuracy));

            Xlabel =("(x10^"+XAccuracy+")");
          } else {
            if (XAccuracy == 3 && logtable.getRowCount() > 500 || (Xmax/pow(10, XAccuracy)) >11 ) {
              spacingX = 2;
            } else {
              spacingX = 1;
            }

            if (ceil(spacingX/(XAccuracy)) < 2)
              Xticks = 5;
            else
              Xticks = ceil(spacingX/(XAccuracy));

            Xlabel =("(x10^"+XAccuracy+")");
          }
          if (zoomSliderControl && logtable.getRowCount() > 500 ) { //
            if ((Xmax/pow(10, XAccuracy)) >11 )
              g.setXAxisTickSpacing(spacingX);
            else {
              spacingX = spacingX +2;
            }

            if (ceil(spacingX/(XAccuracy)) < 2)
              Xticks = 5;
            else
              Xticks = ceil(spacingX/(XAccuracy));
          }
          if (zoomSliderControl && logtable.getRowCount() <= 500) {
            if (ceil(spacingX/(XAccuracy)) < 2)
              Xticks = 5;
            else
              Xticks = ceil(spacingX/(XAccuracy));
            spacingX = 1;
          }
        }

        if (XAccuracy <= 2) {

          if (ceil(spacingX/(XAccuracy)) < 2)
            Xticks = 5;
          else
            Xticks = ceil(spacingX/(XAccuracy));

          Xlabel = ("(x10^"+XAccuracy+")");
          spacingX = 1;

          if (logtable.getRowCount() > 50 || (Xmax/pow(10, XAccuracy)) >11) {
            spacingX = 1;
          } else {
            spacingX = 1;
          }

          if (XAccuracy == 1) {
            Xlabel = ("(x10)");
            spacingX = 1;
          }
        }
      }// End if


      // Set the above calculated X & Y axis values
      if (!zoomSliderControl && !Activated) {
        g.setXAxisMax((Xmax/pow(10, XAccuracy))+ 0.5f);
        g.setXAxisMin(Xmin/pow(10, XAccuracy));
      } else {

        // Overide above value if zoom is enabled
        if ( (!XUp || !XDwn) && graphEnd || !Activated)//
          g.setXAxisMax(Xmax/pow(10, XAccuracy)+0.5f);
        else
          g.setXAxisMax(Xmax/pow(10, XAccuracy));
      }

      // Set the above calculated X & Y axis values
      g.setYAxisTickSpacing(spacingY);
      g.setXAxisTickSpacing(spacingX);
      g.setXAxisMinorTicks(Xticks);
      g.setXAxisLabel(XAxisDataSet+" "+Xlabel);
      g.setYAxisLabel(YAxisDataSet1+" "+Ylabel);

      //println("Spacing X: "+spacingX);
      //println("XAccuracy: "+XAccuracy);
    }
    catch(RuntimeException e) {
      println("Method -> setupXYAxis() Error: "+"  "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
      error.addLast("Method -> setupXYAxis() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
    }
  }
}// End of Function


public double getYAxisValue(String DataSet, double x) {
  if (logtable.getRowCount() <= 1 || logtable == null) {
    Y_Axis_Value = 0;
  } else { 
    try {

      ////////////  Graph Plotting Loop  ///////////////

      for (int i = XfirstCycle.getInt ("id"); i <= XlastCycle.getInt("id"); i++ ) { //Limit the loop to a range of records
        //Get each row from the tableRow object. 
        TableRow row = logtable.getRow(i);
        int X_max = 0;

        // Reads the current row X Axis Value
        double currentCount = (row.getInt(XAxisDataSet)/pow(10, XAccuracy));

        //Check for end of graph when plotting full graph
        if ((x >= (Xmax/pow(10, XAccuracy))) && !zoomSliderControl && !Activated) {
          Y_Axis_Value = 0; //Plot break line
          break;
        } else {
          // Compares the X axis value from the method input to the 
          // value in the current row

          NewYvalue = row.getFloat(DataSet);
          NewXvalue = x;

          if ((effectList.getSelectedIndex() == 0)) {

            if (x >= currentCount) {  //
              //Return the Y Axis value of the current row
              Y_Axis_Value = row.getFloat(DataSet);
            }
          }

          if (effectList.getSelectedIndex() == 1) {
            Boolean SmoothE =(round(_Float(x)) == round(_Float(currentCount)));
            /*Boolean SmoothG =(round(_Float(x)) > round(_Float(currentCount)));
             Boolean SmoothL =(round(_Float(x)) < round(_Float(currentCount)));
             Boolean Smooth =(round(_Float(x)) >= round(_Float(currentCount)));*/

            if (SmoothE) {
              //Y_Axis_Value = row.getFloat(YAxisDataSet);
              //Y_Axis_Value = sin(abs(Float.valueOf(String.valueOf(((OldYvalue - NewYvalue)/(OldXvalue - NewXvalue) )*x)))) + OldYvalue;
              float smthFactor = 0.1f;
              Y_Axis_Value = (smthFactor*NewYvalue)+((1-smthFactor)*OldYvalue);

              Y_Axis_Value = sin(_Float((OldXvalue - NewXvalue)))+(Y_Axis_Value);
            }

            /* if (OldYvalue > Y_Axis_Value) {
             Y_Axis_Value = sin(_Float(-(x)))+(intLoad);
             } else {
             Y_Axis_Value = sin(_Float(+(x)))+(intLoad);
             }*/
          }
        }

        //Calculate the max x axis value that can be zoom to
        if (graphEnd) {
          int Xlastrow = logtable.getRowCount();
          TableRow XlastCycle = logtable.findRow(str(Xlastrow), "id");
          X_max = XlastCycle.getInt(XAxisDataSet);
        }

        //Check for end of graph when zooming
        if ((x >= (X_max/pow(10, XAccuracy))) && graphEnd && !Activated) {
          Y_Axis_Value = 0; //Plot break line
          break;
        }

        //Over ride above values to plot start point
        if (row.getInt("id") <=2)
          Y_Axis_Value = row.getFloat(DataSet);
      }
      ///////////////// End of Loop ////////////////
    }
    catch(RuntimeException e) {
      println("Method -> getYAxisValue() Error: "+"  "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
      error.addLast("Method -> getYAxisValue() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
    }
  }
  OldXvalue = X;
  OldYvalue = NewYvalue;

  return Y_Axis_Value;
}// End of Function


// Method -> to control the graph zoom feature
public void zoom() {
  try {
    if (zoomSliderControl) {

      Xlastrow = zoom_slider.getValueI();
      int Up = 0;
      int Dwn = 0;

      String num = str(Xlastrow);
      int num1 = num.length();
      XAccuracy = ceil(num1);

      if (XUp) {
        if (graphEnd) {
          Up = (logtable.getRowCount()-1) - (zoom_slider.getValueI());
          Dwn = (logtable.getRowCount()-1) - (zoom_slider.getValueI());
        } else
          if (zoomList.getSelectedIndex() == 1) {
          Up = XAxisdwn - XAxisUp;
        } else {
          Up = XAxisUp;
        }
      } else
        Up = 0;

      if (XDwn) {
        if (zoomList.getSelectedIndex() == 1) {
          Up = XAxisdwn;
        } else
          Dwn = XAxisdwn;
      } else
        Dwn = 0;


      //Calculates X-axis min value and X-axis max 
      //values base on the zoom slider position
      if ((Xlastrow+Up-Dwn) <= (logtable.getRowCount())) {

        XlastCycle = logtable.findRow(str(Xlastrow+Up -Dwn), "id");
        Xmax = XlastCycle.getInt(XAxisDataSet);
        g.generateTrace(g.addTrace(trace1));

        XUp = false;
        XDwn = false;
      } else {
        G4P.showMessage(this, "End of Graph", "Error", G4P.ERROR);
      }

      if ((Xfirstrow-Dwn +Up) >= 0) {

        XfirstCycle = logtable.findRow(str(Xfirstrow-Dwn +Up), "id");
        Xmin = XfirstCycle.getInt(XAxisDataSet);
        g.setXAxisMin(Xmin/pow(10, XAccuracy)+1);
        g.generateTrace(g.addTrace(trace1));

        XUp = false;
        XDwn = false;
      } else {
        G4P.showMessage(this, "End of Graph", "Error", G4P.ERROR);
      }
    }
  }
  catch(RuntimeException e) {
    println("Method -> zoom() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> zoom() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}

public int spacingYCal(float Ymax1) {
  int S = 0;
  String YAxisDataSet = "";

  if (zoomSliderControl)
    Ymax1 = 0;

  for (int i = XfirstCycle.getInt ("id"); i <= XlastCycle.getInt("id"); i++ ) {
    lastRow = logtable.findRow(str(i), "id");

    if (checkbox2.isSelected()) {
      YAxisDataSet = txtfldSensor1.getText();
      if (lastRow.getInt(YAxisDataSet)>Ymax1)
        Ymax1 = lastRow.getInt(YAxisDataSet);
      if (lastRow.getInt(YAxisDataSet)< Ymin1)
        Ymin1 = lastRow.getInt(YAxisDataSet);
    }

    if (checkbox3.isSelected()) {
      YAxisDataSet = txtfldSensor2.getText();
      if (lastRow.getInt(YAxisDataSet)>Ymax1)
        Ymax1 = lastRow.getInt(YAxisDataSet);
      if (lastRow.getInt(YAxisDataSet)< Ymin1)
        Ymin1 = lastRow.getInt(YAxisDataSet);
    }

    if (checkbox4.isSelected()) {
      YAxisDataSet = txtfldSensor3.getText();
      if (lastRow.getInt(YAxisDataSet)>Ymax1)
        Ymax1 = lastRow.getInt(YAxisDataSet);
      if (lastRow.getInt(YAxisDataSet)< Ymin1)
        Ymin1 = lastRow.getInt(YAxisDataSet);
    }

    if (checkbox5.isSelected()) {
      YAxisDataSet = txtfldSensor4.getText();
      if (lastRow.getInt(YAxisDataSet)>Ymax1)
        Ymax1 = lastRow.getInt(YAxisDataSet);
      if (lastRow.getInt(YAxisDataSet)< Ymin1)
        Ymin1 = lastRow.getInt(YAxisDataSet);
    }

    if (checkbox6.isSelected()) {
      YAxisDataSet = txtfldSensor5.getText();
      if (lastRow.getInt(YAxisDataSet)>Ymax1)
        Ymax1 = lastRow.getInt(YAxisDataSet);
      if (lastRow.getInt(YAxisDataSet)< Ymin1)
        Ymin1 = lastRow.getInt(YAxisDataSet);
    }

    if (checkbox7.isSelected()) {
      YAxisDataSet = txtfldSensor6.getText();
      if (lastRow.getInt(YAxisDataSet)>Ymax1)
        Ymax1 = lastRow.getInt(YAxisDataSet);
      if (lastRow.getInt(YAxisDataSet)< Ymin1)
        Ymin1 = lastRow.getInt(YAxisDataSet);
    }
  }

  for (int i=100; i<=1024; i+=100) {
    if ((Ymax1) <= (i)) {
      S = i/10;
      g.setYAxisMax(Ymax1 + S);
      g.setYAxisMin(Ymin1 - 5);

      //println("Y min: "+Ymin1);
      //println("Y max: "+Ymax1);
      break;
    }
  }

  return S;
}

public float _Float(double x) {
  return Float.valueOf((String.valueOf(x)));
}




// Method -> to setup general graph axis values and other graph settings
public void graphSetup() {

  try {
    // Graph2D object, arguments are 
    // the parent object, xsize, ysize, cross axes at zero point
    g = new Graph2D(this, 620, 620, true); 

    // setting attributes for the X and Y-Axis
    g.setYAxisMin(0);
    g.setYAxisMax(95);
    g.setXAxisMin(0);
    g.setXAxisMax(Xmax);
    g.setXAxisLabel(XAxisDataSet);
    g.setYAxisLabel(YAxisDataSet1);
    g.setXAxisLabelAccuracy(0);
    g.setYAxisLabelAccuracy(0);
    g.setXAxisTickSpacing(Xmax/10);
    g.setYAxisTickSpacing(10);
    g.setYAxisMinorTicks(4);
    g.setXAxisMinorTicks(4);

    Axis2D ax=g.getXAxis();
    ax.setLabelOffset(20);

    Axis2D ay=g.getYAxis();
    ay.setLabelOffset(20);


    // switching of the border, and changing the label positions
    g.setNoBorder(); 
    g.setXAxisLabelPos(LabelPos.MIDDLE);
    g.setYAxisLabelPos(LabelPos.MIDDLE);

    // switching on Grid, with different colours for X and Y lines
    gb = new  GridBackground(new GWColour(255));
    gb.setGridColour(200, 100, 200, 180, 180, 180);
    g.setBackground(gb);
   
    // graph position within the main window
    g.position.y = 30;
    g.position.x = 100;

    //Setup trace properties
    trace1.setTraceColour(255, 0, 0);
    trace1.setLineWidth(1);

    trace2.setTraceColour(0, 0, 255);
    trace2.setLineWidth(1);

    trace3.setTraceColour(0, 255, 0);
    trace3.setLineWidth(1);

    trace4.setTraceColour(0, 255, 255);
    trace4.setLineWidth(1);

    trace5.setTraceColour(255, 255, 0);
    trace5.setLineWidth(1);

    trace6.setTraceColour(255, 0, 255);
    trace6.setLineWidth(1);

    //Add trace to graph
    g.addTrace(trace1);
    g.addTrace(trace2);
    g.addTrace(trace3);
    g.addTrace(trace4);
    g.addTrace(trace5);
    g.addTrace(trace6);

    //Rolling 2DTrace
    g2D = new Graph2D(this, 620, 600, true);

    g2D.position.y = 30;
    g2D.position.x = 100;
    g2D.setYAxisMax(95);
    g2D.setYAxisTickSpacing(10);
    g2D.setXAxisMax(5f);
    g2D.setYAxisMinorTicks(5);
    //g2D.setBackground(gb);

    //Setup trace properties
    r2D1.setTraceColour(255, 0, 0);
    r2D1.setLineWidth(1);

    r2D2.setTraceColour(0, 0, 255);
    r2D2.setLineWidth(1);

    r2D3.setTraceColour(0, 255, 0);
    r2D3.setLineWidth(1);

    r2D4.setTraceColour(30, 2, 160);
    r2D4.setLineWidth(1);

    r2D5.setTraceColour(2, 156, 160);
    r2D5.setLineWidth(1);

    r2D6.setTraceColour(19, 160, 2);
    r2D6.setLineWidth(1);

    g2D.addTrace(r2D1);
    g2D.addTrace(r2D2);
    g2D.addTrace(r2D3);
    g2D.addTrace(r2D4);
    g2D.addTrace(r2D5);
    g2D.addTrace(r2D6);
  }
  catch(RuntimeException e) {
    println("Method -> graphSetup() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> graphSetup() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function



//Method -> to openfiles save on local computer
public void openFile() {
  try {
    fname = G4P.selectInput("Input Dialog", ".csv", "Log file");

    if (fname == null) {
      String message = "Window was closed or the user cancelled";
      println(message+"  "+ System.currentTimeMillis()%10000000);
      error.addLast(message+"  "+ System.currentTimeMillis()%10000000);
      //G4P.showMessage(this, message, "Error", G4P.ERROR);
    } else {

      //Clear display log and buffer
      textLog.setText(""); 
      buffer1.clear();
      available = true;

      //Load CSV head data and add titles to an array
      logtable = loadTable(fname, "header");
      String[] tableHeader = logtable.getColumnTitles();

      //Determine array length and use info to update the number of sensors
      //to display to the user
      sensorMax.setSelected(tableHeader.length-4);
      sensorMaxSelector();

      //Display the column titles in each sensor text field 
      for (int i = 0; i < tableHeader.length; i++) {
        //print(tableHeader[i]+" ");
        switch(i) {

        case 1:
          txtfldSensor0.setText(tableHeader[i]);
          break; 

        case 2:
          Sensor1Txt = true;
          Sensor1SValue = true;
          txtfldSensor1.setText(tableHeader[i]);
          label10.setText(tableHeader[i]);
          break;  

        case 3:
          Sensor2Txt = true;
          Sensor2SValue = true;
          txtfldSensor2.setText(tableHeader[i]);
          label21.setText(tableHeader[i]);
          break;

        case 4:
          Sensor3Txt = true;
          Sensor3SValue = true;
          txtfldSensor3.setText(tableHeader[i]);
          label22.setText(tableHeader[i]);
          break;

        case 5:
          Sensor4Txt = true;
          Sensor4SValue = true;
          txtfldSensor4.setText(tableHeader[i]);
          label3.setText(tableHeader[i]);
          break;

        case 6:
          Sensor5Txt = true;
          Sensor5SValue = true;
          txtfldSensor5.setText(tableHeader[i]);
          label8.setText(tableHeader[i]);
          break;

        case 7:
          Sensor6Txt = true;
          Sensor6SValue = true;
          txtfldSensor6.setText(tableHeader[i]);
          label13.setText(tableHeader[i]);
          break;
        }
      }
      //println("");

      //Check the size of the log file
      if (sensorSelected >= 1)
        if (logtable.getRowCount() >= 4000) {
          if (!graphdraw) {
            largefile = true;
            message();
          }
        } else {
          largefile = false;
        }
      println("Total rows in log: "+logtable.getRowCount()+"  "+ System.currentTimeMillis()%10000000);
      error.addLast("Log: "+fname+"  "+ System.currentTimeMillis()%10000000);
      error.addLast("Total rows in log: "+logtable.getRowCount()+"  "+ System.currentTimeMillis()%10000000);
      thread("displayRecord");
    }
  }
  catch(RuntimeException e)
  {
    println("Method -> openFile() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> openFile() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


public void message() {
  G4P.showMessage(this, "Displaying a Large File. \nTotal Records in log: "+
    logtable.getRowCount()+'\n', "File Info", G4P.INFO);
}// End of Function


//Method -> to load data from table object and format it to display on screen
public void displayRecord() {

  if (buffer1.isEmpty() && available) {

    if (Activated || largefile) {
      available = false;
      clearTextArea = true;
      buffer1.clear();
    }

    String line = "";
    data = "";
    try {
      textLog.setTextEditEnabled(false);  
      labelfile.setText(fname);

      dataPlotArray = new float[logtable.getRowCount()][7];
      String sensor1Data, sensor2Data, sensor3Data, sensor4Data, sensor5Data, sensor6Data;
      String space = "  |  ";
      String space1 = "              ";

      for (TableRow row : logtable.rows ()) {

        //Time Data Formating
        int id = row.getInt("id");
        int Timedata = row.getInt(trim(txtfldSensor0.getText()));
        dataPlotArray[id-1][0] = Float.valueOf(Timedata);
        line = (nf(id, 4) + space + nf(PApplet.parseInt(Timedata), 6));

        //Sensor 1 Data Formating
        if (sensorSelected >= 1) { 
          sensor1Data = row.getString(trim(txtfldSensor1.getText()));

          if (checkString(sensor1Data))
            dataType1.setSelected(2);
          if (sensor1Data.indexOf(".") > 0)
            dataType1.setSelected(1);

          if (!dataType1.getSelectedText().equals("String") || !checkString(sensor1Data) ) {
            dataPlotArray[id-1][1] = Float.valueOf(sensor1Data);
          } else {
            dataPlotArray[id-1][1] = 0;
          }

          if (dataType1.getSelectedText().equals("Int"))
            line = line + space + (nf(PApplet.parseInt(sensor1Data), 6));
          if (dataType1.getSelectedText().equals("Float"))
            line = line + space + (nf(PApplet.parseFloat(sensor1Data), 4, 2)) ;
          if (dataType1.getSelectedText().equals("String")) {
            line = line + space + space1; //String.format("%6s", sensor1Data)
          }
        }// End of Sensor 1 Data Formating

        //Sensor 2 Data Formating
        if (sensorSelected >= 2) {
          sensor2Data = row.getString(trim(txtfldSensor2.getText()));

          if (checkString(sensor2Data))
            dataType2.setSelected(2);
          if (sensor2Data.indexOf(".") > 0)
            dataType2.setSelected(1);

          if (!dataType2.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][2] = Float.valueOf(sensor2Data);
          } else {
            dataPlotArray[id-1][2] = 0;
          }

          if (dataType2.getSelectedText().equals( "Int"))
            line = line + space +(nf(PApplet.parseInt(sensor2Data), 6));
          if (dataType2.getSelectedText().equals( "Float"))
            line = line + space +(nf(PApplet.parseFloat(sensor2Data), 4, 2)) ;
          if (dataType2.getSelectedText().equals( "String"))
            line = line + space +space1;
        }// End of Sensor 2 Data Formating

        //Sensor 3 Data Formating
        if (sensorSelected >= 3) {
          sensor3Data = row.getString(trim(txtfldSensor3.getText()));

          if (checkString(sensor3Data))
            dataType3.setSelected(2);
          if (sensor3Data.indexOf(".") > 0)
            dataType3.setSelected(1);

          if (!dataType3.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][3] = Float.valueOf(sensor3Data);
          } else {
            dataPlotArray[id-1][3] = 0;
          }

          if (dataType3.getSelectedText() .equals("Int"))
            line = line + space +(nf(PApplet.parseInt(sensor3Data), 6));
          if (dataType3.getSelectedText() .equals("Float"))
            line = line + space +(nf(PApplet.parseFloat(sensor3Data), 4, 2)) ;
          if (dataType3.getSelectedText() .equals("String"))
            line = line + space + space1;
        }// End of Sensor 3 Data Formating

        //Sensor 4 Data Formating
        if (sensorSelected >= 4) {
          sensor4Data = row.getString(trim(txtfldSensor4.getText()));

          if (checkString(sensor4Data))
            dataType4.setSelected(2);
          if (sensor4Data.indexOf(".") > 0)
            dataType4.setSelected(1);

          if (!dataType4.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][4] = Float.valueOf(sensor4Data);
          } else {
            dataPlotArray[id-1][4] = 0;
          }

          if (dataType4.getSelectedText() .equals("Int"))
            line = line + space +(nf(PApplet.parseInt(sensor4Data), 6));
          if (dataType4.getSelectedText() .equals("Float"))
            line = line + space +(nf(PApplet.parseFloat(sensor4Data), 3, 2)) ;
          if (dataType4.getSelectedText() .equals("String"))
            line = line + space +space1;
        }// End of Sensor 4 Data Formating

        //Sensor 5 Data Formating
        if (sensorSelected >= 5) {
          sensor5Data = row.getString(trim(txtfldSensor5.getText()));

          if (checkString(sensor5Data))
            dataType5.setSelected(2);
          if (sensor5Data.indexOf(".") > 0)
            dataType5.setSelected(1);

          if (!dataType5.getSelectedText().equals("String")) {
            dataPlotArray[id-1][5] = Float.valueOf(sensor5Data);
          } else {
            dataPlotArray[id-1][5] = 0;
          }

          if (dataType5.getSelectedText() .equals("Int"))
            line = line + space + (nf(PApplet.parseInt(sensor5Data), 6));
          if (dataType5.getSelectedText() .equals("Float"))
            line = line + space +(nf(PApplet.parseFloat(sensor5Data), 3, 2)) ;
          if (dataType5.getSelectedText() .equals("String"))
            line = line + space + space1;
        }// End of Sensor 5 Data Formating

        //Sensor 6 Data Formating
        if (sensorSelected >= 6) {      
          sensor6Data = row.getString(trim(txtfldSensor6.getText()));

          if (checkString(sensor6Data))
            dataType6.setSelected(2);
          if (sensor6Data.indexOf(".") > 0)
            dataType6.setSelected(1);

          if (!dataType6.getSelectedText().equals("String")) {
            dataPlotArray[id-1][6] = Float.valueOf(sensor6Data);
          } else {
            dataPlotArray[id-1][6] = 0;
          }

          if (dataType6.getSelectedText() .equals("Int"))
            line = line + space +(nf(PApplet.parseInt(sensor6Data), 6));
          if (dataType6.getSelectedText() .equals("Float"))
            line = line + space + (nf(PApplet.parseFloat(sensor6Data), 3, 2)) ;
          if (dataType6.getSelectedText() .equals("String"))
            line = line + space + space1;
        }// End of Sensor 6 Data Formating

        //Add record line break to display
        line = line +'\n'+"--------------------------------------------------"+
          "--------------------------------------------------------------"+'\n';

        // Load Serial Identifier tags from Setting Column in logfile
        switch(id) {  
        case 1:
          txtfldSValue1.setText(row.getString("SETTINGS:"));
          break;

        case 2:
          txtfldSValue2.setText(row.getString("SETTINGS:"));
          break;

        case 3:
          txtfldSValue3.setText(row.getString("SETTINGS:"));
          break;

        case 4:
          txtfldSValue4.setText(row.getString("SETTINGS:"));
          break;

        case 5:
          txtfldSValue5.setText(row.getString("SETTINGS:"));
          break;

        case 6:
          txtfldSValue6.setText(row.getString("SETTINGS:"));
          break;

        default:
          break;
        }

        //Check whether the application is capturing live data 
        //and working with a large log file
        if (!Activated && !largefile)
        {
          data = data+line;
        } else {
          buffer1.addLast(line);
        }
      }

      if (!Activated && !largefile) {
        textLog.setText(data);
      } else {
        available = true;
      }

      //Update Records data label display value
      labelInfo.setText("Total Records in File: "+logtable.getRowCount());
    }
    catch (RuntimeException e) {
      println("Method -> displayRecord() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
      error.addLast("Method -> displayRecord() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
      G4P.showMessage(this, "Missing or incorrect Data Series value.\n"+e.getMessage(), "Error", G4P.ERROR);
    }
  }
}// End of Function

//Method -> to update table object with new data
public void updateLog() {
  try {
    if (logtable != null) { // Only run if the log file have data colums ready for data

      int newId = 0;

      if (logtable.getRowCount()== 0) { // Create new ID if this is the first row to be added
        newId = 1;
      } else { // increment previous ID value
        newId = logtable.getRowCount() + 1;
      }

      //Create new row for new ID, timer and sensor values
      TableRow newRow = logtable.addRow();
      newRow.setInt("id", newId);
      newRow.setString(trim(txtfldSensor0.getText()), str(timer));

      //Determine the number of sensors the user is working with
      // then add each sensor data to the correct column in the new row just created
      if (sensorSelected >= 1) {
        if (!dataType1.getSelectedText().equals("Equation") ) {
          newRow.setString(trim(txtfldSensor1.getText()), trim(txtfld2Sensor1.getText()));
        } else {
          //Result r = Solver.evaluate(trim(txtfldSensor1.getText());
          //newRow.setString(trim(txtfldSensor1.getText()), r.answer.toString());
        }
      }

      if (sensorSelected >= 2) {
        if (!dataType2.getSelectedText().equals("Equation") ) {
          newRow.setString(trim(txtfldSensor2.getText()), trim(txtfld2Sensor2.getText()));
        } else {
          // Result r = Solver.evaluate(trim(txtfldSensor2.getText());
          //newRow.setString(trim(txtfldSensor2.getText()), r.answer.toString());
        }
      }

      if (sensorSelected >= 3) {
        if (!dataType3.getSelectedText().equals("Equation") ) {
          newRow.setString(trim(txtfldSensor3.getText()), trim(txtfld2Sensor3.getText()));
        } else {
          // Result r = Solver.evaluate(trim(txtfldSensor3.getText());
          //newRow.setString(trim(txtfldSensor3.getText()), r.answer.toString());
        }
      }

      if (sensorSelected >= 4) {
        if (!dataType4.getSelectedText().equals("Equation") ) {
          newRow.setString(trim(txtfldSensor4.getText()), trim(txtfld2Sensor4.getText()));
        } else {
          //Result r = Solver.evaluate(trim(txtfldSensor4.getText());
          //newRow.setString(trim(txtfldSensor4.getText()), r.answer.toString());
        }
      }

      if (sensorSelected >= 5) {
        if (!dataType5.getSelectedText().equals("Equation") ) {
          newRow.setString(trim(txtfldSensor5.getText()), trim(txtfld2Sensor5.getText()));
        } else {
          //Result r = Solver.evaluate(trim(txtfldSensor5.getText());
          //newRow.setString(trim(txtfldSensor5.getText()), r.answer.toString());
        }
      }

      if (sensorSelected >= 6) {
        if (!dataType6.getSelectedText().equals("Equation") ) {
          newRow.setString(trim(txtfldSensor6.getText()), trim(txtfld2Sensor6.getText()));
        } else {
          //Result r = Solver.evaluate(trim(txtfldSensor6.getText());
          //newRow.setString(trim(txtfldSensor6.getText()), r.answer.toString());
        }
      }

      // For each new ID created update the settings column with the serial identifier values.
      // Need a better way to do this.. but this should work for now
      switch(newId) {  
      case 1:
        newRow.setString("SETTINGS:", trim(txtfldSValue1.getText()));
        break;

      case 2:
        newRow.setString("SETTINGS:", trim(txtfldSValue2.getText()));
        break;

      case 3:
        newRow.setString("SETTINGS:", trim(txtfldSValue3.getText()));
        break;

      case 4:
        newRow.setString("SETTINGS:", trim(txtfldSValue4.getText()));
        break;

      case 5:
        newRow.setString("SETTINGS:", trim(txtfldSValue5.getText()));
        break;

      case 6:
        newRow.setString("SETTINGS:", trim(txtfldSValue6.getText()));
        break;

      default:
        break;
      }

      //Display the new record if the application is not in live data capture mode
      if (!Activated)
        displayRecord();
    } else {
      println("File is null"+"  "+ System.currentTimeMillis()%10000000);
      error.addLast("Method -> updateLog() Error: No File is open. Cannot Save ;)  "+System.currentTimeMillis()%10000000);
      if (!Activated) {
        int reply = G4P.selectOption(this, "There is no Log file open.\n Do you want to create a New Log file? \n", "Information", G4P.INFO, G4P.YES_NO);

        switch(reply) {
        case G4P.OK:
          newLog();
          break;
        }
      }
    }
  }
  catch (RuntimeException e) {
    println("Method -> updateLog() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> updateLog() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


//Method -> to save table object as a csv file on local computer
public void saveLog() {
  try {
    if (logtable != null) {   // check to see if there is log data in table to save
      if (fname == null) {    // check to see if a log file is open
        if (!Activated)
          fname = G4P.selectOutput("Save As", "csv", "Log files");
        else {
          // Create a Temp log file if the user starts test without first creating a new log file
          fname = ("data/temp/TempLog_"+System.currentTimeMillis()%10000000+".csv");
        }

        if (fname.indexOf(".csv") > 0) {   // check for file extention
          saveTable(logtable, fname, "csv");
          if (!Activated) {
            displayRecord();
          }
        } else {
          fname = (fname +".csv");
          saveTable(logtable, fname, "csv");
          if (!Activated) {
            displayRecord();
          }
        }
      } else {
        saveTable(logtable, fname, "csv");
        if (!Activated) {          
          displayRecord();
        }
      }
    } else {
      if (!Activated) {
        int reply = G4P.selectOption(this, "There is no Log file open."+
          "\n Do you want to create a New Log file? \n", 
        "Information", G4P.INFO, G4P.YES_NO);

        switch(reply) {
        case G4P.OK:
          newLog();
          break;
        }
      } else { 

        //saveTable(logtable, fname, "csv");
      }
    }
  }
  catch(RuntimeException e) {
    println("Method -> saveLog Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> saveLog() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


//Method -> to clear/delete table object contents and display contents
public void deleteLog() {
  try {
    int reply = G4P.selectOption(this, "Are you sure you want to delete log file?", "Warning", G4P.WARNING, G4P.YES_NO);

    switch(reply) {

    case G4P.OK:
      //fname = null;
      textLog.setText("");
      buffer1.clear();
      logtable.clearRows();
      break;
    }
  }
  catch(RuntimeException e) {
    println("Method -> deleteLog() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> deleteLog() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


//Method -> to creat a new table object
public void newLog() {
  try {
    fname = null;
    logtable = new Table();

    logtable.addColumn("id");
    logtable.addColumn(trim(txtfldSensor0.getText()));

    switch(sensorSelected) {
    case 1:
      if (Sensor1Txt && Sensor1SValue) {
        logtable.addColumn(trim(txtfldSensor1.getText()));
        logtable.addColumn("SETTINGS:");
        saveLog();
      } else
        G4P.showMessage(this, "Missing Data Properties Value.", "Error", G4P.ERROR);
      break;

    case 2:
      if (Sensor1Txt && Sensor2Txt && Sensor1SValue && Sensor2SValue ) {
        logtable.addColumn(trim(txtfldSensor1.getText()));
        logtable.addColumn(trim(txtfldSensor2.getText()));  
        logtable.addColumn("SETTINGS:");
        saveLog();
      } else
        G4P.showMessage(this, "Missing Data Properties Value.", "Error", G4P.ERROR);
      break;

    case 3:
      if (Sensor1Txt && Sensor2Txt && Sensor3Txt && Sensor1SValue && 
        Sensor2SValue && Sensor3SValue) {
        logtable.addColumn(trim(txtfldSensor1.getText()));
        logtable.addColumn(trim(txtfldSensor2.getText()));
        logtable.addColumn(trim(txtfldSensor3.getText()));
        logtable.addColumn("SETTINGS:");
        saveLog();
      } else
        G4P.showMessage(this, "Missing Data Properties Value.", "Error", G4P.ERROR);
      break;

    case 4:
      if (Sensor1Txt && Sensor2Txt && Sensor3Txt && Sensor4Txt && Sensor1SValue && 
        Sensor2SValue && Sensor3SValue && Sensor4SValue) {
        logtable.addColumn(trim(txtfldSensor1.getText()));
        logtable.addColumn(trim(txtfldSensor2.getText()));
        logtable.addColumn(trim(txtfldSensor3.getText()));
        logtable.addColumn(trim(txtfldSensor4.getText())); 
        logtable.addColumn("SETTINGS:");
        saveLog();
      } else
        G4P.showMessage(this, "Missing Data Properties Value.", "Error", G4P.ERROR);
      break;

    case 5:
      if (Sensor1Txt && Sensor2Txt && Sensor3Txt && Sensor4Txt && Sensor5Txt &&
        Sensor1SValue && Sensor2SValue && Sensor3SValue && Sensor4SValue && 
        Sensor5SValue) {
        logtable.addColumn(trim(txtfldSensor1.getText()));
        logtable.addColumn(trim(txtfldSensor2.getText()));
        logtable.addColumn(trim(txtfldSensor3.getText()));
        logtable.addColumn(trim(txtfldSensor4.getText()));
        logtable.addColumn(trim(txtfldSensor5.getText()));
        logtable.addColumn("SETTINGS:");
        saveLog();
      } else
        G4P.showMessage(this, "Missing Data Properties Value.", "Error", G4P.ERROR);
      break;

    case 6:
      if (Sensor1Txt && Sensor2Txt && Sensor3Txt && Sensor4Txt && 
        Sensor5Txt && Sensor6Txt && Sensor1SValue && Sensor2SValue && 
        Sensor3SValue && Sensor4SValue && Sensor5SValue && Sensor6SValue) {
        logtable.addColumn(trim(txtfldSensor1.getText()));
        logtable.addColumn(trim(txtfldSensor2.getText()));
        logtable.addColumn(trim(txtfldSensor3.getText()));
        logtable.addColumn(trim(txtfldSensor4.getText()));
        logtable.addColumn(trim(txtfldSensor5.getText()));
        logtable.addColumn(trim(txtfldSensor6.getText()));
        logtable.addColumn("SETTINGS:");
        saveLog();
      } else
        G4P.showMessage(this, "Missing Data Properties Value.", "Error", G4P.ERROR);
      break;
    }

    /*if (!Activated) {
     displayRecord();
     saveLog();
     }*/
  }
  catch(RuntimeException e)
  {
    println("Method -> newLog() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> newLog() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


//Method -> to save picture file to local computer
public void pictureSave() {
  try {
    String pictureFile = G4P.selectOutput("Save As", "SVG", "Picture Export");

    if (pictureFile.indexOf(".svg") > 0) { // check for file extention
      //Do nothing string is ok.
    } else {
      pictureFile = (pictureFile +".svg");
    }

    panel5.setVisible(false);
    zoomTool.setVisible(false);

    noLoop();    
    beginRecord(P8gGraphicsSVG.SVG, pictureFile); 
    background(255);
    refreshPoints();
    displayGraph();
    endRecord(); 
    loop();

    panel5.setVisible(true);
    zoomTool.setVisible(true);
    open(pictureFile);
  }
  catch(RuntimeException e) {
    error.addLast("Method -> pictureSave() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


//Method -> to save pdf file to local computer
public void pdfSave() {
  try {
    String pdfFile = G4P.selectOutput("Save As", ".pdf", "Pdf Export");

    if (pdfFile.indexOf(".pdf") > 0) {                                        // check for file extention
      //Do nothing string is ok.
    } else {
      pdfFile = (pdfFile +".pdf");
    }

    panel5.setVisible(false);
    zoomTool.setVisible(false);

    beginRecord(PDF, pdfFile);
    background(255);
    refreshPoints();
    displayGraph();
    endRecord();

    panel5.setVisible(true);
    zoomTool.setVisible(true);
    open(pdfFile);
  }
  catch(RuntimeException e) {
    error.addLast("Method -> pdfSave() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}// End of Function


public boolean checkString(String s) {
  boolean check = false;
  String[] ch = {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", 
    "j", "k", "l", "m", "n", "o", "p", "q", "r", 
    "s", "t", "u", "v", "w", "x", "y", "z"
  };

  for (int i = 0; i < ch.length; i ++) {
    if (s.indexOf(ch[i]) > 0) {
      check = true;
      //println(ch[i]);
      break;
    }
  }

  return check;
}// End of Function



String serialConfigFile = "data/serialconfig.txt";


//  Method -> to start a serial connection with the Fatigue Tester Control Unit (Model: RR-2015)
public void initSerial() {
  // Check for serial port errors 
  try {
    int selectedPort = 0;
    String[] availablePorts = Serial.list();
    if (availablePorts.length < 1) {
      println("ERROR: No serial ports available!");
      availablePorts = new String[] {
        "None"
      };
    }

    String[] serialConfig = loadStrings(serialConfigFile);

    if (!serialConfig.equals(" ") && serialConfig.length > 0) {
      String savedPort = serialConfig[0];
      // Check if saved port is in available ports.
      for (int i = 0; i < availablePorts.length; ++i) {
        if (availablePorts[i].equals(savedPort)) {
          selectedPort = i;
        }
      }
    } else {
      selectedPort = 0;
    }

    serialList.setItems(availablePorts, selectedPort);
    setSerialPort(serialList.getSelectedText());
  } 
  catch (RuntimeException e) {

    System.out.println("port in use, trying again later ...");
    line = false;
  }
}// End of Function



// Set serial port to desired value.
public void setSerialPort(String portName) {
  try { // Close the port if it's currently open.
    if (port != null) {
      port.stop();
    }

    // Open port.
    port = new Serial(this, portName, baudRate);
    port.bufferUntil('\n');
    // Persist port in configuration.
    saveStrings(serialConfigFile, new String[] {
      portName
    }
    );

    line = true;
    labelStatus.setText("USB CONNECTED");
    labelPort.setText("Serial Port: "+portName);
    println("USB CONNECTED"+"  "+ System.currentTimeMillis()%10000000);
  }
  catch (RuntimeException e) {
    // Swallow error if port can't be opened, keep port closed.
    port = null;

    line = false;
    String message = "USB NOT CONNECTED!";
    labelStatus.setText(message);
    labelPort.setText("null");
    System.out.println(message+"  "+ System.currentTimeMillis()%10000000);
    if (e.getMessage().contains("<init>")) {

      System.out.println("port in use, trying again later ...");
      line = false;
    }
  }
}// End of Function

// Method -> to check the serial connection while application is running
public void serialCheck() {
  try {
    if (line == true) {
      // serial is up and running
      try {
        buffer = port.readString();
        port.bufferUntil('\n');
      } 
      catch (RuntimeException e) {
        // serial port closed :(
        line = false;
        println("Method -> serialCheck1() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
        thread("initSerial");
      }
    } else {
      // serial port is not available. bang on it until it is.
      line = false;
      thread("initSerial");
      //initSerial();
    }
  }
  catch (RuntimeException e)
  {
    // serial port closed :(
    line = false;
    thread("initSerial");
    println("Method -> serialCheck2() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
  }
}// End of Function


// Method -> to recieve data from the serial port
public void serialEvent(Serial p) {

  while (p.available () > 0) {
    try {

      String incoming = p.readStringUntil('\n');
      String[] list = new String[20];

      if ((incoming !=null)) {

        if (incoming.indexOf(" ") > 0) {
          list = split(incoming, " ");
        } else {
          list = split(incoming, ",");
        }

        //Check for timer sync signal time value
        if ( (list.length > 0) && (list[0].equals("TSync:")) ) 
        {
          Tsync = Long.valueOf(list[1]);

          thread("TSync");
          buffer = incoming;
        }


        /////////////////////////////////////////////////////////////////////

        if (!fieldEdit) {
          //Check for Sensor 1 value
          if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue1.getText()))) ) 
          {
            sensor1.addLast(list[1]);

            if ((dataCaptureList.getSelectedText().equals("Variable")) && (sensorMax.getSelectedText() == "1"))
              thread("updateLog");

            buffer = incoming;
          }

          //Check for Sensor 2 value
          if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue2.getText()))) ) 
          {
            sensor2.addLast(list[1]);

            if ((dataCaptureList.getSelectedText().equals("Variable")) && (sensorMax.getSelectedText() == "2"))
              thread("updateLog");

            buffer = incoming;
          }

          //Check for Sensor 3 value
          if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue3.getText()))) ) 
          {
            sensor3.addLast(list[1]);

            if ((dataCaptureList.getSelectedText().equals("Variable")) && (sensorMax.getSelectedText() == "3"))
              thread("updateLog");

            buffer = incoming;
          }

          //Check for Sensor 4 value
          if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue4.getText()))) ) 
          {
            sensor4.addLast(list[1]);

            if ((dataCaptureList.getSelectedText().equals("Variable")) && (sensorMax.getSelectedText() == "4"))
              thread("updateLog");

            buffer = incoming;
          }

          //Check for Sensor 5 value
          if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue5.getText()))) ) 
          {
            sensor5.addLast(list[1]);

            if ((dataCaptureList.getSelectedText().equals("Variable")) && (sensorMax.getSelectedText() == "5"))
              thread("updateLog");

            buffer = incoming;
          }

          //Check for Sensor 6 value
          if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue6.getText()))) ) 
          {
            sensor6.addLast(list[1]);

            if ((dataCaptureList.getSelectedText().equals("Variable")) && (sensorMax.getSelectedText() == "6"))
              thread("updateLog");

            buffer = incoming;
          }
          //////////////////////////////////////////////////////
        }

        /*
      //Check for Control Unit Complete status
         if ( (list.length > 0) && (list[0].equals("Complete:")) ) 
         {
         if (list[1].equals("true")) {
         Complete = true;
         error.addLast("Test Complete = True  "+System.currentTimeMillis()%10000000);
         } else {
         Complete = false;
         }
         
         //println("Complete: "+Complete+"  "+ System.currentTimeMillis()%10000000);
         
         if (plotType.getSelectedIndex()== 0 || plotType.getSelectedIndex()== 1 && Complete)
         {
         thread("updateLog");
         timerAutosave.stop();
         timerLog.stop();
         }
         
         buffer = incoming;
         }
         
         //Check for Activated status
         if ( (list.length > 0) && (list[0].equals("Activated:")) ) 
         {
         if (list[1].equals("true"))
         {
         Activated = true;
         error.addLast("Activated = True  "+System.currentTimeMillis()%10000000);
         } else {
         Activated = false;
         }
         
         //println("Activated: "+Activated+"  "+ System.currentTimeMillis()%10000000);
         
         //L-N Plot - 0
         //S-N Curve - 1
         //None      - 2
         
         if (plotType.getSelectedIndex()== 0 && Activated)
         {
         i = 0;
         
         logtable.clearRows();
         buffer1.clear();
         thread("autoSaveTimer");
         thread("updateLog");
         
         timeInt = Tsync;
         }
         
         if (fname == null && Activated)
         fname = ("data/temp/TempLog_"+System.currentTimeMillis()%10000000+".csv");
         
         buffer = incoming;
         }
         
         //Check for Aborted status
         if ( (list.length > 0) && (list[0].equals("Aborted:")) ) 
         {
         if (list[1].equals("true")) {
         Aborted = true;
         error.addLast("Test Aborted By User -  "+System.currentTimeMillis()%10000000);
         } else {
         Aborted = false;
         }
         
         buffer = incoming;
         //println("Aborted: "+Aborted+"  "+ System.currentTimeMillis()%10000000);
         
         if (plotType.getSelectedIndex()== 0 || plotType.getSelectedIndex()== 1 && Aborted)
         {
         timerLog.stop();
         timerAutosave.stop();
         textLog.setText("");
         logtable.clearRows();
         buffer1.clear();
         }
         
         if (!editEnabled) {
         textfieldMaterial.setTextEditEnabled(true); 
         textfieldDiameter.setTextEditEnabled(true);
         textfieldLength.setTextEditEnabled(true);
         editEnabled = true;
         }
         }
         
         //Check for Reset signal
         if ( (list.length > 0) && (list[0].equals("Reset:")) ) 
         {
         if (list[1].equals("true")) {
         textLog.setText("");
         timer = 0;
         error.addLast("Counter Auto Reset = True -  "+System.currentTimeMillis()%10000000);
         }
         buffer = incoming;
         }
         
         
        /*Communication Handshake
         if ( (list.length > 0) && (list[0].equals("A:")) ) 
         {
         p.write('H');
         buffer = incoming;
         error.addLast("Communication Check = OK -  "+System.currentTimeMillis()%10000000);
         }*/

        buffer = incoming;
      }
      //buffer = incoming;
    }
    catch(RuntimeException e) {
      println("Method -> serialEvent() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
      error.addLast("Method -> serialEvent() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
    }
  }
}// End of Function

public void serialSend() {
  port.write(trim(txtfldSerial.getText())+'\n');  
  error.addLast("Serial Command: "+trim(txtfldSerial.getText())+"  "+System.currentTimeMillis()%10000000);
  txtfldSerial.setText(" ");
}// End of Function





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
      timerLog.setInterval((PApplet.parseInt(dataCaptureList.getSelectedText())*1000));
      interval = PApplet.parseInt(dataCaptureList.getSelectedText());
    }
  }
}// End of Function


public void graphSelect() {
  if (!Activated) {
    timerLog.setInterval((PApplet.parseInt(dataCaptureList.getSelectedText())*1000));

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

  sensorSelected = PApplet.parseInt (sensorMax.getSelectedText ());
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
    baudRate = PApplet.parseInt(baudRateSelect.getSelectedText());
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
  bttnUpdate = new GButton(this, 520, 471, 80, 30);
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
  dataCaptureList = new GDropList(this, 125, 46, 90, 220, 10);
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
  labelBRate = new GLabel(this, 15, 93, 110, 20);
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
  zoom_slider.setLimits(1.0f, 1.0f, 1.0f);
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
  panel4 = new GPanel(controlPanel.papplet, 14, 10, 390, 390, "");
  panel4.setCollapsible(false);
  panel4.setDraggable(false);
  panel4.setLocalColorScheme(GCScheme.YELLOW_SCHEME);
  panel4.setOpaque(true);
  panel4.addEventHandler(this, "panel4_Click2");
  panel6 = new GPanel(controlPanel.papplet, 0, 370, 390, 207, " => System Log");
  panel6.setCollapsed(true);
  panel6.setText(" => System Log");
  panel6.setTextBold();
  panel6.setLocalColorScheme(GCScheme.GOLD_SCHEME);
  panel6.setOpaque(true);
  panel6.addEventHandler(this, "panel6_Click2");
  errorLog = new GTextArea(controlPanel.papplet, 0, 22, 387, 185, G4P.SCROLLBARS_VERTICAL_ONLY | G4P.SCROLLBARS_AUTOHIDE);
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
  txtfldSerial = new GTextField(controlPanel.papplet, 14, 220, 265, 30, G4P.SCROLLBARS_NONE);
  txtfldSerial.setDefaultText("Input Serial Command");
  txtfldSerial.setOpaque(true);
  txtfldSerial.addEventHandler(this, "txtfldSerial_change1");
  bttnSend = new GButton(controlPanel.papplet, 286, 221, 80, 30);
  bttnSend.setText("Send");
  bttnSend.setTextBold();
  bttnSend.addEventHandler(this, "bttnSend_click1");
  panel4.addControl(panel6);
  panel4.addControl(bttnStartTest);
  panel4.addControl(bttnAbortTest);
  panel4.addControl(bttnReset);
  panel4.addControl(txtfldSerial);
  panel4.addControl(bttnSend);
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
GTimer variableTimer; 

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Duino_DCS" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
