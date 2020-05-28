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

class GypsyBgWrapper extends StatelessWidget {

  final Widget child;

  GypsyBgWrapper(this.child);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/table.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return SignInPage();
          }
          return HomePage();
        } else {
          return Scaffold(
            body: GypsyBgWrapper(
              Center(
                child: CircularProgressIndicator(),
              )
            ),
          );
        }
      },
    );
  }
}


class SignInPage extends StatefulWidget {
  const SignInPage({ Key key }) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  String signinErrorMessage = "";
  
  Future<void> _signInAnonymously() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      setState(() { 
        signinErrorMessage = "Unable to Sign in\n"+
          "Check your internet connection, and your password\n" +
          e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign in')),
      body: GypsyBgWrapper(
        Center(
          child: Column(children: <Widget>[
            RaisedButton(
              child: Text('Sign in anonymously'),
              onPressed: _signInAnonymously,
            ),
            Text(
              signinErrorMessage,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow.withOpacity(1.0)),
            ),
          ],)
            
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body: GypsyBgWrapper(Center( child: Text('hello !'))),
    );
  }
}