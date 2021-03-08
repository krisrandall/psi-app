import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/loadingMessages.dart';
import 'package:app/components/utils.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/infoScreens.dart';
import 'package:app/screens/testScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/facebook_logic.dart';
import 'package:share/share.dart';
import 'package:clipboard/clipboard.dart';

class ReceiverScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _receiverScreenScaffoldKey =
      new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _receiverScreenScaffoldKey,
        appBar: AppBar(
          title: Text('𝚿 Psi Telepathy Test'),
          actions: [
            IconButton(
                icon: Icon(Icons.help),
                onPressed: () => goToScreen(context, ReceiverInfo())),
          ],
        ),
        body: RightBgWrapper(StreamBuilder<QuerySnapshot>(
            stream: firestoreDatabaseStream.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (psiTestNotAvailable(snapshot))
                return psiTestNotAvailableWidget(context, snapshot);
              var currentTest =
                  createTestFromFirestore(snapshot.data.documents);
              print(currentTest);
              return _ReceiverScreen(currentTest, _receiverScreenScaffoldKey);
            })));
  }
}

class _ReceiverScreen extends StatelessWidget {
  final PsiTest currentTest;
  final _receiverScreenScaffoldKey;

  void goToTestScreenAsynchronously(
      BuildContext context, PsiTest currentTest) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(currentTest.testId)));
  }

  _ReceiverScreen(this.currentTest, this._receiverScreenScaffoldKey);

  _showSnackBar() {
    final snackBar = new SnackBar(
        backgroundColor: Colors.purple,
        duration: Duration(milliseconds: 1000),
        content:
            new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CopyText('Copied link'),
        ]));
    _receiverScreenScaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      if ((currentTest != null) &&
          (currentTest.testStatus == PsiTestStatus.UNDERWAY)) {
        goToTestScreenAsynchronously(context, currentTest);
      }
    });
    Widget actionButton;

    Widget facebookFriends = FutureBuilder<List>(
        future: getFacebookFriendsList(context, currentTest),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          if (!snapshot.hasData)
            return Button(
                // this appears when ID or access token are not available
                'log on to Facebook',
                () => linkFacebookUserWithCurrentAnonUser(context));
          else {
            print("snapshot.data is ${snapshot.data}");
            return Column(children: [
              SizedBox(height: 30),
              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                      width: 440,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [...snapshot.data])))
            ]);
          }
        }));

    if (currentTest != null) if (currentTest.testStatus ==
        PsiTestStatus.UNDERWAY) return TestScreen(currentTest.testId);

    if (currentTest == null) {
      actionButton = Image.asset("assets/sun_loading_spinner.gif");
    } else if (currentTest.myRole == PsiTestRole.RECEIVER) {
      if (currentTest.testStatus == PsiTestStatus.UNDERWAY) {
        actionButton = TitleText('Test starting now...');
        Button(
          'Continue Test',
          () {
            goToScreen(context, TestScreen(currentTest.testId));
          },
        );
      } else if (currentTest.testStatus == PsiTestStatus.AWAITING_SENDER) {
        actionButton = BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
            builder: (context, state) {
          print(state);
          String shareLink = '';
          if (state is PsiTestSaveShareSuccessful) {
            if (shareLink == '') shareLink = currentTest.shareLink;
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CopyText('''Send the link below to a friend
      to invite them to the test'''),
                  SizedBox(height: 30),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    PsiIconButton(Icon(Icons.copy), () {
                      FlutterClipboard.copy(shareLink);
                      _showSnackBar();
                    }),
                    SizedBox(width: 20),
                    PsiIconButton(Icon(Icons.share), () {
                      Share.share(shareLink);
                    })
                  ]),
                  SizedBox(height: 20),
                  Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: SizedBox(
                          width: 440,
                          height: 70,
                          child: Text(shareLink == null ? '' : shareLink,
                              style: TextStyle(color: Colors.white)))),
                  /*TextFormField(
                              //enabled: false,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  fillColor: Colors.purple[50],
                                  filled: true),
                              initialValue: shareLink))),*/
                  SizedBox(height: 20),
                ]);
          } else {
            return Column(children: [
              CopyText('loading shareLink'),
              CircularProgressIndicator(),
              SizedBox(height: 20),
            ]);
          }
        });
      } else {
        actionButton = CopyText(
            "There is a test underway and you are the Receiver.\n\nGo back and complete the test.");
      }
    }

    return BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
        builder: (context, state) {
      print(state);
      if (currentTest == null ||
          state is PsiTestSaveCreateInProgress ||
          state is PsiTestSaveShareInProgress)
        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Image.asset("assets/sun_loading_spinner.gif")]);
      else if (currentTest.invitedTo != '')
        return Button('${currentTest.invitedTo} invited you to a test', null);
      else
        return SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
              SizedBox(height: 5),
              TitleText('Receiver'),
              actionButton,
              SizedBox(
                height: 40,
              ),
              CopyText('''Or invite your Facebook friends...
   '''),
              facebookFriends,
              SizedBox(height: 130),
            ]));
    });
  }
}
