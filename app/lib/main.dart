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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

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
  Uri link;
  Uri deepLink;
  Future<Uri> initUniLinks() async {
    deepLink = await getInitialUri();
    print('link from main.dart is $deepLink');
    return deepLink;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _signInAnonymously() async {
      StreamSubscription _sub;

      // Attach a listener to the stream
      // WidgetsFlutterBinding.ensureInitialized();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          deepLink = await getInitialUri();
          print('link from main.dart is $deepLink');
          if (deepLink != null) {
            print(deepLink);
            goToScreen(context, OpenedViaLinkWidget(deepLink));
          }
          _sub = getUriLinksStream().listen((Uri link) {
            print('stream $link');
            if (link != null) {
              goToScreen(context, OpenedViaLinkWidget(link));
            }

            // Use the uri and warn the user, if it is not correct
          }, onError: (err) {});
        } catch (e) {
          print('getInitialLink ERROR');
          print(e);
        }
      });
      //TODO: error handling
      try {
        await precacheImage(AssetImage('assets/table.jpg'), context);
        await precacheImage(AssetImage('assets/splash.png'), context);
        await FirebaseAuth.instance.signInAnonymously();
        //initDynamicLinks();
      } catch (e) {
        setState(() {
          signinErrorMessage = "Unable to Sign in\n" +
              "Check your internet connection\n" +
              e.toString();
        });
      }
    }

    _signInAnonymously(); // auto anon signin
    initUniLinks();
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
  final Uri deepLink;
  OpenedViaLinkWidget(this.deepLink);

  @override
  Widget build(BuildContext context) {
    /* return StreamBuilder<QuerySnapshot>(
      stream: firestoreDatabaseStream.snapshots(), // TO CHANNGE TO QUERY BASED ON INPUT PARAM
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (psiTestNotAvailable(snapshot)) return psiTestNotAvailableWidget(snapshot);
        var currentTest = createTestFromFirestore(snapshot.data.documents);*/
    return CopyText(
        'Screen for joining a test invitation ... ${deepLink.toString()} ... ');
  }
  // );
}
//}
