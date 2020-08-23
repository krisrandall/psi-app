import 'dart:wasm';

import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/components/utils.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'dart:async';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /* to prevent device rotation - but not proven yet if works, or needed... 
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    */

    return BlocProvider(
      create: (context) => PsiTestSaveBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Color.fromRGBO(47, 11, 56, 1),
        ),
        home: LandingPage(),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  String signinErrorMessage = "";

  /*void initDynamicLinks() async {

    print('in initDynamicLinks()');

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      goToScreen(context, OpenedViaLinkWidget(deepLink));
    }

    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        final Uri deepLink = dynamicLink?.link;


  Future<Null> initUniLinks() async {
    try {
      Uri deepLink = await getInitialUri();
      print("finished getting Uri: $deepLink");
      //goToScreen(context, OpenedViaLinkWidget(deepLink, 'getInitialUri'));
      //return deepLink;

      /* goToScreen(
            context,
            OpenedViaLinkWidget(
                deepLink, 'Future Uri Object provided by getInitialUri()'));

      StreamSubscription _sub;
      _sub = getUriLinksStream().listen((Uri deepLink) {
        //this never gets called
        print("listener for getUriLinksStream() returned a link: $deepLink");
        return deepLink;
        /*
        goToScreen(
            context,
            OpenedViaLinkWidget(deepLink,
                'listener for getUriLinksStream() returned the link'));*/
      }, onError: (err) {
        print("error with Stream getting deepLink $err");
      });
      void dispose(filename) {
        _sub.cancel();
      }*/

      //this never gets called
      if (deepLink != null) {
        goToScreen(context, OpenedViaLinkWidget(deepLink, 'working'));
      }
    } on FormatException {
      print("couldn't parse the Uri $FormatException");
    } on PlatformException {
      print("couldn't retrieve initital link $PlatformException");
    }
  }

// ...

  /* },
      onError: (OnLinkErrorException e) async {
        print('onLinkError');
        print(e.message);
      }
    )
  }}*/*/
  String deepLink;
  @override
  Widget build(BuildContext context) {
    Future<void> _signInAnonymously() async {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          print('calling getInitialLink');
          deepLink = await getInitialLink();
          print('link from main.dart is $deepLink');
        } catch (e) {
          print('getInitialLink ERROR');
          print(e);
        }

        //initUniLinks();
        if (deepLink != null) {
          print(deepLink);
          goToScreen(context, OpenedViaLinkWidget(deepLink, 'main.dart'));
        }
      });
      try {
        await precacheImage(AssetImage('assets/table.jpg'), context);
        await precacheImage(AssetImage('assets/splash.png'), context);
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        setState(() {
          signinErrorMessage = "Unable to Sign in\n" +
              "Check your internet connection\n" +
              e.toString();
        });
      }
    }

    _signInAnonymously(); // auto anon signin

    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: TableBgWrapper(StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          print(snapshot.connectionState);
          if (snapshot.connectionState == ConnectionState.active) {
            FirebaseUser user = snapshot.data;
            if (user == null) {
              return Column(children: <Widget>[
                CircularProgressIndicator(),
                Text('Logging in ..'),
              ]);
            } else if (signinErrorMessage != '') {
              return TitleText(signinErrorMessage);
            } else {
              globalCurrentUser = user;
              return AfterAuthWidget();
            }
          } else {
            return Column(
              children: <Widget>[
                CircularProgressIndicator(),
                Text('Connecting ..'),
              ],
            );
          }
        },
      )),
    );
  }
}

class AfterAuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestoreDatabaseStream.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (psiTestNotAvailable(snapshot))
            return psiTestNotAvailableWidget(snapshot);
          var currentTest = createTestFromFirestore(snapshot.data.documents);
          return HomePage(currentTest);
        });
  }
}

class OpenedViaLinkWidget extends StatelessWidget {
  final String deepLink;
  final String deepLinkOrigin;
  OpenedViaLinkWidget(this.deepLink, this.deepLinkOrigin);

  @override
  Widget build(BuildContext context) {
    /*return StreamBuilder<QuerySnapshot>(
        stream: firestoreDatabaseStream
            .snapshots(), // TO CHANNGE TO QUERY BASED ON INPUT PARAM
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (psiTestNotAvailable(snapshot))
            return psiTestNotAvailableWidget(snapshot);
          var currentTest = createTestFromFirestore(snapshot.data.documents);*/
    return CopyText(
        'Screen for joining a test invitation ... ${deepLink.toString()} ...link from $deepLinkOrigin ');
    //  });
  }
}
