part of 'psitestsave_bloc.dart';

abstract class PsiTestSaveEvent extends Equatable {
  const PsiTestSaveEvent();
}

class CreatePsiTest extends PsiTestSaveEvent {
  final PsiTest test;
  const CreatePsiTest({@required this.test}) : assert(test != null);
  @override
  List<Object> get props => [test];
}

class SharePsiTest extends PsiTestSaveEvent {
  final PsiTest test;
  const SharePsiTest({@required this.test}) : assert(test != null);
  @override
  List<Object> get props => [test];
}

class AddPsiTestQuestion extends PsiTestSaveEvent {
  final PsiTest test;
  const AddPsiTestQuestion({@required this.test}) : assert(test != null); 
  @override
  List<Object> get props => [test];
}

class AnswerPsiTestQuestion extends PsiTestSaveEvent {
  final PsiTest test;
  final int answer;
  const AnswerPsiTestQuestion({@required this.test, @required this.answer}) : assert(test != null && answer>0 && answer<5); 
  @override
  List<Object> get props => [test];
}

class CancelPsiTest extends PsiTestSaveEvent {
  final PsiTest test;
  const CancelPsiTest({@required this.test}) : assert(test != null);
  @override
  List<Object> get props => [test];
}
