import 'dart:convert';
import 'package:app/components/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

String prettyPrint(Map json) {
  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
  String pretty = encoder.convert(json);
  return pretty;
}

class FaceBookLogin extends StatefulWidget {
  @override
  _FaceBookLoginState createState() => _FaceBookLoginState();
}

class _FaceBookLoginState extends State<FaceBookLogin> {
  Map<String, dynamic> _userData;
  dynamic _friends;
  AccessToken _accessToken;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkIfIsLogged();
  }

  Future<void> _checkIfIsLogged() async {
    final AccessToken accessToken = await FacebookAuth.instance.isLogged;
    setState(() {
      _checking = false;
    });
    print(accessToken);
    if (accessToken != null) {
      print("is Logged:::: ${prettyPrint(accessToken.toJson())}");
      // now you can call to  FacebookAuth.instance.getUserData();
      final userData =
          await FacebookAuth.instance.getUserData(fields: "friends");
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      _accessToken = accessToken;
      setState(() {
        _userData = userData;
        print(userData);
      });
    }
  }

  void _printCredentials() {
    print(
      prettyPrint(_accessToken.toJson()),
    );
  }

  Future<void> _login() async {
    try {
      // show a circular progress indicator
      setState(() {
        _checking = true;
      });
      _accessToken = await FacebookAuth.instance
          .login(); // by the fault we request the email and the public profile
      // loginBehavior is only supported for Android devices, for ios it will be ignored
      // _accessToken = await FacebookAuth.instance.login(
      //   permissions: ['email', 'public_profile', 'user_birthday', 'user_friends', 'user_gender', 'user_link'],
      //   loginBehavior:
      //       LoginBehavior.DIALOG_ONLY, // (only android) show an authentication dialog instead of redirecting to facebook app
      // );
      _printCredentials();
      // get the user data
      // by default we get the userId, email,name and picture
      //final userData = await FacebookAuth.instance.getUserData();
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");
      final userData = await FacebookAuth.instance
          .getUserData(fields: "email,birthday,friends,gender,link");

      _userData = userData;
      //print(userData);
      _friends = userData['friends']['data'][0]['name'];
      //print(_friends);

      //for (dynamic friend in friends){

      // print(userData['friends']['data']);
      //return ((_userData) => _friends = _userData['friends']['data'][0]);
    } on FacebookAuthException catch (e) {
      // if the facebook login fails
      print(e.message); // print the error message in console
      // check the error type
      switch (e.errorCode) {
        case FacebookAuthErrorCode.OPERATION_IN_PROGRESS:
          print("You have a previous login operation in progress");
          break;
        case FacebookAuthErrorCode.CANCELLED:
          print("login cancelled");
          break;
        case FacebookAuthErrorCode.FAILED:
          print("login failed");
          break;
      }
    } catch (e, s) {
      // print in the logs the unknown errors
      print(e);
      print(s);
    } finally {
      // update the view
      setState(() {
        _checking = false;
      });
    }
  }

  Future<void> _logOut() async {
    await FacebookAuth.instance.logOut();
    _accessToken = null;
    _userData = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Facebook Auth Example'),
        ),
        body: _checking
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      (Text(_friends != null ? _friends : "NO LOGGED")),
                      RaisedButton(
                        onPressed: (_checkIfIsLogged),
                        child: (Text("check if logged")),
                      ),
                      SizedBox(height: 20),
                      _accessToken != null
                          ? Text(
                              prettyPrint(_accessToken.toJson()),
                            )
                          : Container(),
                      SizedBox(height: 20),
                      CupertinoButton(
                        color: Colors.blue,
                        child: Text(
                          _userData != null ? "LOGOUT" : "LOGIN",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _userData != null ? _logOut : _login,
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
