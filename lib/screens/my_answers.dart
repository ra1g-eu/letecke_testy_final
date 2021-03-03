import 'dart:async';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:letecky_testy/database/db_helper.dart';
import 'package:letecky_testy/database/question_provider.dart';
import 'package:letecky_testy/database/useranswerdetail_provider.dart';
import 'package:letecky_testy/screens/my_tests.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/state/state_manager.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAnswersDetailPage extends StatefulWidget {
  MyAnswersDetailPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyAnswersDetailPageState();
}

Future<List<UserAnswersDetail>> fetchUADetailsfromDB(int answers) async {
  Future<List<UserAnswersDetail>> uad = getUADetailsById(answers);
  return uad;
}

class _MyAnswersDetailPageState extends State<MyAnswersDetailPage> {
  showAnswersTip(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTimeAnswersTipShown = prefs.getBool(showFirstTimeAnswersTip);
    if (isFirstTimeAnswersTipShown == null) {
      Flushbar(
        flushbarPosition: FlushbarPosition.BOTTOM,
        flushbarStyle: FlushbarStyle.FLOATING,
        reverseAnimationCurve: Curves.decelerate,
        forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
        backgroundColor: Colors.black12,
        blockBackgroundInteraction: true,
        boxShadows: [
          BoxShadow(
              color: Colors.black87, offset: Offset(0.0, 2.0), blurRadius: 1.0)
        ],
        leftBarIndicatorColor: Colors.indigoAccent,
        isDismissible: false,
        duration: Duration(seconds: 60),
        mainButton: OutlineButton(
          onPressed: () {
            Navigator.of(context).pop();
            prefs.setBool(showFirstTimeAnswersTip, false);
          },
          child: Icon(
            Icons.check_outlined,
            size: 50,
            color: ThemeData().accentColor,
          ),
          shape: new BeveledRectangleBorder(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          borderSide: BorderSide(color: Colors.indigoAccent, width: 1.3),
        ),
        titleText: Text(
          "Tip",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        messageText: Text(
          "Kliknutím na odpoveď zobrazíš detail otázky.",
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        ),
      )..show(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    final AnswerID args = ModalRoute.of(context).settings.arguments;
    return new Container(
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
                  final RenderBox box = context.findRenderObject();
                  Share.share(
                      "Moje hodnotenie zo skúšky PPL(A): " +
                          args.score +
                          "% (na absolvovanie je minimum 75%). Z " +
                          args.allAnswers.toString() +
                          " otázok, mám " +
                          args.correctAnswers.toString() +
                          " správne!",
                      subject: "Výsledok skúšky PPL(A)",
                      sharePositionOrigin:
                      box.localToGlobal(Offset.zero) & box.size);
                })
          ],
          title: Text('Skúška ${args.date}'),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back),
          ),
        ),
        body: Container(
          child: new FutureBuilder<List<UserAnswersDetail>>(
            future: fetchUADetailsfromDB(args.answerID),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  Future.delayed(
                      Duration.zero, () => showAnswersTip(context));
                }
                return new SingleChildScrollView(
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
                                  progressColor: (double.parse(args.score)/100 >=
                                      0.75
                                      ? Colors.greenAccent.shade700
                                      : Colors.redAccent.shade700),
                                  percent: double.parse(args.score)/100,
                                  center: AutoSizeText(
                                    '${args.score.substring(0, args.score.indexOf('.'))}%',
                                    style: TextStyle(
                                        color: (double.parse(args.score)/100 >=
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
                              ],),
                            Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 19,
                                            width: 45,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25)),
                                              child: Container(color: (double.parse(args.score)/100 >=
                                                  0.75
                                                  ? Colors.greenAccent.shade700
                                                  : Colors.redAccent
                                                  .shade700)),)),
                                        Text(' Môj výsledok', style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),)
                                      ],),
                                    Divider(color: Colors.transparent,),
                                    Row(
                                      children: [
                                        SizedBox(height: 19,
                                            width: 45,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25)),
                                              child: Container(
                                                color: Colors.indigo[900],),)),
                                        Text(' Minimum 75%', style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16),)
                                      ],),
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
                                    child: SizedBox(width: 35,
                                      height: 35,
                                      child: Icon(Icons.help_outline_outlined),),
                                  ),
                                  title: Text(
                                    'Počet otázok:',
                                    style: TextStyle(fontSize: 20),
                                    textAlign: TextAlign.left,
                                  ),
                                  trailing: Text(
                                    '${args.allAnswers}',
                                    style: TextStyle(fontSize: 36),
                                  ),
                                  isThreeLine: false,
                                ),
                                ListTile(
                                    leading: Card(
                                      shape: new BeveledRectangleBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          side: BorderSide(
                                              color: Colors.black, width: 0.7)),
                                      color: Colors.greenAccent.shade700,
                                      child: SizedBox(width: 35,
                                        height: 35,
                                        child: Icon(Icons.check_outlined),),
                                    ),
                                    title: Text(
                                      'Správne odpovede:',
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.left,
                                    ),
                                    trailing: Text(
                                      '${args.correctAnswers}',
                                      style: TextStyle(fontSize: 36),
                                    ),
                                  ), // správne
                                ListTile(
                                    leading: Card(
                                      shape: new BeveledRectangleBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          side: BorderSide(
                                              color: Colors.black, width: 0.7)),
                                      color: Colors.redAccent.shade700,
                                      child: SizedBox(width: 35,
                                        height: 35,
                                        child: Icon(Icons.close),),
                                    ),
                                    title: Text(
                                      'Nesprávne odpovede:',
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.left,
                                    ),
                                    trailing: Text(
                                      (args.wrongAnswers.toString()),
                                      style: TextStyle(fontSize: 36),
                                    ),
                                  ), //nesprávne
                                ListTile(
                                    leading: Card(
                                      shape: new BeveledRectangleBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10)),
                                          side: BorderSide(
                                              color: Colors.black, width: 0.7)),
                                      color: Colors.white,
                                      child: SizedBox(width: 35,
                                        height: 35,
                                        child: Icon(Icons.remove),),
                                    ),
                                    title: Text(
                                      'Nevyplnené odpovede:',
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.left,
                                    ),
                                    trailing: Text(
                                      '${args.emptyAnswers}',
                                      style: TextStyle(fontSize: 36),
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
                        Padding(padding: EdgeInsets.only(bottom: 8)),
                        GridView.builder(
                          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 12),
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                            return GestureDetector(
                              child: Card(
                                shape: new BeveledRectangleBorder(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    side: BorderSide(
                                        color: Colors.black, width: 1)),
                                elevation: 2,
                                color: snapshot.data[index].answered.isEmpty
                                    ? Colors.white
                                    : snapshot
                                    .data[index].is_correct
                                    .toString() ==
                                    'true'
                                    ? Colors.greenAccent.shade700
                                    : Colors.redAccent.shade700,
                                //farba karty testu - farba karty kategorie
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        'č. ${(index + 1).toString()}\n ${snapshot.data[index]
                                            .answered}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: snapshot.data[index].answered.isEmpty
                                              ? Colors.black
                                              : Colors.white, fontSize: 19,),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              onTap: () async {
                                var questionNV = await getQuestionById(
                                    snapshot.data[index].question_id);
                                context.read(userViewQuestionState).state =
                                    questionNV;
                                var answeredAnswer = snapshot.data[index].answered;
                                var questionNumber = (index + 1).toString();
                                Navigator.pushNamed(
                                    context, "/questionDetail",arguments: AnswerAndQuestionNumber(questionNumber, answeredAnswer));
                              },
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return new Text("Chyba: ${snapshot.error}");
              }
              return new Container(
                alignment: AlignmentDirectional.center,
                child: new LoadingBouncingGrid.square(
                  backgroundColor: Colors.blue[400],
                  inverted: true,
                  borderColor: Colors.black,
                  size: 60,
                  borderSize: 1,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

Future<Question> getQuestionById(questionId) async {
  var db = await copyDB();
  return await QuestionProvider().getQuestionById(db, questionId);
}

class AnswerAndQuestionNumber {
  final String questionNumber;
  final String aA;

  AnswerAndQuestionNumber(this.questionNumber, this.aA);
}
