import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/utils.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/testScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/loadingMessages.dart';

class SenderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              return _SenderScreen(currentTest);
            })));
  }
}

class _SenderScreen extends StatelessWidget {
  final PsiTest currentTest;

  void goToTestScreenAsynchronously(
      BuildContext context, PsiTest currentTest) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestScreen(currentTest.testId)));
  }

  _SenderScreen(this.currentTest);

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
      if (currentTest == null)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/loading_grow_flower.gif")
          // CopyText('loading apps for sharing...'),
        ]);
      else if (state is PsiTestSaveCreateInProgress)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // CopyText(getMessage()),
          Container(
              width: 60,
              child: // LinearProgressIndicator(value: state.getProgress()))
                  Image.asset("assets/loading_grow_flower.gif"))
        ]);
      else if (state is PsiTestSaveAddQuestionsInProgress) {
        print(state.getProgress());
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/loading_grow_flower.gif"),
          // CopyText(getMessage()),
          Container(
              width: 60,
              child: LinearProgressIndicator(value: state.getProgress()))
        ]);
      } else if (state is PsiTestSaveShareInProgress)
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("assets/loading_grow_flower.gif")
          // CopyText('loading apps for sharing...'),
        ]);
      else
        return SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
              SizedBox(height: 5),
              TitleText('Sender'),
              CopyText(
                  '''As the Sender, your job is to send a mental image of what you see to the Receiver.  You will be presented with a series of images, one at a time.  Focus on each one and imagine describing that image to the Receiver.

    The Receiver should not be able to physically see or hear you, they need to receive the mental image you project to them telepathically and pick which image you are Sending.

    There will be $DEFAULT_NUM_QUESTIONS images in the test.
    '''),
              SizedBox(height: 10),
              actionButton,
              SizedBox(height: 130),
            ]));
    });
  }
}
