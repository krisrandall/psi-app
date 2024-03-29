import 'dart:async';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/utils.dart';
import 'package:app/models/psiTest.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:app/config.dart';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
part 'psitestsave_event.dart';
part 'psitestsave_state.dart';

class PsiTestSaveBloc extends Bloc<PsiTestSaveEvent, PsiTestSaveState> {
  @override
  PsiTestSaveState get initialState => PsiTestSaveInitial();

  @override
  Stream<PsiTestSaveState> mapEventToState(
    PsiTestSaveEvent event,
  ) async* {
    if (event is CreatePsiTest) {
      yield* _mapCreatePsiTestToState(event);
    }
    if (event is SharePsiTest) {
      yield* _mapSharePsiTestToState(event);
    }
    if (event is CreateAndSharePsiTest) {
      yield* _mapCreateAndSharePsiTestToState(event);
    }
    if (event is CancelPsiTest) {
      yield* _mapCancelPsiTest(event);
    }
    if (event is JoinPsiTest) {
      yield* _mapJoinPsiTest(event);
    }
    if (event is AnswerPsiTestQuestion) {
      yield* _mapAnswerPsiTestQuestionToState(event);
    }
    if (event is GetFacebookFriendsList) {
      yield* _mapGetFacebookFriendsList(event);
    }
    if (event is InviteFacebookFriend) {
      yield* _mapInviteFacebookFriendToState(event);
    }
    if (event is CompletePsiTest) {
      yield* _mapCompletePsiTest(event);
    }
    if (event is RejectFacebookInvitation) {
      yield* _mapRejectFacebookInvitationToState(event);
    }
    if (event is AddFacebookUIdToTest) {
      yield* _mapAddFacebookUIdToTest(event);
    }
    if (event is GetFacebookID) {
      yield* _mapGetFacebookIDToState(event);
    }
  }

  Stream<PsiTestSaveState> _mapCreateAndSharePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield* _mapCreatePsiTestToState(event);
    yield* _mapSharePsiTestToState(event);
  }

  Stream<PsiTestSaveState> _mapSharePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveShareInProgress();
    try {
      var testId = event.test.testId;
      var shareTestUrl = await dynamicLink(testId);
      print(shareTestUrl);
      var shortUrl = await shortenLink(shareTestUrl.toString());
      if (shortUrl == null) {
        shortUrl = shareTestUrl.toString();
        print(
            'URL shortener returned null, maybe free limit exhausted, using the long URL');
      }

      //Share.share('Take a Telepathy Test with me! $shortUrl');
      print('shortUrl $shortUrl');

      print('shared');
      var db = Firestore.instance;
      db
          .collection('test')
          .document(testId)
          .updateData({'shareLink': shortUrl});

      yield PsiTestSaveShareSuccessful(shortUrl);
    } catch (_) {
      print('share failed');
      yield PsiTestSaveShareFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapCreatePsiTestToState(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCreateInProgress(0.2);
    try {
      final db = Firestore.instance;
      String senderUid;
      String receiverUid;
      String myFacebookID;
      String myFacebookName;

      // check if facebook or anonymous user
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      bool isAnon = _prefs.getBool('isAnonymous');

      myFacebookID = isAnon ? '' : _prefs.getString('facebookID');
      myFacebookName = isAnon ? '' : _prefs.getString('facebookName');

      senderUid =
          event.test.myRole == PsiTestRole.SENDER ? globalCurrentUser.uid : "";
      receiverUid = event.test.myRole == PsiTestRole.RECEIVER
          ? globalCurrentUser.uid
          : "";

      var path = ('https://picsum.photos');
      var questions = new List<Map>();
      var question = new Map<String, dynamic>();

      for (int i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
        yield PsiTestSaveCreateInProgress(i * 0.2 + 0.2);
        var rng = new Random();
        int correctAnswer = rng.nextInt(3);

        var options = List<String>();

        for (int j = 0; j < 4; j++) {
          int imageId;
          bool validChoice = false;
          while (!validChoice) {
            var rng = new Random();
            imageId = rng.nextInt(1085);
            final isBlacklisted = blacklisted
                .where((brokenLinkEntry) => imageId == brokenLinkEntry);
            if (isBlacklisted.isNotEmpty) print('blacklisted imageID $imageId');
            if (isBlacklisted.isEmpty) validChoice = true;
          }
          options.add('$path/id/$imageId/$DEFAULT_IMAGE_SIZE');
        }
        question = {'options': options, 'correctAnswer': correctAnswer};
        questions.add(question);
        yield PsiTestSaveCreateSuccessful();
      }

      DocumentReference ref = await db.collection('test').add({
        'parties': [globalCurrentUser.uid],
        'questions': questions,
        'receiver': receiverUid,
        'sender': senderUid,
        'status': 'underway',
        'shareLink': '',
        'myFacebookID': myFacebookID,
        'myFacebookName': myFacebookName,
        'full': false,
        'invitedFriend': ''
      });

      event.test.testId = ref.documentID;
      print("created test ${ref.documentID}");
      yield PsiTestSaveCreateSuccessful();
    } catch (_) {
      yield PsiTestSaveCreateFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapCancelPsiTest(
    PsiTestSaveEvent event,
  ) async* {
    yield PsiTestSaveCancelInProgress();
    try {
      String testId = event.test.testId;
      await Firestore.instance.collection('test').document(testId).delete();

      yield PsiTestSaveCancelSuccessful();
    } catch (_) {
      yield PsiTestSaveCancelFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapJoinPsiTest(
    PsiTestSaveEvent event,
  ) async* {
    final db = Firestore.instance;
    yield PsiTestJoinInProgress();
    try {
      String testId = event.test.testId;
      var myRole = event.test.myRole;

      if (myRole == PsiTestRole.SENDER) {
        db.collection('test').document(testId).updateData({
          'parties': FieldValue.arrayUnion([globalCurrentUser.uid]),
          'sender': globalCurrentUser.uid,
          'full': true
        });
      } else if (myRole == PsiTestRole.RECEIVER) {
        db.collection('test').document(testId).updateData({
          'parties': FieldValue.arrayUnion([globalCurrentUser.uid]),
          'receiver': globalCurrentUser.uid,
          'full': true
        });
      }
      yield PsiTestJoinSuccessful();
    } catch (_) {
      yield PsiTestJoinFailed(exception: _);
    }
  }

  Stream<PsiTestSaveState> _mapGetFacebookFriendsList(
      PsiTestSaveEvent event) async* {
    yield GetFacebookFriendsListInProgress();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String facebookAccessToken = prefs.getString('facebookAccessToken');
      bool isAnonymous = prefs.getBool('isAnonymous');

      if (isAnonymous) {
        print('user is anonymous');
        yield GetFacebookFriendsListSuccessful(['userIsAnonymous']);
      } else {
        print('continuing along here');

        print('in setfacebookfriends bloc');
        print(facebookAccessToken);
        Map jsonResponse;
        List friends;
        Map friend;
        var friendsList = new List();

        var response;
        // get facebook friends as JSON
        response = await http.get(
            "https://graph.facebook.com/me/friends?access_token=$facebookAccessToken");
        if (response.statusCode != 200) {
          String errorMessage =
              ('error, status code is ${response.statusCode}');

          yield GetFacebookFriendsListFailed(errorMessage: errorMessage);
        } else {
          jsonResponse = convert.jsonDecode(response.body);
          friends = jsonResponse['data'];
          print('friends as json response = $friends');

          for (friend in friends) {
            String friendID = friend['id'];
            String name = friend['name'];
            var friendProfilePic =
                "https://graph.facebook.com/$friendID/picture?small?access_token=$facebookAccessToken";
            friend = {
              'friendID': friendID,
              'name': name,
              'profilePicUrl': friendProfilePic
            };
            print('friend $friend');
            friendsList.add(friend);
          }
        }
        yield GetFacebookFriendsListSuccessful(friendsList);
      }
    } catch (error) {
      yield GetFacebookFriendsListFailed(error: error);
    }
  }
}

Stream<PsiTestSaveState> _mapAddFacebookUIdToTest(
    PsiTestSaveEvent event) async* {
  yield AddFacebookUIdToTestInProgress();
  try {
    final db = Firestore.instance;
    final testId = event.test.testId;
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    String myFacebookID = _prefs.getString('facebookID');
    String myFacebookName = _prefs.getString('facebookName');
    db.collection('test').document(testId).updateData(
        {'facebookID': myFacebookID, 'facebookName': myFacebookName});

    yield AddFacebookUIdToTestSuccessful();
  } catch (error) {
    yield AddFacebookUIdToTestFailed(error: error);
  }
}

Stream<PsiTestSaveState> _mapInviteFacebookFriendToState(
    PsiTestSaveEvent event) async* {
  try {
    yield PsiTestInviteFacebookFriendInProgress();
    var db = Firestore.instance;
    String inviterTestId = event.test.testId;
    String inviteeFriendID = event.facebookFriendID;

    print('inviterTestId = $inviterTestId, inviteeFriendID = $inviteeFriendID');
    db
        .collection('test')
        .document(inviterTestId)
        .updateData({'invitedFriend': inviteeFriendID});
    yield PsiTestInviteFacebookFriendSuccessful();
  } catch (error) {
    yield PsiTestInviteFacebookFriendFailed(error);
  }
}

Stream<PsiTestSaveState> _mapRejectFacebookInvitationToState(
    PsiTestSaveEvent event) async* {
  String testId = event.test.testId;
  var db = Firestore.instance;
  db
      .collection('test')
      .document(testId)
      .updateData({'invitedFriend': '', 'full': false});
}

Stream<PsiTestSaveState> _mapGetFacebookIDToState(
    PsiTestSaveEvent event) async* {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  bool isAnon = _prefs.getBool('isAnonymous');
  String myFacebookID = isAnon ? 'isAnon' : _prefs.getString('facebookID');

  yield GetFacebookIDSuccessful(myFacebookID);
}

Stream<PsiTestSaveState> _mapAnswerPsiTestQuestionToState(
    PsiTestSaveEvent event) async* {
  final db = Firestore.instance;
  yield PsiTestSaveAnswerQuestionInProgress();
  try {
    String testId = event.test.testId;
    //int answerProvided = event.test.currentQuestion.providedAnswer;
    int numCurrentQuestion = event.test.numQuestionsAnswered - 1;
    var questions = new List<Map>();
    for (int i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
      Map question = event.test.questions[i].question;
      if (i == numCurrentQuestion) {
        print(
            'adding question num ${i + 1} with provided answer ${question["providedAnswer"]}');
        question = event.test.currentQuestion.question;
      }
      questions.add(question);
    }
    await db
        .collection('test')
        .document(testId)
        .updateData({'questions': questions});
    yield PsiTestSaveAnswerQuestionSuccessful();

    if (event.test.numQuestionsAnswered == questions.length) {
      // flag the test as done
      yield* _mapCompletePsiTest(event);
    }
  } catch (_) {
    yield PsiTestSaveAnswerQuestionFailed(exception: _);
  }
}

Stream<PsiTestSaveState> _mapCompletePsiTest(PsiTestSaveEvent event) async* {
  final db = Firestore.instance;
  yield PsiTestCompleteInProgress();
  try {
    String testId = event.test.testId;
    await db
        .collection('test')
        .document(testId)
        .updateData({'status': 'completed'});
    yield PsiTestCompleteSuccessful();
  } catch (_) {
    yield PsiTestCompleteFailed(exception: _);
  }
}
