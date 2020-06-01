

import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  final text;
  TitleText(this.text);

  @override 
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.only(top: 20.0, bottom: 10.0, left: 20.0, right: 20.0),
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

class CopyText extends StatelessWidget {
  final text;
  CopyText(this.text);

  @override 
  Widget build(BuildContext context) {
    return Padding(
    padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0, right: 10),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 16.0,
        color: Colors.white.withOpacity(1.0),
        shadows: <Shadow>[
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 2.0,
            color: Colors.black,
          ),
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 2.0,
            color: Colors.black,
            ),
        ],
      ),
    ),
  );
  
  }
}

