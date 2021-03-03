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
import 'package:app/components/facebook_login.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
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

  var facebookFriendsList = new List<Widget>();

  Future<List> getFacebookFriendsList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String facebookAccessToken = prefs.getString('facebookAccessToken');
    //String facebookID = prefs.getString('facebookID');
    Map jsonResponse;
    List friends;
    try {
      var response = await http.get(
          "https://graph.facebook.com/me/friends?access_token=$facebookAccessToken");

      if (response.statusCode == 200) {
        jsonResponse = convert.jsonDecode(response.body);
        friends = jsonResponse['data'];
        print(jsonResponse);
        print("friends object: $friends");
        print("friends 0 ${friends[0]}");

        for (Map friend in friends) {
          String friendID = friend['id'];
          print(friendID);

          var friendProfilePic =
              "https://graph.facebook.com/$friendID/picture?small?access_token=$facebookAccessToken";
          facebookFriendsList.add(ListTile(
              tileColor: Colors.purple[100],
              leading: Image.network(friendProfilePic),
              trailing: Icon(Icons.bar_chart),
              title: Text(friend['name'])));
          facebookFriendsList.add(SizedBox(height: 10));
        }
      } else {
        print(
            'GET Request (facebook api) failed with status: ${response.statusCode}.');
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
    return facebookFriendsList;
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

    Widget facebookFriends = FutureBuilder<List>(
        future: getFacebookFriendsList(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return CircularProgressIndicator();
          if (!snapshot.hasData)
            return Button(
                // this appears when ID or access token are not available
                'log on to Facebook to find your friends',
                signInWithFacebook);
          else {
            print(snapshot.data);
            return Column(children: [
              SizedBox(height: 30),
              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: SizedBox(
                      width: 440,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: facebookFriendsList)))
            ]);
          }
        }));

    if (currentTest != null) if (currentTest.testStatus ==
        PsiTestStatus.UNDERWAY) return TestScreen(currentTest.testId);

    if (currentTest == null) {
      actionButton = Image.asset("assets/loading_grow_flower.gif");
    } else if (currentTest.myRole == PsiTestRole.SENDER) {
      if (currentTest.testStatus == PsiTestStatus.UNDERWAY) {
        actionButton = TitleText('Test starting now...');
        Button(
          'Continue Test',
          () {
            goToScreen(context, TestScreen(currentTest.testId));
          },
        );
      } else if (currentTest.testStatus == PsiTestStatus.AWAITING_RECEIVER) {
        actionButton = BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
            builder: (context, state) {
          print(state);
          String shareLink = '';
          if (state is PsiTestSaveShareSuccessful) {
            shareLink = state.getShareLink();
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
                          child: Text(shareLink,
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
            "There is a test underway and you are the Sender.\n\nGo back and complete the test.");
      }
    }

    return BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
        builder: (context, state) {
      print(state);
      if (currentTest == null)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/loading_grow_flower.gif")
          // CopyText('loading apps for sharing...'),
        ]);
      else if (state is PsiTestSaveCreateInProgress)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          //CopyText(getMessage()
          Container(
              width: 60, child: Image.asset("assets/loading_grow_flower.gif"))
          // child: LinearProgressIndicator(value: state.getProgress()))
        ]);
      else if (state is PsiTestSaveAddQuestionsInProgress) {
        print(state.getProgress());
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          //CopyText('loading test questions...'),
          CopyText('creating test...'),
          Container(
              width: 60,
              child: LinearProgressIndicator(value: state.getProgress()))
        ]);
      } else if (state is PsiTestSaveShareInProgress)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/loading_grow_flower.gif")
          //CopyText('loading apps for sharing...'),
        ]);
      else
        return SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
              //final snackBar = new SnackBar(content: new Text("Copied to Clipboard")),
              SizedBox(height: 5),
              TitleText('Sender'),
              FlatButton(
                  child: Icon(Icons.help),
                  onPressed: () => goToScreen(context, SenderInfo())),

              // SizedBox(height: 19),
              actionButton,
              SizedBox(
                height: 40,
              ),
              CopyText('''    Or connect directly
to your Facebook friends
   (who have this app)'''),
              facebookFriends,
              SizedBox(height: 130),
            ]));
    });
  }
}
