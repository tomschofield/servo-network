import processing.serial.*;
Serial myPort;                       // The serial port
PFont font;
String inString;

void setup() {
  size(200, 200);
  noStroke();
  font = loadFont("ACaslonPro-Bold-48.vlw");
  textFont(font,48);

  // Print a list of the serial ports, for debugging purposes:
  printArray(Serial.list());
  //change the 3 below to whatever the port number of you arduino on your local machine
  String portName = Serial.list()[3];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  background(0);
  textAlign(CENTER);
  text(inString,100,100);
}

void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  inString = myPort.readString().trim();
  if (inString.length()==3) println(inString);
}
