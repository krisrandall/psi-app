

import 'package:flutter/material.dart';

class BgWrapper extends StatelessWidget {

  final Widget child;
  final String bgFile;

  BgWrapper(this.child, this.bgFile);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.75), BlendMode.dstATop),
            image: AssetImage(bgFile),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(child : child, ),
      ),
    );
  }
}

class GypsyBgWrapper extends BgWrapper {
  final Widget child;
  GypsyBgWrapper(this.child) : super(child, "assets/table.jpg");
}

