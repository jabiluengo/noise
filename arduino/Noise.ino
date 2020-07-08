/*
Noise: Sistema de alerta y monitorización del ruido en un aula
Captura el nivel de presión sonora mediante un sensor de sonido analógico y lo muestra visualmente con una tira de leds con los colores de un semáforo.
A la vez envía cada cierto tiempo el dato de presión sonora a Thingspeak para su visualización y posterior tratamiento.
Las líneas de código comentadas corresponden a la monitorización serie que ralentizan el programa. Quitar los comentarios para depurar el código
Creado por Jabi Luengo
*/
 
// Librerías utilizadas
#include "arduino_secrets.h"
#include <TimeAlarms.h>
#include "math.h"
#include <Smoothed.h> 	// Created by Matthew Fryer
#include "ThingSpeak.h"
#include <WiFiNINA.h>
#include <Adafruit_NeoPixel.h>


// Definiciones de la parte de conexión y envío de datos a Thingspeak
char ssid[] = SECRET_SSID;    //  your network SSID (name) 
char pass[] = SECRET_PASS;   // your network password
int keyIndex = 0;            // your network key Index number (needed only for WEP)
WiFiClient  client;
unsigned long myChannelNumber = SECRET_CHANNEL;
const char * myWriteAPIKey = SECRET_API;
const int thing_time = 5; // Cada cuántos segundos se envía el dato a Thingspeak


// Definiciones de la sensorización
#define SENSOR_PIN A1    // Pin de conexionado del sensor 
Smoothed <float> mySensor; // Objeto de tipo Smoothed donde se guarda el nivel sonoro suavizado
const int sanples = 100; // Cuántas muestras se utilizan en el suavizado
const int dBmin = 50; // Presión sonora mínima: equivale al verde puro en el semáforo
const int dBmax = 80; // Presión sonora máxima: equivale al rojo puro en el semáforo
const float vc = 20; // Variable para transformar la tensión obtenida por el sensor analógico en presión sonora
const float vm = 40; // Variable para transformar la tensión obtenida por el sensor analógico en presión sonora
float dB = dBmin;
const int delay_sanple = 2;


// Definiciones del control de LEDS
int led_i = 0;
#ifdef __AVR__
 #include <avr/power.h> // Required for 16 MHz Adafruit Trinket
#endif
#define LED_PIN 8// Pin utilizado para el control de la tira de Leds
#define LED_COUNT 35 // Cuántos Leds tiene la tira
Adafruit_NeoPixel pixels(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);
// Argument 1 = Number of pixels in NeoPixel strip
// Argument 2 = Arduino pin number (most are valid)
// Argument 3 = Pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
//   NEO_RGBW    Pixels are wired for RGBW bitstream (NeoPixel RGBW products)


void ThingSpeak_alarm() // Alarma de envío de datos a Thingspeak
{
  // Connect or reconnect to WiFi
  if(WiFi.status() != WL_CONNECTED){
    //Serial.print("Attempting to connect to SSID: ");
    //Serial.println(SECRET_SSID);
    while(WiFi.status() != WL_CONNECTED){
      WiFi.begin(ssid, pass); // Connect to WPA/WPA2 network. Change this line if using open or WEP network
      //Serial.print(".");
      delay(5000);     
    } 
    //Serial.println("\nConnected.");
  }
  // Write to ThingSpeak. There are up to 8 fields in a channel, allowing you to store up to 8 different
  // pieces of information in a channel.  Here, we write to field 1.
  int x = ThingSpeak.writeField(myChannelNumber, 1, dB, myWriteAPIKey);
  //if(x == 200){
  //  Serial.println("Channel update successful.");
  //}
  //else{
  //  Serial.println("Problem updating channel. HTTP error code " + String(x));
  //}

}

long mapf(float x, float in_min, float in_max, float out_min, float out_max){ // Función de mapeo de variables flotantes
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  }


void setup() {
  
  // These lines are specifically to support the Adafruit Trinket 5V 16 MHz.
  // Any other board, you can remove this part (but no harm leaving it):
  #if defined(__AVR_ATtiny85__) && (F_CPU == 16000000)
  clock_prescale_set(clock_div_1);
  #endif

  pixels.begin();
  Serial.begin(9600);
	mySensor.begin(SMOOTHED_EXPONENTIAL, sanples); // Utilizamos el suavizado con el filtro lineal recursivo exponencial
  mySensor.clear();
  
  Alarm.timerRepeat(thing_time, ThingSpeak_alarm);

  if (WiFi.status() == WL_NO_MODULE) {
    //Serial.println("Communication with WiFi module failed!");
    // don't continue
    while (true);
  }

  String fv = WiFi.firmwareVersion();
  if (fv != "1.0.0") {
    //Serial.println("Please upgrade the firmware");
  }
    
  ThingSpeak.begin(client);  //Initialize ThingSpeak
}



void loop() {

   
  float currentSensorValue = analogRead(SENSOR_PIN); // Leemos el valor del sensor analógico
  mySensor.add(currentSensorValue); // Añadimos el valor al objeto
    
  float smoothedSensorValueExp = mySensor.get(); // Obtenemos suavizado exponencial de las muestras
  if (smoothedSensorValueExp > vc) dB=20*log10(smoothedSensorValueExp-vc)+vm; // Cálculo de la presión sonora mediante fórmula logarítmica
  //else dB=vc;
  float show=dB;
  if (dB > dBmax) show=dBmax; // Si la presión sonora calculada excede la máxima, la recortamos (color rojo)
  if (dB < dBmin) show=dBmin; // Si la presión sonora calculada excede la mínima, la recortamos (color verde)
    
  float mapedsmooth = mapf(show, dBmin, dBmax, 21845, 0); // Mapeamos el valor de presión sonora al intervalo de colores verde-rojo de la paleta HSV. El verde corresponde al valor 21845 y el rojo al valor 0
  Serial.print(smoothedSensorValueExp);
  Serial.print("  ");
  Serial.print(dB);
  Serial.print("  ");
  Serial.println(mapedsmooth);
  uint32_t rgbcolor = pixels.ColorHSV(mapedsmooth);

  if ((led_i != 11) && (led_i != 23)){ // Los pixels 11 y 23 no los utilizamos por el doblado de la tira
    pixels.setPixelColor(led_i, rgbcolor); //encendemos cada pixel con el valor suavizado actual obteniendo un efecto visual
    pixels.show();
    }
  if (led_i >= 34) led_i = 0;
    else led_i++;
  
  // Si queremos utilizar el último valor guardado
  // float lastValueStoredExp = mySensor.getLast();

  Alarm.delay(delay_sanple); // Delay necesario para el funcionamiento de las Alarmas
}
