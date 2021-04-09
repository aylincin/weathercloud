// For using PlatformException
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'bluetooth.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothApp(),
      debugShowCheckedModeBanner: false
    );
  }
}

