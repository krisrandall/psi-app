import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/pictureButton.dart';
import 'package:app/components/utils.dart';
import 'package:app/config.dart';
import 'package:app/main.dart';
import 'package:app/models/psiTest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Test Underway'),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreDatabaseStream.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (psiTestNotAvailable(snapshot))
              return psiTestNotAvailableWidget(context, snapshot);
            var currentTest = createTestFromFirestore(snapshot.data.documents);

            return _TestScreen(currentTest);
          }),
    );
  }
}

class _TestScreen extends StatelessWidget {
  final PsiTest currentTest;
  _TestScreen(this.currentTest);

  @override
  Widget build(BuildContext context) {
    if (currentTest.numQuestionsAnswered == 5) {
      currentTest.testStatus = PsiTestStatus.COMPLETED;
      //update testStatus on Firebase to completeted
      goToScreen(context, AfterAuthWidget());
    }
    if (currentTest.myRole == PsiTestRole.SENDER) {
      String imageUrl = currentTest
          .currentQuestion.options[currentTest.currentQuestion.correctAnswer];
      String imageUrlBig =
          imageUrl.replaceAll(new RegExp(DEFAULT_IMAGE_SIZE), '500');
      return TestQuestionSender(
          imageUrl: imageUrlBig,
          currentQuestionNumber: currentTest.numQuestionsAnswered + 1,
          totalNumberQuestions: currentTest.totalNumQuestions);
    } else if (currentTest.myRole == PsiTestRole.RECEIVER) {
      return TestQuestionReceiver(
          imageUrls: currentTest.currentQuestion.options,
          currentQuestionNumber: currentTest.numQuestionsAnswered + 1,
          totalNumberQuestions: currentTest.totalNumQuestions,
          currentTest: this.currentTest);
    } else {
      return Text('ERROR : You dont have a valid role on this test!');
    }
  }
}

class TestQuestionSender extends StatelessWidget {
  final String imageUrl;
  final int currentQuestionNumber;
  final int totalNumberQuestions;
  TestQuestionSender(
      {this.imageUrl, this.currentQuestionNumber, this.totalNumberQuestions});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.network(imageUrl),
        Padding(
          padding: EdgeInsets.all(30.0),
          child: Text('Concentrate on this image\n\n\n' +
              'Question $currentQuestionNumber of $totalNumberQuestions'),
        ),
      ],
    );
  }
}

class TestQuestionReceiver extends StatelessWidget {
  final List<String> imageUrls;
  final int currentQuestionNumber;
  final int totalNumberQuestions;
  final PsiTest currentTest;
  TestQuestionReceiver(
      {this.imageUrls,
      this.currentQuestionNumber,
      this.totalNumberQuestions,
      this.currentTest});

  void answerQuestion(BuildContext context, {int choice}) {
    currentTest.currentQuestion.provideAnswer(choice);
    currentTest.numQuestionsAnswered++;
    BlocProvider.of<PsiTestSaveBloc>(context)
        .add(AnswerPsiTestQuestion(test: currentTest, answer: choice));
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: [
          PictureButton(imageUrls[0], () => answerQuestion(context, choice: 1)),
          PictureButton(imageUrls[1], () => answerQuestion(context, choice: 2)),
          PictureButton(imageUrls[2], () => answerQuestion(context, choice: 3)),
          PictureButton(imageUrls[3], () => answerQuestion(context, choice: 4)),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Text('\n\nClick to choose'),
          ),
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Text(
                '\n\nQuestion $currentQuestionNumber of $totalNumberQuestions'),
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
