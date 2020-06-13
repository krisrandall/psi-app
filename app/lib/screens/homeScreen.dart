
import 'package:app/bloc/bloc_helpers/bloc_provider.dart';
import 'package:app/bloc/bloc_widgets/bloc_state_builder.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_bloc.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_state.dart';
import 'package:app/components/button.dart';
import 'package:app/components/goToScreen.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/secondaryButton.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/screens/creditsScreen.dart';
import 'package:app/screens/learnMoreScreen.dart';
import 'package:app/screens/receiverScreen.dart';
import 'package:app/screens/senderScreen.dart';
import 'package:app/screens/testScreen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';


class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    PtsiBloc bloc = BlocProvider.of<PtsiBloc>(context);


    // load other BG images to avoid a flash of white BG when navigating to other pages for the first time
    precacheImage(AssetImage('assets/left.jpg'), context);
    precacheImage(AssetImage('assets/right.jpg'), context);
    precacheImage(AssetImage('assets/gypsie.png'), context);
    

    return BlocEventStateBuilder<PtsiState>(
        bloc: bloc,
        builder: (BuildContext context, PtsiState state) {

          List<Widget> noActiveTestOptions = [

              SizedBox(height: 100),
  
              Button(
                "Be the Sender",
                (){ goToScreen(context, SenderScreen(bloc)); },
              ),

              SizedBox(height: 10),

              Button(
                'Be the Receiver',
                (){ goToScreen(context, ReceiverScreen(bloc)); },
              ),
          ];

          List<Widget> activeTestScreen = (state.existingTest==null) ? [] : [

              SizedBox(height: 5),

              CopyText("You have a test underway \nWith ${state.existingTest.totalNumQuestions - state.existingTest.numQuestionsAnswered} questions left to answer   "),

              SizedBox(height: 10),

              Button(
                'Continue the Test',
                (){ goToScreen(context, TestScreen(bloc)); }
              ),

              SecondaryButton( // This should be a subtle (Secondary)Button
                'End the Test',
                (){ print('do logic to cancel the test'); }
              ),

          ];


          List<Widget> screenOptions = 
            (state.existingTest==null) ? noActiveTestOptions : activeTestScreen;


          return TableBgWrapper( 
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                SizedBox(height: 10),

                TitleText('The Psi Telepathy Test App lets you discover your telepathic abilities with a friend.'),
                
                ...screenOptions,
                
                SizedBox(height: 150),

                
                FooterButtons(),
                
                
            ],) 
          );
        }
    );

  }
}


class FooterButtons extends StatelessWidget {
  const FooterButtons({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(10.0),
      child : Stack(
        children: <Widget>[

          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple[900],
              icon: Icon(Icons.help),
              label: Text('Learn More'),
              onPressed: () { 
                goToScreen(context, LearnMoreScreen());
              },
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: FloatingActionButton.extended(
              heroTag: null,
              backgroundColor: Colors.deepPurple[900],
              foregroundColor: Colors.white,
              icon: Icon(Icons.info),
              label: Text('Credits'),
              onPressed: () { 
                goToScreen(context, CreditsScreen());
              },
            ),
          ),

        ],
      ),
    );
  }
}
