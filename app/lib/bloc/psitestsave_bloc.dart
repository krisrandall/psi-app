import 'dart:async';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/utils.dart';
import 'package:app/models/psiTest.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:app/config.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

part 'psitestsave_event.dart';
part 'psitestsave_state.dart';

class PsiTestSaveBloc extends Bloc<PsiTestSaveEvent, PsiTestSaveState> {
  @override
  PsiTestSaveState get initialState => PsiTestSaveInitial();

  @override
  Stream<PsiTestSaveState> mapEventToState(
    PsiTestSaveEvent event,
  ) async* {
    if (event is CreatePsiTest) {
      yield* _mapCreatePsiTestToState(event);
    }
    if (event is SharePsiTest) {
      yield* _mapSharePsiTestToState(event);
    }
    if (event is CreateAndSharePsiTest) {
      yield* _mapCreateAndSharePsiTestToState(event);
    }
    if (event is AddPsiTestQuestions) {
      yield* _mapAddPsiTestQuestions(event);
    }
    if (event is CancelPsiTest) {
      yield* _mapCancelPsiTest(event);
    }
    if (event is JoinPsiTest) {
      yield* _mapJoinPsiTest(event);
    }
    if (event is AnswerPsiTestQuestion) {
      yield* _mapAnswerPsiTestQuestionToState(event);
    }
    if (event is CompletePsiTest) {
      yield* _mapCompletePsiTest(event);
    }
  }

  Stream<PsiTestSaveState> _mapCreateAndSharePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield* _mapCreatePsiTestToState(event);
    yield* _mapSharePsiTestToState(event);
  }

  Stream<PsiTestSaveState> _mapSharePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveShareInProgress();
    try {
      var shareTestUrl = await dynamicLink(event.test.testId);
      print(shareTestUrl);
      var shortUrl = await shortenLink(shareTestUrl.toString());
      if (shortUrl == null) {
        shortUrl = shareTestUrl.toString();
        print(
            'URL shortener returned null, maybe free limit exhausted, using the long URL');
      }
      print(shortUrl);
      //Share.share('Take a Telepathy Test with me! $shortUrl');
      print('shortUrl $shortUrl');
      Share.share('$shortUrl');
      print('shared');
      yield PsiTestSaveShareSuccessful();
    } catch (_) {
      print('share failed');
      yield PsiTestSaveShareFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapAddPsiTestQuestions(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveAddQuestionsInProgress(0.2);
    try {
      final db = Firestore.instance;
      String testId = event.test.testId;
      var path = ('https://picsum.photos');

      var questions = new List<Map>();
      var question = new Map<String, dynamic>();

      for (int i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
        var rng = new Random();
        int correctAnswer = rng.nextInt(3);

        var options = List<String>();

        for (int j = 0; j < 4; j++) {
          var response = await http.get('$path/$DEFAULT_IMAGE_SIZE');
          var imageId = (response.headers['picsum-id']);
          options.add('$path/id/$imageId/$DEFAULT_IMAGE_SIZE');
        }
        question = {'options': options, 'correctAnswer': correctAnswer};
        questions.add(question);
        yield PsiTestSaveAddQuestionsSuccessful();
        yield PsiTestSaveAddQuestionsInProgress(i * 0.2 + 0.4);
      }
      db
          .collection('test')
          .document(testId)
          .updateData({'questions': questions});
      yield PsiTestSaveAddQuestionsSuccessful();
    } catch (_) {
      yield PsiTestSaveAddQuestionsFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapCreatePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCreateInProgress(0);
    try {
      print(globalCurrentUser.uid);

      final db = Firestore.instance;
      String senderUid;
      String receiverUid;

      senderUid =
          event.test.myRole == PsiTestRole.SENDER ? globalCurrentUser.uid : "";
      receiverUid = event.test.myRole == PsiTestRole.RECEIVER
          ? globalCurrentUser.uid
          : "";
      yield PsiTestSaveCreateInProgress(0.2);
      DocumentReference ref = await db.collection("test").add({
        'parties': [globalCurrentUser.uid],
        'questions': [
          {
            'correct answer': 3,
            'options': ['a', 'b', 'c', 'd']
          }
        ],
        'receiver': receiverUid,
        'sender': senderUid,
        'status': 'underway',
      });

      event.test.testId = ref.documentID;

      yield PsiTestSaveCreateSuccessful();
    } catch (_) {
      yield PsiTestSaveCreateFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapCancelPsiTest(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCancelInProgress();
    try {
      String testId = event.test.testId;
      await Firestore.instance.collection('test').document(testId).delete();

      yield PsiTestSaveCancelSuccessful();
    } catch (_) {
      yield PsiTestSaveCancelFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapJoinPsiTest(
    PsiTestSaveEvent event,
  ) async* {
    final db = Firestore.instance;
    yield PsiTestJoinInProgress();
    try {
      String testId = event.test.testId;
      var myRole = event.test.myRole;

      if (myRole == PsiTestRole.SENDER) {
        db.collection('test').document(testId).updateData({
          'parties': FieldValue.arrayUnion([globalCurrentUser.uid]),
          'sender': globalCurrentUser.uid
        });
      } else if (myRole == PsiTestRole.RECEIVER) {
        db.collection('test').document(testId).updateData({
          'parties': FieldValue.arrayUnion([globalCurrentUser.uid]),
          'receiver': globalCurrentUser.uid
        });
      }
      yield PsiTestJoinSuccessful();
    } catch (_) {
      yield PsiTestJoinFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapAnswerPsiTestQuestionToState(
      PsiTestSaveEvent event) async* {
    final db = Firestore.instance;
    yield PsiTestSaveAnswerQuestionInProgress();
    try {
      String testId = event.test.testId;
      //int answerProvided = event.test.currentQuestion.providedAnswer;
      int numCurrentQuestion = event.test.numQuestionsAnswered - 1;
      var questions = new List<Map>();
      for (int i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
        Map question = event.test.questions[i].question;
        if (i == numCurrentQuestion) {
          print(
              'adding question num ${i + 1} with provided answer ${question["providedAnswer"]}');
          question = event.test.currentQuestion.question;
        }
        questions.add(question);
      }
      await db
          .collection('test')
          .document(testId)
          .updateData({'questions': questions});
      yield PsiTestSaveAnswerQuestionSuccessful();

      if (event.test.numQuestionsAnswered == questions.length) {
        // flag the test as done
        yield* _mapCompletePsiTest(event);
      }
    } catch (_) {
      yield PsiTestSaveAnswerQuestionFailed(exception: _);
    }
  }
}

Stream<PsiTestSaveState> _mapCompletePsiTest(PsiTestSaveEvent event) async* {
  final db = Firestore.instance;
  yield PsiTestCompleteInProgress();
  try {
    String testId = event.test.testId;
    await db
        .collection('test')
        .document(testId)
        .updateData({'status': 'completed'});
    yield PsiTestCompleteSuccessful();
  } catch (_) {
    yield PsiTestCompleteFailed(exception: _);
  }
}
