

import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final text;
  TitleText(this.text);

  @override 
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.all(20.0),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 50.0,
        color: Colors.yellow.withOpacity(1.0)
        ),
    ),
    );
  }
}

class CopyText extends StatelessWidget {
  final text;
  CopyText(this.text);

  @override 
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 30.0, right: 20),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 20.0,
        color: Colors.yellow.withOpacity(1.0)
        ),
    ),
  );
  
  }
}

