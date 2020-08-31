import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app/components/utils.dart';
import 'package:app/main.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//var context;
String deepLink;
StreamSubscription _sub;
String getUniLink() {
  Future<Null> initUniLinks() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      deepLink = await getInitialLink();
      print('link from main.dart is $deepLink');
      if (deepLink != null) {
        print(deepLink);
      }

      _sub = getLinksStream().listen((String deepLink) {
        print('stream $deepLink');
        if (deepLink != null) {
          print('stream is $deepLink');
        }
      });
    });
  }

  initUniLinks();
  return deepLink;
}
