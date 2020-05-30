
import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  final buttonText;
  final onPressed;

  Button(this.buttonText, this.onPressed);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            side: BorderSide(color: Colors.yellow)
          ),
          onPressed: onPressed,
          textColor: Colors.white,
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
              ),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 20)
            ),
          ),
        ),

    );
  }

}



class ButtonLeft extends StatelessWidget {

  final buttonText;
  final onPressed;

  ButtonLeft(this.buttonText, this.onPressed);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
            side: BorderSide(color: Colors.yellow)
          ),
          onPressed: onPressed,
          textColor: Colors.white,
          padding: const EdgeInsets.all(0.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF42A5F5),
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                ],
              ),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              buttonText,
              style: TextStyle(fontSize: 20)
            ),
          ),
        ),

    );
  }

}
