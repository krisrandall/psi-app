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

class PsiTestSaveShareSuccessful extends PsiTestSaveState {
  final String _shareLink;
  PsiTestSaveShareSuccessful(this._shareLink);
  String getShareLink() => _shareLink;
}

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

class PsiTestInviteFacebookFriendInProgress extends PsiTestSaveState {}

class PsiTestInviteFacebookFriendSuccessful extends PsiTestSaveState {}

class PsiTestInviteFacebookFriendFailed extends PsiTestSaveState {
  final Error error;
  const PsiTestInviteFacebookFriendFailed(this.error) : assert(error != null);
  @override
  List<Object> get props => [error];
}

class PsiTestAcceptFacebookInvitationInProgress extends PsiTestSaveState {}

class PsiTestAcceptFacebookInvitationSuccessful extends PsiTestSaveState {}

class PsiTestAcceptFacebookInvitationFailed extends PsiTestSaveState {
  final Error error;
  const PsiTestAcceptFacebookInvitationFailed(this.error)
      : assert(error != null);
  @override
  List<Object> get props => [error];
}

class GetFacebookFriendsListInProgress extends PsiTestSaveState {}

class GetFacebookFriendsListSuccessful extends PsiTestSaveState {
  final List facebookFriends;
  GetFacebookFriendsListSuccessful(this.facebookFriends);
}

class GetFacebookFriendsListFailed extends PsiTestSaveState {
  final Error error;
  final String errorMessage;
  const GetFacebookFriendsListFailed({this.error, this.errorMessage});
  @override
  List<Object> get props => [error];
}

class AddFacebookUIdToTestInProgress extends PsiTestSaveState {}

class AddFacebookUIdToTestSuccessful extends PsiTestSaveState {}

class AddFacebookUIdToTestFailed extends PsiTestSaveState {
  final Error error;
  final String errorMessage;
  const AddFacebookUIdToTestFailed({this.error, this.errorMessage});
  @override
  List<Object> get props => [error];
}

class PsiTestCompleteSuccessful extends PsiTestSaveState {}

class PsiTestCompleteInProgress extends PsiTestSaveState {}

class PsiTestCompleteFailed extends PsiTestSaveState {
  final Exception exception;
  const PsiTestCompleteFailed({@required this.exception})
      : assert(exception != null);
  @override
  List<Object> get props => [exception];
}
