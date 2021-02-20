
#include <Arduino.h>

#include <NeoPatterns.h>

#define INFO // if not defined, no Serial related code should be linked

// Which pin on the Arduino is connected to the NeoPixels?
#define PIN_NEOPIXEL_BAR          6

// construct the NeoPatterns instances
void ownPatterns(NeoPatterns *aLedsPtr);
NeoPatterns bar16 = NeoPatterns(150, PIN_NEOPIXEL_BAR, NEO_GRB + NEO_KHZ800, &ownPatterns);

void setup() {
    //pinMode(LED_BUILTIN, OUTPUT);
    Serial.begin(9600);

    bar16.begin(); // This initializes the NeoPixel library.
    bar16.ColorWipe(COLOR32(0, 0, 02), 50, 0, REVERSE); // light Blue
}

char Incoming_value = 0;
bool killAnimation = false;
void loop() {
    if (Serial.available() > 0)
    {
      // Read the incoming data and store it in the variable
      Incoming_value = Serial.read();
  
      // Print value of Incoming_value in Serial monitor
      Serial.print(Incoming_value);
      Serial.print("\n");
  
      // Checking whether value of the variable
      // is equal to 0
      if (Incoming_value == '0'){
        bar16.ColorSet(bar16.Color(0, 0, 0));
        digitalWrite(8, LOW); // If value is 0, turn OFF the device
        killAnimation = true;
      }
        
  
      // Checking whether value of the variable
      // is equal to 1
      else if (Incoming_value == '1'){
        digitalWrite(8, HIGH); // If value is 1, turn ON the device
        killAnimation = false;
      }
        
    }
  if(!killAnimation){
    bar16.update();
  }
}


/************************************************************************************************************
 * Put your own pattern code here
 * Provided are sample implementation not supporting initial direction DIRECTION_DOWN
 * Full implementation of this functions can be found in the NeoPatterns.cpp file of the NeoPatterns library
 ************************************************************************************************************/
int zones[15];
int zoneSize = 10;
int* generateZones(){
    int zoneCount = bar16.numPixels()/zoneSize;
    for(int i = 0; i < zoneCount; i++){
        zones[i] = i*zoneSize;
    }    
    return zones;
  }

/*
 * set all pixel to aColor1 and let a pixel of color2 move through
 * Starts with all pixel aColor1 and also ends with it.
 */
void UserPattern1(NeoPatterns *aNeoPatterns, color32_t aPixelColor, color32_t aBackgroundColor, uint16_t aIntervalMillis,
        uint8_t aDirection) {
    /*
     * Sample implementation not supporting DIRECTION_DOWN
     */
    aNeoPatterns->ActivePattern = PATTERN_USER_PATTERN1;
    aNeoPatterns->Interval = aIntervalMillis;
    aNeoPatterns->Color1 = aPixelColor;
    aNeoPatterns->LongValue1.BackgroundColor = aBackgroundColor;
    aNeoPatterns->Direction = aDirection;
    aNeoPatterns->TotalStepCounter = aNeoPatterns->numPixels() + 1;
    aNeoPatterns->ColorSet(aBackgroundColor);
    aNeoPatterns->show();
    aNeoPatterns->lastUpdate = millis();
}

/*
 * @return - true if pattern has ended, false if pattern has NOT ended
 */
bool UserPattern1Update(NeoPatterns *aNeoPatterns, bool aDoUpdate) {
    /*
     * Sample implementation not supporting initial direction DIRECTION_DOWN
     */
    if (aDoUpdate) {
        if (aNeoPatterns->decrementTotalStepCounterAndSetNextIndex()) {
            return true;
        }
    }

    int* zoneArray = generateZones();
    int zoneCount = bar16.numPixels()/zoneSize;
    int zoneToFlash = random(zoneCount)-1;
  
    int randomWait = 1000 * random(3);
    int colorNormal = bar16.Color(230, 230, 255, random(100));
    flash(zones[zoneToFlash], colorNormal);
    
    
    bar16.show();
    delay(randomWait);
  

    return false;
}

void flash(int zone, int lightningColorCustom){
    int startLed = zone;
    int middleLed = zone + (zoneSize/2);
    int endLed = zone + zoneSize;
    int lightningColorWeak = bar16.Color(230, 230, 255, random(100));
    int lightningColor = bar16.Color(random(255), random(255), 60, 250);
    int afterFlash = 3 + random(5);

    if(lightningColorCustom){
        lightningColorWeak = lightningColorCustom;
      }
    
    bar16.setPixelColor(middleLed, lightningColor);
    bar16.setPixelColor(middleLed+2, lightningColor);
    bar16.setPixelColor(middleLed-2, lightningColor);
    bar16.show();
    delay(50);
    
    bar16.setPixelColor(endLed-random(30), lightningColorWeak);
    bar16.setPixelColor(startLed+random(30), lightningColorWeak);
    bar16.show();
    delay(80);
    
    bar16.setPixelColor(startLed+random(20), lightningColorWeak);
    bar16.setPixelColor(endLed-random(20), lightningColorWeak);

    bar16.setPixelColor(startLed+random(10), lightningColorWeak);
    bar16.setPixelColor(endLed-random(10), lightningColorWeak);
    bar16.show();
    delay(100);

    bar16.clear();

    for(int i = 0; i < afterFlash; i++){
        bar16.setPixelColor(endLed-random(30), lightningColorWeak);
        bar16.setPixelColor(startLed+random(30), lightningColorWeak);
        bar16.show();
        delay(70);
        
        bar16.setPixelColor(startLed+random(20), lightningColorWeak);
        bar16.setPixelColor(endLed-random(20), lightningColorWeak);
    
        bar16.setPixelColor(startLed+random(10), lightningColorWeak);
        bar16.setPixelColor(endLed-random(10), lightningColorWeak);
        bar16.show();
        delay(100);  
        bar16.clear();
    }   
  }

/*
 * let a pixel of aColor move up and down
 * starts and ends with all pixel cleared
 */
void UserPattern2(NeoPatterns *aNeoPatterns, color32_t aColor, uint16_t aIntervalMillis, uint16_t aRepetitions,
        uint8_t aDirection) {
    /*
     * Sample implementation not supporting DIRECTION_DOWN
     */
    aNeoPatterns->ActivePattern = PATTERN_USER_PATTERN2;
    aNeoPatterns->Interval = aIntervalMillis;
    aNeoPatterns->Color1 = aColor;
    aNeoPatterns->Direction = aDirection;
    aNeoPatterns->Index = 0;
    // *2 for up and down. (aNeoPatterns->numPixels() - 1) do not use end pixel twice.
    // +1 for the initial pattern with end pixel. + 2 for the first and last clear pattern.
    aNeoPatterns->TotalStepCounter = ((aRepetitions + 1) * 2 * (aNeoPatterns->numPixels() - 1)) + 1 + 2;
    aNeoPatterns->clear();
    aNeoPatterns->show();
    aNeoPatterns->lastUpdate = millis();
}

/*
 * @return - true if pattern has ended, false if pattern has NOT ended
 */
bool UserPattern2Update(NeoPatterns *aNeoPatterns, bool aDoUpdate) {
    /*
     * Sample implementation
     */
    if (aDoUpdate) {
        // clear old pixel
        aNeoPatterns->setPixelColor(aNeoPatterns->Index, COLOR32_BLACK);

        if (aNeoPatterns->decrementTotalStepCounterAndSetNextIndex()) {
            return true;
        }
        /*
         * Next index
         */
        if (aNeoPatterns->Direction == DIRECTION_UP) {
            // do not use top pixel twice
            if (aNeoPatterns->Index == (aNeoPatterns->numPixels() - 1)) {
                aNeoPatterns->Direction = DIRECTION_DOWN;
            }
        } else {
            // do not use bottom pixel twice
            if (aNeoPatterns->Index == 0) {
                aNeoPatterns->Direction = DIRECTION_UP;
            }
        }
    }
    /*
     * Refresh pattern
     */
    if (aNeoPatterns->TotalStepCounter != 1) {
        // last pattern is clear
        aNeoPatterns->setPixelColor(aNeoPatterns->Index, aNeoPatterns->Color1);
    }
    return false;
}

/*
 * Handler for testing your own patterns
 */
static int8_t sState = 0;
void ownPatterns(NeoPatterns *aLedsPtr) {

    uint8_t tDuration = random(20, 120);
    uint8_t tColor = random(255);
    uint8_t tRepetitions = random(2);

    switch (sState) { //hier vielleicht Incoming_value benutzen
    case 1:
        UserPattern1(aLedsPtr, COLOR32_RED_HALF, NeoPatterns::Wheel(tColor), tDuration, FORWARD);
        break;

    case 2:
        UserPattern2(aLedsPtr, NeoPatterns::Wheel(tColor), tDuration, tRepetitions, FORWARD);
        break;

    default:
        Serial.println("ERROR");
        break;
    }
}