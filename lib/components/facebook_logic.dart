import 'package:app/components/textComponents.dart';
import 'package:app/main.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:app/models/psiTest.dart';

import 'package:app/components/button.dart';

Future<Null> saveFacebookAccessTokenAndName(
    AccessToken accessToken, String name) async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('facebookAccessToken', accessToken.token);
    prefs.setString('facebookID', accessToken.userId);
    prefs.setString('facebookName', name);
  } catch (error) {
    print("error while saving fAcebook access token $error");
  }
}

Future<Null> saveUserIsAnonymous(bool isAnon) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isAnonymous', isAnon);
}

Future<Null> signInWithFacebook() async {
  // Trigger the sign-in flow

  try {
    final AccessToken _accessToken = await FacebookAuth.instance.login(
      permissions: ['user_friends'],
    );
    final userData = await FacebookAuth.instance.getUserData();
    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.getCredential(accessToken: _accessToken.token);

    print("user data name is ${userData['name']}");

    // Once signed in, return the UserCredential
    String name = userData['name'];
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    await saveFacebookAccessTokenAndName(_accessToken, name);
    await saveUserIsAnonymous(false);
    //setFacebookID(_accessToken.userId);
  } catch (error) {
    print(error);
  }
}

// this function is for logging in to Facebook after having logged in as Anonymous User
//
Future<Null> linkFacebookUserWithCurrentAnonUser(context, currentTest) async {
  var anonUser = await FirebaseAuth.instance.currentUser();
  print(
      'just before facebook sign in occurs: current(anon user) is ${anonUser.uid} isanon = ${anonUser.isAnonymous}');

  // Trigger the sign-in flow
  try {
    final AccessToken _accessToken = await FacebookAuth.instance.login(
      permissions: ['user_friends'],
    );
    final userData = await FacebookAuth.instance.getUserData();
    String name = userData['name'];
    print(userData['name']);

    // Create a credential from the access token
    final FacebookAuthCredential facebookAuthCredential =
        FacebookAuthProvider.getCredential(accessToken: _accessToken.token);

    var fbUser = await FirebaseAuth.instance.currentUser();
    print(
        'just before facebook user link occurs: anonuser is ${anonUser.uid}, current user ${fbUser.uid} isanon = ${fbUser.isAnonymous}');

    List providers = fbUser.providerData;
    for (UserInfo provider in providers)
      print(
          'provider (printing just before user link occurs) ${provider.toString}');

    //link the anonymous user with the facebook User **** (keeping the anon user's uid) ****
    //
    anonUser.linkWithCredential(facebookAuthCredential);

    fbUser = await FirebaseAuth.instance.currentUser();
    print(
        'just after facebook user link occurs: anonuser is ${anonUser.uid}, fb user ${fbUser.uid}  isanon = ${fbUser.isAnonymous}');
    for (UserInfo provider in providers)
      print(
          'provider (printing just AFTER user link occurs) ${provider.providerId}');
    //isAnonymous unfortunately returns "true" after signing in to FB.
    // therefore we save user is anonymous to sharedPreferences
    saveUserIsAnonymous(false);

    //need to call getFacebookFriends again to reset the FacebookFriednsList
    //

    BlocProvider.of<PsiTestSaveBloc>(context)
        .add(AddFacebookUIdToTest(test: currentTest));
    BlocProvider.of<PsiTestSaveBloc>(context)
        .add(GetFacebookFriendsList(test: currentTest));

    saveFacebookAccessTokenAndName(_accessToken, name);
  } catch (error) {
    print(error);
  }
}

void logOutOfFacebook(context) async {
  try {
    await FirebaseAuth.instance.signOut();
    //await FirebaseAuth.instance.clearAuthCache();
    print('SignedOut');
    // await globalCurrentUser.delete();
    //await FirebaseAuth.instance.signOut();
    print('signedOut from FireBase');
    //await FacebookAuth.instance.logOut();
    // await FirebaseAuth.instance.signOut();
    //

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('facebookAccessToken', null);
    globalCurrentUser = await FirebaseAuth.instance.currentUser();
    await globalCurrentUser.reload();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LandingPage()));
  } catch (error) {
    print(error);
  }
}

var facebookFriendsList;

Future<DocumentSnapshot> gotInvitedToTest(testId) async {
  var docRef = Firestore.instance.collection('test').document(testId);
  DocumentSnapshot sharedTestDocumentSnapshot = await docRef.get();

  return sharedTestDocumentSnapshot;
}

List<Widget> buildFacebookFriendsList(
    List facebookFriends, PsiTest currentTest, BuildContext context) {
  if (facebookFriends[0] == 'userIsAnonymous') {
    print('user is anonymous, buildFacebookFriends returning []');
    return [
      Button(
          // this appears when ID or access token are not available
          'log on to Facebook', () {
        linkFacebookUserWithCurrentAnonUser(context, currentTest);
        BlocProvider.of<PsiTestSaveBloc>(context)
            .add(GetFacebookFriendsList(test: currentTest));
      })
    ];
  }

  var facebookFriendsList = new List<Widget>();

  {
    print(facebookFriends.length);
    for (Map friend in facebookFriends) {
      String friendID = friend['friendID'];
      String friendName = friend['name'];
      print('friend ID is therefore: $friendID');
      print('now in buildFacebookFriendsList $facebookFriends');
      facebookFriendsList.add(FlatButton(
          height: 62,
          color: Colors.purple,
          child: (Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network(friend['profilePicUrl']),
              Flexible(child: CopyText(friendName)),
              Icon(Icons.share)
            ],
          )),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32.0),
              side: BorderSide(color: Colors.white, width: 4.0)),
          onPressed: () {
            print('inviting $friendID');
            var event = InviteFacebookFriend(
                test: currentTest,
                facebookFriendID: friendID,
                facebookFriendName: friendName);
            BlocProvider.of<PsiTestSaveBloc>(context).add(event);
            //call Get Facebook Friends List to set State to GetFacebookFriendsListSuccessful and return the list
            //
            BlocProvider.of<PsiTestSaveBloc>(context)
                .add(GetFacebookFriendsList(test: currentTest));
          }));
      facebookFriendsList.add(SizedBox(height: 10));
    }
  }
  /*
  if (facebookFriends.length == 0)
    return [
      Text('''none of your Facebook friends have this app installed.''',
          style: TextStyle(color: Colors.white))
    ];
  else*/
  return facebookFriendsList;
}
