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
import 'dart:async';

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

Future<Null> signInWithFacebook() async {
  // Trigger the sign-in flow
  try {
    final AccessToken _accessToken = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.getCredential(accessToken: _accessToken.token);

    print("_accessToken.userId is ${_accessToken.userId}");

    // Once signed in, return the UserCredential

    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    saveFacebookAccessToken(_accessToken);
    //resetGlobalCurrentuser();
    //await globalCurrentUser.reload();
  } catch (error) {
    print(error);
  }
}

void logOutOfFacebook(context) async {
  try {
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();

    //

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('facebookAccessToken', null);
    globalCurrentUser = await FirebaseAuth.instance.currentUser();
    await globalCurrentUser.reload();
    resetMyId();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LandingPage()));
  } catch (error) {
    print(error);
  }
  //print('firebase user ${user.uid}');
}

var facebookFriendsList;

Future<DocumentSnapshot> gotInvitedToTest(testId) async {
  var docRef = Firestore.instance.collection('test').document(testId);
  DocumentSnapshot sharedTestDocumentSnapshot = await docRef.get();

  return sharedTestDocumentSnapshot;
}

/*Future<List> getFacebookFriendsList(context, currentTest) async {
  if (globalCurrentUser.isAnonymous) return null;
  List<dynamic> facebookFriendsList = [];
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String facebookAccessToken = prefs.getString('facebookAccessToken');
  Map jsonResponse;
  List friends;
  try {
    var response;
    response = await http.get(
        "https://graph.facebook.com/me/friends?access_token=$facebookAccessToken");
    if (response.statusCode == 200) {
      jsonResponse = convert.jsonDecode(response.body);
      friends = jsonResponse['data'];
      print(friends);

      for (Map friend in friends) {
        String friendID = friend['id'];

        var friendProfilePic =
            "https://graph.facebook.com/$friendID/picture?small?access_token=$facebookAccessToken";*/
List<Widget> buildFacebookFriendsList(
    List facebookFriends, currentTest, context) {
  var facebookFriendsList = new List<Widget>();
  if (globalCurrentUser.isAnonymous) return [];
  // List facebookFriends = currentTest.facebookFriends;
  print('now in buildFacebookFriendsList $facebookFriends');
  {
    print(facebookFriends.length);
    for (Map friend in facebookFriends) {
      facebookFriendsList.add(ListTile(
          tileColor: Colors.purple[100],
          leading: Image.network(friend['profilePicUrl']),
          trailing: Icon(Icons.send_sharp),
          title: Text(friend['name']),
          onTap: () {
            var event = InviteFacebookFriend(
                test: currentTest, facebookFriend: friend['friendID']);
            BlocProvider.of<PsiTestSaveBloc>(context).add(event);
          }));
      facebookFriendsList.add(SizedBox(height: 10));
    }
  }
  if (facebookFriends.length == 0)
    return [
      Text('''none of your Facebook friends have this app installed.''',
          style: TextStyle(color: Colors.white))
    ];
  else
    return facebookFriendsList;
}

Future<Null> linkFacebookUserWithCurrentAnonUser(context, currentTest) async {
  // Trigger the sign-in flow
  final AccessToken _accessToken = await FacebookAuth.instance.login();
  // Create a credential from the access token
  final FacebookAuthCredential facebookAuthCredential =
      FacebookAuthProvider.getCredential(accessToken: _accessToken.token);
  // Once signed in, return the UserCredential
  await FirebaseAuth.instance
      .signInWithCredential(facebookAuthCredential)
      .catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });
  //globalCurrentUser = await FirebaseAuth.instance.currentUser();

  //need to call getFacebookFriends again to reset the FutureBuilder
  //

  saveFacebookAccessToken(_accessToken).catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });
}

/*
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
  await FirebaseAuth.instance
      .signInWithCredential(facebookAuthCredential)
      .catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });
  //globalCurrentUser = await FirebaseAuth.instance.currentUser();

  //need to call getFacebookFriends again to reset the FutureBuilder
  //
  getFacebookFriendsList(context, currentTest);

  globalCurrentUser
      .linkWithCredential(facebookAuthCredential)
      .catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });

  saveFacebookAccessToken(_accessToken).catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => LandingPage()));
}*/
