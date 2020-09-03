import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/components/utils.dart';
import 'package:app/config.dart';
import 'package:app/main.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:app/components/button.dart';

class OpenedViaLinkWidget extends StatelessWidget {
  final String deepLink;
  OpenedViaLinkWidget(this.deepLink);

  Future<DocumentSnapshot> getSharedPsiTest(testId) async {
    var docRef = Firestore.instance.collection('test').document(testId);
    DocumentSnapshot sharedTestSnapshot = await docRef.get();

    return sharedTestSnapshot;
  }

  //TODO add UID to stream--using JoinPsiTest event*/

  @override
  Widget build(BuildContext context) {
    //extract TestId String from Deep Link
    String testId = deepLink.replaceAll(new RegExp(ADDRESSPARTOFDEEPLINK), '');
    return TableBgWrapper(Scaffold(
        appBar: AppBar(
          title: Text('Opened Via Link'),
        ),
        body: FutureBuilder(
            future: getSharedPsiTest(testId),
            builder: (context, sharedTestSnapshot) {
              switch (sharedTestSnapshot.connectionState) {
                case ConnectionState.none:
                  return CopyText('no Test found');
                  //TODO: a button to handle this case
                  break;
                case ConnectionState.waiting:
                  return CopyText(
                      'looking for Test'); // TODO: Handle this case.
                  break;
                case ConnectionState.active:
                  return CopyText('found Test and retrieving data');
                  break;
                case ConnectionState.done:
                  //String receiverId = sharedTest.data['receiver'];
                  String senderId = sharedTestSnapshot.data['sender'];
                  //PsiTest sharedPsiTest = createTestFromFirestore(sharedTest.data.document);
                  return TableBgWrapper(
                      _OpenedViaLinkWidget(sharedTestSnapshot));
                  //   CopyText('receiver ID: $receiverId senderId: $senderId'));
                  //  if (receiverId == globalCurrentUser && senderId == '')

                  // return _OpenedViaLinkWidget(testToJoinOnFirestore);
                  break;
              }
              return Container();
            })));
  }
}

class _OpenedViaLinkWidget extends StatelessWidget {
  final sharedTestSnapshot;
  _OpenedViaLinkWidget(this.sharedTestSnapshot);
  @override
  Widget build(BuildContext context) {
    String receiverId = sharedTestSnapshot.data['receiver'];
    String senderId = sharedTestSnapshot.data['sender'];
    String status = sharedTestSnapshot.data['status'];
    List<Widget> screenOptions;
    List<Widget> triedToJoinOwnTest = [
      // Column(children: [
      CopyText(
          'You tried to join your own test! Please send the link to a friend instead'),
      CopyText('Press this button and choose and app to send the link'),
      CopyText(
          'Try using a messaging app, an SMS or email (not Firefox, Chrome or Safari)'),
      Button(
        'share test with a friend',
        () {
          List<DocumentSnapshot> sharedTestList;
          sharedTestList[0] = sharedTestSnapshot;
          var testToJoin = createTestFromFirestore(sharedTestList);
          //var testToJoin = createTestFromFirestore(sharedTestSnapshot.data);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(SharePsiTest(test: testToJoin));
        },
      )
    ];

    List<Widget> testAlreadyFull = [
      //Column(children: [
      CopyText('You are unable to join this test'),
      CopyText('It already has a sender and a receiver'),
      Button('Go back', () {
        goToScreen(context, AfterAuthWidget());
      })
    ];

    List<Widget> testNotUnderway = [
      //  Column(children: [
      CopyText('The test is no longer active'),
      CopyText('The status of the test is $status'),
      Button('Go back', () {
        goToScreen(context, AfterAuthWidget());
      })
    ];

    List<Widget> happyPath = [
      // Column(children: [
      CopyText('You have been invited to join a Psi Test'),
      CopyText('your user id is $globalCurrentUser or $globalCurrentUser.uid'),
      Button(
        'Start Psi Test',
        () {
          List<DocumentSnapshot> sharedTestList;
          sharedTestList[0] = sharedTestSnapshot;
          var testToJoin = createTestFromFirestore(sharedTestList);

          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(JoinPsiTest(test: testToJoin));
        },
      )
    ];

    if (globalCurrentUser.uid == receiverId ||
        globalCurrentUser.uid == senderId) {
      screenOptions = triedToJoinOwnTest;
    } else if (receiverId != '' && senderId != '') {
      screenOptions = testAlreadyFull;
    } else if (status != 'underway') {
      screenOptions = testNotUnderway;
    } else {
      screenOptions = happyPath;
    }

    return Column(children: screenOptions);
  }
}
// TO CHANNGE TO QUERY BASED ON INPUT PARAM

/*if record not found..
          if sender or receiver is me...continue test button
          if sender and receiver are full...(test already full) okay button
          if status is "underway" (test not currently underway:status is: $status)
          happy path: button begin test or decline


          begin test button*/
