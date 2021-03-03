import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final buttonText;
  final onPressed;

  Button(this.buttonText, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.deepPurple[900],
      textColor: Colors.white,
      disabledColor: Colors.grey,
      disabledTextColor: Colors.black,
      padding: EdgeInsets.all(18.0),
      splashColor: Colors.blueAccent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32.0),
          side: BorderSide(color: Colors.white, width: 4.0)),
      onPressed: onPressed,
      child: Text(
        buttonText,
        style: TextStyle(fontSize: 20.0),
      ),
    );
  }
}

class PsiIconButton extends StatelessWidget {
  final icon;
  final onPressed;
  PsiIconButton(this.icon, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        height: 62,
        color: Colors.purple,
        child: icon,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0),
            side: BorderSide(color: Colors.white, width: 4.0)),
        onPressed: onPressed);
  }
}
