import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/loadingMessages.dart';
import 'package:app/components/utils.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/testScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share/share.dart';

class ReceiverScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('𝚿 Psi Telepathy Test'),
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
              return _ReceiverScreen(currentTest);
            })));
  }
}

class _ReceiverScreen extends StatelessWidget {
  final PsiTest currentTest;

  void goToTestScreenAsynchronously(
      BuildContext context, PsiTest currentTest) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(currentTest.testId)));
  }

  _ReceiverScreen(this.currentTest);

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      if ((currentTest != null) &&
          (currentTest.testStatus == PsiTestStatus.UNDERWAY)) {
        goToTestScreenAsynchronously(context, currentTest);
      }
    });
    Widget actionButton;
    if (currentTest != null) if (currentTest.testStatus ==
        PsiTestStatus.UNDERWAY) return TestScreen(currentTest.testId);

    if (currentTest == null) {
      actionButton = Image.asset("assets/loading_grow_flower.gif");
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
            shareLink = state.getShareLink();
            return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      //padding: EdgeInsets.only(left: 80.0, right: 80.0),
                      width: 400,
                      height: 70,
                      child: TextFormField(
                          //enabled: false,
                          decoration: InputDecoration(
                              //icon: Icon(Icons.copy, color: Colors.black),
                              border: const OutlineInputBorder(),
                              fillColor: Colors.purple[50],
                              filled: true),
                          initialValue: shareLink)),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    FlatButton(
                        height: 62,
                        color: Colors.purple,
                        child: Icon(Icons.copy),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                            side: BorderSide(color: Colors.white, width: 4.0)),
                        onPressed: () {
                          BlocProvider.of<PsiTestSaveBloc>(context)
                              .add(SharePsiTest(test: currentTest));
                        }),
                    SizedBox(width: 20),
                    FlatButton(
                        height: 62,
                        color: Colors.purple,
                        child: Icon(Icons.share),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32.0),
                            side: BorderSide(color: Colors.white, width: 4.0)),
                        onPressed: () {
                          //  BlocProvider.of<PsiTestSaveBloc>(context)
                          //     .add(SharePsiTest(test: currentTest));
                          Share.share(shareLink);
                        })
                  ]),
                  SizedBox(height: 20),
                  CopyText('Send the link above to a friend'),
                  CopyText('to invite them to the test')
                ]);
          } else {
            return CopyText('loading shareLink $state');
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
              SizedBox(height: 5),
              TitleText('Receiver'),
              CopyText(
                  '''As the Receiver you will be presented with a set of four different pictures.  

The Sender will be looking at one of those pictures and telepathically projecting a mental image of it to you.

Your job as the Receiver is to receive that mental image, and choose the picture that the Sender is sending by clicking on it.

There will be $DEFAULT_NUM_QUESTIONS sets of images in the test.
'''),
              SizedBox(height: 10),
              actionButton,
              SizedBox(height: 130),
            ]));
    });
  }
}
