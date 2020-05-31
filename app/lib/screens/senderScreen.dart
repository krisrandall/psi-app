import 'package:app/components/slideRoute.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:app/components/screenBackground.dart';

class SenderScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text('Sender Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_left),
            onPressed: () {
              Navigator.of(context).push(
                SlideRoute(
                  exitPage: SenderScreen(), 
                  enterPage: HomePage(),
                  ),
              );
            }
          ),
        ]
      ),
      body: LeftBgWrapper( Text('place holder'))
      );
    }
}