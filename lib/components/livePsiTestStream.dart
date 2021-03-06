import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:app/models/psiTestQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

var globalCurrentUser;
String faceBookUid = (globalCurrentUser.email);
String myID = globalCurrentUser.isAnyonymous
    ? globalCurrentUser.email
    : globalCurrentUser.uid;

Query firestoreDatabaseStream = Firestore.instance
    .collection('test')
    .where('parties', arrayContainsAny: [
  globalCurrentUser.uid,
  globalCurrentUser.email
]).where("status", isEqualTo: "underway");

Query userTestStats = Firestore.instance.collection('test').where('parties',
    arrayContainsAny: [
      globalCurrentUser.uid,
      globalCurrentUser.email
    ]).where("status", isEqualTo: "completed");

/// Convert a firestore data snapshot into a psiTest
///
PsiTest createTestFromFirestore(List<DocumentSnapshot> documents) {
  print("myID is $myID");
  if (documents.length == 0) {
    print('no matching documents found');
    return null;
  }

  PsiTest test;

  print('livePsi globaluser = $myID');
  try {
    var data = documents[0];
    var iAm;
    print(data['sender']);

    if (data['sender'] == myID) iAm = PsiTestRole.SENDER;
    if (data['receiver'] == myID) iAm = PsiTestRole.RECEIVER;
    print('first try $iAm');
    if (iAm == null) {
      if (data['sender'] == '') iAm = PsiTestRole.SENDER;
      if (data['receiver'] == '') iAm = PsiTestRole.RECEIVER;
      print('second try $iAm');
    }

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
      answeredQuestions = questions
          .where((question) => question.providedAnswer != null)
          .toList();
      numQuestionsAnswered = answeredQuestions.length;
    } catch (e) {
      print(
          'error while populating answeredQuestions list and /or counting numQuestionsAnswered: $e');
    }
    print('$numQuestionsAnswered questions answered');
    String invitedTo;
    String shareLink;
    try {
      invitedTo = documents[0].data['invitedTo'];

      shareLink = documents[0].data['shareLink'];
    } catch (error) {
      print('error looking for invitedTo property $error');
    }

    PsiTestStatus status;
    if (data['receiver']?.isEmpty == true)
      status = PsiTestStatus.AWAITING_RECEIVER;
    else if (data['sender']?.isEmpty == true)
      status = PsiTestStatus.AWAITING_SENDER;
    else if (data['status'] == 'underway')
      status = PsiTestStatus.UNDERWAY;
    else if (data['status'] == 'completed')
      status = PsiTestStatus.COMPLETED;
    else
      status = PsiTestStatus.UNKNOWN;

    test = PsiTest(
      testId: data.documentID,
      myRole: iAm,
      totalNumQuestions: DEFAULT_NUM_QUESTIONS,
      testStatus: status,
      numQuestionsAnswered: numQuestionsAnswered,
      answeredQuestions: answeredQuestions,
      currentQuestion: numQuestionsAnswered < questions.length
          ? questions[numQuestionsAnswered]
          : null,
      questions: questions,
      invitedTo: invitedTo,
      shareLink: shareLink,
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
    //short delay to stop fetching message appearing while loading questions during test

    Future.delayed(Duration(milliseconds: 300))
        .then((value) => CopyText("Fetching existing test data .."));
    return Container(child: Text('stuck'));
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
