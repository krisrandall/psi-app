import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/components/utils.dart';
import 'package:app/config.dart';
import 'package:app/main.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:app/screens/testScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:app/components/button.dart';

class OpenedViaLinkWidget extends StatelessWidget {
  final String deepLink;
  OpenedViaLinkWidget(this.deepLink);

  Future<DocumentSnapshot> getSharedPsiTest(testId) async {
    var docRef = Firestore.instance.collection('test').document(testId);
    DocumentSnapshot sharedTestDocumentSnapshot = await docRef.get();

    return sharedTestDocumentSnapshot;
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
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData) {
                return TableBgWrapper(
                    Center(child: CopyText('looking for test')));
              } else if (snapshot.hasData) {
                return TableBgWrapper(_OpenedViaLinkWidget(snapshot.data));
              } else if (snapshot.hasError) {
                print('snapshot has error');
                return TableBgWrapper(LinkDoesntExistWidget());
              }
              return Container();
            })));
  }
}

class _OpenedViaLinkWidget extends StatelessWidget {
  final DocumentSnapshot sharedTestSnapshot;
  //final String testId;
  _OpenedViaLinkWidget(this.sharedTestSnapshot);
  @override
  Widget build(BuildContext context) {
    String receiverId = sharedTestSnapshot['receiver'];
    print(receiverId);
    String senderId = sharedTestSnapshot['sender'];

    String status = sharedTestSnapshot['status'];

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
          var testToJoin = createTestFromFirestore([sharedTestSnapshot]);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(ResharePsiTest(test: testToJoin));
          //goToScreen(context, TableBgWrapper(AfterAuthWidget()));
        },
      ),
      SizedBox(height: 10),
      //SecondaryButton('for help click here', () {
      // goToScreen(context, TableBgWrapper(HelpWithSharing()));
      //}),
    ];
    List<Widget> linkIsYourActiveTest = [
      //Column(children: [
      CopyText('You are already part of this test'),
      Button('Continue Test', () {
        goToScreen(context, TableBgWrapper(TestScreen()));
      })
    ];

    List<Widget> testAlreadyFull = [
      //Column(children: [
      CopyText('You are unable to join this test'),
      CopyText('It already has a sender and a receiver'),
      Button('Go back', () {
        goToScreen(context, TableBgWrapper(AfterAuthWidget()));
      })
    ];

    List<Widget> testNotUnderway = [
      //  Column(children: [
      CopyText('The test is no longer active'),
      CopyText('The status of the test is $status'),
      Button('Go back', () {
        goToScreen(context, TableBgWrapper(AfterAuthWidget()));
      })
    ];

    List<Widget> happyPath = [
      // Column(children: [
      CopyText('You have been invited to join a Psi Test'),
      SizedBox(
        height: 10,
      ),
      Button(
        'Start Psi Test',
        () {
          var testToJoin = createTestFromFirestore([sharedTestSnapshot]);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(JoinPsiTest(test: testToJoin));
          goToScreen(context, TableBgWrapper(AfterAuthWidget()));
        },
      )
    ];

    if (receiverId != '' && senderId != '') {
      if (globalCurrentUser.uid == receiverId ||
          globalCurrentUser.uid == senderId) {
        screenOptions = linkIsYourActiveTest;
      } else
        screenOptions = testAlreadyFull;
    } else if (globalCurrentUser.uid == receiverId ||
        globalCurrentUser.uid == senderId) {
      screenOptions = triedToJoinOwnTest;
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
