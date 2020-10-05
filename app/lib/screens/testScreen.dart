import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
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
    if (currentTest.myRole == PsiTestRole.SENDER) {
      return TestQuestionSender(
          currentTest.currentQuestion
              .options[currentTest.currentQuestion.correctAnswer],
          currentTest.numQuestionsAnswered + 1,
          currentTest.totalNumQuestions);
    } else if (currentTest.myRole == PsiTestRole.RECEIVER) {
      return TestQuestionReceiver(currentTest.currentQuestion.options,
          currentTest.numQuestionsAnswered + 1, currentTest.totalNumQuestions);
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
      this.imageUrl, this.currentQuestionNumber, this.totalNumberQuestions);
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
  TestQuestionReceiver(
      this.imageUrls, this.currentQuestionNumber, this.totalNumberQuestions);
  @override
  Widget build(BuildContext context) {
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
