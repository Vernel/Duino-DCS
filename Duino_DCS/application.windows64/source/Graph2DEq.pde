
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
        g.setXAxisMax((Xmax/pow(10, XAccuracy))+ 0.5);
        g.setXAxisMin(Xmin/pow(10, XAccuracy));
      } else {

        // Overide above value if zoom is enabled
        if ( (!XUp || !XDwn) && graphEnd || !Activated)//
          g.setXAxisMax(Xmax/pow(10, XAccuracy)+0.5);
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

