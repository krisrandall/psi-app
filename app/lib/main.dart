
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
      create: (context) =>
          PsiTestSaveBloc(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Color.fromRGBO(47, 11, 56, 1),
        ),
        home:  LandingPage(),
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

  void initDynamicLinks() async {

    print('in initDynamicLinks()');

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri deepLink = data?.link;

    if (deepLink != null) {
      goToScreen(context, OpenedViaLinkWidget(deepLink));
    }

    FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        final Uri deepLink = dynamicLink?.link;

        if (deepLink != null) {
          goToScreen(context, OpenedViaLinkWidget(deepLink));
        }
      },
      onError: (OnLinkErrorException e) async {
        print('onLinkError');
        print(e.message);
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    Future<void> _signInAnonymously() async {
      try {
        await precacheImage(AssetImage('assets/table.jpg'), context);
        await precacheImage(AssetImage('assets/splash.png'), context);
        await FirebaseAuth.instance.signInAnonymously();
        initDynamicLinks(); 
      } catch (e) {
        setState(() { 
          signinErrorMessage = "Unable to Sign in\n"+
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
      body: TableBgWrapper(
        StreamBuilder<FirebaseUser>(
          stream: FirebaseAuth.instance.onAuthStateChanged,
          builder: (context, snapshot) {
            print(snapshot.connectionState);
            if (snapshot.connectionState == ConnectionState.active) {
              
              FirebaseUser user = snapshot.data;
              if (user == null) {
                return Column(children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Logging in ..'),
                    ]
                  );
              } else if (signinErrorMessage!='') {
                return TitleText( signinErrorMessage );
              } else {
                globalCurrentUser = user;
                return AfterAuthWidget();
              }
              
            } else {
              return Column(children: <Widget>[
                      CircularProgressIndicator(),
                      Text('Connecting ..'),
                    ],
              );
            }
          },
        )
      ),
    );
  }
}

class AfterAuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreDatabaseStream.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (psiTestNotAvailable(snapshot)) return psiTestNotAvailableWidget(snapshot);
        var currentTest = createTestFromFirestore(snapshot.data.documents);
        return HomePage(currentTest);
      }
    );
  }
}

class OpenedViaLinkWidget extends StatelessWidget {

  final Uri deepLink;
  OpenedViaLinkWidget(this.deepLink);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreDatabaseStream.snapshots(), // TO CHANNGE TO QUERY BASED ON INPUT PARAM
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (psiTestNotAvailable(snapshot)) return psiTestNotAvailableWidget(snapshot);
        var currentTest = createTestFromFirestore(snapshot.data.documents);
        return CopyText('Screen for joining a test invitation ... ${deepLink.toString()} ... ');
      }
    );
  }
}
