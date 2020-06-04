import 'package:app/components/screenBackground.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: LandingPage(),
    );
  }
}



class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  String signinErrorMessage = "";

  @override
  Widget build(BuildContext context) {

    Future<void> _signInAnonymously() async {
      try {
        await precacheImage(AssetImage('assets/table.jpg'), context);
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        setState(() { 
          signinErrorMessage = "Unable to Sign in\n"+
            "Check your internet connection, and your password\n" +
            e.toString();
        });
      }
    }

    _signInAnonymously(); // auto anon signin

    return GypsyBgWrapper(
      StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return Column(children: <Widget>[
                  CircularProgressIndicator(),
                  Text('Logging in ..'),
                ]
              );
          } else if (signinErrorMessage!='') {
            return Text(
              signinErrorMessage,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow.withOpacity(1.0)),
            );
          } else {
            return HomePage();
          }
          
        } else {
          return Column(children: <Widget>[
                  CircularProgressIndicator(),
                  Text('Connecting ..'),
                ],
          );
        }
      },
    )
    );
  }
}

