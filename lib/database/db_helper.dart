import 'dart:io';

import 'package:flutter/services.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:letecky_testy/database/useranswer_provider.dart';
import 'package:letecky_testy/database/useranswerdetail_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<Database> copyDB() async {
  var dbPath = await getDatabasesPath();
  var path = join(dbPath, db_name);

  var exists = await databaseExists(path);
  if(!exists) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    ByteData data = await rootBundle.load(join("db", db_name));
    List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    //print('DB už existuje!');
  }
  return await openDatabase(path, readOnly: true);
}

Future<Database> answersCopyDB() async {
  var dbPath = await getDatabasesPath();
  var path = join(dbPath, answers_db);

  var exists = await databaseExists(path);
  if(!exists) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}
    ByteData data = await rootBundle.load(join("db", answers_db));
    List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes, data.lengthInBytes);
    await File(path).writeAsBytes(bytes, flush: true);
  } else {
    //print('AnswerDB už existuje!');
  }
  return await openDatabase(path, readOnly: false);
}

Future<List<UserAnswers>> getUA() async {
  var dbClient = await answersCopyDB();
  List<Map> list = await dbClient.rawQuery('SELECT * FROM answers WHERE is_hidden="no" ORDER BY idanswers DESC');
  List<UserAnswers> ua = [];
  for (int i = 0; i < list.length; i++) {
    ua.add(new UserAnswers(list[i]["idanswers"],list[i]["date"], list[i]["score"],
        list[i]["wrongAnswers"],list[i]["correctAnswers"],list[i]["emptyAnswers"],list[i]["allAnswers"]));
  }
  //print("db_helper.getUA() database length: "+ua.length.toString());
  return ua;
}

Future<void> deleteEverythingFromDB() async{
  var dbClient = await answersCopyDB();
  await dbClient.rawQuery('DELETE FROM answers');
  await dbClient.rawQuery('DELETE FROM answers_detail');
  await dbClient.rawQuery('DELETE FROM sqlite_sequence');
}

Future<void> hideUAbyId(int id) async{
  var dbClient = await answersCopyDB();
  await dbClient.rawQuery('UPDATE answers SET is_hidden="yes" WHERE idanswers=$id');
}

Future<int> getIDCount() async {
  var dbClient = await answersCopyDB();
  int idcount = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(idanswers) FROM answers'));
  //print("db_helper.getIDCount() database length: $idcount");
  return idcount;
}

Future<int> countNonHiddenTestsInDb() async{
  var dbClient = await answersCopyDB();
  int idCount = Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(idanswers) FROM answers WHERE is_hidden="no"'));
  int has = idCount>0 ? idCount : 0;
  //print(idCount);
  return has;
}

Future<List<UserAnswersDetail>> getUADetailsById(int answers) async {
  var dbClient = await answersCopyDB();
  List<Map> list = await dbClient.rawQuery('SELECT id_detail,question_id,answered,is_correct,answers FROM answers_detail WHERE answers=$answers');
  List<UserAnswersDetail> uad = [];
  for (int i = 0; i < list.length; i++) {
    uad.add(new UserAnswersDetail(list[i]["id_detail"],list[i]["question_id"], list[i]["answered"],list[i]['is_correct'],list[i]["answers"]));
  }
  //print("db_helper.getUADetailsById(int answers) database length: "+uad.length.toString());
  return uad;
}