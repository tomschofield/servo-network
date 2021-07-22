/*
  Morse.cpp - Library for flashing Morse code.
  Created by David A. Mellis, November 2, 2007.
  Released into the public domain.
*/

#include "Arduino.h"
#include "ServoObject.h"

ServoObject::ServoObject(int _speed, int _pos, int _servoMin, int _servoMax, int _inc)
{

    speed = _speed;
    pos = _pos;

    startTime = millis();
    servoMin = _servoMin;
    servoMax = _servoMax;
    inc = _inc;
    index = 0;
    subDivisionIndex = 0;
    numSubdivisions = 100;
    // posList = _posList;
}
void ServoObject::setArrays(int *_posList, int *_intervalList, int _numPositions)
{
    numPositions = _numPositions;

    pos = 0;

    for (int i = 0; i < MAX_NUMBER_POSITIONS; i++)
    {
        intervalList[i] = -1;
        posList[i] = -1;
    }

    for (int i = 0; i < numPositions; i++)
    {
        intervalList[i] = _intervalList[i];
        posList[i] = _posList[i];
    }

    index = 0;
    inc = intervalList[index];

    startTime = millis();
}
void ServoObject::update()
{
    if (millis() - startTime > inc)
    {
        pos += speed;
        if (pos >= 180 || pos <= 0)
            speed *= -1;
        startTime = millis();
    }
}

int ServoObject::getPulseLength()
{
    return map(pos, 0, 180, servoMin, servoMax);
}
int ServoObject::getLEDPulseLength()
{
    return map(pos, 0, 180, 0, 4096);
}
void ServoObject::updateByArrayPos()
{
    if (millis() - startTime > inc)
    {
        //-1 are our non valid spaces if we've found one we've got to the end of our list of valid values and must restart
        if (posList[index] == -1)
            index = 0;

        pos = posList[index];
        inc = intervalList[index];
        index++;
        if (index >= numPositions)
            index = 0;
        startTime = millis();
    }
}
void ServoObject::updateByInterpolatedArrayPos()
{

    if (millis() - startTime > inc)
    {

        //first work out a list of intermediate timings and positions
        /*

        */
        float dividedPosSize;
        float dividedIntervalSize;

        //as long as we're not at the end of the list (this check should be unnecessary anyway )
        if (index < numPositions - 1)
        {
            dividedPosSize = (float)((float)( posList[index+1] - posList[index ])) / numSubdivisions;
            dividedIntervalSize = intervalList[index] / numSubdivisions;
        }
        //if we are then the next position is the first one in the list
        else
        {
            dividedPosSize = (float)((float)(posList[0]-posList[index] )) / numSubdivisions;
            dividedIntervalSize = intervalList[index] / numSubdivisions;
        }

        inc = dividedIntervalSize;

        //-1 are our non valid spaces if we've found one we've got to the end of our list of valid values and must restart
        if (posList[index] == -1)
        {
            index = 0;
        }

        // pos = posList[index];
        pos += dividedPosSize;
        // Serial.print("current pos: ");

        // Serial.print(posList[index]);
        // Serial.print(", next pos: ");
        // if (index < numPositions - 1)
        // {
        //     Serial.print(posList[index + 1]);
        // }
        // else
        // {
        //     Serial.print(posList[0]);
        // }
        // Serial.print(", dividedPosSize: ");
        // Serial.print(dividedPosSize);
        // Serial.print(", dividedIntervalSize: ");
        // Serial.print(dividedIntervalSize);

        // Serial.print(", subDivisionIndex: ");
        // Serial.print(subDivisionIndex);

        // Serial.print(", pos: ");
        // Serial.println(pos);

        //inc = intervalList[index];
        subDivisionIndex++;
        if (subDivisionIndex == numSubdivisions - 1 )
        {
            index++;
            subDivisionIndex=0;
            if (index >= numPositions)
            {
                index = 0;
            }
        }
        startTime = millis();
    }
}

void ServoObject::reset(int _speed, int _pos, int _servoMin, int _servoMax, int _inc)
{
    speed = _speed;
    pos = _pos;
    // posList = _posList;
    startTime = millis();
    servoMin = _servoMin;
    servoMax = _servoMax;
    inc = _inc;
}