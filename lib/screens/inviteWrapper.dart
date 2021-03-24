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

class InviteWrapper extends StatelessWidget {
  final String destination;
  InviteWrapper(this.destination);
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<PsiTestSaveBloc>(context)
        // bloc requires a test so we send a blank test
        .add(GetFacebookID(test: new PsiTest()));
    return BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
        builder: (context, state) {
      String _myFacebookID;
      if (state is GetFacebookIDInProgress)
        return CircularProgressIndicator();
      else if (state is GetFacebookIDFailed)
        return Text('couldnt get my Facebook ID');
      else if (state is GetFacebookIDSuccessful) {
        _myFacebookID = state.myFacebookID;
        print('facebook id from state : ${_myFacebookID}');
        // shouldn't need this because no test should have 'isAnon' as invitedFriend value
        // ***if (state.myFacebookID == 'isAnon') return HomeScreen();

        return TableBgWrapper(StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('test')
                .where("invitedFriend", isEqualTo: _myFacebookID)
                .where("status", isEqualTo: "underway")
                .where("full", isEqualTo: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                    child: TitleText(
                        'error connecting with database ${snapshot.error}'));
              } else if (snapshot.hasData) {
                print('has data');
                print('${state.myFacebookID}');
                print('number of docs ${snapshot.data.documents.length}');
                if (snapshot.data.documents.length > 0) {
                  List documents = snapshot.data.documents;
                  var invitations = new List<Widget>();
                  for (DocumentSnapshot document in documents) {
                    String inviterFacebookName =
                        //snapshot.data.documents[0].data['facebookName'];
                        document.data['facebookName'];
                    String invitedToTestID =
                        // snapshot.data.documents[0].documentID;
                        document.documentID;
                    Widget invitation = Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CopyText('''You have been invited to a test by '''),
                          TitleText(inviterFacebookName),
                          SizedBox(height: 40),
                          Button('Join Test', () {
                            var testToJoin =
                                new PsiTest(testId: invitedToTestID);
                            BlocProvider.of<PsiTestSaveBloc>(context).add(
                                AcceptFacebookInvitation(test: testToJoin));
                          }),
                          SizedBox(height: 10),
                          SecondaryButton('no thanks', null)
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
                }
              } //else if (!snapshot.hasData) {
              print('destination is $destination');

              return Column(children: [
                CircularProgressIndicator(),
                Text('problem with fetching Database docs '),
                Text('facebookID of test = ${snapshot.data}')
              ]);
            }));
      }
      return Column(
          children: [CircularProgressIndicator(), Text('very bottom')]);
    });
  }
}
