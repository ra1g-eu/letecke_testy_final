class UserAnswer {
  int questionId;
  String answered;
  bool isCorrect;

  UserAnswer({this.questionId, this.answered, this.isCorrect});

  UserAnswer.fromJson(Map<String, dynamic> json)
      : questionId = json['questionId'],
        answered = json['answered'],
        isCorrect = json['isCorrect'];

  Map<String, dynamic> toJson() => {
  'questionId':questionId,
  'answered':answered,
  'isCorrect':isCorrect
  };
}