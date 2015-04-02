/*
This is a simple Arduino program to demonstrate the Duino DCS Software
Open the sample Temperature Control.csv in Duino DCS to see how the program
was setup to read the serial data below.
*/

float Temperature = 0;
long Error1[10];
int syetemValue = 0;



void setup() {

  Serial.begin(115200);
  pinMode(A0, INPUT);
}

void loop() {
  // Read analog values
  float var2 = 1024 - analogRead(0);
  float Resistance = (98 * var2) / (1024 - var2);  //98k resistor in series with the 503 thermister

  // Calculate temperature
  float Ln_Resist = log(Resistance);
  float Temp = log(Resistance);
  float Ln_Resist3 = Ln_Resist * Ln_Resist * Ln_Resist;
  Temperature = (1 / (0.00237531 + 0.00024632 * Ln_Resist + 0.00000028 * Ln_Resist3) - 273);

  // Print output with the Celsius serial tag/identifier
  Serial.print("Celsius: ");  // Serial Identifier for Duino DCS to read
  Serial.print(Temperature); // output current temperature value
  Serial.println(" ");
  //End of output for Celsius serial tag/identifier

  GetError(Temperature, 35, Error1); // Function to get error for PID control
  Serial.print("PID: ");  // Serial Identifier for Duino DCS to read
  int pid = CalculatePID(2000, 250, 5, Error1, 0) / 4; // Function to calculate PID
  Serial.print((pid / 4)); //PID Output
  Serial.println(" ");

  Serial.print("Heater: "); // Serial Identifier for Duino DCS to read
  int val;
  if (pid >= 47) val = 10; else val = 0;
  Serial.print(val); // Heater state output
  Serial.println(" ");
  delay(1000);


}//End of Function


