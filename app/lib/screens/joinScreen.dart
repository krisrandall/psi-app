import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/config.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class OpenedViaLinkWidget extends StatelessWidget {
  final String deepLink;
  OpenedViaLinkWidget(this.deepLink);

  Future<DocumentSnapshot> getSharedPsiTest(testId) async {
    var docRef = Firestore.instance.collection('test').document(testId);
    DocumentSnapshot testToJoinOnFirestore = await docRef.get();
    return testToJoinOnFirestore;
  }

  //TODO add UID to stream--using JoinPsiTest event*/

  @override
  Widget build(BuildContext context) {
    //extract TestId String from Deep Link
    String testId = deepLink.replaceAll(new RegExp(ADDRESSPARTOFDEEPLINK), '');
    return Scaffold(
        appBar: AppBar(
          title: Text('Opened Via Link'),
        ),
        body: FutureBuilder(
            future: getSharedPsiTest(testId),
            builder: (context, testToJoinOnFirestore) {
              switch (testToJoinOnFirestore.connectionState) {
                case ConnectionState.none:
                  return CopyText('no Test found');
                  break;
                case ConnectionState.waiting:
                  return CopyText(
                      'looking for Test'); // TODO: Handle this case.
                  break;
                case ConnectionState.active:
                  return CopyText('found Test and retrieving data');
                  break;
                case ConnectionState.done:
                  String receiverId = testToJoinOnFirestore.data['receiver'];
                  String senderId = testToJoinOnFirestore.data['sender'];
                  return CopyText(
                      'receiver ID: $receiverId senderId: $senderId');
                  //  if (receiverId == globalCurrentUser && senderId == '')
                  //return _OpenedViaLinkWidget(testToJoinOnFirestore);
                  break;
              }
              return Container();
            }));
  }
}

/*class _OpenedViaLinkWidget extends StatelessWidget {
  final testToJoinOnFirestore;
  _OpenedViaLinkWidget(this.testToJoinOnFirestore);
   @override
  Widget build(BuildContext context) {
    Widget actionButton;
    if (currentTest == null) {
      actionButton = Button(
        'Create Test (Invite Friend)',
        () {
          var newlyCreatedTest = PsiTest.beginNewTestAsSender();
          var event = CreatePsiTest(test: newlyCreatedTest);
          BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        },
      );
    } else if (currentTest.myRole == PsiTestRole.SENDER) {
      if (currentTest.testStatus == PsiTestStatus.UNDERWAY) {
        actionButton = Button(
          'Continue Test',
          () {
            goToScreen(context, TestScreen());
          },
        );
      } else if (currentTest.testStatus == PsiTestStatus.AWAITING_RECEIVER) {
        actionButton = Button(
          'Invite Friend via a share link',
          () {
            BlocProvider.of<PsiTestSaveBloc>(context)
                .add(SharePsiTest(test: currentTest));
          },
        );
      }
    } else {
      actionButton = CopyText(
          "There is a test underway and you are the Receiver.\n\nGo back and complete the test.");
    }

    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
          SizedBox(height: 5),
          TitleText('Sender'),
          CopyText(
              '''As the Sender, your job is to send a mental image of what you see to the Receiver.  You will be presented with a series of images, one at a time.  Focus on each one and imagine describing that image to the Receiver.

    The Receiver should not be able to physically see or hear you, they need to receive the mental image you project to them telepathically and pick which image you are Sending.

   There will be DEFAULT_NUM_QUESTIONS images in the test.
    '''),
          SizedBox(height: 10),
          actionButton,
          SizedBox(height: 130),
        ]));
  }
}
}*/

// TO CHANNGE TO QUERY BASED ON INPUT PARAM

/*if record not found..
          if sender or receiver is me...continue test button
          if sender and receiver are full...(test already full) okay button
          if status is "underway" (test not currently underway:status is: $status)
          happy path: button begin test or decline


          begin test button*/
