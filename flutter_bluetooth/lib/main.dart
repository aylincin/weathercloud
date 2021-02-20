// For using PlatformException
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'bluetooth.dart';
import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothApp(),
    );
  }
}

