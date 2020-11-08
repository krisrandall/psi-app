
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {

  final buttonText;
  final onPressed;

  SecondaryButton(this.buttonText, this.onPressed);
  
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      
      textColor: Colors.blueGrey[300],
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(14.0),
      splashColor: Colors.blueAccent,

      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

}
