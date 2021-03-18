/*import 'package:flutter/material.dart';
import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/components/utils.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:app/screens/joinScreen.dart';
import 'package:app/components/facebook_logic.dart';





class IntroScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
      return TableBgWrapper(Scaffold(
        appBar: AppBar(
          title: Text('Opened Via Link'),
        ),
        body: FutureBuilder(
            future: getSharedPsiTest(testId),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              switch (snapshot){
              case  (!snapshot.hasData)  : return Text('waiting');
              case:  (snapshot.hasData && snapshot.data.exists) 
                if (!snapshot.data.exists) {
                  return TableBgWrapper(LinkDoesntExistWidget());
                } else {
                  return TableBgWrapper(_OpenedViaLinkWidget(snapshot.data));
                }
              } else if (snapshot.hasError) {
                print('snapshot has error');
                return TableBgWrapper(LinkDoesntExistWidget());
              }

  }*/
