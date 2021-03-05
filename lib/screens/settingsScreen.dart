import 'package:app/components/button.dart';
import 'package:flutter/material.dart';
import 'package:app/components/textcomponents.dart';
import 'package:app/components/screenBackground.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:app/components/facebook_logic.dart';

// doesn't work

class SettingsScreen extends StatelessWidget {
  void logOutOfFacebook() {
    FacebookAuth.instance.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return RightBgWrapper(Scaffold(
        appBar: AppBar(title: Text("Settings")),
        body: Center(
            child: Column(children: [
          TitleText('Settings'),
          SizedBox(height: 40),
          //Button('Log out of Facebook', () => logOutOfFacebook())
          Button('Sign in to Facebook', () => signInWithFacebook()),
          CopyText('there are currently no settings for this app'),
        ]))));
  }
}
