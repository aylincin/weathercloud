
#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
 #include <avr/power.h> // Required for 16 MHz Adafruit Trinket
#endif

// Which pin on the Arduino is connected to the NeoPixels?
// On a Trinket or Gemma we suggest changing this to 1:
#define LED_PIN    6

// How many NeoPixels are attached to the Arduino?
#define LED_COUNT 150

Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

// Variable for storing incoming value
char Incoming_value = 0;

void setup()
{
  strip.begin();           // INITIALIZE NeoPixel strip object (REQUIRED)
  strip.show();            // Turn OFF all pixels ASAP
  strip.setBrightness(50); // Set BRIGHTNESS to about 1/5 (max = 255)
  
  // Sets the data rate in bits per second (baud)
  // for serial data transmission
  Serial.begin(9600);

  // Sets digital pin 8 as output pin
  pinMode(8, OUTPUT);

  // Initializes the pin 8 to LOW (i.e., OFF)
  digitalWrite(8, LOW);
}

void loop()
{
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
      digitalWrite(8, LOW); // If value is 0, turn OFF the device
    }
      

    // Checking whether value of the variable
    // is equal to 1
    else if (Incoming_value == '1'){
      digitalWrite(8, HIGH); // If value is 1, turn ON the device
    }
      
  }

  // Adding a delay before running the loop again
  delay(1);

}

void rainbow(int wait) {
  // Hue of first pixel runs 5 complete loops through the color wheel.
  // Color wheel has a range of 65536 but it's OK if we roll over, so
  // just count from 0 to 5*65536. Adding 256 to firstPixelHue each time
  // means we'll make 5*65536/256 = 1280 passes through this outer loop:
  for(long firstPixelHue = 0; firstPixelHue < 5*65536; firstPixelHue += 256) {
    for(int i=0; i<strip.numPixels(); i++) {
      // Offset pixel hue by an amount to make one full revolution of the
      // color wheel (range of 65536) along the length of the strip
      // (strip.numPixels() steps):
      int pixelHue = firstPixelHue + (i * 65536L / strip.numPixels());
      // strip.ColorHSV() can take 1 or 3 arguments: a hue (0 to 65535) or
      // optionally add saturation and value (brightness) (each 0 to 255).
      // Here we're using just the single-argument hue variant. The result
      // is passed through strip.gamma32() to provide 'truer' colors
      // before assigning to each pixel:
      strip.setPixelColor(i, strip.gamma32(strip.ColorHSV(pixelHue)));
    }
    strip.show(); // Update strip with new contents
    delay(wait);  // Pause for a moment
  }
}
