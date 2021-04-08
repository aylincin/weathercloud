// For performing some operations asynchronously
import 'dart:async';
import 'dart:convert';
import 'dart:convert' as convert;

import 'package:google_fonts/google_fonts.dart';
import 'home.dart';


// For using PlatformException
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class BluetoothApp extends StatefulWidget {
  //const BluetoothApp({Key key}) : super(key: key);

  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;

  bool power = true;
  bool home = true;
  bool newYork = true;
  bool sydney = true;

  bool thunder = true;
  bool storm = true;
  bool fog = true;
  bool rain = true;
  bool sun = true;
  bool bluesky = true;
  bool snow = true;
  bool cloudy = true;

  Position _currentPosition;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  void _onCloudTapped() {
    print('PowerButton pressed');
    setState(() {
      power = !power;
      home = !home;
    });
  }

  /*Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Position> getPosition() async {
    return await Geolocator.getCurrentPosition().then((value) => {
      print(value)
      return value;
    });
  }*/

  _getCurrentLocation() async{
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        generateWeatherData(2);
        print(_currentPosition);
      });


    }).catchError((e) {
      print(e);
    });
  }

void generateWeatherData(int button){
    String url;
    switch(button){
      case 0:
        url = "https://api.weather.com/v3/wx/forecast/daily/5day?geocode=-33.8469759,150.3715249&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf";
        break;
      case 1:
        url = "https://api.weather.com/v3/wx/forecast/daily/5day?geocode=40.6971494,-74.2598627&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf";
        break;
      case 2:
        if(_currentPosition != null) {
          var longitude = _currentPosition.longitude;
          var latitude = _currentPosition.latitude;
          url = "https://api.weather.com/v3/wx/forecast/daily/5day?geocode= $longitude,$latitude&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf";
        } else {
          _getCurrentLocation();
        }
        break;
      default:
        break;
    }

    if(url != null) {
      Future<int> tmpIconCode = fetchWeather(url);
      if(tmpIconCode == 3  || tmpIconCode == 4 || tmpIconCode == 37 || tmpIconCode == 38 || tmpIconCode == 47){
        //Gewitter
        _sendOnMessageToBluetooth("1");
      } else if(tmpIconCode == 31 || tmpIconCode == 32 || tmpIconCode == 33 || tmpIconCode == 34 || tmpIconCode == 23 || tmpIconCode == 24){
        //Blauer Himmel
        _sendOnMessageToBluetooth("2");
      } else if(tmpIconCode == 0 || tmpIconCode == 1 || tmpIconCode == 2){
        //Sturm
        _sendOnMessageToBluetooth("3");
      } else if(tmpIconCode == 19 || tmpIconCode == 20 || tmpIconCode == 21 || tmpIconCode == 22){
        //Nebel
        _sendOnMessageToBluetooth("4");
      } else if(tmpIconCode == 5 || tmpIconCode == 6 || tmpIconCode == 7|| tmpIconCode == 8 || tmpIconCode == 9 || tmpIconCode == 10 || tmpIconCode == 11 || tmpIconCode == 12 || tmpIconCode == 35 || tmpIconCode == 39 || tmpIconCode == 40 || tmpIconCode == 45) {
        //Regen
        _sendOnMessageToBluetooth("5");
      } else if(tmpIconCode == 13 || tmpIconCode == 14 || tmpIconCode == 15 || tmpIconCode == 16 || tmpIconCode == 17 || tmpIconCode == 18 || tmpIconCode == 25 || tmpIconCode == 41 || tmpIconCode == 42 || tmpIconCode == 43 || tmpIconCode == 46) {
        //Schnee
        _sendOnMessageToBluetooth("6");
      } else if (tmpIconCode == 26 || tmpIconCode == 27 || tmpIconCode == 28 || tmpIconCode == 29 || tmpIconCode == 30){
        //Wolkig
        _sendOnMessageToBluetooth("7");
      } else if (tmpIconCode == 32 || tmpIconCode == 36) {
        //Sonnig
        _sendOnMessageToBluetooth("8");
      } else {
        _sendOnMessageToBluetooth("0");
      }
    }
}


  Future<int> fetchWeather(var url) async {
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var itemCount = jsonResponse['daypart'];
      var dayObject = itemCount[0];
      var iconCode = dayObject['iconCode'];

      if(iconCode[0] != null){
        print(int.parse(iconCode[0].toString()));
        return int.parse(iconCode[0].toString());
      }
      else {
        print(int.parse(iconCode[1].toString()));
        return int.parse(iconCode[1].toString());
      }
      print('Number of books about http: $iconCode.');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _disconnect() async {
    print("not connected");

    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  //in home.dart for onCloudTapped _connected
  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth(String weatherCode) async {
    print("send on message");

    connection.output.add(utf8.encode(weatherCode + "\r\n"));
    await connection.output.allSent;
    show('Device Turned On');
    print("Onmessage to bluetooth");
    setState(() {
      _deviceState = 1; // device on
    });
  }

  //in home.dart for onCloudTapped _connected
  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    print("send off message");

    connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned Off');
    print("Offmessage to bluetooth");
    setState(() {
      _deviceState = -1; // device off
    });
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
      String message, {
        Duration duration: const Duration(seconds: 3),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:  ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: Scaffold(
        key: _scaffoldKey,
        body: Center(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("images/app_background.png")
                ),
              ),
              child: Column(
                children: <Widget>[
                  IconButton(
                      icon: power
                          ? new Image.asset('images/buttons/unpressed_cloud.png')
                          : new Image.asset('images/buttons/pressed_cloud.png'),
                      iconSize: 250,
                      padding: EdgeInsets.only(
                          top: 15.0, bottom: 0.0, left: 60.0, right: 60.0),
                      onPressed: () {
                        _onCloudTapped();
                        if(!_connected) {
                          _sendOffMessageToBluetooth();
                          _connected = true;
                        } else {
                          _sendOnMessageToBluetooth("0");
                          _connected = false;
                        }

                        print(power);
                        print(_connected);
                        if (power == true && _connected == true) {
                          print("Connected");
                          home = true;
                          sydney = true;
                          newYork = true;
                        } else {
                          print("Not connected");
                        }
                      }),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 80,
                          child: TextButton(
                            child: Text('HOME'),
                            style: TextButton.styleFrom(
                              backgroundColor: home
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: home
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              print('pressed home');
                              setState(() {
                                //getPosition();
                                _getCurrentLocation();
                                fetchWeather("https://api.weather.com/v3/wx/forecast/daily/5day?geocode=-33.8469759,150.3715249&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf");
                                sydney = true;
                                newYork = true;
                                storm = true;
                                thunder = true;
                                fog = true;
                                sun = true;
                                bluesky = true;
                                snow = true;
                                cloudy = true;
                                rain = true;

                                home = !home;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: new SizedBox(
                            height: 40,
                            width: 90,
                            child: TextButton(
                              child: Text('NEW YORK'),
                              style: TextButton.styleFrom(
                                backgroundColor: newYork
                                    ? Colors.transparent
                                    : Colors.white,
                                primary: newYork
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                print('pressed home');
                                setState(() {
                                  fetchWeather('https://api.weather.com/v2/pws/observations/current?stationId=KNYNEWYO1384&format=json&units=m&apiKey=118e3a7a78564ef28e3a7a78560ef2bf');
                                  home = true;
                                  sydney = true;
                                  storm = true;
                                  thunder = true;
                                  fog = true;
                                  sun = true;
                                  bluesky = true;
                                  snow = true;
                                  cloudy = true;
                                  rain = true;

                                  newYork = !newYork;
                                });
                              },
                            ),
                          ),
                      ),

                      Padding(
                          padding: EdgeInsets.all(8.0),
                          child: new SizedBox(
                            height: 40,
                            width: 80,
                            child: TextButton(
                              child: Text('SYDNEY'),
                              style: TextButton.styleFrom(
                                backgroundColor: sydney
                                    ? Colors.transparent
                                    : Colors.white,
                                primary: sydney
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                print('pressed home');
                                fetchWeather('https://api.weather.com/v3/wx/forecast/daily/5day?geocode=-33.8469759,150.3715249&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf');
                                setState(() {
                                  home = true;
                                  newYork = true;
                                  storm = true;
                                  thunder = true;
                                  fog = true;
                                  sun = true;
                                  bluesky = true;
                                  snow = true;
                                  cloudy = true;
                                  rain = true;

                                  sydney = !sydney;
                                });
                              },
                            ),
                          ),
                      ),

                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: new Text('MODI', style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold)),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 80,
                          child: TextButton(
                            child: Text('THUNDER'),
                            style: TextButton.styleFrom(
                              backgroundColor: thunder
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: thunder
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                //getPosition();
                                _getCurrentLocation();
                                fetchWeather("https://api.weather.com/v3/wx/forecast/daily/5day?geocode=-33.8469759,150.3715249&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf");
                                home = true;
                                newYork = true;
                                sydney = true;
                                storm = true;
                                fog = true;
                                rain = true;
                                sun = true;
                                bluesky = true;
                                snow = true;
                                cloudy = true;


                                thunder = !thunder;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 90,
                          child: TextButton(
                            child: Text('STORM'),
                            style: TextButton.styleFrom(
                              backgroundColor: storm
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: storm
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                fetchWeather('https://api.weather.com/v2/pws/observations/current?stationId=KNYNEWYO1384&format=json&units=m&apiKey=118e3a7a78564ef28e3a7a78560ef2bf');
                                home = true;
                                newYork = true;
                                sydney = true;
                                thunder = true;
                                fog = true;
                                rain = true;
                                sun = true;
                                bluesky = true;
                                snow = true;
                                cloudy = true;


                                storm = !storm;
                              });
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 80,
                          child: TextButton(
                            child: Text('FOG'),
                            style: TextButton.styleFrom(
                              backgroundColor: fog
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: fog
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              print('pressed home');
                              fetchWeather('https://api.weather.com/v3/wx/forecast/daily/5day?geocode=-33.8469759,150.3715249&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf');
                              setState(() {
                                home = true;
                                newYork = true;
                                sydney = true;
                                storm = true;
                                thunder = true;
                                rain = true;
                                sun = true;
                                bluesky = true;
                                snow = true;
                                cloudy = true;

                                fog = !fog;
                              });
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 80,
                          child: TextButton(
                            child: Text('RAIN'),
                            style: TextButton.styleFrom(
                              backgroundColor: rain
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: rain
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                //getPosition();
                                _getCurrentLocation();
                                fetchWeather("https://api.weather.com/v3/wx/forecast/daily/5day?geocode=-33.8469759,150.3715249&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf");
                                home = true;
                                newYork = true;
                                sydney = true;
                                storm = true;
                                thunder = true;
                                fog = true;
                                sun = true;
                                bluesky = true;
                                snow = true;
                                cloudy = true;

                                rain = !rain;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 90,
                          child: TextButton(
                            child: Text('SUN'),
                            style: TextButton.styleFrom(
                              backgroundColor: sun
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: sun
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                fetchWeather('https://api.weather.com/v2/pws/observations/current?stationId=KNYNEWYO1384&format=json&units=m&apiKey=118e3a7a78564ef28e3a7a78560ef2bf');
                                home = true;
                                newYork = true;
                                sydney = true;
                                storm = true;
                                thunder = true;
                                fog = true;
                                rain = true;
                                bluesky = true;
                                snow = true;
                                cloudy = true;

                                sun = !sun;
                              });
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 80,
                          child: TextButton(
                            child: Text('BLUE SKY'),
                            style: TextButton.styleFrom(
                              backgroundColor: bluesky
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: bluesky
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              print('pressed home');
                              fetchWeather('https://api.weather.com/v3/wx/forecast/daily/5day?geocode=-33.8469759,150.3715249&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf');
                              setState(() {
                                home = true;
                                newYork = true;
                                sydney = true;
                                storm = true;
                                thunder = true;
                                fog = true;
                                sun = true;
                                rain = true;
                                snow = true;
                                cloudy = true;

                                bluesky = !bluesky;
                              });
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 90,
                          child: TextButton(
                            child: Text('SNOW'),
                            style: TextButton.styleFrom(
                              backgroundColor: snow
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: snow
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                fetchWeather('https://api.weather.com/v2/pws/observations/current?stationId=KNYNEWYO1384&format=json&units=m&apiKey=118e3a7a78564ef28e3a7a78560ef2bf');
                                home = true;
                                newYork = true;
                                sydney = true;
                                storm = true;
                                thunder = true;
                                fog = true;
                                sun = true;
                                bluesky = true;
                                rain = true;
                                cloudy = true;

                                snow = !snow;
                              });
                            },
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: new SizedBox(
                          height: 40,
                          width: 80,
                          child: TextButton(
                            child: Text('CLOUDY'),
                            style: TextButton.styleFrom(
                              backgroundColor: cloudy
                                  ? Colors.transparent
                                  : Colors.white,
                              primary: cloudy
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                            onPressed: () {
                              print('pressed home');
                              fetchWeather('https://api.weather.com/v3/wx/forecast/daily/5day?geocode=-33.8469759,150.3715249&format=json&units=e&language=en-US&apiKey=118e3a7a78564ef28e3a7a78560ef2bf');
                              setState(() {
                                home = true;
                                newYork = true;
                                sydney = true;
                                storm = true;
                                thunder = true;
                                fog = true;
                                sun = true;
                                bluesky = true;
                                snow = true;
                                rain = true;

                                cloudy = !cloudy;
                              });
                            },
                          ),
                        ),
                      ),

                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, top: 30.0, right: 5.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'CONNECT TO ARDUINO CLOUD',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.left,
                          softWrap: true,
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0, top: 5.0, right: 35.0, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Enable Bluetooth',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                        Switch(
                          value: _bluetoothState.isEnabled,
                          onChanged: (bool value) {
                            future() async {
                              if (value) {
                                await FlutterBluetoothSerial.instance
                                    .requestEnable();
                              } else {
                                await FlutterBluetoothSerial.instance
                                    .requestDisable();
                              }

                              await getPairedDevices();
                              _isButtonUnavailable = false;

                              if (_connected) {
                                _disconnect();
                              }
                            }

                            future().then((_) {
                              setState(() {});
                            });
                          },
                        )
                      ],
                    ),
                  ),
                  Stack(
                    children: <Widget>[
                      Column(
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0, top: 5.0, right: 30.0, bottom: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Device:',
                                  style: TextStyle(fontSize: 14, color: Colors.white),
                                ),
                                DropdownButton(
                                  items: _getDeviceItems(),
                                  onChanged: (value) =>
                                      setState(() => _device = value),
                                  value: _devicesList.isNotEmpty ? _device : null,
                                ),
                              ],
                            ),
                          ),
                          new Column(
                              children: [
                                Padding(padding: EdgeInsets.all(5.0)),
                                new SizedBox(
                                  height: 40,
                                  width: 300,
                                  child: RaisedButton(
                                    color: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(color: Colors.white, width: 2)
                                    ),
                                    onPressed: _isButtonUnavailable
                                        ? null
                                        : _connected ? _disconnect : _connect,
                                    child:
                                    Text(
                                      _connected ? 'DISCONNECT' : 'CONNECT',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                )
                              ]
                          ),
                          // FlatButton(
                          // onPressed: _connected
                          //  ? sendOnMessageToBluetooth
                          // : null,
                          // child: Text("ON"),
                          // ),
                          // FlatButton(
                          // onPressed: _connected
                          //  ? sendOffMessageToBluetooth
                          // : null,
                          // child: Text("OFF"),
                          // ),

                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text(
          'No Device selected',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    print("connected");
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
            //Navigator.push(context, MaterialPageRoute(builder: (context) => Home(connected: _connected)));
          });

          connection.input.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // void _onDataReceived(Uint8List data) {
  //   // Allocate buffer for parsed data
  //   int backspacesCounter = 0;
  //   data.forEach((byte) {
  //     if (byte == 8 || byte == 127) {
  //       backspacesCounter++;
  //     }
  //   });
  //   Uint8List buffer = Uint8List(data.length - backspacesCounter);
  //   int bufferIndex = buffer.length;

  //   // Apply backspace control character
  //   backspacesCounter = 0;
  //   for (int i = data.length - 1; i >= 0; i--) {
  //     if (data[i] == 8 || data[i] == 127) {
  //       backspacesCounter++;
  //     } else {
  //       if (backspacesCounter > 0) {
  //         backspacesCounter--;
  //       } else {
  //         buffer[--bufferIndex] = data[i];
  //       }
  //     }
  //   }
  // }

  // Method to disconnect bluetooth

}