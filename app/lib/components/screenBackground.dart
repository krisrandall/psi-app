

import 'package:flutter/material.dart';

class BgWrapper extends StatelessWidget {

  final Widget child;
  final String bgFile;
  final Alignment align;
  final double opacity;

  BgWrapper(this.child, this.bgFile, this.align, {this.opacity = 0.75} );

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(opacity), BlendMode.dstATop),
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

class TableBgWrapper extends BgWrapper {
  final Widget child;
  TableBgWrapper(this.child) : super(child, "assets/table.jpg", Alignment.center);
}

class CreditsBgWrapper extends BgWrapper {
  final Widget child;
  CreditsBgWrapper(this.child) : super(child, "assets/left.jpg", Alignment.centerLeft);
}

class GypsyBgWrapper extends BgWrapper {
  final Widget child;
  GypsyBgWrapper(this.child) : super(child, "assets/gypsie.png", Alignment.center);
}

class LeftBgWrapper extends BgWrapper {
  final Widget child;
  LeftBgWrapper(this.child) : super(child, "assets/left.jpg", Alignment.centerRight);
}

class RightBgWrapper extends BgWrapper {
  final Widget child;
  RightBgWrapper(this.child) : super(child, "assets/right.jpg", Alignment.centerLeft);
}

class SplashBgWrapper extends BgWrapper {
  final Widget child;
  SplashBgWrapper(this.child) : super(child, "assets/splash.png", Alignment.center, opacity : 1 );
}

