import 'dart:async';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/utils.dart';
import 'package:app/models/psiTest.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:app/config.dart';
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
    if (event is CancelPsiTest) {
      yield* _mapCancelPsiTest(event);
    }
    if (event is JoinPsiTest) {
      yield* _mapJoinPsiTest(event);
    }
    if (event is AnswerPsiTestQuestion) {
      yield* _mapAnswerPsiTestQuestionToState(event);
    }
    if (event is InviteFacebookFriend) {
      yield* _mapInviteFacebookFriendToState(event);
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

  /*Stream<PsiTestSaveState> _mapCreateShareLinkforPsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestCreateShareLinkInProgress();
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
      
      print('shared');
      yield PsiTestSaveShareSuccessful(shortUrl);
    } catch (_) {
      print('share failed');
      yield PsiTestSaveShareFailed(exception: _);
    }
  }*/

  Stream<PsiTestSaveState> _mapSharePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveShareInProgress();
    try {
      var testId = event.test.testId;
      var shareTestUrl = await dynamicLink(testId);
      print(shareTestUrl);
      var shortUrl = await shortenLink(shareTestUrl.toString());
      if (shortUrl == null) {
        shortUrl = shareTestUrl.toString();
        print(
            'URL shortener returned null, maybe free limit exhausted, using the long URL');
      }

      //Share.share('Take a Telepathy Test with me! $shortUrl');
      print('shortUrl $shortUrl');

      print('shared');
      var db = Firestore.instance;
      db
          .collection('test')
          .document(testId)
          .updateData({'shareLink': shortUrl});

      yield PsiTestSaveShareSuccessful(shortUrl);
    } catch (_) {
      print('share failed');
      yield PsiTestSaveShareFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapCreatePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCreateInProgress(0.2);
    try {
      print(globalCurrentUser.uid);

      final db = Firestore.instance;
      String senderUid;
      String receiverUid;
      String myID;

      myID = globalCurrentUser.isAnonymous
          ? globalCurrentUser.uid
          : globalCurrentUser.email;

      print(myID);

      senderUid = event.test.myRole == PsiTestRole.SENDER ? myID : "";
      receiverUid = event.test.myRole == PsiTestRole.RECEIVER ? myID : "";

      //yield PsiTestSaveCreateInProgress(0.2);

      //String testId = event.test.testId;
      var path = ('https://picsum.photos');

      var questions = new List<Map>();
      var question = new Map<String, dynamic>();

      for (int i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
        yield PsiTestSaveCreateInProgress(i * 0.2 + 0.2);
        var rng = new Random();
        int correctAnswer = rng.nextInt(3);

        var options = List<String>();

        for (int j = 0; j < 4; j++) {
          // var response = await http.get('$path/$DEFAULT_IMAGE_SIZE');
          // var imageId = (response.headers['picsum-id']);
          var imageId = rng.nextInt(1000);
          options.add('$path/id/$imageId/$DEFAULT_IMAGE_SIZE');
        }
        question = {'options': options, 'correctAnswer': correctAnswer};
        questions.add(question);
        yield PsiTestSaveCreateSuccessful();
      }

      DocumentReference ref = await db.collection('test').add({
        'parties': [myID],
        'questions': questions,
        'receiver': receiverUid,
        'sender': senderUid,
        'status': 'underway',
        'invitedTo': ''
      });

      event.test.testId = ref.documentID;
      print("created test ${ref.documentID}");
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
          'sender': globalCurrentUser.uid,
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

  Stream<PsiTestSaveState> _mapInviteFacebookFriendToState(
      PsiTestSaveEvent event) async* {
    try {
      yield PsiTestInviteFacebookFriendInProgress();
      String testId = event.test.testId;
      var facebookFriendID = event.facebookFriend;
      var db = Firestore.instance;

      Query facebookFriendQuery = db
          .collection('test')
          .where('parties', arrayContains: facebookFriendID)
          .where("status", isEqualTo: "underway");
      var snapshot = await facebookFriendQuery.getDocuments();
      var length = snapshot.documents.length;
      print(length);
      if (length == 0) {
        // send push notification
      }

      var docRef = db
          .collection('test')
          .document(testId)
          .updateData({'invitedTo': facebookFriendID});
      yield PsiTestInviteFacebookFriendSuccessful();
    } catch (error) {
      yield PsiTestInviteFacebookFriendFailed(error);
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
