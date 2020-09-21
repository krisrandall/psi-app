import 'dart:async';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/utils.dart';
import 'package:app/models/psiTest.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

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
    if (event is AddPsiTestQuestion) {
      yield* _mapAddPsiTestQuesion(event);
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

  Stream<PsiTestSaveState> _mapAddPsiTestQuesion(
    PsiTestSaveEvent event,
  ) async* {
    var path = ('https://picsum.photos/200');
    var response = await http.get(path);
    var imageId = (response.headers['picsum-id']);
    String testId = event.test.testId;
    final db = Firestore.instance;

    db.collection('test').document(testId).updateData({
      'options':
          FieldValue.arrayUnion(['https://picsum.photos/id/$imageId/200']),
    });
  }

  Stream<PsiTestSaveState> _mapCreatePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCreateInProgress();
    try {
      print(event.test);
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
        //'status': 'awaiting ...'
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
