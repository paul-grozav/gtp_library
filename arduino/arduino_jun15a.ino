int ledPin = 13;
int switchPin = 0;

class Tst{
public:
  Tst(){}
  void openLed(int time){
    digitalWrite(ledPin, HIGH);
    delay(time);
  }
  
  void closeLed(int time){
    digitalWrite(ledPin, LOW);
    delay(time);
  }
};

void setup(){
  pinMode(ledPin, OUTPUT);
  pinMode(switchPin, INPUT);
  Serial.begin(9600);
}

void loop(){
//  Tst t;
//  t.openLed(1000);
//  t.closeLed(2000);

/*
// Shift blink
   digitalWrite(13, HIGH);
   delay(500);
   digitalWrite(13, LOW);
   digitalWrite(11, HIGH);
   delay(500);
   digitalWrite(11, LOW);
*/  

//BTN
//  digitalWrite(ledPin, digitalRead(switchPin));
//Serial.println(digitalRead(switchPin));
//delay(750);
//digitalWrite(ledPin, digitalRead(switchPin));

// speaker
/*
 digitalWrite(ledPin, HIGH);
 delay(500);
 digitalWrite(ledPin, LOW);
 delay(500);
*/

// Potentiometer
/*
int v = analogRead(switchPin);
Serial.println(v);
digitalWrite(ledPin, HIGH);
delay(v);
digitalWrite(ledPin, LOW);
delay(v);
*/

// Potentiometer with analogic led
/*
int v = analogRead(switchPin);
Serial.println(v);
analogWrite(5, v);
Serial.println(v);
delay(500);
*/

// Light sensor lights the LED
int v = digitalRead(0);
Serial.println(v);
if(v == HIGH)
}
