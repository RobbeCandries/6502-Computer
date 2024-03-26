/* 
 * This is an arduino progam that generates a variable clock signal on pin 13.
 * The delay can be set using the serial monitor.
 * It can be stopped using a toggle button and when stopped it can be 
 * single-stepped by sending something over the serial monitor. This will not
 * affect the delay value for the clock signal.
 */

#define clockPin 13
#define togglePin 9
int delayValue = 100;

void setup() {
  Serial.begin(9600);
  pinMode(clockPin, OUTPUT);
  pinMode(togglePin, INPUT_PULLUP);
  pinMode(8, OUTPUT);
  digitalWrite(8, LOW);
}

void loop() {
  if(digitalRead(togglePin)) {
    // Clock mode
    if(Serial.available())
      delayValue = Serial.parseInt();
    digitalWrite(clockPin, HIGH);
    delay(delayValue);
    digitalWrite(clockPin, LOW);
    delay(delayValue);
  }
  else {
    // Single step mode 
    if(Serial.available()) {
      Serial.readString();
      digitalWrite(clockPin, HIGH);
      delay(10);
      digitalWrite(clockPin, LOW);
      delay(10);
    }
  }
}
