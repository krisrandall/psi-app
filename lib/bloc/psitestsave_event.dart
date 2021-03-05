part of 'psitestsave_bloc.dart';

abstract class PsiTestSaveEvent extends Equatable {
  final PsiTest test;
  final String facebookFriend;
  const PsiTestSaveEvent({@required this.test, this.facebookFriend})
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

class InviteFacebookFriend extends PsiTestSaveEvent {
  final String facebookFriend;
  const InviteFacebookFriend({@required test, @required this.facebookFriend});
}

class JoinPsiTest extends PsiTestSaveEvent {
  const JoinPsiTest({@required test}) : super(test: test);
}

class CompletePsiTest extends PsiTestSaveEvent {
  const CompletePsiTest({@required test}) : super(test: test);
}
