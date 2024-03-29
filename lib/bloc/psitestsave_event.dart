part of 'psitestsave_bloc.dart';

abstract class PsiTestSaveEvent extends Equatable {
  final PsiTest test;
  final String facebookFriendName;
  final String facebookFriendID;
  const PsiTestSaveEvent(
      {@required this.test, this.facebookFriendName, this.facebookFriendID})
      : assert(test != null);
  @override
  List<Object> get props => [test];
}

class CreatePsiTest extends PsiTestSaveEvent {
  const CreatePsiTest({@required test}) : super(test: test);
}

class SharePsiTest extends PsiTestSaveEvent {
  const SharePsiTest({@required test}) : super(test: test);
}

class CreateAndSharePsiTest extends PsiTestSaveEvent {
  const CreateAndSharePsiTest({@required test}) : super(test: test);
}

class AddPsiTestQuestions extends PsiTestSaveEvent {
  const AddPsiTestQuestions({@required test}) : super(test: test);
}

class AnswerPsiTestQuestion extends PsiTestSaveEvent {
  final int answer;
  const AnswerPsiTestQuestion({@required test, @required this.answer})
      : assert(answer > -1 && answer < 5),
        super(test: test);
  @override
  List<Object> get props => [test, answer];
}

class CancelPsiTest extends PsiTestSaveEvent {
  const CancelPsiTest({@required test}) : super(test: test);
}

class GetFacebookFriendsList extends PsiTestSaveEvent {
  const GetFacebookFriendsList({@required test}) : super(test: test);
}

class InviteFacebookFriend extends PsiTestSaveEvent {
  final String facebookFriendID;
  final String facebookFriendName;
  final PsiTest test;
  const InviteFacebookFriend(
      {@required this.test,
      @required this.facebookFriendName,
      @required this.facebookFriendID})
      : super(test: test);
}

class RejectFacebookInvitation extends PsiTestSaveEvent {
  const RejectFacebookInvitation({@required test}) : super(test: test);
}

class AddFacebookUIdToTest extends PsiTestSaveEvent {
  const AddFacebookUIdToTest({@required test}) : super(test: test);
}

class JoinPsiTest extends PsiTestSaveEvent {
  const JoinPsiTest({@required test}) : super(test: test);
}

class GetFacebookID extends PsiTestSaveEvent {
  const GetFacebookID({@required test}) : super(test: test);
}

class CompletePsiTest extends PsiTestSaveEvent {
  const CompletePsiTest({@required test}) : super(test: test);
}
