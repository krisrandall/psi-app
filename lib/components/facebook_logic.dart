import 'package:app/components/utils.dart';
import 'package:app/main.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:app/components/livePsiTestStream.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//AccessToken _accessToken;

Future<Null> saveFacebookAccessToken(AccessToken accessToken) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('facebookAccessToken', accessToken.token);
    prefs.setString('facebookID', accessToken.userId);
  } catch (error) {
    print("error while saving fAcebook access token $error");
  }
}

// facebook users need to have their id explicitly added to Firebase.
// see here: (https://github.com/FirebaseExtended/flutterfire/issues/4612#issuecomment-782107867)
//
void _setFacebookIdAsFirebaseUserEmail(facebookUserId) async {
  try {
    if (isFacebookUser(
        globalCurrentUser) /* && globalCurrentUser.email == null*/) {
      globalCurrentUser.updateEmail("$facebookUserId@psi.com");
      print(
          'ran _setFacebookIdAsFirebaseUserEmail and now email  = ${globalCurrentUser.email}');
    } else
      print('email address = ${globalCurrentUser.email}');
  } catch (error) {
    print("error $error");
  }
}

Future<Null> signInWithFacebook() async {
  // Trigger the sign-in flow
  final AccessToken _accessToken =
      await FacebookAuth.instance.login().catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });

  // Create a credential from the access token
  final FacebookAuthCredential facebookAuthCredential =
      FacebookAuthProvider.getCredential(accessToken: _accessToken.token);

  print("_accessToken.userId is ${_accessToken.userId}");

  // Once signed in, return the UserCredential
  await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  saveFacebookAccessToken(_accessToken);
  _setFacebookIdAsFirebaseUserEmail(_accessToken.userId);
}

var facebookFriendsList;

Future<List> getFacebookFriendsList(context, currentTest) async {
  if (!isFacebookUser(globalCurrentUser)) return null;
  List<dynamic> facebookFriendsList = [];
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

      for (Map friend in friends) {
        String friendID = friend['id'];

        var friendProfilePic =
            "https://graph.facebook.com/$friendID/picture?small?access_token=$facebookAccessToken";
        facebookFriendsList.add(ListTile(
            tileColor: Colors.purple[100],
            leading: Image.network(friendProfilePic),
            trailing: Icon(Icons.send_sharp),
            title: Text(friend['name']),
            onTap: () {
              var event = InviteFacebookFriend(
                  test: currentTest, facebookFriend: '$friendID@psi.com');
              BlocProvider.of<PsiTestSaveBloc>(context).add(event);
              facebookFriendsList.add(SizedBox(height: 10));
            }));
      }
      if (facebookFriendsList.length == 0)
        return [
          Text('''none of your Facebook friends have this app installed.''',
              style: TextStyle(color: Colors.white)),
        ];
    } else {
      print(
          'GET Request (facebook api) failed with status: ${response.statusCode}.');
      return [Container()];
    }
  } catch (error) {
    print(error);
    return [Container()];
  }
  return facebookFriendsList;
}

void logOutOfFacebook(context) async {
  var user;
  try {
    FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
    //

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('facebookAccessToken', null);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LandingPage()));
    setGlobalCurrentuser();
  } catch (error) {
    print(error);
  }
  //print('firebase user ${user.uid}');
}

Future<Null> linkFacebookUserWithCurrentAnonUser(context) async {
  // Trigger the sign-in flow
  final AccessToken _accessToken =
      await FacebookAuth.instance.login().catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });

  // Create a credential from the access token
  final FacebookAuthCredential facebookAuthCredential =
      FacebookAuthProvider.getCredential(accessToken: _accessToken.token);

  // Once signed in, return the UserCredential
  /*await FirebaseAuth.instance
      .signInWithCredential(facebookAuthCredential)
      .catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });*/

  _setFacebookIdAsFirebaseUserEmail(_accessToken.userId);
  saveFacebookAccessToken(_accessToken).catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });
  globalCurrentUser = await FirebaseAuth.instance.currentUser();
  globalCurrentUser
      .linkWithCredential(facebookAuthCredential)
      .catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => LandingPage()));
}
