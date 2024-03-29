import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bluetooth.dart';



class Home extends StatefulWidget {
  bool connected;

  Home({Key key, @required this.connected}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool power = true;
  bool home = true;
  bool newYork = true;
  bool sydney = true;

  BluetoothApp bluetoothApp = BluetoothApp();

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
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
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
                // IconButton(
                //     icon: power
                //         ? new Image.asset('images/buttons/unpressed_cloud.png')
                //         : new Image.asset('images/buttons/pressed_cloud.png'),
                //     iconSize: 300,
                //     padding: EdgeInsets.only(
                //         top: 0.0, bottom: 0.0, left: 60.0, right: 60.0),
                //     onPressed: () {
                //       _onCloudTapped();
                //       if (power == true && widget.connected == true) {
                //         print("Connected");
                //         home = true;
                //         sydney = true;
                //         newYork = true;
                //
                //       } else {
                //         bluetoothApp.createState().sendOffMessageToBluetooth();
                //         print("Not connected");
                //       }
                //     }),
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
                new Column(
                  children: [
                    Padding(padding: EdgeInsets.all(8.0)),
                    new SizedBox(
                      height: 50,
                      width: 350,
                      child: TextButton(
                        child: Text('BACK'),
                        style: TextButton.styleFrom(
                          backgroundColor: sydney
                              ? Colors.transparent
                              : Colors.white,
                          primary: sydney
                              ? Colors.white
                              : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            newYork = true;
                            sydney = true;
                            home = true;
                            widget.connected = false;
                            Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothApp()));
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
}





