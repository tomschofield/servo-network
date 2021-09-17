

#include <WiFi.h>
#include <MQTT.h>
//

//

const char ssid[] = "";
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
const int pirPin1 = 27;                 // PIR Out pin
const int pirPin2 = 26;                 // PIR Out pin
const int pirPin3 = 25;                 // PIR Out pin



int pirStat1 = 0;
int pirStat2 = 0;
int pirStat3 = 0;

String pirStatus="000";
String pPirStatus="000";

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

  client.subscribe("/kennedyPIR");

}

//this is also for the networking
void messageReceived(String &topic, String &payload) {
  //nothing here! We just want to send!
  //Serial.println("message");
}
void IRAM_ATTR detectsMovement1() {
  //Serial.println("PIR1 change");
  if (pirStat1 == 0) {
    pirStat1 = 1;
  }
  else {
    pirStat1 = 0;
  }

}

void IRAM_ATTR detectsMovement2() {
  //Serial.println("PIR2 change");
  if (pirStat2 == 0) {
    pirStat2 = 1;
  }
  else {
    pirStat2 = 0;
  }

}
void IRAM_ATTR detectsMovement3() {
  //Serial.println("PIR3 change");
  if (pirStat3 == 0) {
    pirStat3 = 1;
  }
  else {
    pirStat3 = 0;
  }

}
void setup() {
  Serial.begin(115200);
  //WiFi.enableSTA(true);//NK EDIT
  WiFi.begin(ssid, pass);

  //pinMode(ledPin, OUTPUT);

  attachInterrupt(digitalPinToInterrupt(pirPin1), detectsMovement1, CHANGE);
  attachInterrupt(digitalPinToInterrupt(pirPin2), detectsMovement2, CHANGE);
  attachInterrupt(digitalPinToInterrupt(pirPin3), detectsMovement3, CHANGE);


  // Note: Local domain names (e.g. "Computer.local" on OSX) are not supported
  // by Arduino. You need to set the IP address directly.
  client.begin("public.cloud.shiftr.io", net);
  //client.begin("192.168.0.60", net);
  client.onMessage(messageReceived);
  connectAndSubscribe();
  
  client.publish("/kennedyPIR", "PIR ONLINE");
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
      Serial.println("client reconnected");
    }

  }
  char cstr[4];
  sprintf_P(cstr, (PGM_P)F("%1d%1d%1d"), pirStat1, pirStat2, pirStat3);
 
  pirStatus = cstr;
  if(pirStatus!=pPirStatus){
     Serial.println(pirStatus);
      client.publish("/kennedyPIR", pirStatus);
    pPirStatus = pirStatus;
  }
  


  delay(10);
}
