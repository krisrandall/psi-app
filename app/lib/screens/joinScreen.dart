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
  bool testExists = true;

  Future<DocumentSnapshot> getSharedPsiTest(testId) async {
    var docRef = Firestore.instance.collection('test').document(testId);
    DocumentSnapshot sharedTestSnapshot = await docRef.get();
    //var docRefdata = sharedTestSnapshot.data;
    if (!sharedTestSnapshot.exists) {
      testExists = false;
      // return null;
    } //else
    return sharedTestSnapshot;
  }

  @override
  Widget build(BuildContext context) {
    //extract TestId String from Deep Link
    String testIdWithReShareParameter =
        deepLink.replaceAll(new RegExp(ADDRESSPARTOFDEEPLINK), '');
    String testId =
        testIdWithReShareParameter.replaceAll(new RegExp('reshare'), '');
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

                  if (!testExists) {
                    return TableBgWrapper(LinkDoesntExistWidget());
                  } else
                    return TableBgWrapper(_OpenedViaLinkWidget(
                        sharedTestSnapshot, testIdWithReShareParameter));
                  break;
              }
              return Container();
            })));
  }
}

class _OpenedViaLinkWidget extends StatelessWidget {
  final AsyncSnapshot sharedTestSnapshot;
  final String testIdWithReshareParameter;
  _OpenedViaLinkWidget(
      this.sharedTestSnapshot, this.testIdWithReshareParameter);

  @override
  Widget build(BuildContext context) {
    String testId =
        testIdWithReshareParameter.replaceAll(new RegExp('reshare'), '');

    String receiverId = sharedTestSnapshot.data['receiver'];

    String senderId = sharedTestSnapshot.data['sender'];

    String status = sharedTestSnapshot.data['status'];

    List<Widget> screenOptions;
    List<Widget> triedToJoinOwnTest = [
      TitleText('Oops! You tried to join your own test!'),
      SizedBox(height: 10),
      // Column(children: [
      CopyText('Please send the link to a friend instead.'),
      SizedBox(height: 30),
      //CopyText('Press this button and then choose an app to send the link:'),
      SizedBox(height: 10),
      Button(
        'Invite friend via share link',
        () {
          String reShareTestId = testId + ('reshare');
          var dummyTestForReshare = PsiTest(testId: reShareTestId);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(ResharePsiTest(test: dummyTestForReshare));
        },
      ),
      SizedBox(height: 10),
    ];

    List<Widget> triedToJoinOwnTestForASecondTime = [
      TitleText('Oops! You tried to join your own test again!'),
      SizedBox(height: 10),
      // Column(children: [
      CopyText('Having trouble inviting a friend to your test?'),
      SizedBox(height: 30),
      CopyText('''Try this:
      Press the button below.
      A lot of options for different apps will appear.
      Choose an app that can send the link.
      The link will be sent to your friend
      and he or she will click on it.
      Hint: Try sharing with a messaging app, an SMS or an email (not Firefox, Chrome or Safari)') '''),
      SizedBox(height: 10),
      Button(
        'Invite friend via share link',
        () {
          var dummyTestForReshare = PsiTest(testId: testIdWithReshareParameter);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(ResharePsiTest(test: dummyTestForReshare));
        },
      ),
      SizedBox(height: 10),
      // CopyText(
      //   'hint: Try sharing with a messaging app, an SMS or an email (not Firefox, Chrome or Safari)'),
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
      Button(
        'Start Psi Test',
        () {
          var dummyTestForJoining = PsiTest(testId: testId);
          dummyTestForJoining.myRole =
              (receiverId == null ? PsiTestRole.SENDER : PsiTestRole.RECEIVER);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(JoinPsiTest(test: dummyTestForJoining));
        },
      )
    ];

    if (globalCurrentUser.uid == receiverId ||
        globalCurrentUser.uid == senderId) {
      screenOptions = triedToJoinOwnTest;

      if (testIdWithReshareParameter.contains('reshare')) {
        screenOptions = triedToJoinOwnTestForASecondTime;
      }
    } else if (receiverId != '' && senderId != '') {
      screenOptions = testAlreadyFull;
    } else if (status != 'underway') {
      screenOptions = testNotUnderway;
    } else {
      screenOptions = happyPath;
    }

    return SingleChildScrollView(
        child: Column(
            //      mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.center,
            children: screenOptions));
  }
}

class LinkDoesntExistWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        TitleText('Test not found'),
        CopyText("The test you were invited to doesn't seem to exist anymore"),
        Button('Go back to start', () {
          goToScreen(context, TableBgWrapper(AfterAuthWidget()));
        })
      ],
    ));
  }
}
/*if record not found..
          if sender or receiver is me...continue test button
          if sender and receiver are full...(test already full) okay button
          if status is "underway" (test not currently underway:status is: $status)
          happy path: button begin test or decline

          begin test button*/
