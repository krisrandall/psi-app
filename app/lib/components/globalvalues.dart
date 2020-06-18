// GlobalValues.dart
import 'package:flutter/material.dart';

class GlobalValues extends InheritedWidget {
  // StreamController controller;
  // Stream stream;
  // Provider provider = new Provider(); * optional
  // TestBloc testbloc = TestBloc();
  // int counter = 0;
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  GlobalValues({Key key, Widget child}) {
    super(key: key, child: child);
  }

  static GlobalValues of(BuildContext context){
    return context.dependOnInheritedWidgetOfExactType() 
       as GlobalValues;
  }
}