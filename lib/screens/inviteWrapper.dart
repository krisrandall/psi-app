import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/facebook_logic.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/components/utils.dart';
import 'package:app/main.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/receiverScreen.dart';
import 'package:app/screens/senderScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/screenBackground.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/screens/homeScreen.dart';

import 'package:app/components/livePsiTestStream.dart';

import 'package:shared_preferences/shared_preferences.dart';

class InviteWrapper extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final String destination;
  InviteWrapper(this.destination);
  @override
  Widget build(BuildContext context) {
    // these reset methods are for the (theoretically impossible) situation where a user is logged in but
    // SharedPreferences hasn't saved a facebookID for them.
    //
    void resetFacebookID() async {
      await signInWithFacebook();
      goToScreen(context, LandingPage());
    }

    void resetIsAnon() async {
      await signInAnonymously();
      goToScreen(context, LandingPage());
    }

    Future<String> getFacebookID() async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      bool isAnon = _prefs.getBool('isAnonymous');
      String fbID = isAnon ? 'isAnon' : _prefs.getString('facebookID');
      print('got FacebookID $fbID');
      return isAnon ? 'isAnon' : _prefs.getString('facebookID');
    }

    return Scaffold(
        // this future builder's sole task is to get the facebook ID from SharedPreferences asyncchronously,
        // or to retun "isAnon" if SharedPreferences has
        body: FutureBuilder(
            future: getFacebookID(),
            builder: (context, snapshot) {
              String _myFacebookID = snapshot.data;
              /////if for some reason the user is logged in but Shared Preferences doesnt have their Facebook uid
              if (_myFacebookID == null)
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CopyText('Something went wrong. Please log in again'),
                      Button('log in to Facebook', () {
                        resetFacebookID();
                      }),
                      SecondaryButton('no thanks', () => resetIsAnon())
                    ]);
              if (snapshot.connectionState == ConnectionState.done)
                return TableBgWrapper(StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('test')
                        .where("invitedFriend", isEqualTo: _myFacebookID)
                        .where("status", isEqualTo: "underway")
                        .where("full", isEqualTo: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      ////////////
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Center(
                            child: TitleText(
                                'error connecting with database ${snapshot.error}'));
                      }
                      /////////////
                      if (!snapshot.hasData) {
                        print(
                            'checking database for invites before loading $destination');
                        return Container();
                        ////////////
                      } else if (snapshot.hasData) {
                        print('has data');
                        print(
                            'number of docs ${snapshot.data.documents.length}');
                        if (snapshot.data.documents.length > 0) {
                          List documents = snapshot.data.documents;
                          var invitations = new List<Widget>();
                          for (DocumentSnapshot document in documents) {
                            String inviterFacebookName =
                                //snapshot.data.documents[0].data['facebookName'];
                                document.data['myFacebookName'];
                            String invitedToTestID =
                                // snapshot.data.documents[0].documentID;
                                document.documentID;
                            Widget invitation = Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CopyText(
                                      '''You have been invited to a test by '''),
                                  TitleText(inviterFacebookName),
                                  SizedBox(height: 40),
                                  Button('Join Test', () {
                                    var testToJoin =
                                        createTestFromFirestore([document]);

                                    ///this is TODO add roles
                                    BlocProvider.of<PsiTestSaveBloc>(context)
                                        .add(JoinPsiTest(test: testToJoin));
                                  }),
                                  SizedBox(height: 10),
                                  SecondaryButton('no thanks', () {
                                    PsiTest testToReject =
                                        createTestFromFirestore([document]);
                                    BlocProvider.of<PsiTestSaveBloc>(context)
                                        .add(RejectFacebookInvitation(
                                            test: testToReject));
                                    BlocProvider.of<PsiTestSaveBloc>(context)
                                        .add(GetFacebookFriendsList(
                                            test: new PsiTest()));
                                  })
                                ]);
                            invitations.add(invitation);
                          }
                          return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [...invitations]);
                        } else
                          // if documents.length == 0
                          // then there is no active FB invitation for this user
                          print(destination);
                        switch (destination) {
                          case 'homeScreen':
                            return HomeScreen();
                          case 'receiverScreen':
                            return ReceiverScreen(
                              receiverScreenScaffoldKey: _scaffoldKey,
                            );
                          case 'senderScreen':
                            return SenderScreen(
                              senderScreenScaffoldKey: _scaffoldKey,
                            );
                          default:
                            print('in default of invite Wrapper');
                            return Container();
                        }
                      }
                      print('second to bottom of invite Wrapper');
                      return Container();
                    }));
              print('very bottom of invite Wrapper');
              return Container();
            }));
  }
}
