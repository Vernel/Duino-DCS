

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
void setSerialPort(String portName) {
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

void serialSend() {
  port.write(trim(txtfldSerial.getText())+'\n');  
  error.addLast("Serial Command: "+trim(txtfldSerial.getText())+"  "+System.currentTimeMillis()%10000000);
  txtfldSerial.setText(" ");
}// End of Function

