import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/components/utils.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:app/screens/joinScreen.dart';

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
  StreamSubscription _sub;
  String deepLink;

  Future<Null> initUniLinks() async {
    //TODO: error handling
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _signInAnonymously() async {
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        deepLink = await getInitialLink();
        print('link from main.dart is $deepLink');
        if (deepLink != null) {
          print(deepLink);
          // _signInAnonymously();
          goToScreen(context, OpenedViaLinkWidget(deepLink));
        }
        _sub = getLinksStream().listen((String deepLink) {
          print('stream $deepLink');
          if (deepLink != null) {
            goToScreen(context, OpenedViaLinkWidget(deepLink));
          }
          // Use the Link and warn the user, if it is not correct
        }, onError: (err) {});
      } catch (e) {
        print('getInitialLink ERROR');
        print(e);
      }
    });

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

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
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
