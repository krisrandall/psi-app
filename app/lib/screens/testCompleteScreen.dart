import 'package:app/components/button.dart';
import 'package:app/components/utils.dart';
import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/models/psiTest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/screens/homeScreen.dart';

class TestCompleteScreen extends StatelessWidget {
  final PsiTest currentTest;
  TestCompleteScreen(this.currentTest);

  @override
  Widget build(BuildContext context) {
    bool completed = false;
    if (completed == false) {
      BlocProvider.of<PsiTestSaveBloc>(context)
          .add(CompletePsiTest(test: currentTest));
      completed = true;
    }

    var numCorrect = 0;
    currentTest.questions.forEach((q) {
      if (q.answeredCorrectly()) numCorrect++;
    });

    /*var correctAnswerImages = new List<Widget>();
    var providedAnswerImages = new List<Widget>();*/
    var images = new List<Widget>();

    for (int i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
      int correctAnswer = currentTest.questions[i].correctAnswer;
      String correctAnswerUrl = currentTest.questions[i].options[correctAnswer];
      //correctAnswerImages.add(Image.network(correctAnswerimageUrl));

      int providedAnswer = currentTest.questions[i].providedAnswer;
      String providedAnswerUrl =
          currentTest.questions[i].options[providedAnswer];
      //providedAnswerImages.add(Image.network(imageUrl));

      images.add(FittedBox(
          fit: BoxFit.contain,
          child: Row(
            children: [
              Center(
                  child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                    Container(
                        //margin: EdgeInsets.only(b20.0),
                        child: FadeInImage.assetNetwork(
                            placeholder: 'assets/purple_box.png',
                            image: providedAnswerUrl)),
                    Container(
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: Text('Sender'))
                  ])),
              SizedBox(
                width: 10,
              ),
              Center(
                child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      Container(
                          //margin: EdgeInsets.all(20.0),
                          child: FadeInImage.assetNetwork(
                              placeholder: 'assets/purple_box.png',
                              image: correctAnswerUrl)),
                      Container(color: Colors.white, child: Text('Receiver'))
                    ]),
              )
            ],
          )));
      images.add(Text('Question ${i + 1}'));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('𝚿 Test Complete'),
        ),
        backgroundColor: Colors.white,
        body: ListView(children: [
          /*Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Container(child: Text('Sender sent')),
                Container(child: (Text('Receiver received')))
              ]),*/
          ...images,
          CopyText(
              'Test complete, you got $numCorrect right out of ${currentTest.numQuestionsAnswered}'),
          BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
              builder: (context, state) {
            if (state is PsiTestCompleteInProgress)
              return Container(child: CircularProgressIndicator());
            else
              return Button('OK', () {
                goToScreen(context, TableBgWrapper(HomeScreen()));
              });
          })
        ]));
  }
}
