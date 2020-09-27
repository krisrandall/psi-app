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
    if (event is ResharePsiTest) {
      yield* _mapReSharePsiTest(event);
    }
    // TODO add question
    // TODO answer question
    // TODO cancel test
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
      print(shortUrl);
      //Share.share('Take a Telepathy Test with me! $shortUrl');
      print('shortUrl $shortUrl');
      Share.share('$shareTestUrl');
      yield PsiTestSaveShareSuccessful();
    } catch (_) {
      yield PsiTestSaveShareFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapAddPsiTestQuestions(
    PsiTestSaveEvent event,
  ) async* {
    //add questions
    final db = Firestore.instance;
    String testId = event.test.testId;
    var path = ('https://picsum.photos/$DEFAULT_IMAGE_SIZE');
    for (int i = 0; i < DEFAULT_NUM_QUESTIONS - 1; i++) {
      for (int j = 0; j < DEFAULT_NUM_QUESTIONS - 1; j++) {
        var response = await http.get(path);
        var imageId = (response.headers['picsum-id']);

        db.collection('test').document(testId).updateData({
          'questions.$i.options.$j':
              'https://picsum.photos/id/$imageId/$DEFAULT_IMAGE_SIZE',
        });
      }
      var rng = new Random();
      int correctAnswer = rng.nextInt(3);

      db
          .collection('test')
          .document(testId)
          .updateData({'questions.$i.correctAnswer': correctAnswer});
    }
  }

  Stream<PsiTestSaveState> _mapCreatePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCreateInProgress();
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
}

Stream<PsiTestSaveState> _mapReSharePsiTest(
  PsiTestSaveEvent event,
) async* {
  yield PsiTestSaveShareInProgress();
  try {
    var shareTestUrl = await dynamicLink(event.test.testId);
    print(shareTestUrl);
    var shortUrl = await shortenLink(shareTestUrl.toString());
    print(shortUrl);

    //Share.share('Take a Telepathy Test with me! $shortUrl');
    print('shortUrl $shortUrl');
    Share.share('$shortUrl');
    yield PsiTestSaveShareSuccessful();
  } catch (_) {
    yield PsiTestSaveShareFailed(exception: _);
  }
}
