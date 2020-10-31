import 'package:flutter/material.dart';

class PictureButton extends StatefulWidget {
  final String pictureUrl;
  final onPressed;
  final double opacity;

  PictureButton(this.pictureUrl, this.onPressed, {this.opacity});

  @override
  _PictureButtonState createState() => _PictureButtonState();
}

class _PictureButtonState extends State<PictureButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              child: AnimatedOpacity(
                opacity: widget.opacity,
                duration: Duration(milliseconds: 1000),
                child: FadeInImage.assetNetwork(
                    placeholder: 'assets/white_box.png',
                    image: widget.pictureUrl),
              ),
            )));
  }
}
