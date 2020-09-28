class FirestorePsiTestQuestion {
  List options = [];
  int correctAnswer;

  FirestorePsiTestQuestion({this.options, this.correctAnswer});

  void addOption(option) {
    options.add(option);
  }

  void addCorrectAnswer(_correctAnswer) {
    correctAnswer = _correctAnswer;
  }

  Map toJson() => {'options': options, 'correctAnswer': correctAnswer};
}

class FirestorePsiTest {
  List<String> parties = [];
  List<FirestorePsiTestQuestion> questions = [];
  String receiver;
  String sender;
  String status;

  FirestorePsiTest(
      {this.parties, this.questions, this.receiver, this.sender, this.status});

  void addQuestion() {
    questions.add(new FirestorePsiTestQuestion(options: [], correctAnswer: 0));
  }

  void addQuestionOption(int questionNumber, String option) {
    questions[questionNumber].addOption('www.fuckyeahitworks.com');
  }

  void addParty(party) {
    parties.add(party);
  }

  Map toJson() => {
        'parties': parties,
        'questions': questions,
        'receiver': receiver,
        'sender': sender,
        'status': status,
      };
}
