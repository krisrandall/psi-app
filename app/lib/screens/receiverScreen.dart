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
      if (currentTest.testStatus == PsiTestStatus.UNDERWAY) {
        goToTestScreenAsynchronously(context, currentTest);
      }
    });

    Widget actionButton;
    if (currentTest != null) if (currentTest.testStatus ==
        PsiTestStatus.UNDERWAY) return TestScreen(currentTest.testId);

    if (currentTest == null) {
      actionButton = Button(
        'Create Test (Invite Friend)',
        () {
          var newlyCreatedTest = PsiTest.beginNewTestAsReceiver();
          var event = CreatePsiTest(test: newlyCreatedTest);
          BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        },
      );
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
        actionButton = Button(
          'Invite Friend via a share link',
          () {
            BlocProvider.of<PsiTestSaveBloc>(context)
                .add(SharePsiTest(test: currentTest));
          },
        );
      }
    } else {
      actionButton = CopyText(
          "There is a test underway and you are the Receiver.\n\nGo back and complete the test.");
    }

    return BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
        builder: (context, state) {
      print(state);
      if (state is PsiTestSaveCreateInProgress)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CopyText(getMessage()),
          //CopyText('creating test...'),
          Container(
              width: 60,
              child: LinearProgressIndicator(value: state.getProgress()))
        ]);
      else if (state is PsiTestSaveShareInProgress)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CopyText('loading apps for sharing...'),
          //CircularProgressIndicator()
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
