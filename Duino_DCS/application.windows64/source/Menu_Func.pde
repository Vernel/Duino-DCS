

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

      dataPlotArray = new float[logtable.getRowCount()][7];
      String sensor1Data, sensor2Data, sensor3Data, sensor4Data, sensor5Data, sensor6Data;
      String space = "  |  ";
      String space1 = "              ";

      for (TableRow row : logtable.rows ()) {

        int id = row.getInt("id");
        int Time = row.getInt(trim(txtfldSensor0.getText()));

        dataPlotArray[id-1][0] = Float.valueOf(Time);

        line = (nf(id, 4) + space + nf(int(Time), 6));

        //Sensor 1 Data Formating
        if (sensorSelected >= 1) { 
          sensor1Data = row.getString(trim(txtfldSensor1.getText()));

          if (checkString(sensor1Data))
            dataType1.setSelected(2);

          if (!dataType1.getSelectedText().equals("String") || !checkString(sensor1Data) ) {
            dataPlotArray[id-1][1] = Float.valueOf(sensor1Data);
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
        }// End of Sensor 1 Data Formating

        //Sensor 2 Data Formating
        if (sensorSelected >= 2) {
          sensor2Data = row.getString(trim(txtfldSensor2.getText()));

          if (checkString(sensor2Data))
            dataType2.setSelected(2);

          if (!dataType2.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][2] = Float.valueOf(sensor2Data);
          } else {
            dataPlotArray[id-1][2] = 0;
          }

          if (dataType2.getSelectedText().equals( "Int"))
            line = line + space +(nf(int(sensor2Data), 6));
          if (dataType2.getSelectedText().equals( "Float"))
            line = line + space +(nf(float(sensor2Data), 4, 2)) ;
          if (dataType2.getSelectedText().equals( "String"))
            line = line + space +space1;
        }// End of Sensor 2 Data Formating

        //Sensor 3 Data Formating
        if (sensorSelected >= 3) {
          sensor3Data = row.getString(trim(txtfldSensor3.getText()));

          if (checkString(sensor3Data))
            dataType3.setSelected(2);

          if (!dataType3.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][3] = Float.valueOf(sensor3Data);
          } else {
            dataPlotArray[id-1][3] = 0;
          }

          if (dataType3.getSelectedText() .equals("Int"))
            line = line + space +(nf(int(sensor3Data), 6));
          if (dataType3.getSelectedText() .equals("Float"))
            line = line + space +(nf(float(sensor3Data), 4, 2)) ;
          if (dataType3.getSelectedText() .equals("String"))
            line = line + space + space1;
        }// End of Sensor 3 Data Formating

        //Sensor 4 Data Formating
        if (sensorSelected >= 4) {
          sensor4Data = row.getString(trim(txtfldSensor4.getText()));

          if (checkString(sensor4Data))
            dataType4.setSelected(2);

          if (!dataType4.getSelectedText().equals( "String")) {
            dataPlotArray[id-1][4] = Float.valueOf(sensor4Data);
          } else {
            dataPlotArray[id-1][4] = 0;
          }

          if (dataType4.getSelectedText() .equals("Int"))
            line = line + space +(nf(int(sensor4Data), 6));
          if (dataType4.getSelectedText() .equals("Float"))
            line = line + space +(nf(float(sensor4Data), 3, 2)) ;
          if (dataType4.getSelectedText() .equals("String"))
            line = line + space +space1;
        }// End of Sensor 4 Data Formating

        //Sensor 5 Data Formating
        if (sensorSelected >= 5) {
          sensor5Data = row.getString(trim(txtfldSensor5.getText()));

          if (checkString(sensor5Data))
            dataType5.setSelected(2);

          if (!dataType5.getSelectedText().equals("String")) {
            dataPlotArray[id-1][5] = Float.valueOf(sensor5Data);
          } else {
            dataPlotArray[id-1][5] = 0;
          }

          if (dataType5.getSelectedText() .equals("Int"))
            line = line + space + (nf(int(sensor5Data), 6));
          if (dataType5.getSelectedText() .equals("Float"))
            line = line + space +(nf(float(sensor5Data), 3, 2)) ;
          if (dataType5.getSelectedText() .equals("String"))
            line = line + space + space1;
        }// End of Sensor 5 Data Formating

        //Sensor 6 Data Formating
        if (sensorSelected >= 6) {      
          sensor6Data = row.getString(trim(txtfldSensor6.getText()));

          if (checkString(sensor6Data))
            dataType6.setSelected(2);

          if (!dataType6.getSelectedText().equals("String")) {
            dataPlotArray[id-1][6] = Float.valueOf(sensor6Data);
          } else {
            dataPlotArray[id-1][6] = 0;
          }

          if (dataType6.getSelectedText() .equals("Int"))
            line = line + space +(nf(int(sensor6Data), 6));
          if (dataType6.getSelectedText() .equals("Float"))
            line = line + space + (nf(float(sensor6Data), 3, 2)) ;
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

