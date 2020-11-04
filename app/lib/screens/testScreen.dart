import 'package:app/bloc/psitestsave_bloc.dart';

import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/pictureButton.dart';
import 'package:app/config.dart';
import 'package:app/models/psiTest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/screens/testCompleteScreen.dart';

class TestScreen extends StatelessWidget {
  final String testId;

  TestScreen(this.testId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('𝚿 Test Underway'),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('test')
              .where(FieldPath.documentId, isEqualTo: testId)
              .snapshots(),
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

  void goToTestCompleteScreen(BuildContext context, PsiTest currentTest) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TestCompleteScreen(currentTest)));
  }

  void loadTestCompleteScreenIfTestComplete(
      BuildContext context, PsiTest currentTest) {
    Future.microtask(() {
      if (currentTest.numQuestionsAnswered == currentTest.questions.length) {
        goToTestCompleteScreen(context, currentTest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    loadTestCompleteScreenIfTestComplete(context, currentTest);

    if (currentTest.numQuestionsAnswered == currentTest.questions.length)
      return Text('Test complete .. calculating telepathic ability score ..');
    else if (currentTest.myRole == PsiTestRole.SENDER) {
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
    return WillPopScope(
        onWillPop: () async => false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInImage.assetNetwork(
                placeholder: 'assets/white_box.png', image: imageUrl),
            //Image.network(imageUrl),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Text('Concentrate on this image\n\n\n' +
                  'Question $currentQuestionNumber of $totalNumberQuestions'),
            ),
          ],
        ));
  }
}

class TestQuestionReceiver extends StatefulWidget {
  final List<String> imageUrls;
  final int currentQuestionNumber;
  final int totalNumberQuestions;
  final PsiTest currentTest;
  TestQuestionReceiver(
      {this.imageUrls,
      this.currentQuestionNumber,
      this.totalNumberQuestions,
      this.currentTest});

  @override
  _TestQuestionReceiverState createState() => _TestQuestionReceiverState();
}

class _TestQuestionReceiverState extends State<TestQuestionReceiver> {
  void answerQuestion(BuildContext context, {int choice}) {
    //fade out all pictures except selection...
    //
    setState(() {
      for (int i = 0; i < 4; i++) opacity[i] = 0.0;
      opacity[choice] = 1.0;
    });

    //...then update database
    //
    Future.delayed(const Duration(milliseconds: 2000), () {
      widget.currentTest.currentQuestion.provideAnswer(choice);
      widget.currentTest.numQuestionsAnswered++;
      BlocProvider.of<PsiTestSaveBloc>(context)
          .add(AnswerPsiTestQuestion(test: widget.currentTest, answer: choice));
    });
  }

  List<double> opacity = [1.0, 1.0, 1.0, 1.0];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            padding: const EdgeInsets.all(4.0),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            children: [
              PictureButton(
                  widget.imageUrls[0], () => answerQuestion(context, choice: 0),
                  opacity: opacity[0]),
              PictureButton(
                  widget.imageUrls[1], () => answerQuestion(context, choice: 1),
                  opacity: opacity[1]),
              PictureButton(
                  widget.imageUrls[2], () => answerQuestion(context, choice: 2),
                  opacity: opacity[2]),
              PictureButton(
                  widget.imageUrls[3], () => answerQuestion(context, choice: 3),
                  opacity: opacity[3]),
              Stack(alignment: AlignmentDirectional.center, children: [
                Positioned(
                    top: 0,
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text('\n\nClick to choose'),
                    )),
                TextButton.icon(
                    onPressed: () {
                      var event = CancelPsiTest(test: widget.currentTest);
                      BlocProvider.of<PsiTestSaveBloc>(context).add(event);
                    },
                    icon: Icon(Icons.exit_to_app),
                    label: Text('end test'))
              ]),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                    '\n\nQuestion ${widget.currentQuestionNumber} of ${widget.totalNumberQuestions}'),
              ),
            ]
            /*
          children: imageUrls.map((String url) {
            return GridTile(
                child: Image.network(url, fit: BoxFit.cover));
          }).toList()*/
            ));
  }
}
