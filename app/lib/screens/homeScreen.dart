import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
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
import 'package:app/main.dart';
import 'package:app/components/screenBackground.dart';

class HomePage extends StatelessWidget {
  final PsiTest currentTest;
  HomePage(this.currentTest);

  @override
  Widget build(BuildContext context) {
    // load other BG images to avoid a flash of white BG when navigating to other pages for the first time
    precacheImage(AssetImage('assets/left.jpg'), context);
    precacheImage(AssetImage('assets/right.jpg'), context);
    precacheImage(AssetImage('assets/gypsie.png'), context);

    if (currentTest != null) if (currentTest.testStatus ==
        PsiTestStatus.UNDERWAY) return TestScreen(currentTest.testId);

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
    ];

    List<Widget> activeTestScreen = (currentTest == null)
        ? []
        : [
            SizedBox(height: 5),
            CopyText(
                "You have a test underway \nWith ${currentTest.totalNumQuestions - currentTest.numQuestionsAnswered} questions left to answer   "),
            SizedBox(height: 10),
            Button('Continue Test', () {
              goToScreen(context, TestScreen(currentTest.testId));
            }),
            SecondaryButton('End the Test', () {
              print('do logic to cancel the test');
              var event = CancelPsiTest(test: currentTest);
              BlocProvider.of<PsiTestSaveBloc>(context).add(event);
            }),
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
        goToScreen(context, TableBgWrapper(AfterAuthWidget()));
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
        goToScreen(context, TableBgWrapper(AfterAuthWidget()));
      }),
    ];

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

    return BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
        builder: (context, state) {
      print(state);
      if (state is PsiTestSaveShareInProgress)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CopyText('loading apps for sharing...'),
          // CircularProgressIndicator()
        ]);
      if (state is PsiTestSaveCancelInProgress)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CopyText('ending test...'),
          // CircularProgressIndicator()
        ]);
      else
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(height: 10),
            TitleText(
                'The Psi Telepathy Test App lets you discover your telepathic abilities with a friend.'),
            ...screenOptions,
            SizedBox(height: 150),
            FooterButtons(),
          ],
        );
    });
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
