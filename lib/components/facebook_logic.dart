import 'package:app/components/textComponents.dart';
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
import 'package:app/models/psiTest.dart';

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
    final AccessToken _accessToken = await FacebookAuth.instance.login(
      permissions: ['user_friends'],
      //loginBehavior: LoginBehavior.DIALOG_ONLY
    );

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
    List facebookFriends, PsiTest currentTest, BuildContext context) {
  var facebookFriendsList = new List<Widget>();
  if (globalCurrentUser.isAnonymous) return [];
  // List facebookFriends = currentTest.facebookFriends;
  print('now in buildFacebookFriendsList $facebookFriends');
  {
    print(facebookFriends.length);
    for (Map friend in facebookFriends) {
      var friendId = friend['friendID'];
      facebookFriendsList.add(FlatButton(
          height: 62,
          color: Colors.purple,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.network(friend['profilePicUrl']),
              Text(
                friend['name'],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white.withOpacity(1.0)),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
              side: BorderSide(color: Colors.white, width: 4.0)),
          onPressed: () {
            var event = InviteFacebookFriend(
                test: currentTest, facebookFriend: friendId);
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
  final AccessToken _accessToken = await FacebookAuth.instance.login(
    permissions: ['user_friends'],
  );
  final userData = await FacebookAuth.instance.getUserData();
  print(userData);
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

  BlocProvider.of<PsiTestSaveBloc>(context)
      .add(GetFacebookFriendsList(test: currentTest));

  saveFacebookAccessToken(_accessToken).catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });
  globalCurrentUser
      .linkWithCredential(facebookAuthCredential)
      .catchError((error) {
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
