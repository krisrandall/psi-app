
import 'package:app/models/psiTestQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum PsiTestStatus {
  HAVE_NOT_CHECKED_SERVER_FOR_EXISTING_YET,
  ERROR_STATE,
  NO_ACTIVE_TEST,
  AWAITING_SENDER,
  AWAITING_RECEIVER,
  UNDERWAY,
  COMPLETED,
  CANCELLED,
}

enum PsiTestError {
  HAVE_MULTIPLE_TESTS_ON_SERVER,

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
  PsiTestError error;
  int totalNumQuestions;
  int numQuestionsAnswered;
  PsiTestQuestion currentQuestion;

  List<PsiTestQuestion> answeredQuestions;

  static final _databaseReference = Firestore.instance;

  PsiTest() {
    testId = "not_currently_used";
    testStatus = PsiTestStatus.HAVE_NOT_CHECKED_SERVER_FOR_EXISTING_YET;
    totalNumQuestions = DEFAULT_NUM_QUESTIONS;
    numQuestionsAnswered = 0;
  }

  void beginNewTestAsSender() {
    if (testStatus!=PsiTestStatus.NO_ACTIVE_TEST) throw "Cannot begin new test unless current status is NO_ACTIVE_TEST";
    myRole = PsiTestRole.SENDER;
    testStatus = PsiTestStatus.AWAITING_RECEIVER;
  }

  void beginNewTestAsReceiver() {
    if (testStatus!=PsiTestStatus.NO_ACTIVE_TEST) throw "Cannot begin new test unless current status is NO_ACTIVE_TEST";
    myRole = PsiTestRole.RECEIVER;
    testStatus = PsiTestStatus.AWAITING_SENDER;
  }

  void createNewTestOnServer() async {
    if (testStatus!=PsiTestStatus.AWAITING_RECEIVER && testStatus!=PsiTestStatus.AWAITING_SENDER) {
      throw "Can't save new test unless status is AWAITING_RECEIVER or AWAITING_SENDER";
    }

  DocumentReference ref = await _databaseReference.collection("test")
    .add({
      'title': 'Flutter in Action',
      'description': 'Complete Programming Guide to learn Flutter'
    });

    testId = ref.documentID;

  }



  void getCurrentTestDetailsFromServer() {
    _databaseReference
      .collection("test")
      .getDocuments()
      .then((QuerySnapshot snapshot) {

        if (snapshot.documents.length>1) {
          testStatus = PsiTestStatus.ERROR_STATE;
          error = PsiTestError.HAVE_MULTIPLE_TESTS_ON_SERVER;
        } else if (snapshot.documents.length==0) {
          testStatus = PsiTestStatus.NO_ACTIVE_TEST;
        } else {

          // TODO -- add in all the database data 
          snapshot.documents.forEach((f) => print('${f.data}}'));

        }

      });
  }


  
}
