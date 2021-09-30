// This example sketch connects to the public shiftr.io instance and sends a message on every keystroke.
// After starting the sketch you can find the client here: https://www.shiftr.io/try.
//
// Note: If you're running the sketch via the Android Mode you need to set the INTERNET permission
// in Android > Sketch Permissions.
//


import mqtt.*;
import java.util.*;

import controlP5.*;
//int knbValue = 100;
import processing.serial.*;
Serial myPort;                       // The serial port
PFont font;
long startTime=0;
boolean useSerial = false;
boolean useMQTT;
Knob myKnobA;
ControlP5 cp5;
String textValue = "";
int currentServo;
MQTTClient client;
int x = 0;
int y = 0;
int knobValue = 0;
String inString = "000";
String pInString = "000";
boolean windowActive = false;
boolean windowResting = false;

int state  = 0 ;
int pState  =0;
/*
0 = no interactions for a while rest
 1 = first interaction first movement
 
 */

int [] wavePattern = {0, 4, 1, 5, 8, 9, 6, 2, 12, 13, 10, 7, 3, 14, 11, 16, 17, 18, 15, 21, 22, 19, 20, 25, 26, 23, 24, 29, 30, 27, 28, 31};
void setup() {
  useMQTT = !useSerial;
  println(wavePattern.length);
  client = new MQTTClient(this);
  client.connect("mqtt://public:public@public.cloud.shiftr.io", "p55");
  //client.connect("mqtt://192.168.0.60", "p55");
  size(700, 400);
  PFont font = createFont("arial", 48);
  textFont(font);
startTime = millis();
  font = loadFont("ACaslonPro-Bold-48.vlw");
  textFont(font, 72);
  if (useSerial) {
    // Print a list of the serial ports, for debugging purposes:
    printArray(Serial.list());
    //change the 3 below to whatever the port number of you arduino on your local machine


    String portName = Serial.list()[3];
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil('\n');
  }

  cp5 = new ControlP5(this);



  cp5.addTextfield("positions")
    .setPosition(20, 170)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    ;
  cp5.addTextfield("intervals")
    .setPosition(20, 250)
    .setSize(200, 40)
    .setFont(createFont("arial", 20))
    .setAutoClear(false)
    ;
  myKnobA = cp5.addKnob("knob")
    .setRange(0, 180)
    .setValue(0)
    .setPosition(250, 50)
    .setRadius(50)
    .setDragDirection(Knob.VERTICAL)
    ;
  cp5.addBang("clear")
    .setPosition(240, 170)
    .setSize(80, 40)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
    ;

  cp5.addBang("send")
    .setPosition(350, 170)
    .setSize(80, 40)
    .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
    ;


  String [] servoIds = new String[32];
  for (int i=0; i<32; i++) {
    servoIds[i] = str(i);
  }
  List l = Arrays.asList(servoIds);
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("servoId")
    .setPosition(20, 50)
    .setSize(200, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(l)
    // .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    ;
}

void draw() {
  background(0);
  textAlign(CENTER);
  text(inString, width-100, 100);

  /*
  0 no timeout no patterns
   1
   */



  String positions  =  "180,90,180,0,180";//,180,0,180,0,45,90,45,90";
  String intervals =   "1000,4000,1000,1000,5000";//,100,400,200,100,100,100,100,500";
  //sendCircularComesTogether();



  long timeOut = 15000;

  int numStates = 4;
  if (millis()-startTime> timeOut ) {
    //  println("timeout", state);
    if (state==0) {

      sendCircularComesTogether();
    } else if (state==1) {


      positions  =  "0,90,0,180,0";//,180,0,180,0,45,90,45,90";
      intervals =   "1000,4000,1000,1000,5000";//,100,400,200,100,100,100,100,500";
      sendCircularResting(positions, intervals) ;
    } else if (state==2) {


      positions  =  "180,150,180,180,150";//,180,0,180,0,45,90,45,90";
      intervals =   "1000,4000,1000,1000,5000";//,100,400,200,100,100,100,100,500";
      //sendCircularResting(positions, intervals) ;
    } else if (state==3) {


      positions  =  "0,90,0,180,0";//,180,0,180,0,45,90,45,90";
      intervals =   "1000,4000,1000,1000,5000";//,100,400,200,100,100,100,100,500";
      sendCircularResting(positions, intervals) ;
    } else if (state==4) {


      positions  =  "45,90,135,90";//,180,0,180,0,45,90,45,90";
      intervals =   "500,500,500,500";//,100,400,200,100,100,100,100,500";
      sendCircularResting(positions, intervals) ;
    }
    state++;
    if (state>=numStates) {
      state=0;
    }
    println("state", state);
    startTime = millis();
  }
}

void keyReleased() {
  if (key=='a') {
    //sendWaveBackAndForth(32, 10, 50, 18);
    String positions  =  "0,90,0";
    String intervals =   "4000,500,500";
    sendCircularResting(positions, intervals) ;
  } else if (key=='b') {
    sendCircularQuiver();
  } else if (key=='c') {
    //    sendRestingPatternWindow(15);
    //sendWaveStaggeredEveryOtherWindow(15, 10, 100, 18);
    sendAllToPosition(15, 90);
    // delay(1000);
    //String [] addresses = {"/kennedyLEFTHANDSIDE", "/kennedyWINDOW"};
    String [] addresses = {"/kennedyWINDOW", "/kennedyLEFTHANDSIDE", "/kennedyRIGHTHANDSIDE"};
    //sendRestingPatternAnywhere(32, addresses, 100 );
    sendRestingPatternAnywhereColumns(32, addresses, 100);
    // sendRestingPatternAnywhereRows(32, addresses, 100);
    //sendRestingPatternAnywhere(15, addresses, 0 );
  } else if (key=='d') {
    String [] addresses = {"/kennedyWINDOW", "/kennedyLEFTHANDSIDE", "/kennedyRIGHTHANDSIDE"};
    //sendRestingPatternAnywhere(32, addresses, 100 );
    // sendRestingPatternAnywhereColumns(32, addresses, 100);
    sendRestingPatternAnywhereRows(32, addresses, 100);
  } else if (key=='e') {
    String positions  =  "0,90,0";//,180,0,180,0,45,90,45,90";
    String intervals =   "1000,4000,1000";//,100,400,200,100,100,100,100,500";
    sendWallRestingRandom();
  }

  //sendTwitch(32, 10, 50, 8,20);
}
void sendTwitch(int numServos, int numPositions, int numIntervals, int intervalLength, int maxTwitchAngle) {
  String intervals = "";

  for (int i=0; i<numPositions; i++) {
    intervals+= str(intervalLength)+",";
  }



  intervals = intervals.substring(0, intervals.length()-1);



  int [] angles = new int [numServos];
  for (int i=0; i<angles.length; i++) {
    angles[i] = int(random(0, 180));
  }

  for (int j=0; j<numPositions; j++) {
    for (int i=0; i<numServos; i++) {
      String serialisedJSON =  "{\"servoId\":";

      serialisedJSON+=str(wavePattern[i]);
      serialisedJSON+=",\"arrLength\":";
      serialisedJSON+=str(numPositions);
      serialisedJSON+=",\"setPos\":";
      serialisedJSON+="1";
      serialisedJSON+=",\"positions\":[";
      serialisedJSON+= str( angles [i] ) ;//str(knobValue);
      serialisedJSON+="],\"intervals\":[";
      serialisedJSON+=intervals;
      serialisedJSON+="]}";

      println(serialisedJSON);
      client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
      client.publish("/kennedyRIGHTHANDSIDE", serialisedJSON);

      delay(50);
    }
    for (int i=0; i<angles.length; i++) {
      angles[i] += int(random(-maxTwitchAngle, maxTwitchAngle));
      if (angles[i]<0) angles[i] += maxTwitchAngle;
      if (angles[i]>180) angles[i] -= maxTwitchAngle;
    }
  }
}
void sendRestingPatternRandom(int numServos) {
  String positions  = "0, 45, 90,135, 180, 135, 90, 45, 180, 170, 160, 45, 0";
  String intervals = "1000, 2000, 1000, 2000, 500, 1000, 1500, 2000, 2000, 500, 2000, 1500, 1000";

  int numPositions = splitTokens(positions, ",").length;

  for (int i=0; i<numServos; i++) {
    String serialisedJSON =  "{\"servoId\":";

    serialisedJSON+=str(i);
    serialisedJSON+=",\"arrLength\":";
    serialisedJSON+=str(numPositions);
    serialisedJSON+=",\"setPos\":";
    serialisedJSON+="0";
    serialisedJSON+=",\"positions\":[";
    serialisedJSON+=positions;

    serialisedJSON+="],\"intervals\":[";
    serialisedJSON+=intervals;
    serialisedJSON+="]}";

    //  println(serialisedJSON);

    client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
    client.publish("/kennedyRIGHHANDSIDE", serialisedJSON);

    delay(50);
  }
}

void sendRestingPatternAnywhere(int numServos, String [] topics, int offSet) {
  String positions  =  "0,90,0";
  String intervals =   "1000,2000,1000";

  int numPositions = splitTokens(positions, ",").length;

  for (int i=0; i<numServos; i++) {
    String serialisedJSON =  "{\"servoId\":";

    serialisedJSON+=str(i);
    serialisedJSON+=",\"arrLength\":";
    serialisedJSON+=str(numPositions);
    serialisedJSON+=",\"setPos\":";
    serialisedJSON+="0";
    serialisedJSON+=",\"positions\":[";
    serialisedJSON+=positions;

    serialisedJSON+="],\"intervals\":[";
    serialisedJSON+=intervals;
    serialisedJSON+="]}";

    println(serialisedJSON);
    for (int j=0; j<topics.length; j++) {
      client.publish(topics[j], serialisedJSON);
    }

    //introduce delay off set to last interval
    //String [] intervalsExp = splitTokens(intervals, ",");
    //int firstInterval =int(intervalsExp[0]);
    //firstInterval+=offSet;
    //intervals = str(firstInterval)+",";
    //for (int j=1; j<intervalsExp.length; j++) {
    //  intervals+=intervalsExp[j];
    //  intervals+=",";
    //}
    //intervals = intervals.substring(0, intervals.length()-1);
    delay(10);
  }
}

void sendRestingPatternAnywhereColumns(int numServos, String [] topics, int offSet) {
  String positions  =  "0,180,0,90,0";
  String intervals =   "4000,500,500,500,500";

  int numPositions = splitTokens(positions, ",").length;
  int columnCount = 0;
  int columnLength = 4;
  int delayLength = 10;
  int multiPlier  = 100;
  for (int i=0; i<numServos; i+=4) {
    // while(columnCount <columnLength){
    formatJSON( numPositions, intervals, positions, "/kennedyLEFTHANDSIDE", i);
    delay(delayLength);
    formatJSON( numPositions, intervals, positions, "/kennedyLEFTHANDSIDE", i+1);
    delay(delayLength);
    formatJSON( numPositions, intervals, positions, "/kennedyLEFTHANDSIDE", i+2);
    delay(delayLength);
    formatJSON( numPositions, intervals, positions, "/kennedyLEFTHANDSIDE", i+3);
    delay(delayLength*multiPlier);
    //
  }
  for (int i=0; i<numServos; i+=4) {
    // while(columnCount <columnLength){
    formatJSON( numPositions, intervals, positions, "/kennedyRIGHTHANDSIDE", i);
    delay(delayLength);
    formatJSON( numPositions, intervals, positions, "/kennedyRIGHTHANDSIDE", i+1);
    delay(delayLength);
    formatJSON( numPositions, intervals, positions, "/kennedyRIGHTHANDSIDE", i+2);
    delay(delayLength);
    formatJSON( numPositions, intervals, positions, "/kennedyRIGHTHANDSIDE", i+3);
    delay(delayLength*multiPlier);
    //
  }
}
void sendRestingPatternAnywhereRows(int numServos, String [] topics, int offSet) {
  String positions  =  "0,180,0,90,0";
  String intervals =   "4000,500,500,500,500";

  int numPositions = splitTokens(positions, ",").length;
  int columnCount = 0;
  int columnLength = 4;
  int delayLength = 30;
  int multiPlier  = 20;
  int rowLength =16;
  //for the complete length of the 2 arrays go up in 4s
  //for each row
  for (int i=0; i<columnLength; i++) {
    //go up in 4s
    // println("column ", i);
    for (int j=0; j<rowLength/2; j++) {
      //across the first row on left
      int servoIdOffset = i;//(i*(rowLength/2));
      int servoId = servoIdOffset + j*4;
      // print(servoId, " left side ");
      //println();

      formatJSON( numPositions, intervals, positions, "/kennedyLEFTHANDSIDE", servoId);
      delay(delayLength);
    }
    for (int j=0; j<rowLength/2; j++) {
      //across the first row on left
      int servoIdOffset = i;//(i*(rowLength/2));
      int servoId = servoIdOffset + j*4;
      //print(servoId, " right side ");
      //println();

      formatJSON( numPositions, intervals, positions, "/kennedyRIGHTHANDSIDE", servoId);
      delay(delayLength);
    }
    delay(delayLength*multiPlier);
  }



  //
}

void sendCircularQuiver() {
  int numServos =15;
  int delayLength = 10;
  int multiPlier  = 100;
  for (int i=0; i<numServos; i++) {
    String positions  =  "90,90,90";
    String intervals =   "4000,4000,500";
    int numPositions = splitTokens(positions, ",").length;
    // while(columnCount <columnLength){
    formatJSON( numPositions, intervals, positions, "/kennedyWINDOW", i);
    delay(delayLength);

    //
  }
  delay(2000);
  int maxAngle = 30;
  int minInterval = 20;
  int maxInterval  = 100;
  for (int i=0; i<numServos; i++) {
    int lowAngle=90;
    int highAngle=90;
    if (i%2==0) {
      lowAngle =int( 90 - random(maxAngle ));
      highAngle =int( 90 + random(maxAngle ));
    } else {
      lowAngle =int( 90 + random(maxAngle ));
      highAngle =int( 90 - random(maxAngle ));
    }
    int interval =int(random(minInterval, maxInterval ));


    String positions  =  str(lowAngle)+",90,"+str(highAngle);
    String intervals =   str(interval)+","+str(interval) +","+str(interval);
    int numPositions = splitTokens(positions, ",").length;
    // while(columnCount <columnLength){
    formatJSON( numPositions, intervals, positions, "/kennedyWINDOW", i);
    delay(delayLength);

    //
  }
}
void sendCircularResting(String positions, String intervals) {
  int numServos =15;
  int delayLength = 10;
  int multiPlier  = 100;
  for (int i=0; i<numServos; i++) {

    int numPositions = splitTokens(positions, ",").length;
    // while(columnCount <columnLength){
    formatJSON( numPositions, intervals, positions, "/kennedyWINDOW", i);
    delay(delayLength);

    //
  }
}
void sendCircularComesTogether() {
  String  positions ="45,135,45,135";
  String  positions1 ="135,45,135,45";
  String  positions2 = "80,90,80,90";
  String intervals  ="500,500,1000,1000";
  int numServos =15;
  int delayLength = 10;
  int multiPlier  = 100;
  for (int i=0; i<numServos; i+=3) {

    int numPositions = splitTokens(positions, ",").length;
    // while(columnCount <columnLength){


    formatJSON( numPositions, intervals, positions, "/kennedyWINDOW", i);
    formatJSON( numPositions, intervals, positions2, "/kennedyWINDOW", i+1);
    formatJSON( numPositions, intervals, positions1, "/kennedyWINDOW", i+2);
    delay(delayLength);

    //
  }
}

void sendWallResting(String positions, String intervals) {
  int numServos =32;
  int delayLength = 40;
  int multiPlier  = 100;
  for (int i=0; i<numServos; i++) {

    int numPositions = splitTokens(positions, ",").length;
    // while(columnCount <columnLength){
    formatJSON( numPositions, intervals, positions, "/kennedyLEFTHANDSIDE", i);
    delay(delayLength);
    formatJSON( numPositions, intervals, positions, "/kennedyRIGHTHANDSIDE", i);
    delay(delayLength);

    //
  }
}
void sendWallRestingRandom() {
  int numServos =32;
  int delayLength = 40;
  int multiPlier  = 100;

  for (int i=0; i<numServos; i++) {
    String positions = str(int(random(0, 180)))+","+str(int(random(0, 180)))+","+str(int(random(0, 180)));
    String intervals = str(int(random(500, 3000)))+","+str(int(random(500, 3000)))+","+str(int(random(500, 3000)));

    int numPositions = splitTokens(positions, ",").length;
    // while(columnCount <columnLength){
    formatJSON( numPositions, intervals, positions, "/kennedyLEFTHANDSIDE", i);
    delay(delayLength);
    formatJSON( numPositions, intervals, positions, "/kennedyRIGHTHANDSIDE", i);
    delay(delayLength);

    //
  }
}
void formatJSON(int numPositions, String intervals, String positions, String topic, int servoId) {

  String serialisedJSON =  "{\"i\":";

  serialisedJSON+=str(servoId);
  serialisedJSON+=",\"a\":";
  serialisedJSON+=str(numPositions);
  serialisedJSON+=",\"s\":";
  serialisedJSON+="0";
  serialisedJSON+=",\"ps\":[";
  serialisedJSON+=positions;

  serialisedJSON+="],\"is\":[";
  serialisedJSON+=intervals;
  serialisedJSON+="]}";

  // println(serialisedJSON);
  client.publish(topic, serialisedJSON);
}
void sendRestingPattern(int numServos) {
  String positions  =  "0,45,90,135,180,135,90,45,180,0";
  String intervals =   "1000,500,1000,500,500,1000,1500,2000,2000,500";

  int numPositions = splitTokens(positions, ",").length;

  for (int i=0; i<numServos; i++) {
    String serialisedJSON =  "{\"servoId\":";

    serialisedJSON+=str(i);
    serialisedJSON+=",\"arrLength\":";
    serialisedJSON+=str(numPositions);
    serialisedJSON+=",\"setPos\":";
    serialisedJSON+="0";
    serialisedJSON+=",\"positions\":[";
    serialisedJSON+=positions;

    serialisedJSON+="],\"intervals\":[";
    serialisedJSON+=intervals;
    serialisedJSON+="]}";

    println(serialisedJSON);
    client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
    client.publish("/kennedyRIGHTHANDSIDE", serialisedJSON);
    delay(50);
  }
}

void sendWaveStaggeredEveryOtherWindow(int numServos, int numPositions, int intervalLength, int angle) {
  String intervals = "";
  for (int i=0; i<numPositions; i++) {
    intervals+= str(intervalLength)+",";
  }
  intervals = intervals.substring(0, intervals.length()-1);

  for (int j=0; j<numPositions; j++) {

    for (int i=0; i<numServos; i++) {
      String serialisedJSON =  "{\"servoId\":";

      serialisedJSON+=str(wavePattern[i]);
      serialisedJSON+=",\"arrLength\":";
      serialisedJSON+=str(numPositions);
      serialisedJSON+=",\"setPos\":";
      serialisedJSON+="1";
      serialisedJSON+=",\"positions\":[";
      serialisedJSON+= str( angle * j ); //str(knobValue);

      serialisedJSON+="],\"intervals\":[";
      serialisedJSON+=intervals;
      serialisedJSON+="]}";

      println(serialisedJSON);
      client.publish("/kennedyWINDOW", serialisedJSON);

      delay(50);
    }
    delay(500);
  }
}


void sendWaveStaggeredEveryOther(int numServos, int numPositions, int intervalLength, int angle) {
  String intervals = "";
  for (int i=0; i<numPositions; i++) {
    intervals+= str(intervalLength)+",";
  }
  intervals = intervals.substring(0, intervals.length()-1);

  for (int j=0; j<numPositions; j++) {

    for (int i=0; i<numServos; i++) {
      String serialisedJSON =  "{\"servoId\":";

      serialisedJSON+=str(wavePattern[i]);
      serialisedJSON+=",\"arrLength\":";
      serialisedJSON+=str(numPositions);
      serialisedJSON+=",\"setPos\":";
      serialisedJSON+="1";
      serialisedJSON+=",\"positions\":[";
      if (i%2==0) {
        serialisedJSON+= str( angle * j ); //str(knobValue);
      } else {
        serialisedJSON+= str( angle * (10-j) ); //str(knobValue);
      }

      serialisedJSON+="],\"intervals\":[";
      serialisedJSON+=intervals;
      serialisedJSON+="]}";

      println(serialisedJSON);
      client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
      client.publish("/kennedyRIGHHANDSIDE", serialisedJSON);

      delay(50);
    }
    delay(500);
  }
}

void sendWaveBackAndForth(int numServos, int numPositions, int intervalLength, int angle) {

  String intervals = "";
  for (int i=0; i<numPositions; i++) {
    intervals+= str(intervalLength)+",";
  }
  intervals = intervals.substring(0, intervals.length()-1);

  ///wave forward
  for (int j=0; j<numPositions; j++) {
    for (int i=0; i<numServos; i++) {
      String serialisedJSON =  "{\"servoId\":";

      serialisedJSON+=str(wavePattern[i]);
      serialisedJSON+=",\"arrLength\":";
      serialisedJSON+=str(numPositions);
      serialisedJSON+=",\"setPos\":";
      serialisedJSON+="1";
      serialisedJSON+=",\"positions\":[";
      serialisedJSON+= str( angle * j ); //str(knobValue);
      serialisedJSON+="],\"intervals\":[";
      serialisedJSON+=intervals;
      serialisedJSON+="]}";

      //println(serialisedJSON);
      client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
      client.publish("/kennedyRIGHTHANDSIDE", serialisedJSON);

      delay(10);
    }
    delay(500);
  }
  //wave back
  for (int j=10; j>=0; j--) {
    for (int i=0; i<numServos; i++) {
      String serialisedJSON =  "{\"servoId\":";

      serialisedJSON+=str(wavePattern[i]);
      serialisedJSON+=",\"arrLength\":";
      serialisedJSON+=str(numPositions);
      serialisedJSON+=",\"setPos\":";
      serialisedJSON+="1";
      serialisedJSON+=",\"positions\":[";
      serialisedJSON+= str( angle * j ); //str(knobValue);
      serialisedJSON+="],\"intervals\":[";
      serialisedJSON+=intervals;
      serialisedJSON+="]}";

      //println(serialisedJSON);
      client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
      client.publish("/kennedyRIGHTHANDSIDE", serialisedJSON);

      delay(50);
    }

    delay(500);
  }
}

public void clear() {
  cp5.get(Textfield.class, "positions").clear();
  cp5.get(Textfield.class, "intervals").clear();
}
void knob(int theValue) {
  knobValue = theValue;
  String servoId = str(currentServo);
  //first check our lists are the same length

  String positions = cp5.get(Textfield.class, "positions").getText();
  String intervals = cp5.get(Textfield.class, "intervals").getText();
  int numPositions = splitTokens(positions, ",").length;
  int numIntervals = splitTokens(intervals, ",").length;

  String serialisedJSON =  "{\"servoId\":";

  serialisedJSON+=servoId;
  serialisedJSON+=",\"arrLength\":";
  serialisedJSON+=str(1);
  serialisedJSON+=",\"setPos\":";
  serialisedJSON+="1";
  serialisedJSON+=",\"positions\":[";
  serialisedJSON+=str(theValue);
  serialisedJSON+="],\"intervals\":[";
  serialisedJSON+=intervals;
  serialisedJSON+="]}";

  println(serialisedJSON);
  client.publish("/kennedyWINDOW", serialisedJSON);
  client.publish("/kennedyRIGHTHANDSIDE", serialisedJSON);
  client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
}
void sendAllToPosition(int numServos, int theValue) {
  knobValue = theValue;
  String servoId = str(currentServo);
  //first check our lists are the same length

  String positions = cp5.get(Textfield.class, "positions").getText();
  String intervals = cp5.get(Textfield.class, "intervals").getText();
  int numPositions = splitTokens(positions, ",").length;
  int numIntervals = splitTokens(intervals, ",").length;
  for (int i=0; i<numServos; i++) {
    String serialisedJSON =  "{\"servoId\":";

    serialisedJSON+=str(i);
    serialisedJSON+=",\"arrLength\":";
    serialisedJSON+=str(1);
    serialisedJSON+=",\"setPos\":";
    serialisedJSON+="1";
    serialisedJSON+=",\"positions\":[";
    serialisedJSON+=str(theValue);
    serialisedJSON+="],\"intervals\":[";
    serialisedJSON+=intervals;
    serialisedJSON+="]}";

    println(serialisedJSON);
    client.publish("/kennedyWINDOW", serialisedJSON);
  }
}

public void send() {

  String servoId = str(currentServo);
  //first check our lists are the same length

  String positions = cp5.get(Textfield.class, "positions").getText();
  String intervals = cp5.get(Textfield.class, "intervals").getText();
  int numPositions = splitTokens(positions, ",").length;
  int numIntervals = splitTokens(intervals, ",").length;

  if (numPositions==numIntervals && numPositions>1) {
    String serialisedJSON =  "{\"servoId\":";

    serialisedJSON+=servoId;
    serialisedJSON+=",\"arrLength\":";
    serialisedJSON+=str(numPositions);
    serialisedJSON+=",\"setPos\":";
    serialisedJSON+="0";
    serialisedJSON+=",\"positions\":[";
    serialisedJSON+=positions;
    serialisedJSON+="],\"intervals\":[";
    serialisedJSON+=intervals;
    serialisedJSON+="]}";

    println(serialisedJSON);
    client.publish("/kennedyRIGHTHANDSIDE", serialisedJSON);
    client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
    client.publish("/kennedyWINDOW", serialisedJSON);
  } else if (numPositions==1) {

    String serialisedJSON =  "{\"servoId\":";

    serialisedJSON+=servoId;
    serialisedJSON+=",\"arrLength\":";
    serialisedJSON+=str(numPositions);
    serialisedJSON+=",\"setPos\":";
    serialisedJSON+="1";
    serialisedJSON+=",\"positions\":[";
    serialisedJSON+=positions;
    serialisedJSON+="],\"intervals\":[";
    serialisedJSON+=intervals;
    serialisedJSON+="]}";

    println(serialisedJSON);
    client.publish("/kennedyRIGHTHANDSIDE", serialisedJSON);
    client.publish("/kennedyLEFTHANDSIDE", serialisedJSON);
    client.publish("/kennedyWINDOW", serialisedJSON);
  } else {
    println("lists are different lengths, try again");
  }
}

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isAssignableFrom(Textfield.class)) {
    println("controlEvent: accessing a string from controller '"
      +theEvent.getName()+"': "
      +theEvent.getStringValue()
      );
  }
}


void servoId(int n) {
  /* request the selected item based on index n */
  //println(n, cp5.get(ScrollableList.class, "servoId").getItem(n));
  currentServo = n;
  /* here an item is stored as a Map  with the following key-value pairs:
   * name, the given name of the item
   * text, the given text of the item by default the same as name
   * value, the given value of the item, can be changed by using .getItem(n).put("value", "abc"); a value here is of type Object therefore can be anything
   * color, the given color of the item, how to change, see below
   * view, a customizable view, is of type CDrawable
   */

  CColor c = new CColor();
  c.setBackground(color(255, 0, 0));
  cp5.get(ScrollableList.class, "servoId").getItem(n).put("color", c);
}
public void positions(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'positions' : "+theText);
}
public void intervals(String theText) {
  // automatically receives results from controller input
  println("a textfield event for  'intervals' : "+theText);
}

void keyPressed() {
  //  JSONObject obj = new JSONObject();
  //  obj.setString("servoId", "servo 1");
  //  obj.setString("arrLength", "servo 1");
  //  JSONArray values = new JSONArray();
  //  for (int i=0; i<5; i++) {
  //    values.setFloat(i, int(random(10000)));
  //  }
  //  obj.setJSONArray("positions", values);
  //  obj.setJSONArray("intervals", values);
  //  println(obj.toString());
  //  client.publish("/kennedyRIGHTHANDSIDE", "{\"servoId\":3,\"arrLength\":5,\"positions\":[0,10,20,30,45],\"intervals\":[900,6000,900,6000,1000]}");
}

//mouseDragged happens whenever I click and drag the mouse
void mouseDragged() {
  //println(mouseX, mouseY);
  //I want to make a topic called 'mouseX' and send the current value of the x position of the mouse
  //client.publish("/mouseX", str(mouseX));
  //client.publish("/mouseY", str(mouseY));
}


void clientConnected() {
  println("client connected");
  //I want to subscribe to these messages
  client.subscribe("/kennedyPIRWINDOW");
  //client.subscribe("/mouseY");
}

void messageReceived(String topic, byte[] payload) {
  //println("new message: " + topic + " - " + new String(payload));
  String pl  = new String(payload);
  println(pl);
  if (topic.equals("/kennedyPIRWINDOW")) {
    inString=pl;
  }
}

void connectionLost() {
  println("connection lost");
}


void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  inString = myPort.readString().trim();
  //if (inString.length()==3) println(inString);
}
