// This example sketch connects to the public shiftr.io instance and sends a message on every keystroke.
// After starting the sketch you can find the client here: https://www.shiftr.io/try.
//
// Note: If you're running the sketch via the Android Mode you need to set the INTERNET permission
// in Android > Sketch Permissions.
//
// by Joël Gähwiler
// https://github.com/256dpi/processing-mqtt

import mqtt.*;
import java.util.*;

import controlP5.*;
//int knbValue = 100;
import processing.serial.*;
Serial myPort;                       // The serial port
PFont font;
String inString;
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
String pInString = "000"
  int [] wavePattern = {0, 4, 1, 5, 8, 9, 6, 2, 12, 13, 10, 7, 3, 14, 11, 16, 17, 18, 15, 21, 22, 19, 20, 25, 26, 23, 24, 29, 30, 27, 28, 31};
void setup() {
  useMQTT = !useSerial;
  println(wavePattern.length);
  client = new MQTTClient(this);
  client.connect("mqtt://public:public@public.cloud.shiftr.io", "cap");
  //client.connect("mqtt://192.168.0.60", "p55");
  size(700, 400);
  PFont font = createFont("arial", 20);
  textFont(font);

  font = loadFont("ACaslonPro-Bold-48.vlw");
  textFont(font, 48);

  // Print a list of the serial ports, for debugging purposes:
  printArray(Serial.list());
  //change the 3 below to whatever the port number of you arduino on your local machine
  String portName = Serial.list()[3];
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n');



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

  if (inString.equals(pInString)==false) {
    if (inString.equals("000")) {
      sendRestingPattern(32);
    } else if (inString.equals("100")) {
    }
    pInString = inString;
  }
}
void keyReleased() {
}

void sendRestingPattern(int numServos) {
  String positions  = "0, 45, 90,135, 180, 135, 90, 45, 180, 170, 160, 45, 0";
  String intervals = "1000, 2000, 1000, 2000, 500, 1000, 1500, 2000, 2000, 500, 2000, 1500, 1000";

  int numPositions = splitTokens(positions, ",").length;

  for (int i=0; i<numServos; i++) {
    String serialisedJSON =  "{\"servoId\":";

    serialisedJSON+=str(wavePattern[i]);
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
    client.publish("/kennedy", serialisedJSON);
    delay(50);
  }
}

void sendWaveStaggeredEveryOther(int numServos, int numPositions, int intervalLength, int angle) {
  String intervals = "";
  for (int i=0; i<numPositions; i++) {
    intervals+= str(intervalLength)+",";
  }
  intervals = intervals.substring(0, intervals.length()-1);

  for (int j=0; j<10; j++) {

    for (int i=0; i<numServos; i++) {
      String serialisedJSON =  "{\"servoId\":";

      serialisedJSON+=str(wavePattern[i]);
      serialisedJSON+=",\"arrLength\":";
      serialisedJSON+=str(numPositions);
      serialisedJSON+=",\"setPos\":";
      serialisedJSON+="1";
      serialisedJSON+=",\"positions\":[";
      if (i%2==0) {
        serialisedJSON+= str( angle * j ) ;//str(knobValue);
      } else {
        serialisedJSON+= str( angle * (10-j) ) ;//str(knobValue);
      }

      serialisedJSON+="],\"intervals\":[";
      serialisedJSON+=intervals;
      serialisedJSON+="]}";

      println(serialisedJSON);
      client.publish("/kennedy", serialisedJSON);
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
      serialisedJSON+= str( angle * j ) ;//str(knobValue);
      serialisedJSON+="],\"intervals\":[";
      serialisedJSON+=intervals;
      serialisedJSON+="]}";

      println(serialisedJSON);
      client.publish("/kennedy", serialisedJSON);
      delay(50);
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
      serialisedJSON+= str( angle * j ) ;//str(knobValue);
      serialisedJSON+="],\"intervals\":[";
      serialisedJSON+=intervals;
      serialisedJSON+="]}";

      println(serialisedJSON);
      client.publish("/kennedy", serialisedJSON);
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
  client.publish("/kennedy", serialisedJSON);
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
    serialisedJSON+=str(numPositions-1);
    serialisedJSON+=",\"setPos\":";
    serialisedJSON+="0";
    serialisedJSON+=",\"positions\":[";
    serialisedJSON+=positions;
    serialisedJSON+="],\"intervals\":[";
    serialisedJSON+=intervals;
    serialisedJSON+="]}";

    println(serialisedJSON);
    client.publish("/kennedy", serialisedJSON);
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
    client.publish("/kennedy", serialisedJSON);
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
  //  client.publish("/kennedy", "{\"servoId\":3,\"arrLength\":5,\"positions\":[0,10,20,30,45],\"intervals\":[900,6000,900,6000,1000]}");
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
  //client.subscribe("/mouseX");
  //client.subscribe("/mouseY");
}

void messageReceived(String topic, byte[] payload) {
  //println("new message: " + topic + " - " + new String(payload));
  String pl  = new String(payload);

  if (topic.equals("/mouseX")) {
    x = int(pl);
  }
  if (topic.equals("/mouseY")) {
    y = int(pl);
  }
  // x = incoming message on topic mouseX
}

void connectionLost() {
  println("connection lost");
}


void serialEvent(Serial myPort) {
  // read a byte from the serial port:
  inString = myPort.readString().trim();
  //if (inString.length()==3) println(inString);
}
