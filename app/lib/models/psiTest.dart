
import 'package:app/models/psiTestQuestion.dart';

enum PsiTestStatus {
  AWAITING_SENDER,
  AWAITING_RECEIVER,
  UNDERWAY,
  COMPLETED,
  CANCELLED,
}

enum PsiTestRole {
  SENDER,
  RECEIVER,
}

const DEFAULT_NUM_QUESTIONS = 5;

class PsiTest {

  String testId;
  PsiTestStatus testStatus;
  PsiTestRole myRole;
  int totalNumQuestions;
  int numQuestionsAnswered;
  PsiTestQuestion currentQuestion;

  List<PsiTestQuestion> answeredQuestions;

  PsiTest({ 
    this.testId, 
    this.testStatus, 
    this.myRole,
    this.totalNumQuestions,
    this.numQuestionsAnswered,
    this.answeredQuestions,
    this.currentQuestion,
  });

  PsiTest.beginNewTestAsSender() {
    myRole = PsiTestRole.SENDER;
    testStatus = PsiTestStatus.AWAITING_RECEIVER;
    totalNumQuestions = DEFAULT_NUM_QUESTIONS;
    numQuestionsAnswered = 0;
  }

  PsiTest.beginNewTestAsReceiver() {
    myRole = PsiTestRole.RECEIVER;
    testStatus = PsiTestStatus.AWAITING_SENDER;
    totalNumQuestions = DEFAULT_NUM_QUESTIONS;
    numQuestionsAnswered = 0;
  }

  void createNewTestOnServer() async {
    if (testStatus!=PsiTestStatus.AWAITING_RECEIVER && testStatus!=PsiTestStatus.AWAITING_SENDER) {
      throw "Can't save new test unless status is AWAITING_RECEIVER or AWAITING_SENDER";
    }
  }

/* TO MOVE TO BLoCs .. (and completed) .. 
  DocumentReference ref = await _databaseReference.collection("test")
    .add({
      'title': 'Flutter in Action',
      'description': 'Complete Programming Guide to learn Flutter'
    });

    testId = ref.documentID;

  }
*/
  
}
