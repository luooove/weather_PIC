/*
2014年9月21日
Designer：骆晓祥 刘宇林 王衡
测量值：	传感器						        端口
温湿度		DTH11						数字口3
PM2.5		GP2Y1010AU0F 				        模拟口A0 数字口2
气压		BMP180						
液位		液位传感器（电容）			                模拟口A11
风速		光电开关	
光线		光线传感器 模拟输出 			        模拟口A6

				
*/

//#include <MsTimer2.h>
/*******Water_Level**********/
int analogPin = A11; //水位传感器连接到模拟口1
int val = 0; //定义变量val 初值为0
int data = 0; //定义变量data 初值为0

/********温湿度**********/
#include <dht11.h>
dht11 DHT11;
#define DHT11PIN 3

/*******PM2.5**********/
int dustPin=A0;
float dustVal=0;
int ledPower=2;
int delayTime=280;
int delayTime2=40;
float offTime=9680;

/*******Wind_Speed**********/
float Wind_Speed=0;
int wind_count=0;
int pbIn = 3;

/*******Wind_Speed**********/
int Light = A6;
int Light_val=0;

float Water_Level_Update=0;
float PM25_Update=0;
float Humidity_Update=0;
float Temperature_Update=0;
float Wind_Speed_Update=0;
float Light_Update=0;

void setup(){
    Serial.begin(115200);
    pinMode(ledPower,OUTPUT);
    pinMode(dustPin, INPUT);
    Serial.println("DHT11 TEST PROGRAM ");
    Serial.print("LIBRARY VERSION: ");
    Serial.println(DHT11LIB_VERSION);
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
    Serial.print(Water_Level_Update);
    Serial.print("|");
    Serial.print(PM25_Update);//
    Serial.print("|");
    Serial.print(Humidity_Update);
    Serial.print("|");
    Serial.print(Temperature_Update);
    Serial.print("|");
    Serial.print(Wind_Speed_Update);
    Serial.print("|");
    Serial.print(Light_Update);
    Serial.print("|");
    Serial.println(1013);
    delay(1000);
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
  //  Serial.println((float(dustVal/1024)-0.0356)*120000*0.035,2);
    PM25_Update = (float(dustVal/1024)-0.0356)*120000*0.035;
}


/***********************************/
void Updata_Temperature_Humidity()
{
      int chk = DHT11.read(DHT11PIN);
      //Serial.print("Read sensor: ");
      switch (chk)
      {
        case DHTLIB_OK: 
                 //   Serial.println("OK"); 
                    break;
        case DHTLIB_ERROR_CHECKSUM: 
                    Serial.println("Checksum error"); 
                    break;
        case DHTLIB_ERROR_TIMEOUT: 
                    Serial.println("Time out error"); 
                    break;
        default: 
                    Serial.println("Unknown error"); 
                    break;
      }
    
     // Serial.print("Humidity (%): ");
    //  Serial.println((float)DHT11.humidity, 2);
      Humidity_Update = (float)DHT11.humidity;
    //  Serial.print("Temperature (oC): ");
    //  Serial.println((float)DHT11.temperature, 2);
      Temperature_Update = (float)DHT11.temperature;
     // delay(2000);
}


double Fahrenheit(double celsius) 
{
        return 1.8 * celsius + 32;
}    //摄氏温度度转化为华氏温度

double Kelvin(double celsius)
{
        return celsius + 273.15;
}     //摄氏温度转化为开氏温度

// 露点（点在此温度时，空气饱和并产生露珠）
// 参考: http://wahiduddin.net/calc/density_algorithms.htm 
double dewPoint(double celsius, double humidity)
{
        double AA0= 373.15/(273.15 + celsius);
        double SUM = -7.90298 * (AA0-1);
        SUM += 5.02808 * log10(AA0);
        SUM += -1.3816e-7 * (pow(10, (11.344*(1-1/AA0)))-1) ;
        SUM += 8.1328e-3 * (pow(10,(-3.49149*(AA0-1)))-1) ;
        SUM += log10(1013.246);
        double VP = pow(10, SUM-3) * humidity;
        double T = log(VP/0.61078);   // temp var
        return (241.88 * T) / (17.558-T);
}

// 快速计算露点，速度是5倍dewPoint()
// 参考: http://en.wikipedia.org/wiki/Dew_point
double dewPointFast(double celsius, double humidity)
{
        double a = 17.271;
        double b = 237.7;
        double temp = (a * celsius) / (b + celsius) + log(humidity/100);
        double Td = (b * temp) / (a - temp);
        return Td;
}

