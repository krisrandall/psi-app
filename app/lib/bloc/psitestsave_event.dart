part of 'psitestsave_bloc.dart';

abstract class PsiTestSaveEvent extends Equatable {
  final PsiTest test;
  const PsiTestSaveEvent({@required this.test}) : assert(test != null);
  @override
  List<Object> get props => [test];
  String get testId => test.testId;
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

class AddPsiTestQuestion extends PsiTestSaveEvent {
  const AddPsiTestQuestion({@required test}) : super(test: test);
}

class AnswerPsiTestQuestion extends PsiTestSaveEvent {
  final int answer;
  const AnswerPsiTestQuestion({@required test, @required this.answer})
      : assert(answer > 0 && answer < 5),
        super(test: test);
  @override
  List<Object> get props => [test, answer];
}

class CancelPsiTest extends PsiTestSaveEvent {
  const CancelPsiTest({@required test}) : super(test: test);
}

class ResharePsiTest extends PsiTestSaveEvent {
  // final String testId;
  const ResharePsiTest({@required test}) : super(test: test);
}

class JoinPsiTest extends PsiTestSaveEvent {
  @override
  const JoinPsiTest({@required testId});
}
