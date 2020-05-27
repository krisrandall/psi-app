import 'package:app/senderScreen.dart';
import 'receiverScreen.dart';
import 'package:flutter/material.dart';
bool receiver;

class ChooseScreen extends StatelessWidget{
  build(context){return MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Choose Sender or Receiver')), 
      body: Column(mainAxisAlignment: MainAxisAlignment.center, 
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [      
        Container(padding: EdgeInsets.only(left:20.0, right:20.0), child: 
        RaisedButton(child: Text('Sender'),
        onPressed:()
        { [(Navigator.push(context, MaterialPageRoute(builder: (context) => SenderScreen()))),
           receiver=false];
           ;}
        )),
        //choice takes us to new screen and sends
        Container(padding: EdgeInsets.only(left: 20.0, right: 20.0),child: 
        RaisedButton(child: Text('Receiver'), onPressed:()
        { [(Navigator.push(context, MaterialPageRoute(builder: (context) => ReceiverScreen()))),
        receiver= true];} 

        
        //TOD=
           ))

        ]
    )
    )
  );
}}