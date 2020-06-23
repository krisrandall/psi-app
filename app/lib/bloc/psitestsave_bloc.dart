import 'dart:async';
import 'package:app/components/utils.dart';
import 'package:app/models/psiTest.dart';
import 'package:bloc/bloc.dart';
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

    if (event is CreatePsiTest)   
        { yield* _mapCreatePsiTestToState(event); }
    if (event is SharePsiTest)        
        { yield* _mapSharePsiTestToState(event); }
    if (event is CreateAndSharePsiTest)   
        { yield* _mapCreateAndSharePsiTestToState(event); }
    
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
      var shortUrl = await shortenLink(shareTestUrl.toString());
      //Share.share('Take a Telepathy Test with me! $shortUrl');
      Share.share('$shortUrl');
      yield PsiTestSaveShareSuccessful();
    } catch (_) {
      yield PsiTestSaveShareFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapCreatePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCreateInProgress();
    try {
      // TODO DB write firebase
      yield PsiTestSaveCreateSuccessful();
    } catch (_) {
      yield PsiTestSaveCreateFailed(exception: _);
    }
  }

}
