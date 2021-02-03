// For performing some operations asynchronously
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'main.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
  bool connected = false;
  bool _isButtonUnavailable = false;


  bool power = true;
  bool home = true;
  bool newYork = true;
  bool sydney = true;

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

  // Tapped power button
  void _onCloudTapped() {
    print('PowerButton pressed');
    setState(() {
      power = !power;
      home = !home;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:ThemeData(
        textButtonTheme:TextButtonThemeData(
          style:TextButton.styleFrom(
            primary:Colors.white,
            side:BorderSide(color:Colors.white,width:2),
            textStyle:TextStyle(
              fontSize:28,
              fontWeight:FontWeight.w400,
            ),
          ),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    icon: power
                        ? new Image.asset('images/buttons/unpressed_cloud.png')
                        : new Image.asset('images/buttons/pressed_cloud.png'),
                    iconSize: 300,
                    padding: EdgeInsets.only(
                        top: 0.0, bottom: 0.0, left: 60.0, right: 60.0),
                    onPressed: () {
                      _onCloudTapped();
                      connected = !connected;

                      if (connected == true) {
                        _sendOnMessageToBluetooth();
                      } else {
                        _sendOffMessageToBluetooth();
                      }

                      if (power == true) {
                        home = true;
                        sydney = true;
                        newYork = true;
                      }
                    }),
                new Column(
                  children: [
                    Padding(padding: EdgeInsets.all(8.0)),
                    new SizedBox(
                      height: 50,
                      width: 350,
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
                            newYork = true;
                            sydney = true;
                            home = !home;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                new Column(
                  children: [
                    Padding(padding: EdgeInsets.all(8.0)),
                    new SizedBox(
                      height: 50,
                      width: 350,
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
                            newYork = !newYork;
                            sydney = true;
                            home = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                new Column(
                  children: [
                    Padding(padding: EdgeInsets.all(8.0)),
                    new SizedBox(
                      height: 50,
                      width: 350,
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
                          setState(() {
                            newYork = true;
                            sydney = !sydney;
                            home = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
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
            connected = true;
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

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  void _sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("1" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // Method to send message,
  // for turning the Bluetooth device off
  void _sendOffMessageToBluetooth() async {
    connection.output.add(utf8.encode("0" + "\r\n"));
    await connection.output.allSent;
    show('Device Turned Off');
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

}





