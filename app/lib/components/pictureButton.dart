import 'package:flutter/material.dart';

class PictureButton extends StatelessWidget {
  final String pictureUrl;
  final onPressed;

  PictureButton(this.pictureUrl, this.onPressed);
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
      onTap: onPressed,
      child: Container(
          child: Image.network(
        pictureUrl,
        fit: BoxFit.cover,
      )),
    ));
  }
}
