import 'package:app/components/button.dart';
import 'package:app/components/utils.dart';
import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/screens/inviteWrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/screens/homeScreen.dart';
import 'package:app/screens/testScreen.dart';

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
    int numberQuestionsAnswered = currentTest.numQuestionsAnswered;
    print(numberQuestionsAnswered);
    /*currentTest.questions.forEach((q) {
      if (q.answeredCorrectly()) numCorrect++;
    });*/

    var images = new List<Widget>();

    for (int i = 0; i < numberQuestionsAnswered; i++) {
      if (currentTest.questions[i].answeredCorrectly()) numCorrect++;

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
                          image: providedAnswerUrl,
                          imageErrorBuilder: (BuildContext context,
                                  Object exception, StackTrace stacktrace) =>
                              Image.network('https://picsum.photos/id/1/400')),
                      /*FutureBuilder(
                                  future: findValidUrl(
                                      providedAnswerUrl, exception),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData)
                                      return CircularProgressIndicator();
                                    else {
                                      print(snapshot.data);
                                      return Image.network(snapshot.data);
                                    }
                                  })),*/
                    ),
                    /*  Container(
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: Text('Sender'))
                  */
                  ])),
              SizedBox(
                width: 10,
              ),
              Center(
                child: Stack(alignment: AlignmentDirectional.center, children: [
                  Container(
                    //margin: EdgeInsets.all(20.0),
                    child: FadeInImage.assetNetwork(
                        placeholder: 'assets/purple_box.png',
                        image: correctAnswerUrl,
                        imageErrorBuilder: (BuildContext context,
                                Object exception, StackTrace stacktrace) =>
                            Image.network('https://picsum.photos/id/1/400')),
                    /*FutureBuilder(
                                future:
                                    findValidUrl(correctAnswerUrl, exception),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return CircularProgressIndicator();
                                  else {
                                    print(snapshot.data);
                                    return Image.network(snapshot.data);
                                  }
                                })),*/
                  ),
                  Container(
                      height: 50,
                      width: 50,
                      color: correctAnswer == providedAnswer
                          ? Colors.green
                          : Colors.red,
                      child: correctAnswer == providedAnswer
                          ? Icon(Icons.check, size: 45)
                          : Icon(Icons.clear,
                              size: 45)) //child: Text('Receiver'))
                ]),
              )
            ],
          )));
      images.add(Text('Question ${i + 1}'));
    }

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
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
              Center(
                  child: CopyText(
                      'Test complete, you got $numCorrect right out of ${currentTest.numQuestionsAnswered}')),
              BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(
                  builder: (context, state) {
                if (state is PsiTestCompleteInProgress)
                  return Row(children: [
                    Spacer(),
                    CircularProgressIndicator(),
                    Spacer()
                  ]);
                else
                  return Row(children: [
                    Spacer(),
                    Button('OK', () {
                      goToScreen(
                          context, TableBgWrapper(InviteWrapper('homeScreen')));
                    }),
                    Spacer()
                  ]);
              })
            ])));
  }
}
