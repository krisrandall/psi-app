
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /* to prevent device rotation - but not proven yet if works, or needed... 
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    */
    
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Color.fromRGBO(47, 11, 56, 1),
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
        await precacheImage(AssetImage('assets/splash.png'), context);
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

    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: TableBgWrapper(
        StreamBuilder<FirebaseUser>(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (context, snapshot) {
            print(snapshot.connectionState);
            if (snapshot.connectionState == ConnectionState.active) {
              
              FirebaseUser user = snapshot.data;
              if (user == null) {
                return Column(children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Logging in ..'),
                    ]
                  );
              } else if (signinErrorMessage!='') {
                return TitleText( signinErrorMessage );
              } else {
                globalCurrentUser = user;
                return AfterAuthWidget();
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
      ),
    );
  }
}

class AfterAuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreDatabaseStream.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (psiTestNotAvailable(snapshot)) return psiTestNotAvailableWidget(snapshot);
        var currentTest = createTestFromFirestore(snapshot.data.documents);
        return HomePage(currentTest);
      }
    );
  }
}
