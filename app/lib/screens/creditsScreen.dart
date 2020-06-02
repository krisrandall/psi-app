import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:flutter/material.dart';

class LearnMoreScreen extends StatelessWidget{

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
      body: GypsyBgWrapper( 
        SingleChildScrollView( child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[

            SizedBox(height: 5),

            TitleText('Credits'),

            CopyText('This app was originally inspired by the Google TechTalk “Science and the Taboo of psi”'),

            SizedBox(height: 60),

        ])
        )
      )
    );
  }
        
}