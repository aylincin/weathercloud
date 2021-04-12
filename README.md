# WEATHERCLOUD
WEATHERCLOUD is a student project developed as part of the elective course **Mediale Inszenierung** under the direction of *Lukas Loss* at the University of Applied Sciences Düsseldorf. The project includes a physical cloud with an LED strip that can visualize the live weather data of different locations. The functionality of the cloud is realized via Arduino and a corresponding Flutter app for Android and iOS. Possible locations, but also individual weather programs can be selected via Bluetooth connection using the app.

## CONCEPT
The cloud can be used in both, private and corporate, contexts. The impressive thing about this project is that, conceptually speaking, it does not apply to one specific target group. On the one hand, the cloud can be placed in a living room but also in a child's room, for example as a night light. On the other hand, an installation can be developed in which several clouds are attached in an international company and display the weather data of the different locations. Multiple clouds can also be used as event or store decorations. 

Since the cloud can theoretically visualize any weather situation, it is also suitable for any mood and can be adapted to the appropriate occasion or the desired atmosphere. For this purpose, other color schemes can also be added as desired.

## THE WEATHER
To access live weather data, the API of [wunderground.com](https://www.wunderground.com/) was used. For this, the various icon codes of [*The Weather Company*](https://docs.google.com/document/d/1qpc4QN3YDpGDGGNYVINh7tfeulcZ4fxPSC5f4KzpR_U/edit) of the weather types were considered and clustered. This resulted in a total of **8** groups, which were visualized by different colors and animations:

- Thunderstorm
- Blue Sky
- Storm
- Fog
- Rain
- Snow
- Clouds
- Sun

*Please note:*
The different colors to display the weather were chosen according to personal favor.

## THE APP
Hier einfach die drei Bilder der App (wie in der Präsentation einfügen)

## HOW TO BUILD THE WEATHERCLOUD
The following contains a list of materials (hardware and software) as well as instructions to build a weathercloud.

**Materials:**
- Bastelwatte (hab noch kein englisches Äquivalent zu Bastelwatte gefunden)
- Rabbit wires

**Hardware:**
- Arduino (e.g. Nano)
- Bluetooth module (for Android: HC-05, for iOS: AC09)
- WS2812B LED strip
- Soldering iron

**Software:**
Arduino IDE ([Windows](https://www.arduino.cc/en/guide/windows#toc1), [macOS](https://www.arduino.cc/en/guide/macOSX)
Android Studio ([Windows and Mac](https://developer.android.com/studio#downloads))
Flutter SDK ([Windows](https://flutter.dev/docs/get-started/install/windows), [macOS](https://flutter.dev/docs/get-started/install/macos))

**Instructions**
*Corpus:*
1. With rabbit wires, form the corpus of the cloud as desired
2. Erst Löten oder?
3. Wrap the LED strip around the corpus as desired. Attach the strip with wires to the corpus

*Functionality:*
1. Install the needed software
2. Clone the repository
3. Connect the arduino to your computer
4. Upload the custom-neopatterns.ino.ino file to your arduino
5. Disconnect your Arduino from your computer and apply it to the cloud
6. Open the project in Android Studio and connect your phone to your computer
7. Run the project on your phone

### WHY FLUTTER?
- Hier kurz Erklären warum Flutter benutzt wurde, kann aber wahrscheinlich auch raus. Da würde wohl eh nicht so viel stehen

## ISSUES
- Hier kurz auf Probleme bei Entwicklung eingehen
  - Limitierungen Flutter
  - Probleme Arduino
  - Limiterungen Farbspektrum

## WEITERENTWICKLUNG
Due to the limited time of the project, there are still a number of options for further development that should be considered. Basically, this optiones for improvement can be divided into three different areas: the cloud itself, functionality, app design.

**Wolke:**
- Bessere Lichtverteilung durch größere oder mehrere LED strips in einer Wolke
- Diffuses Licht für stärkere Atmosphäre
- Stabilität der Wolken
- Dauerhafte Stromquelle (eventuell über Kippschalter steuerbar)

**Funktionalität:**
- Kompatibilität mehrerer Wolken (Steuerbar über ein Gerät)
- Detailliertere Farbschemen
- Kleinere "Wettergruppen", also mehr Auswahl
- Suchfunktion, wie bei einer Wetterapp, nach beliebigem Standort


**App-Design:**
- Responsive design
- Additional views or split the view:
  - #1: connection via bluetooth
  - #2: control the cloud, choose location
  - #3: choose individual weather regardless of weather data
