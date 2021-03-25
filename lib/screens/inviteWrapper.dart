import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/textComponents.dart';
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
  final String destination;
  InviteWrapper(this.destination);
  @override
  Widget build(BuildContext context) {
    Future<String> getFacebookID() async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      bool isAnon = _prefs.getBool('isAnonymous');
      String fbID = isAnon ? 'isAnon' : _prefs.getString('facebookID');
      print('got FacebookID $fbID');
      return isAnon ? 'isAnon' : _prefs.getString('facebookID');
    }

    return FutureBuilder(
        future: getFacebookID(),
        builder: (context, snapshot) {
          String _myFacebookID = snapshot.data;
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
                    return Center(
                        child: Image.asset("assets/sun_loading_spinner.gif"));
                    ////////////
                  } else if (snapshot.hasData) {
                    print('has data');
                    print('number of docs ${snapshot.data.documents.length}');
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
                                    new PsiTest(testId: invitedToTestID);

                                ///this is TODO add roles
                                BlocProvider.of<PsiTestSaveBloc>(context)
                                    .add(JoinPsiTest(test: testToJoin));
                              }),
                              SizedBox(height: 10),
                              SecondaryButton('no thanks', () {
                                PsiTest testToReject =
                                    createTestFromFirestore([document]);
                                BlocProvider.of<PsiTestSaveBloc>(context).add(
                                    RejectFacebookInvitation(
                                        test: testToReject));
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
                        return ReceiverScreen();
                      case 'senderScreen':
                        return SenderScreen();
                      default:
                        return Image.asset("assets/sun_loading_spinner.gif");
                    }
                  }
                  return Image.asset("assets/sun_loading_spinner.gif");
                }));
          return Text('down here at the bottom');
        });
  }
}
