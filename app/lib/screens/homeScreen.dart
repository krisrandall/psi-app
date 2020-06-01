
import 'package:app/components/button.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/screens/receiverScreen.dart';
import 'package:app/screens/senderScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';


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
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: GypsyBgWrapper( 
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            SizedBox(height: 10),

            TitleText('The Psi Telepathy Test App lets you discover your telepathic abilities with a friend.'),

            SizedBox(height: 100),
            
            Button(
              "Be the Sender",
              (){
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade, 
                    child: SenderScreen()
                  )
                );
              },
            ),

            SizedBox(height: 10),

            Button('Be the Receiver',
            () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.fade, 
                  child: ReceiverScreen()
                )
              );
            }),
            
            SizedBox(height: 150),

            
            Padding(
              padding: EdgeInsets.all(10.0),
              child : Stack(
                children: <Widget>[

                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple[900],
                      icon: Icon(Icons.help),
                      label: Text('Learn More'),
                      onPressed: () { 
                        print('Clicked'); 
                      },
                    ),
                  ),

                  // This looks SO GOOD here, but sadly and bizarely 
                  // breaks the sender and receiver screens (on iOS emulater tests)
                  // (they show just a black screen if this button exists)
                  /*
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: FloatingActionButton.extended(
                      backgroundColor: Colors.deepPurple[900],
                      foregroundColor: Colors.white,
                      icon: Icon(Icons.info),
                      label: Text('Credits'),
                      onPressed: () { print('Clicked'); },
                    ),
                  ),
                  */

                ],
              ),
            ),
            
            
        ],) 
      )
    );

  }
}

