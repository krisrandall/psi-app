import 'dart:math';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/models/psiTestQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/button.dart';

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

    try {
      if (data['questions'] != null) {
        data['questions'].forEach((q) {
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

    List<PsiTestQuestion> answeredQuestions;
    int numQuestionsAnswered = 0;

    try {
      for (PsiTestQuestion question in questions) {
        if (question.providedAnswer != null) {
          //answeredQuestions.add(question);
          numQuestionsAnswered++;
        }
      }
    } catch (e) {
      print('error while counting numQuestionsAnswered: $e');
    }
    print('$numQuestionsAnswered questions answered');
    test = PsiTest(
      testId: data.documentID,
      myRole: iAm,
      totalNumQuestions: DEFAULT_NUM_QUESTIONS,
      testStatus: ((data['sender']?.isEmpty ?? true)
          ? PsiTestStatus.AWAITING_SENDER
          : (data['receiver']?.isEmpty ?? true)
              ? PsiTestStatus.AWAITING_RECEIVER
              : PsiTestStatus.UNDERWAY),
      numQuestionsAnswered: numQuestionsAnswered,
      answeredQuestions: answeredQuestions,
      currentQuestion:
          numQuestionsAnswered < 5 ? questions[numQuestionsAnswered] : null,
      //(questions.length > 0) ? questions[questions.length - 1] : null,
      questions: questions,
    );
  } catch (exception) {
    // TODO - better global app error handling
    print('Error happened during createTestFromFirestore');
    print(exception);
    test = null;
  }

  return test;
}

/// PsiTest not available conditions
///
bool psiTestNotAvailable(AsyncSnapshot<QuerySnapshot> snapshot) {
  return ((snapshot.hasError) ||
      (snapshot.connectionState == ConnectionState.waiting) ||
      (snapshot.data.documents.length > 1));
}

/// PsiTest not available Widgets
///
Widget psiTestNotAvailableWidget(
    BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  if (snapshot.hasError) {
    return new Text('Error: ${snapshot.error}');
  } else if (snapshot.connectionState == ConnectionState.waiting) {
    return CopyText("Fetching existing test data ..");
  } else {
    List<DocumentSnapshot> documents = snapshot.data.documents;
    DocumentSnapshot document;
    if (documents.length > 1) {
      var testToDelete;

      for (document in documents) {
        if (document.data.isEmpty)
          testToDelete = createTestFromFirestore([document]);
      }
      //if one of the tests has sender and receiver, keep it and delete the other
      if (testToDelete == null)
        for (document in documents) {
          if (document['parties'].length == 1)
            testToDelete = createTestFromFirestore([document]);
        }

      var event = CancelPsiTest(test: testToDelete);
      BlocProvider.of<PsiTestSaveBloc>(context).add(event);
      print('deleting test');
      return CopyText("joining test");
      //TODO -- decide how to handle this bettter
    } /*else if (documents.length == 2) {
      return Column(children: [
        CopyText("More than one active test"),
        Button('Start over', () {
          for (document in documents) {
            var testToDelete = createTestFromFirestore([document]);
            var event = CancelPsiTest(test: testToDelete);
            BlocProvider.of<PsiTestSaveBloc>(context).add(event);
            print('deleting test');
          }
        })
      ]);
    }*/
    else {
      return CopyText("Whoops!  Unexpected thing happened !?!?");
    }
  }
}
