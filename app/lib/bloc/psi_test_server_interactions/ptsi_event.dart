import 'package:app/bloc/bloc_helpers/bloc_event_state.dart';
import 'package:app/models/psiTest.dart';

abstract class PtsiEvent extends BlocEvent {
  final PsiTest existingTest;

  PtsiEvent({
    this.existingTest,
  });
}

class PtsiEventFetchExistingTest extends PtsiEvent {
  PtsiEventFetchExistingTest({
    PsiTest existingTest,
  }) : super(
          existingTest: existingTest,
        );
}
