import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:sqflite/sqflite.dart';

class UserAnswersDetail {
  int id_detail,question_id,answers;
  String answered,is_correct;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      answersDetailId: id_detail,
      answersDetailQuestionId: question_id,
      answersDetailAnswered: answered,
      answersDetailIsCorrect: is_correct,
      answersDetailAnswers: answers
    };
    return map;
  }

  UserAnswersDetail(this.id_detail,this.question_id,this.answered,this.is_correct,this.answers);

  UserAnswersDetail.fromMap(Map<String, dynamic> map) {
    id_detail = map[answersDetailId];
    question_id = map[answersDetailQuestionId];
    answered = map[answersDetailAnswered];
    is_correct = map[answersDetailIsCorrect];
    answers = map[answersDetailAnswers];
  }
}

class UserAnswersDetailProvider {
  Future<List<UserAnswersDetail>> getAnswersDetailByAnswerId(Database db, int id) async {
    var maps = await db.query(answersTableName,
        columns: [
          answersDetailQuestionId,
          answersDetailAnswered,
          answersDetailIsCorrect,
          answersDetailAnswers
        ],
        where: '$answersIDAnswers=?',
        whereArgs: [id]);
    if (maps.length > 0) return maps.map((useranswersdetail) => UserAnswersDetail.fromMap(useranswersdetail)).toList();
    return null;
  }

}

class UserAnswersDetailList extends StateNotifier<List<UserAnswersDetail>>{
  UserAnswersDetailList(List<UserAnswersDetail> state):super(state ?? []);

  void addAll(List<UserAnswersDetail> useranswersdetail){
    state.addAll(useranswersdetail);
  }

  void add(UserAnswersDetail useranswersdetail){
    state = [
      ...state,
      useranswersdetail,
    ];
  }
}
