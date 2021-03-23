import 'package:app/bloc/psitestsave_bloc.dart';

import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/pictureButton.dart';
import 'package:app/components/utils.dart';
import 'package:app/config.dart';
import 'package:app/models/psiTest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/screens/testCompleteScreen.dart';
import 'package:http/http.dart' as http;

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
      //if either the test is finished properly or if the other person presses "end test" and changes the status to completed
      if (currentTest.numQuestionsAnswered == currentTest.questions.length ||
          currentTest.testStatus == PsiTestStatus.COMPLETED) {
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
          totalNumberQuestions: currentTest.totalNumQuestions,
          currentTest: currentTest);
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

// this function fires if the image url returns 404, which happens because we
// are using random numbers to generate the PsiTest images. Some of the image IDs don't exist
// the function just takes the image ID (eg 744) and increases it by 1 and then tries that.
// It keeps going until it gets a different status code to 404
Future<String> findValidUrl(imageUrl, exception) async {
  int statusCode = 404;
  print('exception $exception');
  String newImageUrl;
  while (statusCode == 404) {
    var uri = Uri.dataFromString(imageUrl);
    List data = uri.pathSegments;
    String newImageId = data[4];
    int imageAsInt = int.parse(newImageId);
    imageAsInt++;
    String imageId = imageAsInt.toString();
    newImageUrl = 'https://picsum.photos/id/$imageId/400';
    var response = await http.get(newImageUrl);
    statusCode = response.statusCode;
    print('next try $statusCode');
  }
  print('out of while loop');
  return newImageUrl;
}

class TestQuestionSender extends StatelessWidget {
  final String imageUrl;
  final int currentQuestionNumber;
  final int totalNumberQuestions;
  final PsiTest currentTest;
  TestQuestionSender(
      {this.imageUrl,
      this.currentQuestionNumber,
      this.totalNumberQuestions,
      this.currentTest});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInImage.assetNetwork(
                placeholder: 'assets/white_box.png',
                image: imageUrl,
                imageErrorBuilder: (BuildContext context, Object exception,
                        StackTrace stacktrace) =>
                    FutureBuilder(
                        future: findValidUrl(imageUrl, exception),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return CircularProgressIndicator();
                          else {
                            print(snapshot.data);
                            return Image.network(snapshot.data);
                          }
                        })),
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Text('Concentrate on this image\n\n\n' +
                  'Question $currentQuestionNumber of $totalNumberQuestions'),
            ),
            TextButton.icon(
                onPressed: () {
                  goToScreen(context, TestCompleteScreen(currentTest));
                },
                icon: Icon(Icons.exit_to_app),
                label: Text('end test'))
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
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Text('\n\nClick to choose'),
              ),
              Stack(alignment: AlignmentDirectional.center, children: [
                Positioned(
                    top: 0,
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                          '\n\nQuestion ${widget.currentQuestionNumber} of ${widget.totalNumberQuestions}'),
                    )),
                Positioned(
                    top: 80,
                    child: TextButton.icon(
                        onPressed: () {
                          goToScreen(
                              context, TestCompleteScreen(widget.currentTest));
                        },
                        icon: Icon(Icons.exit_to_app),
                        label: Text('end test')))
              ]),
            ]
            /*
          children: imageUrls.map((String url) {
            return GridTile(
                child: Image.network(url, fit: BoxFit.cover));
          }).toList()*/
            ));
  }
}
