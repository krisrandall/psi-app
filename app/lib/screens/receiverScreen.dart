import 'package:app/components/button.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/utils.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/testScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReceiverScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: RightBgWrapper(
        StreamBuilder<QuerySnapshot>(
            stream: firestoreDatabaseStream.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (psiTestNotAvailable(snapshot))
                return psiTestNotAvailableWidget(context, snapshot);
              var currentTest =
                  createTestFromFirestore(snapshot.data.documents);
              return _ReceiverScreen(currentTest);
            }),
      ),
    );
  }
}

class _ReceiverScreen extends StatelessWidget {
  final PsiTest currentTest;
  _ReceiverScreen(this.currentTest);

  @override
  Widget build(BuildContext context) {
    Widget actionButton;
    if (currentTest == null) {
      actionButton = Button(
        'Begin Test (Invite Friend)',
        () {
          print('does nothinng yet ..');
        },
      );
    } else if (currentTest.myRole == PsiTestRole.RECEIVER) {
      actionButton = Button(
        'Continue Test',
        () {
          goToScreen(context, TestScreen(currentTest.testId));
        },
      );
    } else {
      actionButton = CopyText(
          "There is a test underway and you are the Sender.\n\nGo back and complete the test.");
    }
    return Column(
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
        ]);
  }
}
