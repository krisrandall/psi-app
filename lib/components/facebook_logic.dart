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

Stream<List> getFacebookFriendsListStream(context, currentTest) async* {
  while (true) {
    await Future.delayed(Duration(seconds: 1));
    yield await getFacebookFriendsList(context, currentTest);
  }
}

Future<DocumentSnapshot> gotInvitedToTest(testId) async {
  var docRef = Firestore.instance.collection('test').document(testId);
  DocumentSnapshot sharedTestDocumentSnapshot = await docRef.get();

  return sharedTestDocumentSnapshot;
}

Future<List> getFacebookFriendsList(context, currentTest) async {
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

    Timer.periodic(Duration(seconds: 5), (Timer t) {
      response = http.get(
          "https://graph.facebook.com/me/friends?access_token=$facebookAccessToken");
    });

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
                  test: currentTest, facebookFriend: '$friendID');
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
  globalCurrentUser = await FirebaseAuth.instance.currentUser();
  /* globalCurrentUser
      .linkWithCredential(facebookAuthCredential)
      .catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });*/
  globalCurrentUser.setUserId('a');

  saveFacebookAccessToken(_accessToken).catchError((error) {
    print('error possibly user cancelled facebook login$error');
  });
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => LandingPage()));
}
