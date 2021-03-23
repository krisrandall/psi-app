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

class SenderScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _senderScreenScaffoldKey =
      new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _senderScreenScaffoldKey,
        appBar: AppBar(
          title: Text('𝚿 Psi Telepathy Test'),
          actions: [
            IconButton(
                icon: Icon(Icons.help),
                onPressed: () => goToScreen(context, SenderInfo())),
          ],
        ),
        body: LeftBgWrapper(StreamBuilder<QuerySnapshot>(
            stream: firestoreDatabaseStream.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (psiTestNotAvailable(snapshot))
                return psiTestNotAvailableWidget(context, snapshot);
              var currentTest =
                  createTestFromFirestore(snapshot.data.documents);
              print(currentTest);
              return _SenderScreen(currentTest, _senderScreenScaffoldKey);
            })));
  }
}

class _SenderScreen extends StatelessWidget {
  final PsiTest currentTest;
  final _senderScreenScaffoldKey;

  void goToTestScreenAsynchronously(
      BuildContext context, PsiTest currentTest) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(currentTest.testId)));
  }

  _SenderScreen(this.currentTest, this._senderScreenScaffoldKey);

  _showSnackBar() {
    final snackBar = new SnackBar(
        backgroundColor: Colors.purple,
        duration: Duration(milliseconds: 1000),
        content:
            new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CopyText('Copied link'),
        ]));
    _senderScreenScaffoldKey.currentState.showSnackBar(snackBar);
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
    Widget facebookFriends;

    if (currentTest != null) if (currentTest.testStatus ==
        PsiTestStatus.UNDERWAY) return TestScreen(currentTest.testId);

    if (currentTest == null) {
      actionButton = Image.asset("assets/sun_loading_spinner.gif");
    }
    if (currentTest.testStatus == PsiTestStatus.UNDERWAY) {
      actionButton = TitleText('Test starting now...');
      Button(
        'Continue Test',
        () {
          goToScreen(context, TestScreen(currentTest.testId));
        },
      );
      facebookFriends = Container();
    } else if (currentTest.testStatus == PsiTestStatus.AWAITING_RECEIVER) {
      String shareLink = currentTest.shareLink;
      actionButton =
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                child: shareLink == ''
                    ? CircularProgressIndicator()
                    : Text(shareLink, style: TextStyle(color: Colors.white)))),
        /*TextFormField(
                              //enabled: false,
                              decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  fillColor: Colors.purple[50],
                                  filled: true),
                              initialValue: shareLink))),*/
        SizedBox(height: 20),
      ]);
      facebookFriends = BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
          builder: (context, state) {
        if (state is GetFacebookFriendsListFailed)
          return Column(
            children: [
              CopyText('There was a problem accessing your facebook friends'),
              Button('Try again', () {
                BlocProvider.of<PsiTestSaveBloc>(context)
                    .add(GetFacebookFriendsList(test: currentTest));
              })
            ],
          );
        if (state is GetFacebookFriendsListInProgress)
          return CircularProgressIndicator();
        else if (state is GetFacebookFriendsListSuccessful) {
          if (state.facebookFriends == [])
            return Button(
                // this appears when ID or access token are not available
                'log on to Facebook', () {
              linkFacebookUserWithCurrentAnonUser(context, currentTest);
              BlocProvider.of<PsiTestSaveBloc>(context)
                  .add(GetFacebookFriendsList(test: currentTest));
            });

          if (state.facebookFriends.length == 0)
            return Text(
                '''none of your Facebook friends have this app installed.''',
                style: TextStyle(color: Colors.white));
          else
            return Column(children: [
              SizedBox(height: 30),
              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                      width: 400,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: buildFacebookFriendsList(
                              state.facebookFriends, currentTest, context))))
            ]);
        }
        return CircularProgressIndicator();
      });
    } else {
      actionButton = Column(children: [
        CopyText('loading shareLink'),
        CircularProgressIndicator(),
        SizedBox(height: 20),
      ]);
      facebookFriends = Container(child: Text('here i am'));
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
      else if (currentTest.invitedTo.isNotEmpty)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TitleText(
              '${currentTest.invitedTo[0]['inviter']} invited you to a test'),
          FutureBuilder(
              future: gotInvitedToTest(currentTest.invitedTo[0]['testId']),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  print(
                      'looking for test with testID ${currentTest.invitedTo[0]['testId']}');
                  return (Center(child: CopyText('looking for test...')));
                } else if (snapshot.hasData) {
                  if (snapshot.data.exists) {
                    return Button('okay, join', () {
                      var testToJoin = createTestFromFirestore([snapshot.data]);
                      print(testToJoin.myRole);
                      BlocProvider.of<PsiTestSaveBloc>(context)
                          .add(JoinPsiTest(test: testToJoin));
                    });
                  } else
                    return Column(children: [
                      CopyText('Test no longer exists :('),
                      Button('okay', () {
                        BlocProvider.of<PsiTestSaveBloc>(context)
                            .add(CancelPsiTest(test: currentTest));
                      })
                    ]);
                } else if (snapshot.hasError) {
                  print('snapshot has error');
                }
                return Container();
              })
        ]);
      else
        return SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
              SizedBox(height: 5),
              TitleText('Sender'),
              SizedBox(height: 19),
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
