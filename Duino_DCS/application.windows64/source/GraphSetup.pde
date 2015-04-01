


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

