
import 'package:app/components/button.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/screens/receiverScreen.dart';
import 'package:app/screens/senderScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class HomePage extends StatelessWidget {

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: _signOut,
          ),
        ],
      ),
      body: GypsyBgWrapper( 
        Column(children: <Widget>[

          TitleText('𝚿 Psi'),

          CopyText('The Psi Test App lets you discover your telepathic abilities with a friend.'),

          Padding( padding: EdgeInsets.all(80.0) ),
          
          Button(
            " ◄  Be The Sender",
            (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SenderScreen()
                )
              );
            },
          ),
/*
              Navigator.of(context).push(
                PageTransition(
                  type: PageTransitionType.slideInLeft, 
                  child: SenderScreen(),
                  ),
              );
              */

          Padding( padding: EdgeInsets.all(20.0) ),

          ButtonLeft('Be The Receiver ► ',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReceiverScreen()
              )
            );
          }),
          

        ],) 
      )
    );

  }
}

