


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


int ledPin = 13;                // LED
int pirPin1 = 25;                 // PIR Out pin
int pirPin2 = 26;                 // PIR Out pin
int pirPin3 = 27;                 // PIR Out pin


int pirStat = 0;                   // PIR status
String pPIRstatuses = "";
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


void setup() {

  //the wee light on the arduino should go on when the PIR is active
  pinMode(ledPin, OUTPUT);

  pinMode(pirPin1, INPUT);
  pinMode(pirPin2, INPUT);
  pinMode(pirPin3, INPUT);


  Serial.begin(115200);
  WiFi.begin(ssid, pass);
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
  if (pPIRstatuses!=PIRstatuses) {
    client.publish("/kennedyPIR", PIRstatuses);
    pPIRstatuses = PIRstatuses;
  }

}
