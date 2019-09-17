#ifndef LIDAR_H
#define LIDAR_H

#include "mbed.h"
#define RING_BUFFER_SIZE 36
#define HEADER_FIRST_BYTE 0x59
#define HEADER_SECOND_BYTE 0x59
#define SENSOR_FREQ 10000   // [us] 10ms
#define DEFAULT_BAUD 115200
class Lidar : public Serial {
    public :
        Lidar(PinName serialTX, PinName serialRX);
        int getDistance();
        int getStrength();
    private :
        void recieveData();
        void decode();      // decode buffered data
        enum {HEADER1, HEADER2, DATA, BCC} state;
        uint8_t index;
        uint8_t checkSum;
        Ticker decodeTicker;// decode every 500us
        int distance;
        int strength;
        CircularBuffer<uint8_t,RING_BUFFER_SIZE> buff;
        uint8_t *data;      // store decoded data
};
#endif