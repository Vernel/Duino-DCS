
public class GraficaPlot {
  int oldRecord;
  float gcx, gcy, gcw;
  float zf = 1.1, czf = 1.0;
  boolean update;

  void setup(GPlot plot, int pos) {
    float[] firstPlotPos = new float[] {
      0, 0
    };

    float[] panelDim = new float[] {
      200, 200
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
      plot4.setPos(450, 350);
      plot4.setMar(margins[0], 0, 0, margins[3]);
      plot4.setDim(panelDim1);
      break;

    case 6: // Top Left 6Position
      plot.setPos(firstPlotPos);
      //Margins: bottom,left, top, right
      plot.setMar(0, margins[1], margins[3], 0);
      plot.setDim(panelDim);
      break;

    case 7: // Top Middle 6Position
      plot.setPos(firstPlotPos);
      //Margins: bottom,left, top, right
      plot.setMar(0, margins[1], margins[3], 0);
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

  void zoomOut(GPlot plot) {
    float[] idim = plot.getDim();
    float[] mar = plot.getMar();
    gcx = idim[0]/2 + mar[1];
    gcy = idim[1]/2 + mar[2];
    gcw = idim[0];
    plot.zoom(1/zf, gcx, gcy);
  }
  void zoomIn(GPlot plot) {
    float[] idim = plot.getDim();
    float[] mar = plot.getMar();
    gcx = idim[0]/2 + mar[1];
    gcy = idim[1]/2 + mar[2];
    gcw = idim[0];
    plot.zoom(zf, gcx, gcy);
  }

  void updatePoints(GPlot plot, GPointsArray points, int XDataSet, int YDataSet, String XAxisLabel, String YAxisLabel) {
    int records = dataPlotArray.length;  

    for (int i = 0; i < records; i++ ) {      
      points.add(dataPlotArray[i][XDataSet], dataPlotArray[i][YDataSet],String.valueOf("X:"+dataPlotArray[i][XDataSet]+" "+"Y: "+dataPlotArray[i][YDataSet]));
    }
    plot.addPoints(points);
    plot.getYAxis().setAxisLabelText(YAxisLabel);
    plot.getXAxis().setAxisLabelText(XAxisLabel);
  }

  void draw(GPlot plot, GPointsArray points) {

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

