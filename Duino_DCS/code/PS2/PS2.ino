const int xPin = A0;
const int yPin = A1;
const int swPin = 8;
const int delayTime = 700;


void setup()
{
  pinMode(swPin, INPUT);
  digitalWrite(swPin, HIGH);
  Serial.begin(115200);
}

void loop()
{
  int X = analogRead(xPin);
  int Y = analogRead(yPin);

  if ( X > 510) {
    Serial.print("xBack: ");
    Serial.print(map(analogRead(xPin), 505, 1023, 22, 255), DEC);
    Serial.println(" ");
    delay(delayTime);
    //Serial.println("mStop: ");

  }

  if ( X < 500) {
    Serial.print("xForward: ");  //Serial Identifier. Change string but maintain formating style. eg: "xForward: " -> "Temp: "
    Serial.print(map(analogRead(xPin), 505, 0, 22, 255), DEC);
    Serial.println(" ");
    delay(delayTime);
   // Serial.println("mStop: ");

  }

  if ( Y > 520) {
    Serial.print("yLeft: ");
    Serial.print(map(analogRead(yPin), 515, 1023, 22, 255), DEC);
    Serial.println(" ");
    delay(delayTime);
    //Serial.println("mStop: ");
  }

  if ( Y < 510) {
    Serial.print("yRight: ");
    Serial.print(map(analogRead(yPin), 515, 0, 22, 255), DEC);
    Serial.println(" ");
    delay(delayTime);
    //Serial.println("mStop: ");
  }

  if (digitalRead(swPin) == 0) {
   Serial.println("mStop: ");
   delay(delayTime);
  }


  //delay(delayTime);
}
