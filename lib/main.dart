import 'package:app/bloc/psitestsave_bloc.dart';
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

  void goToHomeScreenAsynchronously(BuildContext context) async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    print('landing page');
    Future<void> _signInAnonymously() async {
      print('signinanon page');
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

    return /*Scaffold(
        appBar: AppBar(
          title: Text('𝚿 Psi Telepathy Test'),
        ),
        body: */
        TableBgWrapper(StreamBuilder<FirebaseUser>(
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
