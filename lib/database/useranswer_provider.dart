import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:sqflite/sqflite.dart';

class UserAnswers {
  int idanswers, wrongAnswers, correctAnswers, emptyAnswers, allAnswers;
  String date,score;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      answersIDAnswers: idanswers,
      answersDate: date,
      answersScore: score,
      answersWrong: wrongAnswers,
      answersCorrect: correctAnswers,
      answersEmpty: emptyAnswers,
      answersAll: allAnswers
    };
    return map;
  }

  UserAnswers(this.idanswers,this.date,this.score, this.wrongAnswers, this.correctAnswers, this.emptyAnswers, this.allAnswers);

  UserAnswers.fromMap(Map<String, dynamic> map) {
    idanswers = map[answersIDAnswers];
    date = map[answersDate];
    score = map[answersScore];
    wrongAnswers = map[answersWrong];
    correctAnswers = map[answersCorrect];
    emptyAnswers = map[answersEmpty];
    allAnswers = map[answersAll];
  }
}

class UserAnswersProvider {
  Future<List<UserAnswers>> getAnswers(Database db) async {
    var maps = await db.query(answersTableName,
        columns: [
          answersIDAnswers,
          answersDate,
          answersScore,
          answersWrong,
          answersCorrect,
          answersEmpty,
          answersAll
        ]);
    if (maps.length > 0) return maps.map((useranswers) => UserAnswers.fromMap(useranswers)).toList();
    return null;
  }

}

class UserAnswersList extends StateNotifier<List<UserAnswers>>{
  UserAnswersList(List<UserAnswers> state):super(state ?? []);

  void addAll(List<UserAnswers> useranswers){
    state.addAll(useranswers);
  }

  void add(UserAnswers useranswers){
    state = [
      ...state,
      useranswers,
    ];
  }
}
