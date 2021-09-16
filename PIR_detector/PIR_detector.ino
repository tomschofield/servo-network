int ledPin = 13;                // LED
int pirPin1 = 2;                 // PIR Out pin
int pirPin2 = 3;                 // PIR Out pin
int pirPin3 = 4;                 // PIR Out pin


int pirStat = 0;                   // PIR status
void setup() {

  //the wee light on the arduino should go on when the PIR is active
  pinMode(ledPin, OUTPUT);

  pinMode(pirPin1, INPUT);
  pinMode(pirPin2, INPUT);
  pinMode(pirPin3, INPUT);


  Serial.begin(9600);
}
void loop() {
  String PIRstatuses = "";
  /*we're going to make a list of the statuses of all the PIR sensors 
  that will look like this 
  if they're all off: 000
  this if they're all on 111
  this if the first is off 011
  etc

*/
  pirStat = digitalRead(pirPin1);

  if (pirStat == HIGH) {            // if motion detected
    digitalWrite(ledPin, HIGH);  // turn LED ON
    // Serial.write("1");
    PIRstatuses += "1";
  }
  else {
    // Serial.write("0");
    PIRstatuses += "0";
    digitalWrite(ledPin, LOW); // turn LED OFF if we have no motion
  }

  pirStat = digitalRead(pirPin2);

  if (pirStat == HIGH) {            // if motion detected

    PIRstatuses += "1";
  }
  else {
    // Serial.write("0");
    PIRstatuses += "0";

  }

  pirStat = digitalRead(pirPin3);

  if (pirStat == HIGH) {            // if motion detected

    PIRstatuses += "1";
  }
  else {
    // Serial.write("0");
    PIRstatuses += "0";

  }
  
  Serial.println(PIRstatuses);
  
}
