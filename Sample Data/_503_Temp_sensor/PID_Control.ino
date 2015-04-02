

// define some constants
int Output;
long Accumulator[3];
long PID;
byte i = 0;

int imax = 255;
int imin = -255;


void GetError(int processVariable, int setPoint, long *_Error) {

  long ActualPosition = processVariable;
  long DesiredPosition = setPoint;

  for (i = 0; i < 10; i++) // shift error values
    _Error[i + 1] = _Error[i];
  _Error[0] = DesiredPosition - ActualPosition; // load new error into top array spot

  /*Serial.print("Error= ");
  Serial.println(_Error[0], DEC);
  Serial.println(F(" "));*/

}// End of function


int CalculatePID(int Kp, int Ki, int Kd, long *_Error, byte K)
{
  /*
  Kp depends on the present error,
  Ki on the accumulation of past errors, and
  Kd on the prediction of future errors based on current rate of change.
  */
  int PTerm = Kp;
  int ITerm = Ki;
  int DTerm = Kd;
  int Divider = 5;

  // Calculate the PID
  PID = _Error[0] * PTerm;   // start with proportional gain
  Accumulator[K] = Accumulator[K] + _Error[0];  // accumulator is sum of errors
  PID += ITerm * Accumulator[K]; // add integral gain and error accumulation
  PID += DTerm * (_Error[0] - _Error[9]); // differential gain comes next
  PID = PID >> Divider; // scale PID down with divider

  /*Serial.print(F("PID: "));
  Serial.print(PID, DEC);
  Serial.println(F(" "));*/

  // limit the PID
  if (PID >= imax) {
    PID = imax;
  }
  if (PID <= imin) {
    PID = imin;
  }

  //windup protection
  if (Accumulator[K] > 50) {
    Accumulator[K] = 0;
    _Error = 0;
  } else if (Accumulator[K] < -50) {
    Accumulator[K] = 0;
    _Error = 0;
  }

  //PWM output should be between 1 and 254 so we add to the PID
  Output = PID;// + 127;

  /*Serial.print(F("PIDOutput: "));
  Serial.print(Output, DEC);
  Serial.println(F(" "));
  Serial.println(F(" "));*/

  /*Serial.print(F("Accumulator: "));
  Serial.print(Accumulator, DEC);
  Serial.println(F(" "));*/

  return Output;
}// End of function

