/*
2014年9月21日
Designer：骆晓祥 刘宇林 王衡
测量值：	传感器						        端口
温度		LM35 				                模拟口A2
湿度		AM1001					        模拟口A4
PM2.5		GP2Y1010AU0F 				        模拟口A0 数字口2
气压		BMP180						
液位		液位传感器（电容）			                模拟口A1
风速		光电开关	
光线		光线传感器 模拟输出 			        模拟口A5

				
*/

//#include <MsTimer2.h>
/*******Water_Level**********/
int analogPin = A1; //水位传感器连接到模拟口1
int val = 0; //定义变量val 初值为0
int data = 0; //定义变量data 初值为0


int len;
char command;
String comdata = "";
int mark =0;
String pressure ;
String pm ;
/*******PM2.5**********/
int dustPin=A0;
float dustVal=0;
int ledPower=13;
int delayTime=280;
int delayTime2=40;
float offTime=9680;

/*******Wind_Speed**********/
float Wind_Speed=0;
int wind_count=0;
int pbIn = 3;

/*******Wind_Speed**********/
int Light = A5;
int Light_val=0;

/*******Humidity**********/
int Humidity = A4;
float Humidity_val=0;

/*******Temperature**********/
int Temperature = A2;
float Temperature_val=0;

float Water_Level_Update=0;
float PM25_Update=0;
float Humidity_Update=0;
float Temperature_Update=0;
float Wind_Speed_Update=0;
float Light_Update=0;

void setup(){
    Serial1.begin(112500);
    pinMode(ledPower,OUTPUT);
    pinMode(dustPin, INPUT);
    Serial.println();
    
   // MsTimer2::set(1000, Caculate_Wind_Speed);        // 中断设置函数，每 1s 进入一次中断
  //  MsTimer2::start();
    attachInterrupt(pbIn, stateChange, FALLING);
}

/****************Main*******************/
/***********************************/
void loop(){
    Updata_PM25();
    Updata_Water_Level();
    Updata_Temperature_Humidity();
    Caculate_Wind_Speed();
    Updata_Wind_Speed();
    Light_Level();
    get_data_serial();
    Serial1.print(Water_Level_Update);//OK
    Serial1.print("|");
    Serial1.print(pm);//pm
    Serial1.print("|");
    Serial1.print(Humidity_Update);//OK
    Serial1.print("|");
    Serial1.print(Temperature_Update);//OK
    Serial1.print("|");
    Serial1.print(Wind_Speed_Update);//OK
    Serial1.print("|");
    Serial1.print(Light_Update);//OK
    Serial1.print("|");
    Serial1.println(pressure);//pressure
    delay(1000);
}


void get_data_serial()
{
    int j = 0;
  while (Serial1.available())
  {
    comdata += char(Serial1.read());
    delay(2);
    mark = 1;
  //  Serial.println("*");
  }
  //Serial.println("123");
 if(mark == 1)
  {
    len=comdata.length();
    if(len>2)
    for(int i=0;i<len;i++){
      command=comdata[i];
       if(command=='a')
       {
         pressure=comdata.substring(1+i,7+i);
         // Serial.print("!!!!");
   //      Serial.println(pressure);
       }
        if(command=='b')
       {
         pm=comdata.substring(1+i,7+i);
         // Serial.print("!!!!");
 //        Serial.println(pm);
       }
    }
   
    comdata = String("");
    mark = 0;
}
}
/***********************************/
void Light_Level()
{
  Light_val = analogRead(Light); //读取模拟值送给变量val
  Light_Update = Light_val;
 // Serial.print("Light_val: "); //串口打印变量data
 // Serial.println(Light_val); //串口打印变量data
}


/***********************************/
void Caculate_Wind_Speed()
{
   Wind_Speed = (float)wind_count/24;
   Wind_Speed_Update = Wind_Speed;
   wind_count=0;
}
void Updata_Wind_Speed()
{
  //Serial.print("Wind Speed: "); //串口打印变量data
  //Serial.println(Wind_Speed,2); //串口打印变量data
}
void stateChange()
{
  wind_count = wind_count+1;
}



/***********************************/
void Updata_Water_Level()
{
    val = analogRead(analogPin); //读取模拟值送给变量val
    Water_Level_Update = val; //变量val 赋值给变量data
   // Serial.println("_______________________");
  //  Serial.print("Water_Level:");
  //  Serial.println(data,2); //串口打印变量data
   // delay(100);
}



/***********************************/
void Updata_PM25()
{
    // ledPower is any digital pin on the arduino connected to Pin 3 on the sensor
    digitalWrite(ledPower,LOW); 
    delayMicroseconds(delayTime);
    dustVal=analogRead(dustPin); 
    delayMicroseconds(delayTime2);
    digitalWrite(ledPower,HIGH); 
    delayMicroseconds(offTime);
   // delay(100);
   // Serial.print("PM2.5:  ");
  //  Serial.println(dustVal,2);
 //   Serial.println((float(dustVal/1024)-0.0356)*120000*0.035,2);
    PM25_Update = (float(dustVal/1024)-0.0356)*120000*0.035;
}


void Updata_Temperature_Humidity()
{
  Humidity_val = analogRead(Humidity); //读取模拟值送给变量val
  Humidity_Update = Humidity_val*5/1024/3*100; //变量val 赋值给变量data
  Temperature_val = analogRead(Temperature); //读取模拟值送给变量val
  Temperature_Update = Temperature_val*0.48828125; //变量val 赋值给变量data
 // Serial.println(Temperature_val);
}
