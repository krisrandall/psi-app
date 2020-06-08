
class PsiTestQuestion {

  List<String> options; // a list of 4 URLs to the images represented
  int _providedAnswer;
  int _correctAnswer;

  PsiTestQuestion(String o1, String o2, String o3, String o4, {int answer}) {
    options.add(o1);
    options.add(o2);
    options.add(o3);
    options.add(o4);
    _correctAnswer = answer;
  }

  int get providedAnswer { return _providedAnswer; }
  provideAnswer(int answer) {
    if (answer<1 || answer>4) {
      throw "Answer outside of bounds";
    }
    _providedAnswer = answer;
  }

  int get correctAnswer { return _correctAnswer; }

  bool answeredCorrectly() {
    if (_correctAnswer==null) {
      throw "Correct answer to question is not known";
    }
    if (_providedAnswer==null) return null;
    else return (_providedAnswer==_correctAnswer);
  }
  
}
