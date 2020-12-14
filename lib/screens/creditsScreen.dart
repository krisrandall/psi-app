import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsScreen extends StatelessWidget{

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: CreditsBgWrapper( 
        SingleChildScrollView( child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            SizedBox(height: 5),

            TitleText('Credits'),

            CopyText('This app was originally inspired by the Google TechTalk “Science and the Taboo of psi”.'),

            FlatButton.icon(
              onPressed: () { _launchURL('http://www.youtube.com/watch?v=qw_O9Qiwqew'); },
              icon: Icon(Icons.play_arrow),
              label: Text('Watch “Science and the Taboo of psi”'),
              color: Colors.deepPurple[900],
              textColor: Colors.white,
            ),

            SizedBox(height: 30),

            CopyText('The test images  are courtesy of Lorem Picsum.'),

            FlatButton.icon(
              onPressed: () { _launchURL('https://picsum.photos/'); },
              icon: Icon(Icons.image),
              label: Text('Visit picsum.photos'),
              color: Colors.white,
              textColor: Colors.deepPurple[900],
            ),

            SizedBox(height: 30),

            CopyText('The wonderful artwork, and the basis for app icon, are designed by upklyak (from Freepik).'),

            FlatButton.icon(
              onPressed: () { _launchURL('http://www.freepik.com'); },
              icon: Icon(Icons.image),
              label: Text('Visit freepik.com'),
              color: Colors.white,
              textColor: Colors.deepPurple[900],
            ),

            SizedBox(height: 30),

            CopyText('This app was created by Nick Randall and Kris Randall.  Please feel free to reach out to us with any questions or comments.'),

            FlatButton.icon(
              onPressed: () { _launchURL('mailto:psiapp@cocreations.com.au'); },
              icon: Icon(Icons.email),
              label: Text('psiapp@cocreations.com.au'),
              color: Colors.deepPurple[900],
              textColor: Colors.white,
            ),

            SizedBox(height: 60),

            CopyText('This app is a CoCreations creation.'),

            Container(
              child: FlatButton(
                onPressed: () { _launchURL('https://cocreations.com.au'); },
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 3.0),
                child: Column(children: <Widget>[
                  Image.asset('assets/cocreations.png'),
                  SizedBox(height: 2.0),
                  Text('cocreations.com.au'),
                ],),
                color: Colors.white,
                textColor: Colors.deepPurple[900],
              ),
              padding: EdgeInsets.only(left: 20.0, right: 20.0),
            ),

            SizedBox(height: 60),

        ])
        )
      )
    );
  }
        
}