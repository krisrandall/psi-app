import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/components/utils.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:app/screens/joinScreen.dart';
import 'package:app/components/facebook_logic.dart';
import 'package:app/screens/inviteWrapper.dart';

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
  AudioCache audioCache = AudioCache();

  void goToHomeScreenAsynchronously(BuildContext context) async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => InviteWrapper('home')));
  }

  Future<void> precacheImages() async {
    await precacheImage(AssetImage('assets/table.jpg'), context);
    await precacheImage(AssetImage('assets/splash.png'), context);
  }

  Future<void> _signInAnonymously() async {
    try {
      await saveUserIsAnonymous(true);
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TitleText("Sign in with Facebook"),
                  SizedBox(height: 40),
                  Button("Sign in with Facebook", signInWithFacebook),
                  SecondaryButton("Not now", () {
                    _signInAnonymously().catchError((error) {
                      print('error while signing in anonymously$error');
                    });
                  })
                ]);
          } else if (signinErrorMessage != '') {
            return TitleText(signinErrorMessage);
          } else if (user != null && signinErrorMessage == '') {
            globalCurrentUser = user;
            // audioCache.loop('psi-bg-music.mp3');

            return InviteWrapper('homeScreen');
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
