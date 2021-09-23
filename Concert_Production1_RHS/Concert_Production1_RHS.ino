#include <ArduinoJson.h>

#include <ServoObject.h>

#include <WiFi.h>
#include <MQTT.h>
//

//

const char ssid[] = "TP-Link_14DD";
const char pass[] = "";
//const char ssid[] = "x";
//const char pass[] = "x";
WiFiClient net;
MQTTClient client;

//adapted from https://github.com/256dpi/arduino-mqtt

/***************************************************
  This is an example for our Adafruit 16-channel PWM & Servo driver
  Servo test - this will drive 8 servos, one after the other on the
  first 8 pins of the PCA9685
  Pick one up today in the adafruit shop!
  ------> http://www.adafruit.com/products/815
  These drivers use I2C to communicate, 2 pins are required to
  interface.
  Adafruit invests time and resources providing this open source code,
  please support Adafruit and open-source hardware by purchasing
  products from Adafruit!
  Written by Limor Fried/Ladyada for Adafruit Industries.
  BSD license, all text above must be included in any redistribution
 ****************************************************/

#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// called this way, it uses the default address 0x40


//we now have one pwm objhect for the servos and another for the LEDS
//Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
//Adafruit_PWMServoDriver LEDpwm = Adafruit_PWMServoDriver();

//NK edit for x2 PCA9865 addresses

Adafruit_PWMServoDriver board1 = Adafruit_PWMServoDriver(0x40);
Adafruit_PWMServoDriver board2 = Adafruit_PWMServoDriver(0x41);

#define SERVOMIN  120 // This is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  480 // This is the 'maximum' pulse length count (out of 4096)

//change this to the number of servos you want
#define NUM_SERVOS 32

#define SERVO_FREQ 50 // Analog servos run at ~50 Hz updates

int servoPositionsA [] = {0, 45, 90};//, 135, 180, 135, 90, 45}; //, 180, 170, 160, 45, 0};
int servoIntervalsA [] = {1000, 2000, 1000};//, 2000, 500, 1000, 1500, 2000}; //, 2000, 500, 2000, 1500, 1000};




StaticJsonDocument<512> doc;

//this is our LED controller. You can make as many as you want or make an array like the below
ServoObject led(1, 0, SERVOMIN, SERVOMAX, 1000);

//make sure the number of objects below matches NUM_SERVOS
ServoObject servos [NUM_SERVOS] = {
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000)

};

//ignore this it's just for the networkign stuff
void connectAndSubscribe() {
  Serial.print("checking wifi...");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(1000);

  }

  Serial.print("\nconnecting...");
  while (!client.connect("arduino", "public", "public")) {
    Serial.print(".");
    delay(1000);
  }

  Serial.println("\nconnected!");

  client.subscribe("/kennedyLEFTHANDSIDE");

}

//this is also for the networking
void messageReceived(String &topic, String &payload) {
 // Serial.println("incoming: " + topic + " - " + payload);



  DeserializationError error = deserializeJson(doc, payload);

  if (error) {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return;
  }

  // const char* servoId = doc["servoId"];
  int  servoId = doc["servoId"];
  int arrLength = doc["arrLength"];
  int  setPos = doc["setPos"];
  if (setPos == 0) {
  //  Serial.print("servoId : ");
    ////.Serial.println(servoId);

    //Serial.print("arrLength : ");
   // Serial.println(arrLength);

    int servoPositions [20] ;
    int servoIntervals [20] ;

    for (int i = 0; i < 20; i++) {
      servoPositions[i] = -1;
      servoIntervals[i] = -1;
    }


    for (int i = 0; i < arrLength; i++) {
      servoPositions[i] = doc["positions"][i];
      servoIntervals[i] = doc["intervals"][i];

//      Serial.print("index : ");
//      Serial.print(i);
//      Serial.print("position : ");
//      Serial.print(servoPositions[i]);
//      Serial.print(", interval : ");
//      Serial.println(servoIntervals[i]);
    }


    servos[servoId].setArrays(servoPositions, servoIntervals, arrLength);
    servos[servoId].setUpdate(true);
  }
  else if (setPos == 1) {
    servos[servoId].setPos(doc["positions"][0]);
    servos[servoId].setUpdate(false);
  }
}
void setup() {
  Serial.begin(115200);
 // Serial.println("9 channel Servo test!");
  //WiFi.enableSTA(true);//NK EDIT
  WiFi.begin(ssid, pass);

  // Note: Local domain names (e.g. "Computer.local" on OSX) are not supported
  // by Arduino. You need to set the IP address directly.
  client.begin("public.cloud.shiftr.io", net);
  //client.begin("192.168.0.60", net);
  client.onMessage(messageReceived);
  connectAndSubscribe();

  //comment all out
  //pwm.begin();
  //LEDpwm.begin();
  //LEDpwm.setPWMFreq(60);
  //pwm.setOscillatorFrequency(27000000);
  //pwm.setPWMFreq(SERVO_FREQ);  // Analog servos run at ~50 Hz updates

  //NK edit
  board1.begin();
  board2.begin();
  board1.setPWMFreq(SERVO_FREQ);
  board2.setPWMFreq(SERVO_FREQ);

  delay(10);

  //this is a for loop. it goes through things one at a time
  for (int i = 0; i < NUM_SERVOS; i++) {

    //this is where I assign the servo list of positions and intervals
    servos[i].setArrays(servoPositionsA, servoIntervalsA, 3);
    servoIntervalsA[2] += 1500;
  }
  //  //set the arrays for our first servo
  //  servos[0].setArrays(servoPositionsA, servoIntervalsA, 4);
  //  //set the arrays for our second servo
  //  servos[1].setArrays(servoPositionsA, servoIntervalsA, 4);

  //led.setArrays(servoPositionsA, servoIntervalsA, 3);
}



void loop() {
  client.loop();
  //once every 10 secs
  if ( millis() % (10 * 1000) ) {
    // check if client is connected
    if (client.connected()) {
      //Serial.println("client connected");

    } else {
      Serial.println("client disconnected");
      connectAndSubscribe();
    }

  }

  for (int i = 0; i < NUM_SERVOS; i++) {

    //servos[i].updateByArrayPos();
    if (servos[i].getUpdate()) {
      servos[i].updateByInterpolatedArrayPos();

      //      Serial.print(i);
      //      Serial.print(" : ");
      //      Serial.println(servos[i].getPulseLength());
    }
    // pwm.setPWM(i, 0, servos[i].getPulseLength()); //NK edit out

    //NK edit
    if(i<16){
    board1.setPWM(i, 0, servos[i].getPulseLength());
    }
    else{
    board2.setPWM(i-16, 0, servos[i].getPulseLength());
    }
  }




  //  led.updateByInterpolatedArrayPos();
  //  int servoPWM = led.getLEDPulseLength();
  //  LEDpwm.setPWM(5, 0, servoPWM);


  //delay(10);
}
