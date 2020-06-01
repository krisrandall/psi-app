

import 'package:flutter/material.dart';

class BgWrapper extends StatelessWidget {

  final Widget child;
  final String bgFile;
  final Alignment align;

  BgWrapper(this.child, this.bgFile, this.align);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(.75), BlendMode.dstATop),
            image: AssetImage(bgFile),
            fit: BoxFit.cover,
            alignment: align,
          ),
        ),
        child: Center(child : child, ),
      ),
    );
  }
}

class GypsyBgWrapper extends BgWrapper {
  final Widget child;
  GypsyBgWrapper(this.child) : super(child, "assets/table.jpg", Alignment.center);
}

class LeftBgWrapper extends BgWrapper {
  final Widget child;
  LeftBgWrapper(this.child) : super(child, "assets/left.jpg", Alignment.centerRight);
}

class RightBgWrapper extends BgWrapper {
  final Widget child;
  RightBgWrapper(this.child) : super(child, "assets/right.jpg", Alignment.centerLeft);
}

