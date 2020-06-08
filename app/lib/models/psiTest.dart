
import 'package:app/models/psiTestQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum PsiTestStatus {
  HAVE_NOT_CHECKED_SERVER_FOR_EXISTING_YET,
  HAVE_MULTIPLE_TESTS_ON_SERVER,
  NOT_STARTED,
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

  static final _databaseReference = Firestore.instance;

  PsiTest() {
    testId = "not_currently_used";
    testStatus = PsiTestStatus.HAVE_NOT_CHECKED_SERVER_FOR_EXISTING_YET; // (myRole==PsiTestRole.SENDER) ? PsiTestStatus.AWAITING_RECEIVER : PsiTestStatus.AWAITING_SENDER;
    totalNumQuestions = DEFAULT_NUM_QUESTIONS;
    numQuestionsAnswered = 0;
  }

  void beginNewTestAsSender() {
    myRole = PsiTestRole.SENDER;
  }



  void getCurrentTestDetailsFromServer() {
    _databaseReference
      .collection("test")
      .getDocuments()
      .then((QuerySnapshot snapshot) {

        if (snapshot.documents.length>1) {
          testStatus = PsiTestStatus.HAVE_MULTIPLE_TESTS_ON_SERVER;
        } else if (snapshot.documents.length==0) {
          testStatus = PsiTestStatus.NOT_STARTED;
        } else {

          // TODO -- add in all the database data 
          //snapshot.documents.forEach((f) => print('${f.data}}'));

        }

      });
  }


  
}
