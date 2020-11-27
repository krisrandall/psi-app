import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/components/utils.dart';
import 'package:app/config.dart';
import 'package:app/screens/testScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:app/components/button.dart';
import 'package:app/screens/homeScreen.dart';

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
                print('looking for test with testID $testId');
                return TableBgWrapper(
                    Center(child: CopyText('looking for test...')));
              } else if (snapshot.hasData) {
                if (!snapshot.data.exists) {
                  return TableBgWrapper(LinkDoesntExistWidget());
                } else {
                  return TableBgWrapper(_OpenedViaLinkWidget(snapshot.data));
                }
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
      Button('Go back and try again', () {
        goToScreen(context, TableBgWrapper(HomeScreen()));
      }),
      SizedBox(height: 10),
      //SecondaryButton('for help click here', () {
      // goToScreen(context, TableBgWrapper(HelpWithSharing()));
      //}),*/
    ];
    List<Widget> linkIsYourActiveTest = [
      CopyText('You are already part of this test'),
      Button('Continue Test', () {
        goToScreen(
            context, TableBgWrapper(TestScreen(sharedTestSnapshot.documentID)));
      })
    ];

    List<Widget> testAlreadyFull = [
      CopyText('You are unable to join this test'),
      CopyText('It already has a sender and a receiver'),
      Button('Go back', () {
        goToScreen(context, TableBgWrapper(HomeScreen()));
      })
    ];

    List<Widget> testNotUnderway = [
      CopyText('The test is no longer active'),
      CopyText('The status of the test is $status'),
      Button('Go back', () {
        goToScreen(context, TableBgWrapper(HomeScreen()));
      })
    ];

    List<Widget> happyPath = [
      TitleText('Join Psi Test'),
      SizedBox(height: 20),
      CopyText('You have been invited to join a Psi Test'),
      SizedBox(
        height: 10,
      ),
      Button(
        'Start Psi Test',
        () {
          var testToJoin = createTestFromFirestore([sharedTestSnapshot]);
          print(testToJoin.myRole);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(JoinPsiTest(test: testToJoin));
          goToScreen(context, TableBgWrapper(HomeScreen()));
        },
      ),
      SizedBox(
        height: 10,
      ),
      SecondaryButton("No thanks. I don't want to join", () {
        goToScreen(context, TableBgWrapper(HomeScreen()));
      })
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
          goToScreen(context, TableBgWrapper(HomeScreen()));
        })
      ],
    ));
  }
}
