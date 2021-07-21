#include <ArduinoJson.h>

#include <ServoObject.h>

#include <WiFi.h>
#include <MQTT.h>

const char ssid[] = "VM2516911";
const char pass[] = "Vr6spfsfkcwt";

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
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define SERVOMIN  120 // This is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  480 // This is the 'maximum' pulse length count (out of 4096)


#define SERVO_FREQ 50 // Analog servos run at ~50 Hz updates

int servoPositionsA [] = {0, 90, 180, 170, 160, 45, 0};
int servoIntervalsA [] = {1000, 5000, 2000, 500, 2000, 1500, 1000};


int servoPositionsB [] = {0, 180, 18, 45, 10, 95, 0};
int servoIntervalsB [] = {1000, 5000, 2000, 500, 2000, 1500, 1000};

StaticJsonDocument<512> doc;
ServoObject  servoA (1, 0, SERVOMIN, SERVOMAX, 1000);
ServoObject  servoB (1, 0, SERVOMIN, SERVOMAX, 1000);
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

  client.subscribe("/kennedy");

}


void messageReceived(String &topic, String &payload) {
  Serial.println("incoming: " + topic + " - " + payload);



  DeserializationError error = deserializeJson(doc, payload);

  if (error) {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return;
  }

  // const char* servoId = doc["servoId"];
  int  servoId = doc["servoId"];
  int arrLength = doc["arrLength"];

  Serial.print("servoId : ");
  Serial.println(servoId);

  Serial.print("arrLength : ");
  Serial.println(arrLength);
  
  int servoPositions [20] ;
  int servoIntervals [20] ;

  for (int i = 0; i < 20; i++) {
    servoPositions[i] = -1;
    servoIntervals[i] = -1;
  }


  for (int i = 0; i < arrLength; i++) {
    servoPositions[i] = doc["positions"][i];
    servoIntervals[i] = doc["intervals"][i];

    Serial.print("index : ");
    Serial.print(i);
    Serial.print("position : ");
    Serial.print(servoPositions[i]);
    Serial.print(", interval : ");
    Serial.println(servoIntervals[i]);
  }


  servoA.setArrays(servoPositions, servoIntervals, 5);
}
void setup() {
  Serial.begin(115200);
  Serial.println("9 channel Servo test!");
  WiFi.begin(ssid, pass);

  // Note: Local domain names (e.g. "Computer.local" on OSX) are not supported
  // by Arduino. You need to set the IP address directly.
  client.begin("public.cloud.shiftr.io", net);
  client.onMessage(messageReceived);
  connectAndSubscribe();
  pwm.begin();

  pwm.setOscillatorFrequency(27000000);
  pwm.setPWMFreq(SERVO_FREQ);  // Analog servos run at ~50 Hz updates

  delay(10);

  servoA.setArrays(servoPositionsA, servoIntervalsA, 7);
  servoB.setArrays(servoPositionsB, servoIntervalsB, 7);

}


void loop() {
  client.loop();

  servoA.updateByArrayPos();
  pwm.setPWM(0, 0, servoA.getPulseLength());

  servoB.updateByArrayPos();
  pwm.setPWM(1, 0, servoB.getPulseLength());


  delay(10);
}
