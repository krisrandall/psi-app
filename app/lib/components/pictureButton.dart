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
        child: FadeInImage.assetNetwork(
            placeholder: 'assets/purple_box.png',
            image:
                pictureUrl), /*Image.network(
        pictureUrl,
        fit: BoxFit.cover,
      )*/
      ),
    ));
  }
}
