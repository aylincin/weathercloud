/*
 * MatrixFire.cpp
 *
 *  For testing the MatrixNeoPatterns Fire pattern
 *
 *  You need to install "Adafruit NeoPixel" library under "Tools -> Manage Libraries..." or "Ctrl+Shift+I" -> use "neoPixel" as filter string
 *
 *  Copyright (C) 2019  Armin Joachimsmeyer
 *  armin.joachimsmeyer@gmail.com
 *
 *  This file is part of NeoPatterns https://github.com/ArminJo/NeoPatterns.
 *
 *  NeoPatterns is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/gpl.html>.
 *
 */

#include <Arduino.h>
#include <MatrixNeoPatterns.h>

#define PIN_NEOPIXEL_MATRIX     8
#define MATRIX_NUMBER_OF_COLUMNS 8
#define MATRIX_NUMBER_OF_ROWS    8
/*
 * Specify your matrix geometry as 4th parameter.
 * ....BOTTOM ....RIGHT specify the position of the zeroth pixel.
 * See MatrixNeoPatterns.h for further explanation.
 */
MatrixNeoPatterns NeoPixelMatrix = MatrixNeoPatterns(MATRIX_NUMBER_OF_COLUMNS, MATRIX_NUMBER_OF_ROWS, PIN_NEOPIXEL_MATRIX,
NEO_MATRIX_BOTTOM | NEO_MATRIX_RIGHT | NEO_MATRIX_ROWS | NEO_MATRIX_PROGRESSIVE, NEO_GRB + NEO_KHZ800, NULL);

void setup() {
    pinMode(LED_BUILTIN, OUTPUT);

    Serial.begin(115200);
#if defined(__AVR_ATmega32U4__) || defined(SERIAL_USB) || defined(SERIAL_PORT_USBVIRTUAL)
    delay(2000); // To be able to connect Serial monitor after reset and before first printout
#endif
    // Just to know which program is running on my Arduino
    Serial.println(F("START " __FILE__ " from " __DATE__ "\r\nUsing library version " VERSION_NEOPATTERNS));

    // This initializes the NeoPixel library and checks if enough memory was available
    if (!NeoPixelMatrix.begin(&Serial)) {
        // Blink forever
        while (true) {
            digitalWrite(LED_BUILTIN, HIGH);
            delay(500);
            digitalWrite(LED_BUILTIN, LOW);
            delay(500);
        }
    }
    NeoPixelMatrix.clear();

    Serial.println(F("Fire"));
    NeoPixelMatrix.Fire(42, 30);
}

void loop() {
    NeoPixelMatrix.FireMatrixUpdate();
    NeoPixelMatrix.show();
    NeoPixelMatrix.TotalStepCounter = 42;
    delay(30);
    /*
     * Can set cooling and sparking parameters by potentiometers
     */
    // set cooling. 10 to 25 are sensible with optimum around 14 to 20
    NeoPixelMatrix.PatternLength = map(analogRead(A0), 0, 1023, 2, 40);
    Serial.print(F("Cooling="));
    Serial.println(NeoPixelMatrix.PatternLength);

    // Not yet implemented
//    NeoPixelMatrix.PatternFlags = map(analogRead(A1), 0, 1023, 30, 200);
//    Serial.print(F(" Sparking="));
//    Serial.println(NeoPixelMatrix.PatternFlags);

}
