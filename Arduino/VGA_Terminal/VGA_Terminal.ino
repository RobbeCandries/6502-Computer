/*
  VGA Terminal

  This program serves as a serial terminal to communicate with the 6502 computer over the Serial2 port using an ESP32.
  It features two main functions, each running on a different core of the ESP32:
  1. VGA Display Handler
  2. PS2 Keyboard Handler

  - The VGA Display Handler reads incoming data from the Serial2 port and displays it on a VGA monitor.
  - The PS2 Keyboard Handler reads input from a PS2 keyboard and sends it to the Serial2 port.
*/


#include <ESP32Lib.h>
#include <Ressources/Font6x8.h>
#include <PS2Keyboard.h>

// Pin configuration
const int redPin = 14;
const int greenPin = 19;
const int bluePin = 27;
const int hsyncPin = 32;
const int vsyncPin = 33;

// Define the pins for the PS2 keyboard
const int DataPin = 39;
const int IRQpin = 36;

// VGA Device
VGA3Bit vga;

// Keyboard device
PS2Keyboard keyboard;

// Function to handle VGA
void handleVGA(void *parameter) {
  while (true) {
    // Check if data is available to read
    if (Serial2.available() > 0) {
      // Read the incoming byte
      char incomingByte = Serial2.read();

      // Check if the incoming byte is a newline character
      if (incomingByte == '\r') {
        // If Enter key is pressed, print a message
        vga.println();
      } else {
        vga.print(incomingByte);
      }
    }
    delay(1); // Add a small delay to prevent watchdog timeout
  }
}

// Function to handle PS2 keyboard
void handlePS2Keyboard(void *parameter) {
  while (true) {
    // Handle keyboard
    if (keyboard.available()) {
      // Read the key
      char c = keyboard.read();

      if (c == PS2_ENTER) {
        Serial2.println();
      } else if (c == PS2_TAB) {
        Serial2.print("\t");
      } else if (c != 0) {
        // Print the key to the serial monitor
        Serial2.print(c);
      }
    }
    delay(1); // Add a small delay to prevent watchdog timeout
  }
}

void setup() {
  // Init serial
  Serial2.begin(19200);

  // Start VGA on the specified pins
  vga.init(vga.MODE400x300, redPin, greenPin, bluePin, hsyncPin, vsyncPin);

  // Make the background blue
  vga.clear(vga.RGBA(0, 0, 0));
  vga.backColor = vga.RGB(0, 0, 0);

  // Select the font
  vga.setFont(Font6x8);

  // Initialize keyboard
  keyboard.begin(DataPin, IRQpin, PS2Keymap_Belgian);

  // Create a task for handling VGA on core 1
  xTaskCreatePinnedToCore(
    handleVGA,    // Function to be called
    "handleVGA",  // Name of the task
    10000,        // Stack size (bytes)
    NULL,         // Parameter to pass
    1,            // Task priority
    NULL,         // Task handle
    1             // Core to run the task on (0 or 1)
  );

  // Create a task for handling PS2 keyboard on core 0
  xTaskCreatePinnedToCore(
    handlePS2Keyboard,   // Function to be called
    "handlePS2Keyboard", // Name of the task
    10000,               // Stack size (bytes)
    NULL,                // Parameter to pass
    1,                   // Task priority
    NULL,                // Task handle
    0                    // Core to run the task on (0 or 1)
  );
}

void loop() {
  // The main loop can be empty or used for other tasks
  delay(1); // Add a small delay to prevent watchdog timeout
}
