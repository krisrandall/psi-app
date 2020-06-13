import 'package:app/bloc/bloc_helpers/bloc_provider.dart';
import 'package:app/bloc/bloc_widgets/bloc_state_builder.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_bloc.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_state.dart';
import 'package:app/models/psiTest.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget{
  final PtsiBloc bloc;
  TestScreen( this.bloc );

  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Test Underway'),
      ),
      body: BlocEventStateBuilder<PtsiState>(
        bloc: bloc,
        builder: (BuildContext context, PtsiState state) {

          if (state.existingTest.myRole == PsiTestRole.SENDER) {
            return TestQuestionSender(
              state.existingTest.currentQuestion.options[state.existingTest.currentQuestion.correctAnswer],
              state.existingTest.numQuestionsAnswered+1,
              state.existingTest.totalNumQuestions
            );
          } else {
            return TestQuestionReceiver(
              state.existingTest.currentQuestion.options,
              state.existingTest.numQuestionsAnswered+1,
              state.existingTest.totalNumQuestions
            );
          }
          
        }
      )
    );
  }   
}

class TestQuestionSender extends StatelessWidget{
  final String imageUrl;
  final int currentQuestionNumber;
  final int totalNumberQuestions;
  TestQuestionSender( this.imageUrl, this.currentQuestionNumber, this.totalNumberQuestions  );
  @override
  Widget build(BuildContext context){
    return Column( 
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [ 
        Image.network(imageUrl),
        Padding(
          padding: EdgeInsets.all(30.0),
          child: Text('Concentrate on this image\n\n\n'+
                'Question $currentQuestionNumber of $totalNumberQuestions'),
        ),
      ],
    );
  }
}

class TestQuestionReceiver extends StatelessWidget{
  final List<String> imageUrls;
  final int currentQuestionNumber;
  final int totalNumberQuestions;
  TestQuestionReceiver( this.imageUrls, this.currentQuestionNumber, this.totalNumberQuestions );
  @override
  Widget build(BuildContext context){
    return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          padding: const EdgeInsets.all(4.0),
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: [
            Image.network(imageUrls[0], fit: BoxFit.cover),
            Image.network(imageUrls[1], fit: BoxFit.cover),
            Image.network(imageUrls[2], fit: BoxFit.cover),
            Image.network(imageUrls[3], fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Text('\n\nClick to choose'),
            ),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Text('\n\nQuestion $currentQuestionNumber of $totalNumberQuestions'),
            ),
          ]
          /*
          children: imageUrls.map((String url) {
            return GridTile(
                child: Image.network(url, fit: BoxFit.cover));
          }).toList()*/
        );
  }
}
