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
import 'package:app/models/psiTest.dart';

class OpenedViaLinkWidget extends StatelessWidget {
  final String deepLink;
  OpenedViaLinkWidget(this.deepLink);

  Future<DocumentSnapshot> getSharedPsiTest(testId) async {
    var docRef = Firestore.instance.collection('test').document(testId);
    DocumentSnapshot sharedTestSnapshot = await docRef.get();

    return sharedTestSnapshot;
  }

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
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CopyText('no Test found'),
                        // TODO:  Button('start a new test' , () ==>logic to start new test);
                      ]);

                  break;
                case ConnectionState.waiting:
                  return CopyText(
                      'looking for Test'); // TODO: Handle this case.
                  break;
                case ConnectionState.active:
                  return CopyText('found Test and retrieving data');
                  break;
                case ConnectionState.done:
                  //PsiTest sharedPsiTest = createTestFromFirestore(sharedTest.data.document);
                  return TableBgWrapper(
                      _OpenedViaLinkWidget(sharedTestSnapshot, testId));
                  break;
              }
              return Container();
            })));
  }
}

class _OpenedViaLinkWidget extends StatelessWidget {
  final AsyncSnapshot sharedTestSnapshot;
  final String testId;
  _OpenedViaLinkWidget(this.sharedTestSnapshot, this.testId);
  @override
  Widget build(BuildContext context) {
    String receiverId = sharedTestSnapshot.data['receiver'];
    String senderId = sharedTestSnapshot.data['sender'];
    String status = sharedTestSnapshot.data['status'];

    List<Widget> screenOptions;
    List<Widget> triedToJoinOwnTest = [
      TitleText('Oops! You tried to join your own test!'),
      // Column(children: [
      CopyText('Please send the link to a friend instead.'),
      CopyText('Press this button and then choose an app to send the link:'),
      Button(
        'Share test with a friend',
        () {
          var dummyTestForReshare = PsiTest(testId: testId);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(ResharePsiTest(test: dummyTestForReshare));
        },
      ),
      CopyText(
          'hint: Try using a messaging app, an SMS or an email (not Firefox, Chrome or Safari)'),
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
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(JoinPsiTest(testId: testId));
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

    return Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        //crossAxisAlignment: CrossAxisAlignment.center,
        children: screenOptions);
  }
}

/*if record not found..
          if sender or receiver is me...continue test button
          if sender and receiver are full...(test already full) okay button
          if status is "underway" (test not currently underway:status is: $status)
          happy path: button begin test or decline


          begin test button*/
