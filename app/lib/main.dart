import 'package:app/bloc/bloc_widgets/bloc_state_builder.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_event.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_state.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'bloc/bloc_helpers/bloc_provider.dart';
import 'bloc/psi_test_server_interactions/ptsi_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
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

    return GypsyBgWrapper(
      StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
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
              return BlocProvider<PtsiBloc>(
                    bloc: PtsiBloc(),
                    child:AfterAuthWidget(),
              );
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
    );
  }
}

class AfterAuthWidget extends StatefulWidget {
  @override
  _AfterAuthWidgetState createState() => _AfterAuthWidgetState();
}

class _AfterAuthWidgetState extends State<AfterAuthWidget> {

  @override
  Widget build(BuildContext context) {

    PtsiBloc bloc = BlocProvider.of<PtsiBloc>(context);

    bloc.emitEvent(PtsiEventFetchExistingTest());

    return BlocEventStateBuilder<PtsiState>(
      bloc: bloc,
      builder: (BuildContext context, PtsiState state) {

        if (state.isFetchingForExistingTest) {
          return Text("Fetching existing test data ..");
        }

        // Display a text if the authentication failed
        if (state.exceptionFetchingExistingTest!=null){
          return CopyText('Failure fetching existing test! ${state.exceptionFetchingExistingTest.toString()} ');
        }

        return HomePage();

      },
    );

  }

} 