#include "mbed.h"
#include "DRV8825.h"
#define MOTOR_STEPS_PER_REV 400     // 모터 회전당 기본 스텝수
#define MICRO_STEP_DIV 32           // 마이크로 스텝수
#define MICRO_STEP_PER_REV (MOTOR_STEPS_PER_REV*MICRO_STEP_DIV)// 총
#define DESIRED_STEPS_PER_SEC   (1000/20)                       //50
#define MICRO_DESIRED_STEPS_PER_SEC  (32*DESIRED_STEPS_PER_SEC) // 1600
#define SAMPLE_TIME  (1000000L/MICRO_DESIRED_STEPS_PER_SEC)   //625
#define MAX_STEP (MICRO_STEP_PER_REV/2)   // Half revolution 6400
#define SKIP 16
#include "Lidar.h"
InterruptIn bot(BUTTON1);
DigitalOut led1(LED1);
Lidar tf(PC_6, PC_7);
Serial pc(USBTX, USBRX, 230400);
DRV8825 stepper(D3,D2);
volatile bool f_run=false;
Timer tmr;
void botPress(){
    f_run=!f_run;
}
int main() {

    bot.fall(&botPress);
    tmr.start();
    while(1) {
      if (tmr.read_us()>SAMPLE_TIME){
          tmr.reset();
          if (f_run){
              stepper.scan(0,MAX_STEP);
              int32_t steps=stepper.getSteps();          
              if (steps%SKIP==0){
               // led1=!led1;
               // pc.printf("::,%d,%5.2f\n",steps/32,sonar.read());
                pc.printf("%d,%d.",steps/SKIP, tf.getDistance());
              }
          }
      }  
    }
}
