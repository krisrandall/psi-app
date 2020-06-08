import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:flutter/material.dart';

class SenderScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: LeftBgWrapper( 
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

            TitleText('[Here goes the button, or other text depending on state]'),

            SizedBox(height: 130),

        ])
        )
      )
    );
  }
        
}