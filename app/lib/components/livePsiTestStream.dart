import 'dart:math';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/models/psiTestQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

var globalCurrentUser;

Query firestoreDatabaseStream = Firestore.instance
    .collection('test')
    .where('parties', arrayContains: globalCurrentUser.uid)
    .where("status", isEqualTo: "underway");

/// Convert a firestore data snapshot into a psiTest
///
PsiTest createTestFromFirestore(List<DocumentSnapshot> documents) {
  if (documents.length == 0) return null;

  PsiTest test;

  try {
    var data = documents[0];
    var iAm;

    if (data['sender'] == globalCurrentUser.uid)
      iAm = PsiTestRole.SENDER;
    else
      iAm = PsiTestRole.RECEIVER;

    // create the questions

    List<PsiTestQuestion> questions = [];
    //print(data['questions'][0]['options'][0]);
    print(data[(['questions'])[0]]);
    try {
      if (data['questions'] != null) {
        data['questions'].forEach((q) {
          print(questions);
          questions.add(PsiTestQuestion(
            q['options'][0],
            q['options'][1],
            q['options'][2],
            q['options'][3],
            correctAnswer: q['correctAnswer'],
            providedAnswer: q['providedAnswer'],
          ));
        });
      } else {
        print('questions on firestore = null');
      }
    } catch (e) {
      print('error while creating questions: $e');
    }

    test = PsiTest(
      testId: data.documentID,
      myRole: iAm,
      totalNumQuestions: DEFAULT_NUM_QUESTIONS,
      testStatus: ((data['sender']?.isEmpty ?? true)
          ? PsiTestStatus.AWAITING_SENDER
          : (data['receiver']?.isEmpty ?? true)
              ? PsiTestStatus.AWAITING_RECEIVER
              : PsiTestStatus.UNDERWAY),
      numQuestionsAnswered: max(questions.length - 1, 0),
      answeredQuestions: questions,
      currentQuestion:
          (questions.length > 0) ? questions[questions.length - 1] : null,
    );
  } catch (exception) {
    // TODO - better global app error handling
    print('Error happened during createTestFromFirestore');
    print(exception);
    test = null;
  }

  return test;
}

/*PsiTest createTestToJoinFromFirestore(DocumentSnapshot sharedTestSnapshot) {
  
  var data = sharedTestSnapshot.data;

  String receiverId = data['receiver'];
  String senderId = data['sender'];
  String status = data['status'];

   test = PsiTest(
      testId: data.documentID,


}*/

/// PsiTest not available conditions
///
bool psiTestNotAvailable(AsyncSnapshot<QuerySnapshot> snapshot) {
  return ((snapshot.hasError) ||
      (snapshot.connectionState == ConnectionState.waiting) ||
      (snapshot.data.documents.length > 1));
}

/// PsiTest not available Widgets
///
Widget psiTestNotAvailableWidget(AsyncSnapshot<QuerySnapshot> snapshot) {
  if (snapshot.hasError) {
    return new Text('Error: ${snapshot.error}');
  } else if (snapshot.connectionState == ConnectionState.waiting) {
    return CopyText("Fetching existing test data ..");
  } else if (snapshot.data.documents.length > 1) {
    // TODO -- decide how to handle this bettter
    return CopyText("More than one active test");
  } else {
    return CopyText("Whoops!  Unexpected thing happened !?!?");
  }
}
