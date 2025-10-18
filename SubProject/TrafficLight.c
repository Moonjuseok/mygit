#include <stdio.h>
#include <stdlib.h>

const int SW=9;
const int RED = 12;       //적색 신호등
const int YELLOW = 11;        //황색 신호등
const int GREEN = 10;       //녹색 신호등
const int GREEN2 = 5;       // 보행자 녹색 신호등
const int RED2 = 6;       //보행자 황색 신호등

void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(SW, INPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(YELLOW, OUTPUT);
  pinMode(RED, OUTPUT);
  pinMode(RED2,OUTPUT);
  pinMode(GREEN2, OUTPUT);
}

void loop() {
  while(digitalRead(SW)) {
    while(1) {                   //버튼을 한번 더 누를 때 까지 반복 
//3색 신호등이 켜지게 하기 위한 for 문, LED는 변수    
      for(int LED = 10; LED < 13; LED++) {  
        digitalWrite(LED, HIGH);
//차량 신호등이 녹색일 시 보행자 신호등 적색
        if(LED == GREEN) {
          digitalWrite(RED2, HIGH);
          delay(6000);        //짧으면 햇갈릴 수 있으므로 딜레이를 길게 만듦
          digitalWrite(LED, LOW);
          digitalWrite(RED2, LOW); 
        }
//차량 신호등이 황색일 시 보행자 신호등 적색
        else if(LED == YELLOW) {          
          digitalWrite(RED2, HIGH);
          delay(1000);  //황색 신호등 짧게
          digitalWrite(LED, LOW);
        }
//차량 신호등이 적색일 시 보행자 신호등 녹색
        else {    
          delay(200); // 안전을 위해 차량 적색신호등과 보행자 녹색신호등 사이에 delay 추가
          digitalWrite(RED2, LOW);
          digitalWrite(GREEN2, HIGH); 
          delay(2500);
          for(int LED1 = 0; LED1 < 4; LED1++) {        //보행자 녹색신호가 거의 다 됬을 때 깜빡임
            delay(300);
            digitalWrite(GREEN2, HIGH);
            delay(300);
            digitalWrite(GREEN2, LOW);
          }
          digitalWrite(RED2, HIGH);     // 실제 신호등 처럼 보행자 녹색신호를 짧게 만듦
          delay(3000);
          digitalWrite(LED, LOW); 
          digitalWrite(RED2, LOW);
        }
      }
    }
  }  
}