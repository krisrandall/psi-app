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
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/components/facebook_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('main build started');
    /* to prevent device rotation - but not proven yet if works, or needed... 
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    */

    return BlocProvider(
      create: (context) => PsiTestSaveBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
  AccessToken _accessToken;
  bool _checking = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void goToHomeScreenAsynchronously(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  Future<void> precacheImages() async {
    await precacheImage(AssetImage('assets/table.jpg'), context);
    await precacheImage(AssetImage('assets/splash.png'), context);
  }

// TO DO : use these methods below to store facebook access token instead

  Future<String> _getFacebookPreference() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('facebookPreference') ?? 'use';
  }

  Future _saveFacebookPreference(preference) async {
    print('setting facebook preference to $preference');
    final SharedPreferences prefs = await _prefs;
    setState(() {
      prefs.setString('facebookPreference', preference);
    });
  }

  Future<void> _signInAnonymously() async {
    //set preference
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      setState(() {
        signinErrorMessage = "Unable to Sign in\n" +
            "Check your internet connection\n" +
            e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('landing page');

    precacheImages();
    //_signInAnonymously(); // auto anon signin
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        deepLink = await getInitialLink();
        print('link from main.dart is $deepLink');
        if (deepLink != null) {
          print(deepLink);
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

    return TableBgWrapper(StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        print(snapshot.connectionState);
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  TitleText("Sign in with Facebook"),
                  Button("Sign in with Facebook", signInWithFacebook),
                  SecondaryButton("Not now", () {
                    _signInAnonymously();
                    //  _setFacebookPreference('dontUse');
                  }),
                  !_checking
                      ? CircularProgressIndicator()
                      : Text("access Token $_accessToken"),
                  Text('Logging in ..'),
                ]);
          } else if (signinErrorMessage != '') {
            return TitleText(signinErrorMessage);
          } else if (user != null && signinErrorMessage == '') {
            globalCurrentUser = user;

            return HomeScreen();
            /*
                Future.microtask(() {
                  goToHomeScreenAsynchronously(context);
                });
                return Container();*/
          } else
            return Container();
        } else {
          return Column(
            children: <Widget>[
              CircularProgressIndicator(),
              Text('Connecting ..'),
            ],
          );
        }
      },
    ));
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
