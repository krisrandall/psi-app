import 'package:app/components/button.dart';
import 'package:app/components/utils.dart';
import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/screenBackground.dart';
import 'package:app/models/psiTest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/main.dart';

class TestCompleteScreen extends StatelessWidget {
  final PsiTest currentTest;
  TestCompleteScreen(this.currentTest);
  @override
  Widget build(BuildContext context) {
    bool completed = false;
    if (completed == false) {
      BlocProvider.of<PsiTestSaveBloc>(context)
          .add(CompletePsiTest(test: currentTest));
      completed = true;
    }

    var numCorrect = 0;
    currentTest.questions.forEach((q) {
      if (q.answeredCorrectly()) numCorrect++;
    });

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
          'Test complete, you got $numCorrect right out of ${currentTest.numQuestionsAnswered}'),
      BlocBuilder<PsiTestSaveBloc, PsiTestSaveState>(builder: (context, state) {
        if (state is PsiTestCompleteInProgress)
          return Container(child: CircularProgressIndicator());
        else
          return Button('OK', () {
            goToScreen(context, TableBgWrapper(AfterAuthWidget()));
          });
      })
    ]);
  }
}
