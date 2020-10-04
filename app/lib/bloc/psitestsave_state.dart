part of 'psitestsave_bloc.dart';

abstract class PsiTestSaveState extends Equatable {
  const PsiTestSaveState();
  @override
  List<Object> get props => [];
}

class PsiTestSaveInitial extends PsiTestSaveState {}

class PsiTestSaveCreateInProgress extends PsiTestSaveState {
  final double _progress;
  PsiTestSaveCreateInProgress(this._progress);
  double getProgress() => _progress;
}

class PsiTestSaveCreateSuccessful extends PsiTestSaveState {}

class PsiTestSaveCreateFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveCreateFailed({@required this.exception})
      : assert(exception != null);
  @override
  List<Object> get props => [exception];
}

class PsiTestSaveShareInProgress extends PsiTestSaveState {}

class PsiTestSaveShareSuccessful extends PsiTestSaveState {}

class PsiTestSaveShareFailed extends PsiTestSaveState {
  final StateError
      exception; /*got `StateError is not a subset of Exception` error when this was an Exception */
  const PsiTestSaveShareFailed({@required this.exception})
      : assert(exception != null);
  @override
  List<Object> get props => [exception];
}

class PsiTestSaveAddQuestionsInProgress extends PsiTestSaveState {
  final double _progress;
  PsiTestSaveAddQuestionsInProgress(this._progress);
  double getProgress() => _progress;
}

class PsiTestSaveAddQuestionsSuccessful extends PsiTestSaveState {}

class PsiTestSaveAddQuestionsFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveAddQuestionsFailed({@required this.exception})
      : assert(exception != null);
  @override
  List<Object> get props => [exception];
}

class PsiTestSaveAnswerQuestionInProgress extends PsiTestSaveState {}

class PsiTestSaveAnswerQuestionSuccessful extends PsiTestSaveState {}

class PsiTestSaveAnswerQuestionFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveAnswerQuestionFailed({@required this.exception})
      : assert(exception != null);
  @override
  List<Object> get props => [exception];
}

class PsiTestSaveCancelInProgress extends PsiTestSaveState {}

class PsiTestSaveCancelSuccessful extends PsiTestSaveState {}

class PsiTestSaveCancelFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveCancelFailed({@required this.exception})
      : assert(exception != null);
  @override
  List<Object> get props => [exception];
}

class PsiTestJoinInProgress extends PsiTestSaveState {}

class PsiTestJoinSuccessful extends PsiTestSaveState {}

class PsiTestJoinFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestJoinFailed({@required this.exception})
      : assert(exception != null);
  @override
  List<Object> get props => [exception];
}

class PsiTestReshareInProgress extends PsiTestSaveState {}

class PsiTestReshareSuccessful extends PsiTestSaveState {}

class PsiTestReshareFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestReshareFailed({@required this.exception})
      : assert(exception != null);
  @override
  List<Object> get props => [exception];
}
