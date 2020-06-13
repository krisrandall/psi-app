import 'package:app/components/button.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:flutter/material.dart';

class ReceiverScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: RightBgWrapper( 
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            SizedBox(height: 5),

            TitleText('Receiver'),

            CopyText('''As the Receiver you will be presented with a set of four different pictures.  

The Sender will be looking at one of those pictures and telepathically projecting a mental image of it to you.

Your job as the Receiver is to receive that mental image, and choose the picture that the Sender is sending by clicking on it.

There will be $DEFAULT_NUM_QUESTIONS sets of images in the test.

'''),

            SizedBox(height: 10),

            BeginTestActionButton(),

            SizedBox(height: 150),

        ])
      )
    );
  }
        
}

class BeginTestActionButton extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    return Button(
      'Begin Test (Invite Friend)',
      () { print('does nothinng yet ..'); },
    );
  }

}