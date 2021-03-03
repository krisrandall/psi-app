import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';

AccessToken _accessToken;

Future<Null> _saveFacebookAccessToken(AccessToken accessToken) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('facebookAccessToken', accessToken.token);
  prefs.setString('facebookID', accessToken.userId);
}

Future<Null> signInWithFacebook() async {
  // Trigger the sign-in flow
  final AccessToken accessToken = await FacebookAuth.instance.login();
  _accessToken = accessToken;
  _saveFacebookAccessToken(accessToken);
  // Create a credential from the access token
  final FacebookAuthCredential facebookAuthCredential =
      FacebookAuthProvider.getCredential(accessToken: _accessToken.token);
  print(_accessToken.token);

  // Once signed in, return the UserCredential
  await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
}
