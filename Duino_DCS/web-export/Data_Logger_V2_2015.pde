
//
// Software: Arduino Data Logger V2.2015
// Programmer: Vernel Young
// Date of last edit: 2/25/2015
// Released to the public domain
//

/*
Todo:
 1 - Format code to make Versatile
 2 - Improve Zooming
 3 - Improve graph axis auto calculation
 4 - Add features to enable program to calculate
 for different specimen sizes
 */

////////////  External Libraries  /////////////////////////////////////
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
import org.gwoptics.graphics.graph2D.backgrounds.*;
import org.philhosoft.p8g.svg.P8gGraphicsSVG;
///////////////////////////////////////////////////////////////////////



//////////////// Gobal Application Properties  ////////////////////////////

///  Serial Properties
String   ttyPort;
Boolean  line, Complete, Activated, Aborted;
int      j, i;
long     Tsync = 0;
long     timeInt = 0;
int      interval = 0;
int      baudRate = 115200;
//////////////////////////////////////////////////////////////

/// Properties to control general application state
String   timer, fname;
boolean  available = true;
boolean  inputAvailable = true;
boolean  largefile = false;
boolean  clearTextArea = false;
boolean  editEnabled = true;
boolean  menuVisible = true;
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
int      spacingX = 0;
double   OldXvalue = 0;
double   NewXvalue = 0;
String   XAxisDataSet = "Time";

TableRow lastRow;
TableRow XlastCycle;
TableRow XfirstCycle;
int      spacingY=0;

int      Ymin = -20;
float    Ymax = 100;
int      YAccuracy = 2;
int      Yfirstrow = 1;
int      Ylastrow = 1;
double   OldYvalue = 0;
double   NewYvalue = 0;
String   YAxisDataSet = "Temperature (deg)";

// Graph state control properties
boolean  zoomSliderControl = false;
boolean  graphEnd = false;
boolean  graphdraw = false;
boolean  XUp = false;
boolean  XDwn = false;

// Graph objects
Graph2D                  g;
GridBackground           gb;
Line2DTrace              trace1 = new Line2DTrace(new eq1());
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

double[][] dataPlotArray;

////////////////////////////////////////////////////////////


///////////// MAIN APPLICATION CONTROLL CODE  /////////////

// Setup program before running main code
public void setup() {
  try {

    size(780, 700);
    frameRate(240);

    // init gui
    createGUI();
    controlPanel.setVisible(false);
    sensorMaxSelector();

    // setup serial connection
    thread("initSerial");

    //init variables
    timer = "00:00:00";
    Complete = false;
    Activated = false;

    //set various properties
    //controlPanel.setOnTop(false);
    controlPanel.setResizable(false);

    logtable = loadTable("_TestLog4.csv", "header");  //loads sample graph data
    labelDate.setText("Date: "+str(month())+"-"+str(day())+"-"+str(year()));
    bttnUpdate.setVisible(false);
    logtable = loadTable("_TestLog4.csv", "header");  //loads sample graph
    interval = int(dataCaptureList.getSelectedText());

    //setup graph
    graphSetup();
  } 
  catch(RuntimeException e) {
    println("Program Setup Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Program Setup Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}

// Main Control Loop
public void draw() {
  try {
    //frame.setResizable(true);
    background(255);

    // Check to show graph
    if (graphdraw) {
      g.draw();
      panel5.setVisible(true);
      //zoomTool.setVisible(false);
    } else {
      panel1.setVisible(true);
      panel2.setVisible(true);
      panel3.setVisible(true);
      panel5.setVisible(false);
      zoomTool.setVisible(false);
    }

    // controls the rate at which the log display window is refreshed
    if (buffer1.isEmpty()&& Activated)
    {
      j++;
    }

    updatedisplay();
    thread("timerdisplay");

    if (!line) { //If serial connection is broken try to reconnect
      //initSerial();
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
  try {
    timerAutosave.start();
  }
  catch(RuntimeException e) {
    println("Method -> autoSaveTimer() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> autoSaveTimer() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}


// Method -> run as a timer to update the displaying of logged data during live capture
public void timerdisplay() {
  try {

    if (buffer1.isEmpty() && Activated && (j >= 300)) {
      j =0;
      displayRecord();
    }
  }
  catch(RuntimeException e) {
    println("Method -> timerdisplay() Error:"+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> timerdisplay() Error "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}


//  Method -> run as a timer to auto update capture data in the table object
public void TSync() {
  try {
    if (Activated && (Tsync - timeInt) >= (interval))
    {
      timeInt = Tsync;
      labelRate.setText(str(Tsync));
      thread("updateLog");
      thread("updateGraph");
      thread("timerdisplay");

      if (editEnabled) {  // Disables the specimen properties fields
        /* textfieldMaterial.setTextEditEnabled(false); 
         textfieldDiameter.setTextEditEnabled(false);
         textfieldLength.setTextEditEnabled(false);
         editEnabled = false;*/
      }
    }
  }
  catch(RuntimeException e) {
    println("Method -> TSync() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> TSync() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}


// Method -> allows g.generateTrace() to run as a thread during live data capture
public void updateGraph() {
  try {
    if (Activated && !Complete)
      g.generateTrace(g.addTrace(trace1));
  }
  catch(RuntimeException e) {
    println("Method -> updateGraph() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> updateGraph() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}

// Method -> to update the displaying of the live capture date to the screen
public void updatedisplay() {
  try {
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

    if (Complete && !editEnabled) {
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
          /*textfieldMaterial.setTextEditEnabled(true); 
           textfieldDiameter.setTextEditEnabled(true);
           textfieldLength.setTextEditEnabled(true);
           editEnabled = true;*/
        }
      }
    }
  }
  catch(RuntimeException e) {
    println("Method -> updatedisplay() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> updatedisplay() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}

public void delay(int delay)
{
  int time = millis();
  while (millis () - time <= delay);
}




// class to implement the ILine2DEquation with the custom computePoint Method 
// which allows for the plotting of Y axis values against X axis input values
public class eq1 implements ILine2DEquation {

  double Y_Axis_Value = 0;
  double intLoad = 0;

  //  This Method is called by graph2D. Arguement 'x' is the current x axis value, arguement 'pos'
  //  is the location of value 'x' position in pixels
  public double computePoint(double x, int pos) {

    if (logtable.getRowCount() <= 1 || logtable == null) {
      Y_Axis_Value = 0;
    } else { 
      try {

        String Xlabel = "";
        //String Ylabel;
        //int Yticks = 0;
        int Xticks = 0;


        if (!zoomSliderControl) {  //Dont run if zooming

          Xfirstrow = 1;
          Xlastrow = 1;

          //Calculates the exponent value to scale the X axis to
          Xlastrow = logtable.getRowCount()-1;
          String num = str(Xlastrow);
          int num1 = num.length();
          XAccuracy = ceil(num1); // XAxis exponent value


          //Calculates X-axis min value and X-axis max value
          XlastCycle = logtable.findRow(str(Xlastrow), "id");
          XfirstCycle = logtable.findRow(str(Xfirstrow), "id");
          Xmax = XlastCycle.getInt(XAxisDataSet);
          Xmin = XfirstCycle.getInt(XAxisDataSet);

          if (Xmax <= 100)
            XAccuracy = 0;
          if (Xmin < 1)
            Xmin = 0;


          //Calculates Y-axis max value
          Ylastrow = logtable.getRowCount();
          TableRow YmaxLoad = logtable.findRow(str(Ylastrow), "id");
          Ymax = YmaxLoad.getFloat(YAxisDataSet);

          TableRow IntLoad = logtable.findRow(str(1), "id");
          intLoad = IntLoad.getInt(YAxisDataSet);
        }


        if (x <= (1+(Xmin/pow(10, XAccuracy)))) { //limits the amount of times this section runs

          //Determine the spacing between each major y axis value
          spacingY = spacingYCal(Ymax);

          //Determine the spacing between each major x axis value
          spacingX = ceil((Xmax/pow(10, XAccuracy)))/10;

          // Determine the X axis minor tick count & label exponent value to display
          if (  (XAccuracy >2)) { 
            if (spacingX > 3) {
              if (ceil(spacingX/(XAccuracy)) < 2)
                Xticks = 4;
              else
                Xticks = ceil(spacingX/(XAccuracy));

              Xlabel =("(x10^"+XAccuracy+")");
            } else {
              if (XAccuracy == 3 && logtable.getRowCount() > 500 || (Xmax/pow(10, XAccuracy)) >11 ) {
                spacingX = 4;
              } else {
                spacingX = 1;
              }

              if (ceil(spacingX/(XAccuracy)) < 2)
                Xticks = 4;
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
                Xticks = 4;
              else
                Xticks = ceil(spacingX/(XAccuracy));
            }
            if (zoomSliderControl && logtable.getRowCount() <= 500) {
              if (ceil(spacingX/(XAccuracy)) < 2)
                Xticks = 4;
              else
                Xticks = ceil(spacingX/(XAccuracy));
              spacingX = 1;
            }
          }


          if (XAccuracy <= 2) {

            if (ceil(spacingX/(XAccuracy)) < 2)
              Xticks = 4;
            else
              Xticks = ceil(spacingX/(XAccuracy));

            Xlabel = ("(x10^"+XAccuracy+")");
            spacingX = 1;

            if (logtable.getRowCount() > 50 || (Xmax/pow(10, XAccuracy)) >11) {
              spacingX = 4;
            } else {
              spacingX = 1;
            }

            if (XAccuracy == 1) {
              Xlabel = ("(x10)");
              spacingX = 2;
            }
          }

          // Determine the maximum value to display on the X axis
          // in multiples of ten
          if (!zoomSliderControl && !Activated) {
            g.setXAxisMax((Xmax/pow(10, XAccuracy))+ 0.5);
            g.setXAxisMin(Xmin/pow(10, XAccuracy)+0.1);
          } else {

            // Overide above value if zoom is enabled
            if ( (!XUp || !XDwn) && graphEnd || !Activated)//
              g.setXAxisMax(Xmax/pow(10, XAccuracy)+0.5);
            else
              g.setXAxisMax(Xmax/pow(10, XAccuracy));
          }


          // Set the above calculated X & Y axis values
          g.setXAxisMinorTicks(Xticks);
          g.setXAxisLabel(XAxisDataSet+" "+Xlabel);
          g.setYAxisTickSpacing(spacingY);
          g.setXAxisTickSpacing(spacingX);
        }

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

            NewYvalue = row.getFloat(YAxisDataSet);
            NewXvalue = x;

            if ((effectList.getSelectedIndex() == 0)) {

              if (x >= currentCount) {  //
                //Return the Y Axis value of the current row
                Y_Axis_Value = row.getFloat(YAxisDataSet);
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
                float smthFactor = 0.1;
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
          if (row.getInt("id") <= 2)
            Y_Axis_Value = intLoad;
        }
        ///////////////// End of Loop ////////////////
      }
      catch(RuntimeException e) {
        println("Method -> computePoint() Error: "+"  "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
        error.addLast("Method -> computePoint() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
      }
    }

    OldXvalue = X;
    OldYvalue = NewYvalue;


    return Y_Axis_Value;
  }
}


// Method -> to setup general graph axis values and other graph settings
public void graphSetup() {

  try {
    // Graph2D object, arguments are 
    // the parent object, xsize, ysize, cross axes at zero point
    g = new Graph2D(this, 620, 620, true); 

    // setting attributes for the X and Y-Axis
    g.setYAxisMin(-15);
    g.setYAxisMax(95);
    g.setXAxisMin(1);
    g.setXAxisMax(Xmax);
    g.setXAxisLabel(XAxisDataSet);
    g.setYAxisLabel(YAxisDataSet);
    g.setXAxisLabelAccuracy(0);
    g.setYAxisLabelAccuracy(0);
    g.setXAxisTickSpacing(Xmax/10);
    g.setYAxisTickSpacing(10);
    g.setYAxisMinorTicks(4);
    g.setXAxisMinorTicks(4);

    Axis2D ax=g.getXAxis();
    ax.setLabelOffset(70);

    Axis2D ay=g.getYAxis();
    ay.setLabelOffset(20);


    // switching of the border, and changing the label positions
    g.setNoBorder(); 
    g.setXAxisLabelPos(LabelPos.MIDDLE);
    g.setYAxisLabelPos(LabelPos.MIDDLE);

    // switching on Grid, with differet colours for X and Y lines
    gb = new  GridBackground(new GWColour(255));
    gb.setGridColour(200, 100, 200, 180, 180, 180);
    g.setBackground(gb);

    // graph position within the main window
    g.position.y = 30;
    g.position.x = 100;

    trace1.setTraceColour(255, 0, 0);
    trace1.setLineWidth(1);
    g.addTrace(trace1);
    //println("trace1 Index: "+g.addTrace(trace1));
  }
  catch(RuntimeException e) {
    println("Method -> graphSetup() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> graphSetup() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}


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

public int spacingYCal(float Ymax) {
  int Y = 0;

  if (zoomSliderControl)
    Ymax = 0;

  for (int i = XfirstCycle.getInt ("id"); i <= XlastCycle.getInt("id"); i++ ) {
    lastRow = logtable.findRow(str(i), "id");

    if (lastRow.getInt(YAxisDataSet)>Ymax)
      Ymax = lastRow.getInt(YAxisDataSet);
  }

  for (int i=100; i<=1000; i+=100) {
    if (floor(Ymax) <= (i)) {
      Y = i/10;
      g.setYAxisMax(Ymax+(Y+5));
      Axis2D ax=g.getXAxis();
      ax.setLabelOffset(75-Y);
      break;
    }
  }

  return Y;
}

public float _Float(double x) {
  return Float.valueOf((String.valueOf(x)));
}


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

      textLog.setText("");
      buffer1.clear();
      available = true;

      logtable = loadTable(fname, "header");
      String[] tableHeader = logtable.getColumnTitles();

      sensorMax.setSelected(tableHeader.length-3);
      sensorMaxSelector();

      for (int i = 0; i < tableHeader.length; i++) {
        //print(tableHeader[i]+" ");
        switch(i) {

        case 2:
          txtfldSensor1.setText(tableHeader[i]);
          label10.setText(tableHeader[i]);
          break;  
        case 3:
          txtfldSensor2.setText(tableHeader[i]);
          label21.setText(tableHeader[i]);
          break;
        case 4:
          txtfldSensor3.setText(tableHeader[i]);
          label22.setText(tableHeader[i]);
          break;
        case 5:
          txtfldSensor4.setText(tableHeader[i]);
          label3.setText(tableHeader[i]);
          break;
        case 6:
          txtfldSensor5.setText(tableHeader[i]);
          label8.setText(tableHeader[i]);
          break;
        case 7:
          txtfldSensor6.setText(tableHeader[i]);
          label13.setText(tableHeader[i]);
          break;
        }
      }
      //println("");


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
}


public void message() {
  G4P.showMessage(this, "Displaying a Large File. \nTotal Records in log: "+
    logtable.getRowCount()+'\n', "File Info", G4P.INFO);
}

//Method -> to load data from table object to display on screen
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

      dataPlotArray = new double[logtable.getRowCount()][7];
      String sensor1Data, sensor2Data, sensor3Data, sensor4Data, sensor5Data, sensor6Data;
      String space = "  |  ";
      String space1 = "              ";

      for (TableRow row : logtable.rows ()) {

        int id = row.getInt("id");
        int Time = row.getInt("Time");


        dataPlotArray[id-1][0] = Double.valueOf(Time);

        line = (nf(id, 4) + space + nf(int(Time), 6));

        if (sensorSelected >= 1) {
          sensor1Data = row.getString(trim(txtfldSensor1.getText()));
          if (checkString(sensor1Data))
            dataType1.setSelected(2);

          if (!dataType1.getSelectedText().equals("String") || !checkString(sensor1Data) ) {
            dataPlotArray[id-1][1] = Double.valueOf(sensor1Data);
          } else {
            dataPlotArray[id-1][1] = 0;
          }

          if (dataType1.getSelectedText().equals("Int"))
            line = line + space + (nf(int(sensor1Data), 6));

          if (dataType1.getSelectedText().equals("Float"))
            line = line + space + (nf(float(sensor1Data), 4, 2)) ;

          if (dataType1.getSelectedText().equals("String")) {
            line = line + space + space1; //String.format("%6s", sensor1Data)
          }
        }

        if (sensorSelected >= 2) {
          sensor2Data = row.getString(trim(txtfldSensor2.getText()));

          if (checkString(sensor2Data))
            dataType2.setSelected(2);

          if (!dataType2.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][2] = Double.valueOf(sensor2Data);
          } else {
            dataPlotArray[id-1][2] = 0;
          }

          if (dataType2.getSelectedText().equals( "Int"))
            line = line + space +(nf(int(sensor2Data), 6));

          if (dataType2.getSelectedText().equals( "Float"))
            line = line + space +(nf(float(sensor2Data), 4, 2)) ;

          if (dataType2.getSelectedText().equals( "String"))
            line = line + space +space1;
        }

        if (sensorSelected >= 3) {
          sensor3Data = row.getString(trim(txtfldSensor3.getText()));

          if (checkString(sensor3Data))
            dataType3.setSelected(2);

          if (!dataType3.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][3] = Double.valueOf(sensor3Data);
          } else {
            dataPlotArray[id-1][3] = 0;
          }

          if (dataType3.getSelectedText() .equals("Int"))
            line = line + space +(nf(int(sensor3Data), 6));

          if (dataType3.getSelectedText() .equals("Float"))
            line = line + space +(nf(float(sensor3Data), 4, 2)) ;

          if (dataType3.getSelectedText() .equals("String"))
            line = line + space + space1;
        }

        if (sensorSelected >= 4) {
          sensor4Data = row.getString(trim(txtfldSensor4.getText()));

          if (checkString(sensor4Data))
            dataType4.setSelected(2);

          if (!dataType4.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][4] = Double.valueOf(sensor4Data);
          } else {
            dataPlotArray[id-1][4] = 0;
          }

          if (dataType4.getSelectedText() .equals("Int"))
            line = line + space +(nf(int(sensor4Data), 6));

          if (dataType4.getSelectedText() .equals("Float"))
            line = line + space +(nf(float(sensor4Data), 3, 2)) ;

          if (dataType4.getSelectedText() .equals("String"))
            line = line + space +space1;
        }

        if (sensorSelected >= 5) {
          sensor5Data = row.getString(trim(txtfldSensor4.getText()));

          if (checkString(sensor5Data))
            dataType5.setSelected(2);

          if (!dataType5.getSelectedText().equals("String")) {
            dataPlotArray[id-1][5] = Double.valueOf(sensor5Data);
          } else {
            dataPlotArray[id-1][5] = 0;
          }

          if (dataType5.getSelectedText() .equals("Int"))
            line = line + space + (nf(int(sensor5Data), 6));

          if (dataType5.getSelectedText() .equals("Float"))
            line = line + space +(nf(float(sensor5Data), 3, 2)) ;

          if (dataType5.getSelectedText() .equals("String"))
            line = line + space + space1;
        }

        if (sensorSelected >= 6) {      
          sensor6Data = row.getString(trim(txtfldSensor6.getText()));

          if (checkString(sensor6Data))
            dataType6.setSelected(2);

          if (!dataType6.getSelectedText().equals("String")) {
            dataPlotArray[id-1][6] = Double.valueOf(sensor6Data);
          } else {
            dataPlotArray[id-1][6] = 0;
          }

          if (dataType6.getSelectedText() .equals("Int"))
            line = line + space +(nf(int(sensor6Data), 6));

          if (dataType6.getSelectedText() .equals("Float"))
            line = line + space + (nf(float(sensor6Data), 3, 2)) ;

          if (dataType6.getSelectedText() .equals("String"))
            line = line + space + space1;
        }

        line = line +'\n'+"--------------------------------------------------"+
          "--------------------------------------------------------------"+'\n';

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
      labelInfo.setText("Total Records in File: "+logtable.getRowCount());
    }
    catch (RuntimeException e) {
      println("Method -> displayRecord() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
      error.addLast("Method -> displayRecord() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
      G4P.showMessage(this, "Missing or incorrect Data Series value.\n"+e.getMessage(), "Error", G4P.ERROR);
    }
  }
}

//Method -> to update table object with new data
public void updateLog() {
  try {
    if (logtable != null) {
      int newId = 0;
      if (logtable.getRowCount()== 0) {
        newId = 1;
      } else { 
        newId = logtable.getRowCount() + 1;
      }

      TableRow newRow = logtable.addRow();
      newRow.setInt("id", newId);
      newRow.setString("Time", timer);

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
}

//Method -> to save table object as a csv file on local computer
public void saveLog() {
  try {
    if (logtable != null) {                                                     // check to see if there is log data in table to save
      if (fname == null) {        // check to see if a log file is open
        if (!Activated)
          fname = G4P.selectOutput("Save As", "csv", "Log files");
        else {
          // Create a Temp log file if the user starts test without first creating a new log file
          fname = ("data/temp/TempLog_"+System.currentTimeMillis()%10000000+".csv");
        }

        if (fname.indexOf(".csv") > 0) {                                        // check for file extention
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
}

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
      //textfieldDiameter.setText("4.08");
      //textfieldMaterial.setText("Steel (RF1010)");
      //textfieldLength.setText("28.0");
      break;
    }
  }
  catch(RuntimeException e) {
    println("Method -> deleteLog() Error: "+e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
    error.addLast("Method -> deleteLog() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}

//Method -> to creat a new table object
public void newLog() {
  try {
    fname = null;
    logtable = new Table();

    logtable.addColumn("id");
    logtable.addColumn("Time");

    switch(sensorSelected) {
    case 1:
      if (Sensor1Txt && Sensor1SValue) {
        logtable.addColumn(trim(txtfldSensor1.getText()));
        saveLog();
      } else
        G4P.showMessage(this, "Missing Data Properties Value.", "Error", G4P.ERROR);
      break;

    case 2:
      if (Sensor1Txt && Sensor2Txt && Sensor1SValue && Sensor2SValue ) {
        logtable.addColumn(trim(txtfldSensor1.getText()));
        logtable.addColumn(trim(txtfldSensor2.getText()));
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
}

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
    g.generateTrace(g.addTrace(trace1));
    g.draw();
    endRecord(); 
    loop();

    panel5.setVisible(true);
    zoomTool.setVisible(true);
    open(pictureFile);
  }
  catch(RuntimeException e) {
    error.addLast("Method -> pictureSave() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}

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
    g.generateTrace(g.addTrace(trace1));
    g.draw();
    endRecord();

    panel5.setVisible(true);
    zoomTool.setVisible(true);
    open(pdfFile);
  }
  catch(RuntimeException e) {
    error.addLast("Method -> pdfSave() Error: "+e.getMessage()+"  "+System.currentTimeMillis()%10000000);
  }
}

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
}


//  Method -> to start a serial connection with the Fatigue Tester Control Unit (Model: RR-2015)
public void initSerial() {
  // Check for serial port errors
  try {
    ttyPort = Serial.list()[0];
    println("Serial: "+ttyPort);
    port = new Serial(this, ttyPort, baudRate);
    port.bufferUntil('\n');
    line = true;
    labelPort.setText("Serial Port: "+ttyPort);
    labelStatus.setText("USB CONNECTED");
    println("USB CONNECTED"+"  "+ System.currentTimeMillis()%10000000);
  } 
  catch (RuntimeException e) {
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
}

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
}


// Method -> to recieve Fatigue Tester Control Unit (Model: RR-2015) 
// data from the serial port
public void serialEvent(Serial p) 
{
  try {

    String incoming = p.readStringUntil('\n');
    String[] list;

    if ((incoming !=null)) {

      if (incoming.indexOf(",") > 0) {
        list = split(incoming, ",");
      } else {
        list = split(incoming, " ");
      }

      //Check for timer sync signal time value
      if ( (list.length > 0) && (list[0].equals("TSync:")) ) 
      {
        Tsync = Long.valueOf(list[1]);

        thread("TSync");
        buffer = incoming;
      }


      /////////////////////////////////////////////////////////////////////

      //Check for Sensor 1 value
      if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue1.getText()))) ) 
      {
        txtfld2Sensor1.setText(list[1]);

        if ((dataCaptureList.getSelectedText()=="Variable") && (sensorMax.getSelectedText() == "1"))
          thread("TSync");

        buffer = incoming;
      }

      //Check for Sensor 2 value
      if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue2.getText()))) ) 
      {
        txtfld2Sensor2.setText(list[1]);

        if ((dataCaptureList.getSelectedText()=="Variable") && (sensorMax.getSelectedText() == "2"))
          thread("TSync");

        buffer = incoming;
      }

      //Check for Sensor 3 value
      if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue3.getText()))) ) 
      {
        txtfld2Sensor3.setText(list[1]);

        if ((dataCaptureList.getSelectedText()=="Variable") && (sensorMax.getSelectedText() == "3"))
          thread("TSync");

        buffer = incoming;
      }

      //Check for Sensor 4 value
      if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue4.getText()))) ) 
      {
        txtfld2Sensor4.setText(list[1]);

        if ((dataCaptureList.getSelectedText()=="Variable") && (sensorMax.getSelectedText() == "4"))
          thread("TSync");

        buffer = incoming;
      }

      //Check for Sensor 5 value
      if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue5.getText()))) ) 
      {
        txtfld2Sensor5.setText(list[1]);

        if ((dataCaptureList.getSelectedText()=="Variable") && (sensorMax.getSelectedText() == "5"))
          thread("TSync");

        buffer = incoming;
      }

      //Check for Sensor 6 value
      if ( (list.length > 0) && (list[0].equals(trim(txtfldSValue6.getText()))) ) 
      {
        txtfld2Sensor6.setText(list[1]);

        if ((dataCaptureList.getSelectedText()=="Variable") && (sensorMax.getSelectedText() == "6"))
          thread("TSync");

        buffer = incoming;
      }
      //////////////////////////////////////////////////////



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
          /*  textfieldMaterial.setTextEditEnabled(true); 
           textfieldDiameter.setTextEditEnabled(true);
           textfieldLength.setTextEditEnabled(true);*/
          editEnabled = true;
        }
      }

      //Check for Reset signal
      if ( (list.length > 0) && (list[0].equals("Reset:")) ) 
      {
        if (list[1].equals("true")) {
          textLog.setText("");
          timer ="00:00:00";
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





public void about() {
  G4P.showMessage(this, "This program was created by: "+ 
    "Vernel Young \n Email: lennrev@gmail.com", 
  "About", G4P.PLAIN);
}


public void resetUSB() {
  if (!Activated) {
    G4P.showMessage(this, "Please unplug USB, press OK then replug your \n"+ 
      "USB cable to RESET Serial Connection", "Information", G4P.INFO);
    port.clear();
    port.stop();
    serialCheck();
    thread("initSerial");
  }
}


public void showGraph() {
  panel1.setVisible(false);
  panel2.setVisible(false);
  panel3.setVisible(false);
  panel5.setVisible(true);
  zoomTool.setVisible(true);

  if (!error.isEmpty())
    errorLog.appendText(error.removeFirst());

  g.generateTrace(g.addTrace(trace1));
  graphdraw = true;
}


public void showMain() {
  if (Complete) {
    displayRecord();
    updatedisplay();
  }

  if (!error.isEmpty())
    errorLog.appendText(error.removeFirst());

  zoomSliderControl = false;
  graphdraw=false;
  zoomList.setSelected(0);
}


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
}


public void graphSelect() {
  if (!Activated) {
    timerLog.setInterval((int(dataCaptureList.getSelectedText())*1000));

    switch(plotType.getSelectedIndex()) {
    case 0:
      bttnUpdate.setVisible(false);
      bttnShowgraph.setVisible(true);
      break;
    case 1:
      G4P.showMessage(this, "This feature was not implemented in this release. \nSelect a different option.", "Info", G4P.INFO);
      bttnShowgraph.setVisible(false);
      bttnUpdate.setVisible(true);
      break;
    case 2:
      bttnShowgraph.setVisible(false);
      bttnUpdate.setVisible(true);
      break;
    default:
      break;
    }
  }
}


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
    Xmax = XlastCycle.getInt(YAxisDataSet);
    Xmin = XfirstCycle.getInt(YAxisDataSet);

    zoomSliderControl = false;
    g.setXAxisMin(0);
    g.generateTrace(g.addTrace(trace1));
  }
}


public void zoomUp() {
  if (!Activated) { 
    if (spacingX < 10)
      spacingX = 10;
    XAxisUp += spacingX; 
    XUp = true;
    thread("zoom");
  }
}


public void zoomDwn() {
  if (!Activated) { 
    if (spacingX < 10)
      spacingX = 10;
    XAxisdwn += spacingX;
    XDwn = true;
    thread("zoom");
  }
}


public void startCapture() {
  int reply = G4P.selectOption(this, "Do you want to begin Capture?"+
    "\nPress YES to Continue or No to Cancel", "Warning", G4P.WARNING, G4P.YES_NO);
  switch(reply) {
  case G4P.YES:

    Activated = true;
    //port.write('S');

    if (plotType.getSelectedIndex()== 0 && Activated)
    {
      i = 0;

      logtable.clearRows();
      buffer1.clear();
      thread("autoSaveTimer");
      thread("updateLog");
      timerLog.start();
      timeInt = Tsync;
    }

    break;
  }
}

public void endCapture() {
  int reply = G4P.selectOption(this, "Do you want to Stop Capture?"+
    "\nPress YES to Continue or No to Cancel", "Warning", G4P.WARNING, G4P.YES_NO);
  switch(reply) {
  case G4P.YES:
    if (Activated) {
      //port.write('B');
      timerLog.stop();
      timerAutosave.stop();
      Activated = false;
      Complete = true;
    }
    break;
  }
}


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
}

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
}


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
}

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
  if (txtfldSValue1.getText().compareTo(" ") < 1)
    Sensor1SValue = false;
  else
    Sensor1SValue = true;
  updateLabel();
} //_CODE_:txtfldSValue1:233262:

public void txtfldSValue3_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue3:378274:
  println("textfield2 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue3.getText() .compareTo(" ") < 1 )
    Sensor3SValue = false;
  else
    Sensor3SValue = true;
  updateLabel();
} //_CODE_:txtfldSValue3:378274:

public void txtfldSValue2_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue2:774609:
  println("textfield3 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue2.getText() .compareTo(" ") < 1 )
    Sensor2SValue = false;
  else
    Sensor2SValue = true;
  updateLabel();
} //_CODE_:txtfldSValue2:774609:

public void option1_clicked1(GOption source, GEvent event) { //_CODE_:option1:810704:
  println("option1 - GOption event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:option1:810704:

public void option2_clicked1(GOption source, GEvent event) { //_CODE_:option2:693902:
  println("option2 - GOption event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:option2:693902:

public void option3_clicked1(GOption source, GEvent event) { //_CODE_:option3:498561:
  println("option3 - GOption event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:option3:498561:

public void option4_clicked1(GOption source, GEvent event) { //_CODE_:option4:639658:
  println("option4 - GOption event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:option4:639658:

public void option5_clicked1(GOption source, GEvent event) { //_CODE_:option5:368559:
  println("option5 - GOption event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:option5:368559:

public void option6_clicked1(GOption source, GEvent event) { //_CODE_:option6:460484:
  println("option6 - GOption event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:option6:460484:

public void option7_clicked1(GOption source, GEvent event) { //_CODE_:option7:366940:
  println("option7 - GOption event occured " + System.currentTimeMillis()%10000000 );
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

public void checkbox1_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox1:520485:
  println("checkbox1 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:checkbox1:520485:

public void checkbox2_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox2:519786:
  println("checkbox2 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:checkbox2:519786:

public void checkbox3_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox3:959938:
  println("checkbox3 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:checkbox3:959938:

public void checkbox4_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox4:213151:
  println("checkbox4 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:checkbox4:213151:

public void checkbox6_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox6:611576:
  println("checkbox5 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:checkbox6:611576:

public void checkbox7_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox7:638228:
  println("checkbox6 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:checkbox7:638228:

public void checkbox5_clicked1(GCheckbox source, GEvent event) { //_CODE_:checkbox5:483634:
  println("checkbox7 - GCheckbox event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:checkbox5:483634:

public void txtfldSensor1_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor1:503979:
  println("txtfldSensor1 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor1.getText() .compareTo(" ") < 1 )
    Sensor1Txt = false;
  else
    Sensor1Txt = true;
} //_CODE_:txtfldSensor1:503979:

public void txtfldSensor2_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor2:799399:
  println("txtfldSensor2 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor2.getText() .compareTo(" ") < 1 )
    Sensor2Txt = false;
  else
    Sensor2Txt = true;
} //_CODE_:txtfldSensor2:799399:

public void txtfldSensor3_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor3:939079:
  println("txtfldSensor3 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor3.getText() .compareTo(" ") < 1 )
    Sensor3Txt = false;
  else
    Sensor3Txt = true;
} //_CODE_:txtfldSensor3:939079:

public void txtfldSensor4_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor4:435714:
  println("txtfldSensor4 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor4.getText() .compareTo(" ") < 1 )
    Sensor4Txt = false;
  else
    Sensor4Txt = true;
} //_CODE_:txtfldSensor4:435714:

public void txtfldSensor5_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor5:283009:
  println("txtfldSensor5 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor5.getText() .compareTo(" ") < 1 )
    Sensor5Txt = false;
  else
    Sensor5Txt = true;
} //_CODE_:txtfldSensor5:283009:

public void txtfldSensor6_change(GTextField source, GEvent event) { //_CODE_:txtfldSensor6:645507:
  println("txtfldSensor6 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSensor6.getText() .compareTo(" ") < 1 )
    Sensor6Txt = false;
  else
    Sensor6Txt = true;
} //_CODE_:txtfldSensor6:645507:

public void txtfldSValue4_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue4:572591:
  println("txtfldSValue4 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue4.getText() .compareTo(" ") < 1 )
    Sensor4SValue = false;
  else
    Sensor4SValue = true;
  updateLabel();
} //_CODE_:txtfldSValue4:572591:

public void txtfldSValue5_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue5:875329:
  println("txtfldSValue5 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue5.getText() .compareTo(" ") < 1 )
    Sensor5SValue = false;
  else
    Sensor5SValue = true;
  updateLabel();
} //_CODE_:txtfldSValue5:875329:

public void txtfldSValue6_change(GTextField source, GEvent event) { //_CODE_:txtfldSValue6:268716:
  println("txtfldSValue6 - GTextField event occured " + System.currentTimeMillis()%10000000 );
  if (txtfldSValue6.getText() .compareTo(" ") < 1 )
    Sensor6SValue = false;
  else
    Sensor6SValue = true;
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

public void bttnSettingSave_click1(GButton source, GEvent event) { //_CODE_:bttnSettingSave:943838:
  println("bttnSettingSave - GButton event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:bttnSettingSave:943838:

public void settingsRestore_click3(GDropList source, GEvent event) { //_CODE_:settingsRestore:812839:
  println("settingsRestore - GDropList event occured " + System.currentTimeMillis()%10000000 );
} //_CODE_:settingsRestore:812839:

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

  try {
    TSync();
  }
  catch(RuntimeException e) {
    println(e.getMessage()+"  "+ System.currentTimeMillis()%10000000);
  }
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



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  if(frame != null)
    frame.setTitle("Duino Data Capture Software V2.2015 x64");
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
  txtfld2Sensor2.setDefaultText("0");
  txtfld2Sensor2.setOpaque(true);
  txtfld2Sensor2.addEventHandler(this, "txtfld2Sensor2_change1");
  labelSensor1 = new GLabel(this, 144, 29, 90, 20);
  labelSensor1.setText("-");
  labelSensor1.setTextBold();
  labelSensor1.setOpaque(true);
  txtfld2Sensor1 = new GTextField(this, 234, 29, 90, 20, G4P.SCROLLBARS_NONE);
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
  txtfld2Sensor3.setDefaultText("0");
  txtfld2Sensor3.setOpaque(true);
  txtfld2Sensor3.addEventHandler(this, "txtfld2Sensor3_change");
  labelSensor4 = new GLabel(this, 143, 70, 90, 20);
  labelSensor4.setText("-");
  labelSensor4.setTextBold();
  labelSensor4.setOpaque(true);
  txtfld2Sensor4 = new GTextField(this, 234, 70, 90, 20, G4P.SCROLLBARS_NONE);
  txtfld2Sensor4.setDefaultText("0");
  txtfld2Sensor4.setOpaque(true);
  txtfld2Sensor4.addEventHandler(this, "txtfld2Sensor4_change1");
  labelSensor5 = new GLabel(this, 346, 69, 90, 20);
  labelSensor5.setText("-");
  labelSensor5.setTextBold();
  labelSensor5.setOpaque(true);
  txtfld2Sensor5 = new GTextField(this, 437, 69, 90, 20, G4P.SCROLLBARS_NONE);
  txtfld2Sensor5.setDefaultText("0");
  txtfld2Sensor5.setOpaque(true);
  txtfld2Sensor5.addEventHandler(this, "txtfld2Sensor5_change2");
  labelSensor6 = new GLabel(this, 552, 68, 90, 20);
  labelSensor6.setText("-");
  labelSensor6.setTextBold();
  labelSensor6.setOpaque(true);
  txtfld2Sensor6 = new GTextField(this, 643, 68, 90, 20, G4P.SCROLLBARS_NONE);
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
  txtfldSValue1.setOpaque(true);
  txtfldSValue1.addEventHandler(this, "txtfldSValue1_change");
  txtfldSValue3 = new GTextField(this, 219, 108, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue3.setText("-");
  txtfldSValue3.setOpaque(true);
  txtfldSValue3.addEventHandler(this, "txtfldSValue3_change");
  txtfldSValue2 = new GTextField(this, 219, 88, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue2.setText("-");
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
  txtfldSensor0.setText("Time (Sec)");
  txtfldSensor0.setOpaque(true);
  txtfldSensor0.addEventHandler(this, "txtfldSensor0_change");
  checkbox1 = new GCheckbox(this, 431, 50, 30, 20);
  checkbox1.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  checkbox1.setOpaque(false);
  checkbox1.addEventHandler(this, "checkbox1_clicked1");
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
  txtfldSValue4.setOpaque(true);
  txtfldSValue4.addEventHandler(this, "txtfldSValue4_change");
  txtfldSValue5 = new GTextField(this, 219, 148, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue5.setText("-");
  txtfldSValue5.setOpaque(true);
  txtfldSValue5.addEventHandler(this, "txtfldSValue5_change");
  txtfldSValue6 = new GTextField(this, 219, 168, 100, 20, G4P.SCROLLBARS_NONE);
  txtfldSValue6.setText("-");
  txtfldSValue6.setOpaque(true);
  txtfldSValue6.addEventHandler(this, "txtfldSValue6_change");
  labelRate = new GLabel(this, 219, 46, 170, 20);
  labelRate.setText("----");
  labelRate.setOpaque(false);
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
  properties.addControl(checkbox1);
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
  dataCaptureList.setItems(loadStrings("list_769263"), 1);
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
  labelEndTime = new GLabel(this, 16, 117, 110, 20);
  labelEndTime.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  labelEndTime.setText("Select Time Period");
  labelEndTime.setTextItalic();
  labelEndTime.setOpaque(false);
  endTime = new GDropList(this, 125, 119, 90, 154, 7);
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
  bttnSettingSave = new GButton(this, 134, 0, 80, 19);
  bttnSettingSave.setText("Save Settings");
  bttnSettingSave.setLocalColorScheme(GCScheme.ORANGE_SCHEME);
  bttnSettingSave.addEventHandler(this, "bttnSettingSave_click1");
  label9 = new GLabel(this, 16, 174, 110, 20);
  label9.setTextAlign(GAlign.LEFT, GAlign.MIDDLE);
  label9.setText("Restore Settings");
  label9.setTextBold();
  label9.setTextItalic();
  label9.setOpaque(false);
  settingsRestore = new GDropList(this, 125, 175, 90, 220, 10);
  settingsRestore.setItems(loadStrings("list_812839"), 0);
  settingsRestore.addEventHandler(this, "settingsRestore_click3");
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
  settings.addControl(bttnSettingSave);
  settings.addControl(label9);
  settings.addControl(settingsRestore);
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
  panel4 = new GPanel(controlPanel.papplet, 10, 10, 390, 390, "");
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
  panel4.addControl(panel6);
  panel4.addControl(bttnStartTest);
  panel4.addControl(bttnAbortTest);
  panel4.addControl(bttnReset);
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
GCheckbox checkbox1; 
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
GButton bttnSettingSave; 
GLabel label9; 
GDropList settingsRestore; 
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


