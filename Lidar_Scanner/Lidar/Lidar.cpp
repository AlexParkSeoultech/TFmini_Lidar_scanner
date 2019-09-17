#include "Lidar.h"
extern DigitalOut led1;
Lidar::Lidar(PinName serialTX, PinName serialRX) :
    Serial(serialTX, serialRX, DEFAULT_BAUD),  // Father Class
    distance(0), index(0), checkSum(0) 
    {
    data = new uint8_t[RING_BUFFER_SIZE];
    Serial::attach(callback(this, &Lidar::recieveData));  //Father method
    decodeTicker.attach_us(callback(this, &Lidar::decode), SENSOR_FREQ/20);
    state=HEADER1;
}
void Lidar::recieveData() { //whenever data arrived
    if (readable()){
        uint8_t b=getc();
        if (!buff.full())
            buff.push(b); // to the circular buff
    }
}
void Lidar::decode() {
    uint8_t b;
    if (!buff.empty()){
         buff.pop(b);
        switch (state){
            case HEADER1:
               if (b==HEADER_FIRST_BYTE) state=HEADER2; 
                 break;
            case HEADER2:
               if (b==HEADER_SECOND_BYTE) { 
                  state=DATA; index=0;
                  checkSum = HEADER_FIRST_BYTE + HEADER_SECOND_BYTE;
                }else state=HEADER1;
                 break;                
            case DATA:
                data[index++]=b; checkSum += b;
                if (index==6)
                    state=BCC;
                break;
             case BCC: 
                if (b==checkSum){
                    distance = ((data[1]<<8)|data[0]);
                    strength = ((data[3]<<8)|data[2]);                   
                    led1=!led1;
                }
                state=HEADER1;
        }                  
    }
}       
int Lidar::getDistance() { return distance;}
int Lidar::getStrength(){ return strength;}