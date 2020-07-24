import 'dart:async';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/utils.dart';
import 'package:app/models/psiTest.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

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
    // TODO add question
    // TODO answer question
    // TODO cancel test
  }

  Stream<PsiTestSaveState> _mapCreateAndSharePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield* _mapCreatePsiTestToState(event);
//    yield* _mapSharePsiTestToState(event);
  }

  Stream<PsiTestSaveState> _mapSharePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveShareInProgress();
    try {
      event.test.testId = '150';
      var shareTestUrl = await dynamicLink(event.test.testId);
      var shortUrl = await shortenLink(shareTestUrl.toString());
      //Share.share('Take a Telepathy Test with me! $shortUrl');
      print('shortUrl $shortUrl');
      Share.share('$shortUrl');
      yield PsiTestSaveShareSuccessful();
    } catch (_) {
      yield PsiTestSaveShareFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapAddPsiTestQuesion(
    PsiTestSaveEvent event,
  ) async* {}

  Stream<PsiTestSaveState> _mapCreatePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCreateInProgress();
    try {
      print(event.test);
      print(globalCurrentUser.uid);

      final db = Firestore.instance;

      DocumentReference ref = await db.collection("test").add({
        'parties': [globalCurrentUser.uid],
        'correct answer': [3],
        'questions': [
          'there are ${event.test.totalNumQuestions} questions in the test'
        ],
        'status': 'underway',
      });
      event.test.testId = ref.documentID;

      yield PsiTestSaveCreateSuccessful();
    } catch (_) {
      yield PsiTestSaveCreateFailed(exception: _);
    }
  }
}
