#include <ServoObject.h>

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

int servoPositionsA [] ={0,90,180,170,160,45,0};
int servoIntervalsA [] ={1000,5000,2000,500,2000,1500,1000};


int servoPositionsB [] ={0,180,18,45,10,95,0};
int servoIntervalsB [] ={1000,5000,2000,500,2000,1500,1000};


ServoObject  servoA (1, 0, SERVOMIN, SERVOMAX, 1000);
ServoObject  servoB (1, 0, SERVOMIN, SERVOMAX, 1000);


void setup() {
  Serial.begin(9600);
  Serial.println("9 channel Servo test!");

  pwm.begin();

  pwm.setOscillatorFrequency(27000000);
  pwm.setPWMFreq(SERVO_FREQ);  // Analog servos run at ~50 Hz updates

  delay(10);

  servoA.setArrays(servoPositionsA,servoIntervalsA,7);
  servoB.setArrays(servoPositionsB,servoIntervalsB,7);

}


void loop() {


  servoA.updateByArrayPos();
  pwm.setPWM(0, 0, servoA.getPulseLength());

  servoB.updateByArrayPos();
  pwm.setPWM(1, 0, servoB.getPulseLength());


  delay(10);
}
