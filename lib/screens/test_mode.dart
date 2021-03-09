import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:letecky_testy/database/db_helper.dart';
import 'package:letecky_testy/database/question_provider.dart';
import 'package:letecky_testy/model/user_answer_model.dart';
import 'package:letecky_testy/screens/home_page.dart';
import 'package:letecky_testy/state/state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/widgets/question_body.dart';
import 'package:loading_animations/loading_animations.dart';

class MyTestModePage extends StatefulWidget {
  final String title;

  MyTestModePage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MyTestModePageState();
}

class _MyTestModePageState extends State<MyTestModePage>
    with SingleTickerProviderStateMixin {
  CarouselController carouselController = new CarouselController();
  List<UserAnswer> userAnswers = new List<UserAnswer>();
  bool isAnswerSheetOpen = false;
  bool isTimeNearEnd = false;
  Duration _duration;
  Color endTime = Colors.red;

  @override
  void dispose() {
    isAnswerSheetOpen = false;
    isTimeNearEnd = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserTestModeInfo args = ModalRoute.of(context).settings.arguments;
    _duration = Duration(seconds: args.userSelectedTestTime.toInt());
    return WillPopScope(
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.033),
            decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
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
            body: Column(children: [
              Expanded(
                child: FutureBuilder<List<Question>>(
                    future: getQuestion(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Center(
                          child: Text('${snapshot.error}'),
                        );
                      else if (snapshot.hasData) {
                        return Container(
                          margin: const EdgeInsets.all(0.2),
                          child: Card(
                            color: Colors.transparent,
                            elevation: 3,
                            shadowColor: Colors.black54,
                            clipBehavior: Clip.hardEdge,
                            shape: BeveledRectangleBorder(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            margin: const EdgeInsets.all(4),
                            child: QuestionBody(
                              context: context,
                              carouselController: carouselController,
                              questions: snapshot.data,
                              userAnswers: userAnswers,
                            ),
                          ),
                        );
                      } else
                        return Center(
                          child: LoadingBouncingGrid.square(
                            backgroundColor: Colors.blue[400],
                            inverted: true,
                            borderColor: Colors.black,
                            size: 60,
                            borderSize: 1,
                            duration: Duration(milliseconds: 1500),
                          ),
                        );
                    }),
              ),
            ],),
            bottomNavigationBar: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                OutlineButton(
                  onPressed: () {
                    isAnswerSheetOpen = true;
                    showDialog(
                      context: context,
                      useRootNavigator: false,
                      barrierDismissible: false,
                      barrierColor: Colors.black54,
                      child: WillPopScope(
                          child: Builder(
                              builder: (_) => new AlertDialog(
                                backgroundColor: Colors.indigo[500],
                                shape: new BeveledRectangleBorder(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    side: BorderSide(
                                        color: Colors.black, width: 1.3)),
                                elevation: 5,
                                title: Text('Zoznam odpovedí'),
                                content: Container(
                                    width:
                                    MediaQuery.of(context).size.width,
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1.4,
                                      padding: const EdgeInsets.all(2.0),
                                      mainAxisSpacing: 8.0,
                                      crossAxisSpacing: 8.0,
                                      children: context
                                          .read(userListAnswer)
                                          .state
                                          .asMap()
                                          .entries
                                          .map((e) {
                                        return GestureDetector(
                                          child: Card(
                                            shape: new BeveledRectangleBorder(
                                                borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                    Radius.circular(
                                                        10),
                                                    bottomRight:
                                                    Radius.circular(
                                                        10)),
                                                side: BorderSide(
                                                    color:
                                                    Colors.indigoAccent,
                                                    width: 1.3)),
                                            elevation: 2,
                                            color:
                                            (e.value.answered != null &&
                                                e.value.answered
                                                    .isNotEmpty)
                                                ? Colors.indigoAccent
                                                : Colors.transparent,
                                            //farba karty testu - farba karty kategorie
                                            child: Row(
                                              verticalDirection:
                                              VerticalDirection.down,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: AutoSizeText(
                                                    '${e.key + 1}. ',
                                                    textAlign:
                                                    TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.w300,
                                                        fontSize: 25),
                                                  ),
                                                ),
                                                Center(
                                                  child: AutoSizeText(
                                                    '${e.value.answered == null || e.value.answered.isEmpty ? '' : e.value.answered}',
                                                    textAlign:
                                                    TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 25),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            carouselController
                                                .animateToPage(e.key);
                                          },
                                        );
                                      }).toList(),
                                    )),
                                actions: [
                                  OutlineButton.icon(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // zatvoriť dialogove okno
                                      isAnswerSheetOpen = false;
                                    },
                                    label: Text(
                                      'Zatvoriť',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: ThemeData().accentColor),
                                    ),
                                    icon: Icon(
                                      Icons.close_outlined,
                                      color: ThemeData().accentColor,
                                      size: 20,
                                    ),
                                    shape: new BeveledRectangleBorder(
                                        borderRadius:
                                        const BorderRadius.only(
                                            topLeft:
                                            Radius.circular(10),
                                            bottomRight:
                                            Radius.circular(10))),
                                    borderSide: BorderSide(
                                        color: Colors.indigoAccent,
                                        width: 1.3),
                                  ),
                                ],
                              )),
                          onWillPop: () async {
                            isAnswerSheetOpen = false;
                            return true;
                          }),
                    );
                  },
                  child: Icon(Icons.grid_view, size: 30),
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  borderSide:
                  BorderSide(color: Colors.indigoAccent, width: 1.2),
                ),
                OutlineButton(
                  onPressed: () {
                    return false;
                  },
                  child: CountdownFormatted(
                    duration: _duration,
                    onFinish: () {
                      onTimeExpireDialog();
                    },
                    builder: (BuildContext ctx, String remaining) {
                      switch (_duration.inMinutes.toString()) {
                        case '5':
                          {
                            if (remaining == '02:30') isTimeNearEnd = true;
                          }
                          break;

                        case '10':
                          {
                            if (remaining == '03:30') isTimeNearEnd = true;
                          }
                          break;

                        case '15':
                          {
                            if (remaining == '05:30') isTimeNearEnd = true;
                          }
                          break;

                        case '20':
                          {
                            if (remaining == '07:30') isTimeNearEnd = true;
                          }
                          break;

                        case '25':
                          {
                            if (remaining == '09:30') isTimeNearEnd = true;
                          }
                          break;

                        case '30':
                          {
                            if (remaining == '11:30') isTimeNearEnd = true;
                          }
                          break;

                        case '35':
                          {
                            if (remaining == '13:30') isTimeNearEnd = true;
                          }
                          break;

                        case '40':
                          {
                            if (remaining == '15:30') isTimeNearEnd = true;
                          }
                          break;

                        case '50':
                          {
                            if (remaining == '17:30') isTimeNearEnd = true;
                          }
                          break;

                        case '60':
                          {
                            if (remaining == '19:30') isTimeNearEnd = true;
                          }
                          break;

                        case '70':
                          {
                            if (remaining == '21:30') isTimeNearEnd = true;
                          }
                          break;

                        case '75':
                          {
                            if (remaining == '23:30') isTimeNearEnd = true;
                          }
                          break;

                        default:
                          {
                            isTimeNearEnd = false;
                          }
                          break;
                      }
                      return AutoSizeText(
                        remaining,
                        style: TextStyle(
                          fontSize: isTimeNearEnd ? 30 : 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.12,
                          color: isTimeNearEnd ? endTime : Colors.white,
                        ),
                        softWrap: true,
                        wrapWords: true,
                        maxLines: 3,
                      ); // 01:00:00
                    },
                  ),
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  borderSide: BorderSide(
                      color: Colors.indigoAccent, width: 1.8),
                ),
                FlatButton(
                  color: Colors.green,
                  onPressed: () {
                    showFinishDialog();
                  },
                  child: Icon(Icons.send, size: 32, color: Colors.white,),
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)), side: BorderSide(color: Colors.black, width: 0.6),),
                ),

              ],
            ),
          ),),
        onWillPop: () async {
          showCloseExamDialog();
          return false;
        });
  }

  void onTimeExpireDialog() {
    showDialog(
      useRootNavigator: false,
      barrierDismissible: false,
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        // return object of type Dialog
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: Colors.indigo[500],
            shape: new BeveledRectangleBorder(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
                side: BorderSide(color: Colors.black, width: 1.3)),
            elevation: 5,
            title: Text('Vypršal čas'),
            content: Text('Vypršal ti tvoj čas na skúšku!'),
            actions: [
              OutlineButton(
                onPressed: () {
                  print(isAnswerSheetOpen);
                  if (isAnswerSheetOpen == true) {
                    Navigator.pop(context);
                  }
                  Navigator.pop(context);
                  Navigator.pop(context);
                  context.read(userListAnswer).state = userAnswers;
                  Navigator.pushNamed(context, "/showResult");
                },
                child: Text(
                  'Odoslať skúšku',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: ThemeData().accentColor),
                ),
                shape: new BeveledRectangleBorder(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                borderSide: BorderSide(color: Colors.indigoAccent, width: 1.3),
              ),
            ],
          ),
          onWillPop: () async {
            return false;
          },
        );
      },
    );
  }

  void showCloseExamDialog() {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        useRootNavigator: false,
        builder: (_) => new AlertDialog(
          backgroundColor: Colors.indigo[500],
              shape: new BeveledRectangleBorder(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  side: BorderSide(color: Colors.black, width: 1.3)),
              elevation: 5,
              title: Text('Opustenie'),
              content: Text(
                  'Naozaj chceš opustiť túto skúšku? Všetky odpovede budú stratené!'),
              actions: [
                OutlineButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // zatvoriť dialogove okno
                    },
                    child: Text(
                      'Nie',
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.normal),
                    ),
                    shape: new BeveledRectangleBorder(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)))),
                OutlineButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, "/homePage");
                  },
                  child: Text(
                    'Áno',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: ThemeData().accentColor),
                  ),
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  borderSide:
                      BorderSide(color: Colors.indigoAccent, width: 1.3),
                ),
              ],
            ));
  }

  Future<List<Question>> getQuestion() async {
    final UserTestModeInfo args = ModalRoute.of(context).settings.arguments;
    print('testmode ${args.userCategoryID.first}');
    var db = await copyDB();
    if(args.userCategoryID.length == 1 && (args.userCategoryID.first == 10 || args.userCategoryID.last == 10)) {
      var result = await QuestionProvider()
          .getAllQuestionsAndNumberOfQuestions(
          db, args.userNumberOfQuestions);
      userAnswers.clear();
      result.forEach((element) {
        userAnswers.add(new UserAnswer(
            questionId: element.questionId, answered: '', isCorrect: false));
      });
      context
          .read(userListAnswer)
          .state = userAnswers;
      return result;
    } else if(args.userCategoryID.length == 2){
      var result = await QuestionProvider()
          .getQuestionByCategoryIdAndNumberOfQuestions(
          db, args.userCategoryID.first, args.userCategoryID.last, args.userNumberOfQuestions);
      userAnswers.clear();
      result.forEach((element) {
        userAnswers.add(new UserAnswer(
            questionId: element.questionId, answered: '', isCorrect: false));
      });
      context
          .read(userListAnswer)
          .state = userAnswers;
      return result;
    } else if(args.userCategoryID.length == 1 && (args.userCategoryID.first != 10 || args.userCategoryID.last != 10)){
      var result = await QuestionProvider()
          .getQuestionsFromSingleCategoryByNumber(
          db, args.userCategoryID.first, args.userNumberOfQuestions);
      userAnswers.clear();
      result.forEach((element) {
        userAnswers.add(new UserAnswer(
            questionId: element.questionId, answered: '', isCorrect: false));
      });
      context
          .read(userListAnswer)
          .state = userAnswers;
      return result;
    }
  }

  void showFinishDialog() {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        useRootNavigator: false,
        builder: (_) => new AlertDialog(
          backgroundColor: Colors.indigo[500],
              shape: new BeveledRectangleBorder(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  side: BorderSide(color: Colors.black, width: 1.3)),
              elevation: 5,
              title: Text('Odoslanie'),
              content: Text(
                  'Naozaj chceš odoslať svoje odpovede a zobraziť výsledky?'),
              actions: [
                OutlineButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // zatvoriť dialogove okno
                    },
                    child: Text(
                      'Nie',
                      style: TextStyle(
                          fontSize: 25, fontWeight: FontWeight.normal),
                    ),
                    shape: new BeveledRectangleBorder(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)))),
                OutlineButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    context.read(userListAnswer).state = userAnswers;
                    Navigator.pushNamed(context, "/showResult");
                  },
                  child: Text(
                    'Áno',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: ThemeData().accentColor),
                  ),
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  borderSide:
                      BorderSide(color: Colors.indigoAccent, width: 1.3),
                  color: Colors.indigoAccent,
                ),
              ],
            ));
  }
}
