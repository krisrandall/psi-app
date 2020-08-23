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
import 'package:uni_links/uni_links.dart';

class SenderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: LeftBgWrapper(
        StreamBuilder<QuerySnapshot>(
            stream: firestoreDatabaseStream.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (psiTestNotAvailable(snapshot))
                return psiTestNotAvailableWidget(snapshot);
              var currentTest =
                  createTestFromFirestore(snapshot.data.documents);
              return _SenderScreen(currentTest);
            }),
      ),
    );
  }
}

class _SenderScreen extends StatefulWidget {
  final PsiTest currentTest;
  _SenderScreen(this.currentTest);

  @override
  __SenderScreenState createState() => __SenderScreenState();
}

class __SenderScreenState extends State<_SenderScreen> {
  String deepLink;
  void getLink() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        print('calling getInitialLink');
        deepLink = await getInitialLink();
        getLink();
        print('link is $deepLink');
      } catch (e) {
        print('getInitialLink ERROR');
        print(e);
      }

      //initUniLinks();
      if (deepLink != null) {
        print('link is $deepLink');
        //goToScreen(context, OpenedViaLinkWidget(deepLink, 'getInitialUri'));
      }
    });
    Widget actionButton;
    if (widget.currentTest == null) {
      actionButton = Button(
        'Create Test (Invite Friend)',
        () {
          var newlyCreatedTest = PsiTest.beginNewTestAsSender();
          var event = CreatePsiTest(test: newlyCreatedTest);
          BlocProvider.of<PsiTestSaveBloc>(context).add(event);
        },
      );
    } else if (widget.currentTest.myRole == PsiTestRole.SENDER) {
      if (widget.currentTest.testStatus == PsiTestStatus.UNDERWAY) {
        actionButton = Button(
          'Continue Test',
          () {
            goToScreen(context, TestScreen());
          },
        );
      } else if (widget.currentTest.testStatus ==
          PsiTestStatus.AWAITING_RECEIVER) {
        actionButton = Button(
          'Invite Friend via a share link',
          () {
            BlocProvider.of<PsiTestSaveBloc>(context)
                .add(SharePsiTest(test: widget.currentTest));
          },
        );
      }
    } else {
      actionButton = CopyText(
          "There is a test underway and you are the Receiver.\n\nGo back and complete the test.");
    }

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
  }
}
