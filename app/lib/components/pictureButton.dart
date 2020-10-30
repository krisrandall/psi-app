import 'package:flutter/material.dart';

class PictureButton extends StatefulWidget {
  final String pictureUrl;
  final onPressed;
  final double fadeOut;

  PictureButton(this.pictureUrl, this.onPressed, {this.fadeOut});

  @override
  _PictureButtonState createState() => _PictureButtonState();
}

class _PictureButtonState extends State<PictureButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
            onTap: widget.onPressed,
            child: Container(
              child: AnimatedOpacity(
                // If the widget is visible, animate to 0.0 (invisible).
                // If the widget is hidden, animate to 1.0 (fully visible).
                opacity: widget.fadeOut,
                duration: Duration(milliseconds: 1000),
                // The green box must be a child of the AnimatedOpacity widget.

                child: FadeInImage.assetNetwork(
                    placeholder: 'assets/white_box.png',
                    image: widget
                        .pictureUrl), /*Image.network(
        pictureUrl,
        fit: BoxFit.cover,
      )*/
              ),
            )));
  }
}
