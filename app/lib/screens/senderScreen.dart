import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:flutter/material.dart';

class SenderScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: LeftBgWrapper( 
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            SizedBox(height: 10),

            CopyText('Sender Screen'),

            SizedBox(height: 480),

        ])
      )
    );
  }
        
}