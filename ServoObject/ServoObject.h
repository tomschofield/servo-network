/*
  Morse.h - Library for flashing Morse code.
  Created by David A. Mellis, November 2, 2007.
  Released into the public domain.
*/
#ifndef ServoObject_h
#define ServoObject_h

#include "Arduino.h"

class ServoObject
{
  public:
    ServoObject(int _speed,int _pos,int _servoMin, int _servoMax, int _inc);
     void update();
          void updateByArrayPos();

     void setArrays(int* _posList,int* _intervalList, int _numPositions);
    void reset(int _speed,int _pos,int _servoMin, int _servoMax, int _inc);
    int getPulseLength();
  private:
     int speed;
    int inc;
    int pos;
    // int* posList ;
    // int* intervalList ;
    int posList [20];
    int intervalList [20];
    long startTime;
    int servoMin;
    int servoMax;
    int index;
    int numPositions;
   
};

#endif