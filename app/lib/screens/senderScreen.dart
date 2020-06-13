import 'package:app/bloc/bloc_widgets/bloc_state_builder.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_bloc.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_state.dart';
import 'package:app/components/button.dart';
import 'package:app/components/goToScreen.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/testScreen.dart';
import 'package:flutter/material.dart';

class SenderScreen extends StatelessWidget{

  final PtsiBloc bloc;
  SenderScreen( this.bloc );

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Psi Telepathy Test'),
      ),
      body: LeftBgWrapper( 
        BlocEventStateBuilder<PtsiState>(
          bloc: bloc,
          builder: (BuildContext context, PtsiState state) {

            Widget actionButton;
            if (state.existingTest == null) {
              actionButton = Button(
                                  'Begin Test (Invite Friend)',
                                  () { print('does nothinng yet ..'); },
                                );
            } else if (state.existingTest.myRole == PsiTestRole.SENDER) {
              actionButton = Button(
                                  'Continue Test',
                                  (){ goToScreen(context, TestScreen(bloc)); },
                                );
            } else {
              actionButton = CopyText("There is a test underway and you are the Receiver.\n\nGo back and complete the test.");
            }

            return SingleChildScrollView( child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[

                SizedBox(height: 5),

                TitleText('Sender'),

                CopyText('''As the Sender, your job is to send a mental image of what you see to the Receiver.  You will be presented with a series of images, one at a time.  Focus on each one and imagine describing that image to the Receiver.

    The Receiver should not be able to physically see or hear you, they need to receive the mental image you project to them telepathically and pick which image you are Sending.

    There will be $DEFAULT_NUM_QUESTIONS images in the test.
    '''),

                SizedBox(height: 10),


                actionButton,


                SizedBox(height: 130),

            ])
            );
          }
        ),
      )
    );
  }

}
