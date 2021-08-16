/*
  Morse.h - Library for flashing Morse code.
  Created by David A. Mellis, November 2, 2007.
  Released into the public domain.
*/
#ifndef ServoObject_h
#define ServoObject_h

#include "Arduino.h"

#define MAX_NUMBER_POSITIONS 20
class ServoObject
{
public:
  ServoObject(int _speed, int _pos, int _servoMin, int _servoMax, int _inc);
  void updateOsc();
  void updateByArrayPos();
  void updateByInterpolatedArrayPos();
  void setArrays(int *_posList, int *_intervalList, int _numPositions);
  void setPos(int _pos);
  void reset(int _speed, int _pos, int _servoMin, int _servoMax, int _inc);
  int getPulseLength();
  int getLEDPulseLength();
  void setUpdate(bool _update);
  boolean getUpdate();
  
private:
  int speed;
  int inc;
  float pos;
  int numSubdivisions;
  int subDivisionIndex;
  // int* posList ;
  // int* intervalList ;
  int posList[20];
  int intervalList[20];
  long startTime;
  int servoMin;
  int servoMax;
  int index;
  int numPositions;
  boolean servoUpdate;
  
};

#endif