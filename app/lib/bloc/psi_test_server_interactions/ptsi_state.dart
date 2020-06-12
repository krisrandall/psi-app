import 'package:app/bloc/bloc_helpers/bloc_event_state.dart';
import 'package:app/models/psiTest.dart';
import 'package:meta/meta.dart';

class PtsiState extends BlocState {
  PtsiState({
    @required this.haveFetchedForExistingTest,
    this.isFetchingForExistingTest: false,
    this.exceptionFetchingExistingTest,
    this.existingTest
  });

  final bool haveFetchedForExistingTest;
  final bool isFetchingForExistingTest;
  final Object exceptionFetchingExistingTest;

  final PsiTest existingTest;
  

  factory PtsiState.beforeFetching() {
    return PtsiState(
      haveFetchedForExistingTest: false,
    );
  }

  factory PtsiState.fetched(PsiTest test) {
    return PtsiState(
      haveFetchedForExistingTest: true,
      existingTest: test,
    );
  }

  factory PtsiState.fetching() {
    return PtsiState(
      haveFetchedForExistingTest: false,
      isFetchingForExistingTest: true,
    );
  }

  factory PtsiState.failureFetching(Object e) {
    return PtsiState(
      haveFetchedForExistingTest: false,
      exceptionFetchingExistingTest: e,
    );
  }
}
