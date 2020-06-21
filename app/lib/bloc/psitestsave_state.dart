part of 'psitestsave_bloc.dart';

abstract class PsiTestSaveState extends Equatable {
  const PsiTestSaveState();
  @override
  List<Object> get props => [];
}

class PsiTestSaveInitial extends PsiTestSaveState {}

class PsiTestSaveCreateInProgress extends PsiTestSaveState {}

class PsiTestSaveCreateSuccessful extends PsiTestSaveState {}

class PsiTestSaveCreateFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveCreateFailed({@required this.exception}) : assert(exception != null);
  @override
  List<Object> get props => [exception];
}


class PsiTestSaveShareInProgress extends PsiTestSaveState {}

class PsiTestSaveShareSuccessful extends PsiTestSaveState {}

class PsiTestSaveShareFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveShareFailed({@required this.exception}) : assert(exception != null);
  @override
  List<Object> get props => [exception];
}

class PsiTestSaveAddQuestionInProgress extends PsiTestSaveState {}

class PsiTestSaveAddQuestionSuccessful extends PsiTestSaveState {}

class PsiTestSaveAddQuestionFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveAddQuestionFailed({@required this.exception}) : assert(exception != null);
  @override
  List<Object> get props => [exception];
}


class PsiTestSaveAnswerQuestionInProgress extends PsiTestSaveState {}

class PsiTestSaveAnswerQuestionSuccessful extends PsiTestSaveState {}

class PsiTestSaveAnswerQuestionFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveAnswerQuestionFailed({@required this.exception}) : assert(exception != null);
  @override
  List<Object> get props => [exception];
}


class PsiTestSaveCancelInProgress extends PsiTestSaveState {}

class PsiTestSaveCancelSuccessful extends PsiTestSaveState {}

class PsiTestSaveCancelFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestSaveCancelFailed({@required this.exception}) : assert(exception != null);
  @override
  List<Object> get props => [exception];
}
