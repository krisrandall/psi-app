import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/loadingMessages.dart';
import 'package:app/components/utils.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/creditsScreen.dart';
import 'package:app/screens/learnMoreScreen.dart';
import 'package:app/screens/receiverScreen.dart';
import 'package:app/screens/senderScreen.dart';
import 'package:app/screens/testScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('𝚿 Psi Telepathy Test'),
        ),
        body: TableBgWrapper(StreamBuilder<QuerySnapshot>(
            stream: firestoreDatabaseStream.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (psiTestNotAvailable(snapshot))
                return psiTestNotAvailableWidget(context, snapshot);
              var currentTest =
                  createTestFromFirestore(snapshot.data.documents);
              return _HomeScreen(currentTest);
            })));
  }
}

class _HomeScreen extends StatelessWidget {
  final PsiTest currentTest;
  _HomeScreen(this.currentTest);

  void goToTestScreenAsynchronously(
      BuildContext context, PsiTest currentTest) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(currentTest.testId)));
  }

  @override
  Widget build(BuildContext context) {
    // load other BG images to avoid a flash of white BG when navigating to other pages for the first time
    precacheImage(AssetImage('assets/left.jpg'), context);
    precacheImage(AssetImage('assets/right.jpg'), context);
    precacheImage(AssetImage('assets/gypsie.png'), context);

    Future.microtask(() {
      if (currentTest.testStatus == PsiTestStatus.UNDERWAY) {
        goToTestScreenAsynchronously(context, currentTest);
      }
    });

    List<Widget> noActiveTestOptions = [
      SizedBox(height: 100),
      Button(
        "Be the Sender",
        () {
          goToScreen(context, SenderScreen());
        },
      ),
      SizedBox(height: 10),
      Button(
        'Be the Receiver',
        () {
          goToScreen(context, ReceiverScreen());
        },
      ),
      StreamBuilder<QuerySnapshot>(
          stream: userTestStats.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container();

            int numTests = 0;
            int numQuestions = 0;
            int numCorrect = 0;

            snapshot.data.documents.forEach((test) {
              numTests++;
              test['questions'].forEach((question) {
                numQuestions++;
                if (question['correctAnswer'] == question['providedAnswer'])
                  numCorrect++;
              });
            });

            if (snapshot.hasError) return CopyText('error loading stats');
/*
                      if (numTests == 0)
                        return Container();
                      else
                        return CopyText(
                            "$numTests tests taken \n $numAnsweredAsReceiver questions answered as Receiver ,\n $numCorrectAsReceiver correct , \n $numAnsweredAsSender questions answered as Sender, \n $numCorrectAsSender correct ");
                    }),*/
            return CopyText(
                '$numCorrect correct from $numQuestions questions in $numTests tests');
          })
    ];

    List<Widget> activeTestScreen = (currentTest == null)
        ? []
        : [
            SizedBox(height: 60),
            /*CopyText(
                "You have a test underway \nWith ${currentTest.totalNumQuestions - currentTest.numQuestionsAnswered} questions left to answer   "),*/
            CopyText("Test starting now...."),
            SizedBox(height: 10),
            /*Button('Continue Test', () {
              goToScreen(context, TestScreen(currentTest.testId));
            }),
            SecondaryButton('End the Test', () {
              print('do logic to cancel the test');
              var event = CancelPsiTest(test: currentTest);
              BlocProvider.of<PsiTestSaveBloc>(context).add(event);
            }),*/
          ];

    List<Widget> awaitingReceiver = [
      CopyText('You have created a test and you are the Sender.'),
      CopyText('Try inviting a friend to join your test.'),
      Button(
        'Invite Friend via a share link',
        () {
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(SharePsiTest(test: currentTest));
        },
      ),
      SecondaryButton('End the Test', () {
        print('do logic to cancel the test');
        var event = CancelPsiTest(test: currentTest);
        BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        goToScreen(context, TableBgWrapper(HomeScreen()));
      }),
    ];

    List<Widget> awaitingSender = [
      CopyText('You have created a test and you are the Receiver.'),
      CopyText('Try inviting a friend to join your test.'),
      Button(
        'Invite Friend via a share link',
        () {
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(SharePsiTest(test: currentTest));
        },
      ),
      SecondaryButton('End the Test', () {
        print('do logic to cancel the test');
        var event = CancelPsiTest(test: currentTest);
        BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        goToScreen(context, TableBgWrapper(HomeScreen()));
      }),
    ];

    // Widget stats =

    List<Widget> screenOptions = [];
    if (currentTest == null) {
      screenOptions = noActiveTestOptions;
    } else if (currentTest.testStatus == PsiTestStatus.UNDERWAY) {
      screenOptions = activeTestScreen;
    } else if (currentTest.testStatus == PsiTestStatus.AWAITING_SENDER) {
      screenOptions = awaitingSender;
    } else if (currentTest.testStatus == PsiTestStatus.AWAITING_RECEIVER) {
      screenOptions = awaitingReceiver;
    }

//WillPopScope with onWillPop=>false disables the back button
    return WillPopScope(
        onWillPop: () async => false,
        child: BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
            builder: (context, state) {
          print(state);
          if (state is PsiTestSaveShareInProgress)
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CopyText('loading apps for sharing...'),
                  // CircularProgressIndicator()
                ]);
          if (state is PsiTestSaveCancelInProgress)
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CopyText(getMessage()),
                  // CircularProgressIndicator()
                ]);
          else
            return SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(height: 10),
                TitleText(
                    'The Psi Telepathy Test App lets you discover your telepathic abilities with a friend.'),
                ...screenOptions,
                SizedBox(height: 60),
                FooterButtons(),
              ],
            ));
        }));
  }
}

class FooterButtons extends StatelessWidget {
  const FooterButtons({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple[900],
              icon: Icon(Icons.help),
              label: Text('Learn More'),
              onPressed: () {
                goToScreen(context, LearnMoreScreen());
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Colors.deepPurple[900],
              foregroundColor: Colors.white,
              icon: Icon(Icons.info),
              label: Text('Credits'),
              onPressed: () {
                goToScreen(context, CreditsScreen());
              },
            ),
          ),
        ],
      ),
    );
  }
}