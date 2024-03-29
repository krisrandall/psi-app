import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/utils.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/creditsScreen.dart';
import 'package:app/screens/inviteWrapper.dart';
import 'package:app/screens/learnMoreScreen.dart';
import 'package:app/screens/testScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/screens/infoScreens.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('in home screen');
    print(
        'isFacebookUser = ${globalCurrentUser.isAnonymous} gcu uid is ${globalCurrentUser.uid}');
    return Scaffold(
        appBar: AppBar(
          title: Text('𝚿 Psi Telepathy Test'),
          actions: [
            IconButton(
              icon: Icon(Icons.help),
              onPressed: () => goToScreen(context, SenderAndReceiverInfo()),
            )
          ],
        ),
        body: TableBgWrapper(StreamBuilder<QuerySnapshot>(
            stream: firestoreDatabaseStream.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              if (psiTestNotAvailable(snapshot))
                return psiTestNotAvailableWidget(context, snapshot);
              var currentTest =
                  createTestFromFirestore(snapshot.data.documents);
              print('got to bottom of _HomeScreen');
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
    precacheImage(AssetImage('assets/sun_loading_spinner.gif'), context);

    Future.microtask(() {
      if ((currentTest != null) &&
          (currentTest.testStatus == PsiTestStatus.UNDERWAY)) {
        goToTestScreenAsynchronously(context, currentTest);
      }
    });

    List<Widget> noActiveTestOptions = [
      SizedBox(height: 60),
      Button(
        "Be the Sender",
        () {
          goToScreen(context, InviteWrapper('senderScreen'));
          var newlyCreatedTest = PsiTest.beginNewTestAsSender();
          var event = CreatePsiTest(test: newlyCreatedTest);
          BlocProvider.of<PsiTestSaveBloc>(context).add(event);

          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(SharePsiTest(test: newlyCreatedTest));

          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(GetFacebookFriendsList(test: newlyCreatedTest));
        },
      ),
      SizedBox(height: 10),
      Button(
        'Be the Receiver',
        () {
          goToScreen(context, InviteWrapper('receiverScreen'));
          var newlyCreatedTest = PsiTest.beginNewTestAsReceiver();
          var event = CreatePsiTest(test: newlyCreatedTest);
          BlocProvider.of<PsiTestSaveBloc>(context).add(event);

          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(SharePsiTest(test: newlyCreatedTest));
          //This has to be last so that the facebook friends are returned in the State of GetFacebookFriendsList
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(GetFacebookFriendsList(test: newlyCreatedTest));
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
            if (numTests == 0)
              return CopyText(' ');
            else
              return CopyText(
                  '$numCorrect correct from $numQuestions questions in $numTests tests');
          })
    ];

    List<Widget> activeTestScreen = (currentTest == null)
        ? []
        : [
            SizedBox(height: 60),
            CopyText("Test starting now...."),
            SizedBox(height: 10),
          ];

    List<Widget> awaitingReceiver = [
      CopyText('''You are the Sender.'''),
      SizedBox(height: 30),
      Button(
        'Invite Friend to your Test',
        () {
          goToScreen(context, InviteWrapper('senderScreen'));
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(GetFacebookFriendsList(test: currentTest));
        },
      ),
      SecondaryButton('Choose different role', () {
        print('do logic to cancel the test');
        var event = CancelPsiTest(test: currentTest);
        BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        goToScreen(context, InviteWrapper('homeScreen'));
      }),
    ];

    List<Widget> awaitingSender = [
      CopyText('''You are the Receiver.'''),
      SizedBox(height: 30),
      Button(
        'Invite Friend to your Test',
        () {
          goToScreen(context, InviteWrapper('receiverScreen'));

          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(GetFacebookFriendsList(test: currentTest));
        },
      ),
      SecondaryButton('Choose different role', () {
        print('do logic to cancel the test');
        var event = CancelPsiTest(test: currentTest);
        BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        event = CancelPsiTest(test: currentTest);
        goToScreen(context, InviteWrapper('homeScreen'));
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

// WillPopScope with onWillPop=>false disables the back button
//
    return WillPopScope(
        onWillPop: () async => false,
        child: BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
            builder: (context, state) {
          print(state);
          if (state is PsiTestSaveShareInProgress)
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/sun_loading_spinner.gif")
                  // CircularProgressIndicator()
                ]);
          if (state is PsiTestSaveCancelInProgress)
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image.asset("assets/sun_loading_spinner.gif")
                  //CopyText('Ending Test'),
                  // CircularProgressIndicator()
                ]);
          else
            return SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(height: 10),
                SizedBox(
                    width: 440,
                    child: TitleText(
                        'The Psi Telepathy Test App lets you discover your telepathic abilities with a friend.')),
                SizedBox(
                  height: 40,
                ),
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
