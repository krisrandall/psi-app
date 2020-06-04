
import 'package:app/components/button.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/screens/creditsScreen.dart';
import 'package:app/screens/learnMoreScreen.dart';
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

    void _goToScreen(Widget screen) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.fade, 
          child: screen
        )
      );
    }

    // load other BG images to avoid a flash of white BG when navigating to other pages for the first time
    precacheImage(AssetImage('assets/left.jpg'), context);
    precacheImage(AssetImage('assets/right.jpg'), context);
    precacheImage(AssetImage('assets/gypsie.png'), context);
    

    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: TableBgWrapper( 
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            SizedBox(height: 10),

            TitleText('The Psi Telepathy Test App lets you discover your telepathic abilities with a friend.'),

            SizedBox(height: 100),
            
            Button(
              "Be the Sender",
              (){ _goToScreen(SenderScreen()); },
            ),

            SizedBox(height: 10),

            Button(
              'Be the Receiver',
              (){ _goToScreen(ReceiverScreen()); },
            ),
            
            SizedBox(height: 150),

            
            Padding(
              padding: EdgeInsets.all(10.0),
              child : Stack(
                children: <Widget>[

                  Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.deepPurple[900],
                      icon: Icon(Icons.help),
                      label: Text('Learn More'),
                      onPressed: () { 
                        _goToScreen(LearnMoreScreen());
                      },
                    ),
                  ),


                  Align(
                    alignment: Alignment.bottomLeft,
                    child: FloatingActionButton.extended(
                      heroTag: null,
                      backgroundColor: Colors.deepPurple[900],
                      foregroundColor: Colors.white,
                      icon: Icon(Icons.info),
                      label: Text('Credits'),
                      onPressed: () { 
                        _goToScreen(CreditsScreen());
                      },
                    ),
                  ),


                ],
              ),
            ),
            
            
        ],) 
      )
    );

  }
}

