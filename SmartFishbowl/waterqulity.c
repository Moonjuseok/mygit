/*

//With Arduino.. Not .C

unsigned long int avgValue;     //Store the average value of the sensor feedback
int i=0;
void setup()
{
    Serial.begin(9600);
    pinMode(A0, INPUT);
    pinMode(A1, OUTPUT);
}
void loop()
{
    float sensorValue;
    int m;
    long sensorSum;
    int buf[10];                //buffer for read analog
  for(int i=0;i<10;i++)       //Get 10 sample value from the sensor for smooth the value
  { 
    buf[i]=analogRead(A0);//Connect the PH Sensor to A0 port
    delay(10);
  }
  for(int i=0;i<9;i++)        //sort the analog from small to large
  {
    for(int j=i+1;j<10;j++)
    {
      if(buf[i]>buf[j])
      {
        int temp=buf[i];
        buf[i]=buf[j];
        buf[j]=temp;
      }
    }
  }
       avgValue=0;
 
      for(int i=2;i<8;i++)                      //take the average value of 6 center sample
      avgValue+=buf[i];
    
     sensorValue =   avgValue/6;
     Serial.print(sensorValue);
     Serial.println(" ");

    Serial.print(" the PH value is");
    Serial.print(7-1000*(sensorValue-365)*Vref/59.16/1023,2);
    Serial.println(" ");
    delay(1000);


} */