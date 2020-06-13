

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

void goToScreen(context, Widget screen) {
  Navigator.push(
    context,
    PageTransition(
      type: PageTransitionType.fade, 
      child: screen
    )
  );
}