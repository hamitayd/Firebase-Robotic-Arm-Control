#include <Arduino.h>
#if defined(ESP32)
#include <WiFi.h>
#include <Servo.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#include <Servo.h>
#endif
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

#define WIFI_SSID "MSI8548"
#define WIFI_PASSWORD "38c4M389"

#define API_KEY "-------------------------------" //your API key
#define DATABASE_URL "---------------------------------" // your database url

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Servo nesneleri
Servo servo1, servo2, servo3, servo4;

// Servo pinleri (ESP8266 için D1–D4, ESP32 için 13–16 gibi GPIO numaraları kullan)
#define SERVO1_PIN D1
#define SERVO2_PIN D2
#define SERVO3_PIN D3
#define SERVO4_PIN D4
String sonKonumu[4];
void setup() {
  
  sonKonumu[0]=45;
  sonKonumu[1]=45;
  sonKonumu[2]=45;
  sonKonumu[3]=45;
  Serial.begin(115200);

  // Servo pinlerini başlat
  servo1.attach(SERVO1_PIN);
  servo2.attach(SERVO2_PIN);
  servo3.attach(SERVO3_PIN);
  servo4.attach(SERVO4_PIN);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Ağa bağlanıyor");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Bağlandı. IP Adresi: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  Firebase.signUp(&config, &auth, "", "");
  config.token_status_callback = tokenStatusCallback;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  if (Firebase.RTDB.setString(&fbdo, "/motor_konumlari/durum", "0")) {
    Serial.println("Durum 0 olarak güncellendi.");
  } else {
    Serial.print("Durum güncellenemedi: ");
    Serial.println(fbdo.errorReason());
  }

}

void loop() {
  String durum;
  if (Firebase.RTDB.getString(&fbdo, "/motor_konumlari/durum")) {
  durum = fbdo.to<String>();
  Serial.print("Durum: ");
  Serial.println(durum);
  } 
  else {
  Serial.print("Durum okunamadı: ");
  Serial.println(fbdo.errorReason());
  }
  if (Firebase.RTDB.getString(&fbdo, "/motor_konumlari/motor_1")) {
    String val = fbdo.to<String>();
    Serial.print("Motor 1: ");
    
    while(val.toInt()!=sonKonumu[0].toInt()){
      servo1.write((sonKonumu[0].toInt())*2);
      if(sonKonumu[0].toInt()>val.toInt()){
        sonKonumu[0]=String(sonKonumu[0].toInt()-1);
      }
      else{
        sonKonumu[0]=String(sonKonumu[0].toInt()+1);
      }
      if(durum=="1"){
        delay(1000);
      }
      else{
        delay(2);
      }
      
    }
    sonKonumu[0]=String(val.toInt());
    Serial.println(sonKonumu[0]);
    if (Firebase.RTDB.setString(&fbdo, "/motor_konumlari/durum", "0")) {
    Serial.println("Durum 0 olarak güncellendi.");
  } else {
    Serial.print("Durum güncellenemedi: ");
    Serial.println(fbdo.errorReason());
  }
  } else {
    Serial.println("Motor 1 Hatası: " + fbdo.errorReason());
  }

  if (Firebase.RTDB.getString(&fbdo, "/motor_konumlari/motor_2")) {
    String val = fbdo.to<String>();
    Serial.print("Motor 2: ");
    
    while(val.toInt()!=sonKonumu[1].toInt()){
      servo2.write((sonKonumu[1].toInt())*2);
      if(sonKonumu[1].toInt()>val.toInt()){
        sonKonumu[1]=String(sonKonumu[1].toInt()-1);
      }
      else{
        sonKonumu[1]=String(sonKonumu[1].toInt()+1);
      }
      delay(2);
    }
    sonKonumu[1]=String(val.toInt());
    Serial.println(sonKonumu[2]);
  } else {
    Serial.println("Motor 2 Hatası: " + fbdo.errorReason());
  }

  if (Firebase.RTDB.getString(&fbdo, "/motor_konumlari/motor_3")) {
    String val = fbdo.to<String>();
    Serial.print("Motor 3: ");
    
    while(val.toInt()!=sonKonumu[2].toInt()){
      servo3.write((sonKonumu[2].toInt())*2);
      if(sonKonumu[2].toInt()>val.toInt()){
        sonKonumu[2]=String(sonKonumu[2].toInt()-1);
      }
      else{
        sonKonumu[2]=String(sonKonumu[2].toInt()+1);
      }
      delay(2);
    }
    sonKonumu[2]=String(val.toInt());
    Serial.println(sonKonumu[2]);
  } else {
    Serial.println("Motor 3 Hatası: " + fbdo.errorReason());
  }

  if (Firebase.RTDB.getString(&fbdo, "/motor_konumlari/motor_4")) {
    String val = fbdo.to<String>();
    Serial.print("Motor 4: ");
    
    while(val.toInt()!=sonKonumu[3].toInt()){
      servo4.write((sonKonumu[3].toInt())*2);
      if(sonKonumu[3].toInt()>val.toInt()){
        sonKonumu[3]=String(sonKonumu[3].toInt()-1);
      }
      else{
        sonKonumu[3]=String(sonKonumu[3].toInt()+1);
      }
      delay(2);
    }
    sonKonumu[3]=String(val.toInt());
    Serial.println(sonKonumu[3]);
  } else {
    Serial.println("Motor 4 Hatası: " + fbdo.errorReason());
  }

  delay(1000); // 1 saniyede bir veri çekme
}
