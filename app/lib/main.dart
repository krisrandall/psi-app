
import 'dart:math';

import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/models/psiTestQuestion.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

var currentUser;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    /* to prevent device rotation - but not proven yet if works, or needed... 
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    */
    
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Color.fromRGBO(47, 11, 56, 1),
      ),
      home: LandingPage(),
    );
  }
}



class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

  String signinErrorMessage = "";

  @override
  Widget build(BuildContext context) {

    Future<void> _signInAnonymously() async {
      try {
        await precacheImage(AssetImage('assets/table.jpg'), context);
        await precacheImage(AssetImage('assets/splash.png'), context);
        await FirebaseAuth.instance.signInAnonymously();
      } catch (e) {
        setState(() { 
          signinErrorMessage = "Unable to Sign in\n"+
            "Check your internet connection, and your password\n" +
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

            print(' building main - ${snapshot.toString()}');
            
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
                currentUser = user;
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
      stream: Firestore
              .instance
              .collection('test')
              .where('parties', arrayContains: currentUser.uid)
              .where("status", isEqualTo: "underway")
              .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {

        if (snapshot.hasError) {
          return new Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState==ConnectionState.waiting) {
          return CopyText("Fetching existing test data ..");
        }

        if (snapshot.data.documents.length>1) {
          // TODO -- decide how to handle this bettter
          return CopyText("More than one active test");
        }

        if (snapshot.data.documents.length==0) {
          return HomePage(null);
        }

        var currentTest = createTestFromFirestore(snapshot.data.documents[0]);
        return HomePage(currentTest);
      }

    );
  }
}

PsiTest createTestFromFirestore(DocumentSnapshot data) {

  var iAm; 
  
  if (data['sender'] == currentUser) iAm = PsiTestRole.SENDER;
  else iAm = PsiTestRole.RECEIVER;

  // create the questions
  List<PsiTestQuestion> questions = [];
  data['questions'].forEach( (q) {
    print(questions);
    questions.add(PsiTestQuestion(
      q['options'][0],
      q['options'][1],
      q['options'][2],
      q['options'][3],
      correctAnswer : q['correctAnswer'],
      providedAnswer : q['providedAnswer'],
    ));
  });

  PsiTest test = PsiTest(
    myRole : iAm,
    totalNumQuestions : DEFAULT_NUM_QUESTIONS,
    testStatus : ( 
          (data['sender']?.isEmpty ?? true) ? PsiTestStatus.AWAITING_SENDER :
          (data['receiver']?.isEmpty ?? true) ? PsiTestStatus.AWAITING_RECEIVER :
          PsiTestStatus.UNDERWAY
    ),
    numQuestionsAnswered : max(data['questions'].length-1, 0),
    answeredQuestions : questions,
    currentQuestion : questions[questions.length-1],
  );

  return test;

}
