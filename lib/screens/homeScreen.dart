import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/utils.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/main.dart';
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
  final GlobalKey<ScaffoldState> _homeScaffoldKey =
      new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    print('in home screen');
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
              return _HomeScreen(currentTest, _homeScaffoldKey);
            })));
  }
}

class _HomeScreen extends StatelessWidget {
  final PsiTest currentTest;
  final _homeScaffoldKey;
  _HomeScreen(this.currentTest, this._homeScaffoldKey);

  void goToTestScreenAsynchronously(
      BuildContext context, PsiTest currentTest) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(currentTest.testId)));
  }

  _showSnackBar() {
    final snackBar = new SnackBar(
        backgroundColor: Colors.purple,
        //duration: Duration(milliseconds: 1000),
        content: new Center(
            child: Column(children: [
          CopyText('Copied link'),
          Button(() {
            _homeScaffoldKey.currentState.hideCurrentSnackBar();
          }, 'No, Thanks'),
        ])));
    _homeScaffoldKey.currentState.showSnackBar(snackBar);
  }

  var user = globalCurrentUser;

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
          goToScreen(context, SenderScreen());
          var newlyCreatedTest = PsiTest.beginNewTestAsSender();
          var event = CreatePsiTest(test: newlyCreatedTest);
          BlocProvider.of<PsiTestSaveBloc>(context).add(event);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(SharePsiTest(test: newlyCreatedTest));
        },
      ),
      SizedBox(height: 10),
      Button(
        'Be the Receiver',
        () {
          goToScreen(context, ReceiverScreen());
          var newlyCreatedTest = PsiTest.beginNewTestAsReceiver();
          var event = CreatePsiTest(test: newlyCreatedTest);
          BlocProvider.of<PsiTestSaveBloc>(context).add(event);
          BlocProvider.of<PsiTestSaveBloc>(context)
              .add(SharePsiTest(test: newlyCreatedTest));
        },
      ),
      SizedBox(height: 10),
      Button('FB logout', () {
        goToScreen(context, LandingPage());
      }),
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
      CopyText('You are the Sender.'),
      CopyText('Try inviting a friend to join your test.'),
      SizedBox(height: 30),
      Button(
        'Invite Friend to your Test',
        () {
          goToScreen(context, SenderScreen());
        },
      ),
      SecondaryButton('Choose different role', () {
        print('do logic to cancel the test');
        var event = CancelPsiTest(test: currentTest);
        BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        goToScreen(context, TableBgWrapper(HomeScreen()));
      }),
    ];

    List<Widget> awaitingSender = [
      CopyText('You are the Receiver.'),
      CopyText('Try inviting a friend to join your test.'),
      SizedBox(height: 30),
      Button(
        'Invite Friend to your Test',
        () {
          goToScreen(context, ReceiverScreen());
        },
      ),
      SecondaryButton('Choose different role', () {
        print('do logic to cancel the test');
        var event = CancelPsiTest(test: currentTest);
        BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        event = CancelPsiTest(test: currentTest);
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

// WillPopScope with onWillPop=>false disables the back button

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
                  CopyText('Ending Test'),
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
