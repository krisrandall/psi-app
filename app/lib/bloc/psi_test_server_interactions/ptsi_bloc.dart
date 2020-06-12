import 'package:app/bloc/bloc_helpers/bloc_event_state.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_event.dart';
import 'package:app/bloc/psi_test_server_interactions/ptsi_state.dart';
import 'package:app/models/psiTest.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PtsiBloc
    extends BlocEventStateBase<PtsiEvent, PtsiState> {
  PtsiBloc()
      : super(
          initialState: PtsiState.beforeFetching(),
        );

  static final _databaseReference = Firestore.instance;
  
  @override
  Stream<PtsiState> eventHandler(
      PtsiEvent event, PtsiState currentState) async* {

    if (event is PtsiEventFetchExistingTest) {

      yield PtsiState.fetching();

      try {

        var currentUser = await FirebaseAuth.instance.currentUser();

        // Fetch from Firebase
        // The user should only ever have one test that is underway
        var senderQuery = _databaseReference
          .collection("test")
          .where("sender", isEqualTo: currentUser.uid)
          .where("status", isEqualTo: "underway");
        var receiverQuery = _databaseReference
          .collection("test")
          .where("receiver", isEqualTo: currentUser.uid)
          .where("status", isEqualTo: "underway");
        
        QuerySnapshot snapshotS = await senderQuery.getDocuments();
        QuerySnapshot snapshotR = await receiverQuery.getDocuments();

        if (snapshotS.documents.length + snapshotR.documents.length >1 ) {
          PtsiState.failureFetching(Exception( "Multiple Tests on Server"));
          // then we need a mechanism to prooceed - probably we pick one, or delete both
        } else if (snapshotS.documents.length + snapshotR.documents.length ==0) {
          PtsiState.fetched(null);
        } else {

          var serverTestData; 
          var iAm; 
          
          if (snapshotS.documents.length == 1) { 
            iAm = PsiTestRole.SENDER;
            serverTestData = snapshotS.documents[0].data;
          } else {
            iAm = PsiTestRole.RECEIVER;
            serverTestData = snapshotR.documents[0].data;
          }

          PsiTest test = PsiTest(
            myRole : iAm,
            totalNumQuestions : DEFAULT_NUM_QUESTIONS,
            testStatus : PsiTestStatus.UNDERWAY // TODOD - this logic !,
            //numQuestionsAnswered,
            //answeredQuestions,
            //currentQuestion,
          );
          print(serverTestData);
          print(test);

          yield PtsiState.fetched(test);

        }

      } catch (e) {
        print('is this a thing !?!?!?');
        print(e);
        yield PtsiState.failureFetching(e);
      }


    }

  
    /* Example of anoher event :
    if (event is AuthenticationEventLogout){
      yield AuthenticationState.notAuthenticated();
    }
    */

  }


}


