import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:letecky_testy/database/db_helper.dart';
import 'package:letecky_testy/database/question_provider.dart';
import 'package:letecky_testy/database/useranswer_provider.dart';
import 'package:letecky_testy/database/useranswerdetail_provider.dart';
import 'package:letecky_testy/state/state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share/share.dart';

import 'my_answers.dart';

class MyResultPage extends StatefulWidget {
  MyResultPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MyResultPageState();
}

class _MyResultPageState extends State<MyResultPage> {
  int _count = 0;
  String _currTime = "";

  int increment() {
    setState(() {
      return _count++;
    });
  }

  void idWtf() async {
    final id = await getIDCount();
    print("idWtf setState: $id");
  }

  /*int incrementAnswerId() {
    getIDCount().then((idcount) => _answerId++);
    return _answerId;
  }*/
  var myPercentScore;
  var myNumberOfCorrectQuestions;
  var myNumberOfWrongQuestions;
  var myNumberOfEmptyQuestions;
  var myNumberOfAllQuestions;

  @override
  void initState() {
    super.initState();
    setState(() {
      myNumberOfCorrectQuestions = context
          .read(userListAnswer)
          .state
          .where((answer) => answer.isCorrect)
          .toList()
          .length;
      myNumberOfWrongQuestions = (context.read(userListAnswer).state.length) -
          (context
              .read(userListAnswer)
              .state
              .where((answer) => answer.isCorrect)
              .toList()
              .length) -
          (context
              .read(userListAnswer)
              .state
              .where((answer) => answer.answered.isEmpty)
              .toList()
              .length);
      myNumberOfEmptyQuestions = context
          .read(userListAnswer)
          .state
          .where((answer) => answer.answered.isEmpty)
          .toList()
          .length;
      myNumberOfAllQuestions = context.read(userListAnswer).state.length;
      _currTime = DateFormat("dd.MM.yyyy, HH:mm").format(DateTime.now());
      _insertUserAnswer(
          (((context
                          .read(userListAnswer)
                          .state
                          .where((answer) => answer.isCorrect)
                          .toList()
                          .length) *
                      100) /
                  context.read(userListAnswer).state.length)
              .toStringAsFixed(2),
          _currTime,
          myNumberOfWrongQuestions,
          myNumberOfCorrectQuestions,
          myNumberOfEmptyQuestions,
          myNumberOfAllQuestions);
      myPercentScore = (((context
                      .read(userListAnswer)
                      .state
                      .where((answer) => answer.isCorrect)
                      .toList()
                      .length) *
                  100) /
              context.read(userListAnswer).state.length)
          .toStringAsFixed(2);
      idWtf();
      //print(setState);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.05, 0.15, 0.30, 0.45, 0.60, 0.75, 0.90, 0.99],
              colors: [
                Colors.blue[600],
                Colors.blue[600],
                Colors.blue,
                Colors.blue,
                Colors.blue[400],
                Colors.blue[400],
                Colors.blue[400],
                Colors.blue[400],
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              actions: [
                IconButton(
                    tooltip: "Zdielať výsledky",
                    icon: Icon(Icons.share_sharp),
                    onPressed: () {
                      var myNumberOfQuestions =
                          context.read(userListAnswer).state.length.toString();
                      final RenderBox box = context.findRenderObject();
                      Share.share(
                          "Moje hodnotenie zo skúšky PPL(A): " +
                              myPercentScore +
                              "% (na absolvovanie je minimum 75%). Z " +
                              myNumberOfQuestions +
                              " otázok, mám " +
                              myNumberOfCorrectQuestions.toString() +
                              " správne!",
                          subject: "Výsledok skúšky PPL(A)",
                          sharePositionOrigin:
                              box.localToGlobal(Offset.zero) & box.size);
                    })
              ],
              title: Text('Výsledok skúšky'),
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/homePage");
                },
                child: Icon(Icons.arrow_back),
              ),
            ),
            body: Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularPercentIndicator(
                                backgroundColor: Colors.black12,
                                radius: 136,
                                fillColor: Colors.transparent,
                                lineWidth: 14,
                                progressColor: Colors.indigo[900],
                                circularStrokeCap: CircularStrokeCap.round,
                                percent: 0.75,
                              ),
                              CircularPercentIndicator(
                                backgroundColor: Colors.black12,
                                radius: 164,
                                fillColor: Colors.transparent,
                                lineWidth: 14,
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: (context
                                                .read(userListAnswer)
                                                .state
                                                .where((e) => e.isCorrect)
                                                .toList()
                                                .length /
                                            context
                                                .read(userListAnswer)
                                                .state
                                                .length >=
                                        0.75
                                    ? Colors.greenAccent.shade700
                                    : Colors.redAccent.shade700),
                                percent: context
                                        .read(userListAnswer)
                                        .state
                                        .where((e) => e.isCorrect)
                                        .toList()
                                        .length /
                                    context.read(userListAnswer).state.length,
                                center: AutoSizeText(
                                  '${((context.read(userListAnswer).state.where((answer) => answer.isCorrect).toList().length * 100) / context.read(userListAnswer).state.length).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      color: (context
                                                      .read(userListAnswer)
                                                      .state
                                                      .where((e) => e.isCorrect)
                                                      .toList()
                                                      .length /
                                                  context
                                                      .read(userListAnswer)
                                                      .state
                                                      .length >=
                                              0.75
                                          ? Colors.greenAccent.shade700
                                          : Colors.redAccent.shade700),
                                      shadows: [
                                        Shadow(
                                            // bottomLeft
                                            offset: Offset(-1, -1),
                                            color: Colors.black),
                                        Shadow(
                                            // bottomRight
                                            offset: Offset(1, -1),
                                            color: Colors.black),
                                        Shadow(
                                            // topRight
                                            offset: Offset(1, 1),
                                            color: Colors.black),
                                        Shadow(
                                            // topLeft
                                            offset: Offset(-1, 1),
                                            color: Colors.black),
                                      ],
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold),
                                  softWrap: true,
                                  wrapWords: true,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          Container(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      height: 19,
                                      width: 45,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        child: Container(
                                            color: (context
                                                            .read(
                                                                userListAnswer)
                                                            .state
                                                            .where((e) =>
                                                                e.isCorrect)
                                                            .toList()
                                                            .length /
                                                        context
                                                            .read(
                                                                userListAnswer)
                                                            .state
                                                            .length >=
                                                    0.75
                                                ? Colors.greenAccent.shade700
                                                : Colors.redAccent.shade700)),
                                      )),
                                  Text(
                                    ' Môj výsledok',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                              Divider(
                                color: Colors.transparent,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                      height: 19,
                                      width: 45,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        child: Container(
                                          color: Colors.indigo[900],
                                        ),
                                      )),
                                  Text(
                                    ' Minimum 75%',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            ],
                          ))
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 8)),
                      Divider(
                          color: Colors.white12,
                          height: 1.5,
                          endIndent: 2,
                          indent: 2,
                          thickness: 2),
                      Padding(padding: EdgeInsets.only(top: 8)),
                      Container(
                          padding: EdgeInsets.all(2),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Card(
                                  shape: new BeveledRectangleBorder(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)),
                                      side: BorderSide(
                                          color: Colors.black, width: 0.7)),
                                  color: Colors.blue,
                                  child: SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: Icon(Icons.help_outline_outlined),
                                  ),
                                ),
                                title: Text(
                                  'Počet otázok:',
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.left,
                                ),
                                trailing: Text(
                                  '$myNumberOfAllQuestions',
                                  style: TextStyle(fontSize: 36),
                                ),
                                isThreeLine: false,
                              ),
                              Visibility(
                                visible: (myNumberOfAllQuestions ==
                                            myNumberOfEmptyQuestions ||
                                        myNumberOfCorrectQuestions == 0 ||
                                        myNumberOfWrongQuestions +
                                                myNumberOfEmptyQuestions ==
                                            myNumberOfAllQuestions)
                                    ? false
                                    : true,
                                child: ListTile(
                                  leading: Card(
                                    shape: new BeveledRectangleBorder(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        side: BorderSide(
                                            color: Colors.black, width: 0.7)),
                                    color: Colors.greenAccent.shade700,
                                    child: SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: Icon(Icons.check_outlined),
                                    ),
                                  ),
                                  title: Text(
                                    'Správne odpovede:',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.left,
                                  ),
                                  trailing: Text(
                                    '${context.read(userListAnswer).state.where((answer) => answer.isCorrect).toList().length}',
                                    style: TextStyle(fontSize: 36),
                                  ),
                                ),
                              ), // správne
                              Visibility(
                                visible: (myNumberOfAllQuestions ==
                                            myNumberOfEmptyQuestions ||
                                        myNumberOfWrongQuestions == 0)
                                    ? false
                                    : true,
                                child: ListTile(
                                  leading: Card(
                                    shape: new BeveledRectangleBorder(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        side: BorderSide(
                                            color: Colors.black, width: 0.7)),
                                    color: Colors.redAccent.shade700,
                                    child: SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: Icon(Icons.close),
                                    ),
                                  ),
                                  title: Text(
                                    'Nesprávne odpovede:',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.left,
                                  ),
                                  trailing: Text(
                                    (myNumberOfWrongQuestions.toString()),
                                    style: TextStyle(fontSize: 36),
                                  ),
                                ),
                              ), //nesprávne
                              Visibility(
                                visible: myNumberOfEmptyQuestions == 0
                                    ? false
                                    : true,
                                child: ListTile(
                                  leading: Card(
                                    shape: new BeveledRectangleBorder(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        side: BorderSide(
                                            color: Colors.black, width: 0.7)),
                                    color: Colors.white,
                                    child: SizedBox(
                                      width: 35,
                                      height: 35,
                                      child: Icon(Icons.remove),
                                    ),
                                  ),
                                  title: Text(
                                    'Nevyplnené odpovede:',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.left,
                                  ),
                                  trailing: Text(
                                    '${context.read(userListAnswer).state.where((answer) => answer.answered.isEmpty).toList().length}',
                                    style: TextStyle(fontSize: 36),
                                  ),
                                ),
                              ), //nevyplnené
                            ],
                          )),
                      Padding(padding: EdgeInsets.only(top: 8)),
                      Divider(
                          color: Colors.white12,
                          height: 1.5,
                          endIndent: 2,
                          indent: 2,
                          thickness: 2),
                      Padding(
                        padding: EdgeInsets.only(bottom: 4, top: 4),
                        child: Center(
                            child: Text(
                          "Kliknutím na otázku zobrazíš detaily",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          textAlign: TextAlign.center,
                        )),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 5,
                        childAspectRatio: 1.0,
                        padding: const EdgeInsets.all(4.0),
                        mainAxisSpacing: 3.0,
                        crossAxisSpacing: 3.0,
                        children: context
                            .read(userListAnswer)
                            .state
                            .asMap()
                            .entries
                            .map((question) {
                          _insertUserAnswerDetail(
                              question.value.questionId,
                              question.value.answered,
                              question.value.isCorrect.toString());
                          return GestureDetector(
                            child: Card(
                              shape: new BeveledRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  side: BorderSide(
                                      color: Colors.black, width: 1)),
                              elevation: 2,
                              color: question.value.answered.isEmpty
                                  ? Colors.white
                                  : question.value.isCorrect
                                      ? Colors.greenAccent.shade700
                                      : Colors.redAccent.shade700,
                              //farba karty testu - farba karty kategorie
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      'č. ${question.key + 1}\n ${question.value.answered}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: question.value.answered.isEmpty
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 19,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            onTap: () async {
                              var questionNV = await getQuestionById(
                                  question.value.questionId);
                              context.read(userViewQuestionState).state =
                                  questionNV;
                              var aA = question.value.answered;
                              var questionNumber =
                                  (question.key + 1).toString();
                              Navigator.pushNamed(context, "/questionDetail",
                                  arguments: AnswerAndQuestionNumber(
                                      questionNumber, aA));
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          Navigator.pop(context);
          Navigator.pushNamed(context, "/homePage");
          return true;
        });
  }

  Future<Question> getQuestionById(questionId) async {
    var db = await copyDB();
    return await QuestionProvider().getQuestionById(db, questionId);
  }
}

Future<int> insertUserAnswer(UserAnswers ua) async {
  var db = await answersCopyDB();
  return await db.insert('answers', {
    'date': ua.date,
    'score': ua.score,
    'wrongAnswers': ua.wrongAnswers,
    'correctAnswers': ua.correctAnswers,
    'emptyAnswers': ua.emptyAnswers,
    'allAnswers': ua.allAnswers,
  });
}

Future<int> insertUserAnswerDetail(UserAnswersDetail uad, int answers) async {
  var db = await answersCopyDB();
  return await db.insert('answers_detail', {
    'question_id': uad.question_id,
    'answered': uad.answered,
    'is_correct': uad.is_correct,
    'answers': answers
  });
}

void _insertUserAnswer(score, date, wrong, correct, empty, all) async {
  // row to insert
  Map<String, dynamic> row = {
    answersDate: date,
    answersScore: score,
    answersWrong: wrong,
    answersCorrect: correct,
    answersEmpty: empty,
    answersAll: all
  };
  UserAnswers ua = UserAnswers.fromMap(row);
  final id = await insertUserAnswer(ua);
  //print('_insertUserAnswer: inserted row id: $id');
}

void _insertUserAnswerDetail(qID, answered, is_correct) async {
  final id = await getIDCount();
  //print("_insertUserAnswerDetail: $id");

  Map<String, dynamic> rowDetail = {
    answersDetailQuestionId: qID,
    answersDetailAnswered: answered,
    answersDetailIsCorrect: is_correct,
    answersDetailAnswers: id
  };
  UserAnswersDetail uad = UserAnswersDetail.fromMap(rowDetail);
  final idDetail = await insertUserAnswerDetail(uad, id);
  //print('_insertUserAnswerDetail: inserted row id: $idDetail and $id');
}
