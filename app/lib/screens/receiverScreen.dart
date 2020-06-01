import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:flutter/material.dart';

class ReceiverScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: RightBgWrapper( 
        Column(children: <Widget>[

          SizedBox(height: 50),

          CopyText('Receiver Screen'),

        ])
      )
    );
  }
        
}