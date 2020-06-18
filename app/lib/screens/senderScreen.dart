import 'package:app/components/button.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/utils.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/testScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

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
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            print('... ${snapshot.connectionState}');
            print(' has data = ${snapshot.hasData} ');
            if (psiTestNotAvailable(snapshot)) return psiTestNotAvailableWidget(snapshot);
            var currentTest = createTestFromFirestore(snapshot.data.documents);
            return _SenderScreen(currentTest);
          }
        ),
      ),
    );
  }
}

class _SenderScreen extends StatelessWidget{

  final PsiTest currentTest;
  _SenderScreen(this.currentTest);

  @override
  Widget build(BuildContext context){

    Widget actionButton;
    if (currentTest == null) {
      actionButton = Button(
                          'Begin Test (Invite Friend)',
                          () async { 
                            print('TODO - actually CREATE THE TEST ON THE SERVER FIRST !!!');
                            var shareTestUrl = await dynamicLink('123'); 
                            // TODO -- shorten this link -- maybe with https://developers.rebrandly.com/docs
                            Share.share('Take a Telepathy Test with me! $shareTestUrl');
                          },
                        );
    } else if (currentTest.myRole == PsiTestRole.SENDER) {
      actionButton = Button(
                          'Continue Test',
                          (){ goToScreen(context, TestScreen()); },
                        );
    } else {
      actionButton = CopyText("There is a test underway and you are the Receiver.\n\nGo back and complete the test.");
    }

    return 
         SingleChildScrollView( child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(height: 5),
                TitleText('Sender'),
                CopyText('''As the Sender, your job is to send a mental image of what you see to the Receiver.  You will be presented with a series of images, one at a time.  Focus on each one and imagine describing that image to the Receiver.

    The Receiver should not be able to physically see or hear you, they need to receive the mental image you project to them telepathically and pick which image you are Sending.

    There will be $DEFAULT_NUM_QUESTIONS images in the test.
    '''),
                SizedBox(height: 10),

                actionButton,

                SizedBox(height: 130),
            ])
    );
  }

}
