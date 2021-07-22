
#include <ServoObject.h>

#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// called this way, it uses the default address 0x40


//we now have one pwm objhect for the servos and another for the LEDS
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
Adafruit_PWMServoDriver LEDpwm = Adafruit_PWMServoDriver();

#define SERVOMIN  120 // This is the 'minimum' pulse length count (out of 4096)
#define SERVOMAX  480 // This is the 'maximum' pulse length count (out of 4096)

//change this to the number of servos you want
#define NUM_SERVOS 4

#define SERVO_FREQ 50 // Analog servos run at ~50 Hz updates

int servoPositionsA [] = {0, 45, 90};//, 135, 180, 135, 90, 45}; //, 180, 170, 160, 45, 0};
int servoIntervalsA [] = {1000, 2000, 1000};//, 2000, 500, 1000, 1500, 2000}; //, 2000, 500, 2000, 1500, 1000};





//this is our LED controller. You can make as many as you want or make an array like the below
ServoObject led(1, 0, SERVOMIN, SERVOMAX, 1000);

//make sure the number of objects below matches NUM_SERVOS
ServoObject servos [NUM_SERVOS] = {
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000),
  ServoObject(1, 0, SERVOMIN, SERVOMAX, 1000)

};


void setup() {
  Serial.begin(9800);
  Serial.println("LED/Servo test");


  
  pwm.begin();
  LEDpwm.begin();
  LEDpwm.setPWMFreq(60);
  pwm.setOscillatorFrequency(27000000);
  pwm.setPWMFreq(SERVO_FREQ);  // Analog servos run at ~50 Hz updates

  delay(10);

  //this is a for loop. it goes through things one at a time
  for (int i = 0; i < NUM_SERVOS; i++) {

    //this is where I assign the servo list of positions and intervals
    servos[i].setArrays(servoPositionsA, servoIntervalsA, 3);
    //here I'm increasing the delay to the last movement of each servo cumulatively
    servoIntervalsA[2]+=1500;
  }

  //this is how you set the arrays for individual servos
//  //set the arrays for our first servo
//  servos[0].setArrays(servoPositionsA, servoIntervalsA, 4);
//  //set the arrays for our second servo
//  servos[1].setArrays(servoPositionsA, servoIntervalsA, 4);
  
  led.setArrays(servoPositionsA, servoIntervalsA, 3);
}



void loop() {

  
  for (int i = 0; i < NUM_SERVOS; i++) {
    //function below will move from one pos to another at the intervals given
    //servos[i].updateByArrayPos();

    //move from position to position by small increments
    servos[i].updateByInterpolatedArrayPos();
    //get the hcurrent pwm from the servo object and use it to assign to the pwm channel
    pwm.setPWM(i, 0, servos[i].getPulseLength());
  }

  

  //do the same for an LED on PWM channel 5
  led.updateByInterpolatedArrayPos();
  LEDpwm.setPWM(5, 0, led.getLEDPulseLength());


  delay(10);
}
