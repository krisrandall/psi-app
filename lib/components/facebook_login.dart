import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

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

var facebookFriendsList;

Future<List> getFacebookFriendsList() async {
  facebookFriendsList = new List<Widget>();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String facebookAccessToken = prefs.getString('facebookAccessToken');
  //String facebookID = prefs.getString('facebookID');
  Map jsonResponse;
  List friends;
  try {
    var response = await http.get(
        "https://graph.facebook.com/me/friends?access_token=$facebookAccessToken");

    if (response.statusCode == 200) {
      jsonResponse = convert.jsonDecode(response.body);
      friends = jsonResponse['data'];
      print(jsonResponse);
      print("friends object: $friends");
      print("friends 0 ${friends[0]}");

      for (Map friend in friends) {
        String friendID = friend['id'];
        print(friendID);

        var friendProfilePic =
            "https://graph.facebook.com/$friendID/picture?small?access_token=$facebookAccessToken";
        facebookFriendsList.add(ListTile(
            tileColor: Colors.purple[100],
            leading: Image.network(friendProfilePic),
            trailing: Icon(Icons.send_sharp),
            title: Text(friend['name'])));
        facebookFriendsList.add(SizedBox(height: 10));
      }
      if (facebookFriendsList.length == 0)
        return [
          Text('''none of your Facebook friends have this app installed. 
Use the link above to invite them''', style: TextStyle(color: Colors.white)),
        ];
    } else {
      print(
          'GET Request (facebook api) failed with status: ${response.statusCode}.');
      return null;
    }
  } catch (error) {
    print(error);
    return null;
  }
  return facebookFriendsList;
}
