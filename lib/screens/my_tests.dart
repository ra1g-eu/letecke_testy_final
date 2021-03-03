import 'dart:async';
import 'dart:ui';
import 'package:another_flushbar/flushbar.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:letecky_testy/database/db_helper.dart';
import 'package:letecky_testy/database/useranswer_provider.dart';
import 'package:letecky_testy/database/useranswerdetail_provider.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyTestsPage extends StatefulWidget {
  MyTestsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MyTestsPageState();
}

Future<List<UserAnswers>> fetchUAfromDB() async {
  Future<List<UserAnswers>> ua = getUA();
  return ua;
}

Future<List<UserAnswersDetail>> fetchUADetailsfromDB(int answers) async {
  Future<List<UserAnswersDetail>> ua = getUADetailsById(answers);
  return ua;
}

void hideUserAnswers(int id) async {
  //schovat LEN JEDNU ODPOVED BEZ DETAILOV
  hideUAbyId(id);
}

void deleteAllUserAnswersAndDetails() async {
  //vymazat UPLNE CELU DATABAZU ODPOVEDI A DETAILOV
  deleteEverythingFromDB();
}

class _MyTestsPageState extends State<MyTestsPage> {
bool _isDel;
  @override
  void initState() {
    _isDel = false;
    super.initState();
  }

  showTestsTip(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTimeTestsTipShown = prefs.getBool(showFirstTimeTestsTip);
    if (isFirstTimeTestsTipShown == null) {
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
            prefs.setBool(showFirstTimeTestsTip, false);
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
          "Kliknutím na skúšku v zozname zobrazíš viac možností.",
          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
        ),
      )..show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: new Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.delete_forever_outlined),
              tooltip: 'Vymazať skúšky',
              onPressed: () {
                showDialog(
                    context: context,
                    barrierColor: Colors.black54,
                    useRootNavigator: false,
                    builder: (_) => new AlertDialog(
                      backgroundColor: Colors.indigo[500],
                          shape: new BeveledRectangleBorder(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              side:
                                  BorderSide(color: Colors.black, width: 1.3)),
                          elevation: 5,
                          title: Text('Vymazanie'),
                          content: Text(
                              'Naozaj chceš vymazať všetky skúšky? Táto akcia je nenávratná!'),
                          actions: [
                            OutlineButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // zatvoriť dialogove okno
                                },
                                child: Text(
                                  'Nie',
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.normal),
                                ),
                                shape: new BeveledRectangleBorder(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)))),
                            OutlineButton(
                              onPressed: () {
                                deleteAllUserAnswersAndDetails();
                                Navigator.of(context).pop();
                                setState(() {
                                  _isDel = true;
                                });
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
                              borderSide: BorderSide(
                                  color: Colors.indigoAccent, width: 1.3),
                            ),
                          ],
                        ));
              },
            ),
          ],
        ),
        body: new Container(
          padding: new EdgeInsets.all(2.0),
          child: new FutureBuilder<List<UserAnswers>>(
            future: fetchUAfromDB(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 0) {
                  Future.delayed(Duration.zero, () => showTestsTip(context));
                }
                return ListView.separated(
                  shrinkWrap: true,
                  reverse: false,
                  itemCount: snapshot.data.length,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 1.0,
                      color: Colors.transparent,
                    );
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: ExpansionTileCard(
                        baseColor: Colors.blue[900].withOpacity(0.7),
                        expandedColor: Colors.blue[900],
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo[900],
                          child: Text(
                            (snapshot.data.length - index).toString() + ".",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        title: Text(snapshot.data[index].date,
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 23)),
                        children: <Widget>[
                          Divider(
                            thickness: 1.0,
                            height: 1.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 10.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Výsledok skúšky:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 21),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Počet otázok:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 21),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Správne odpovede:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 21),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Nesprávne odpovede:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 21),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "${snapshot.data[index].score}%",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 21),
                                              textAlign: TextAlign.left,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "${snapshot.data[index].allAnswers.toString()}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 21),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "${snapshot.data[index].correctAnswers.toString()}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 21),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "${snapshot.data[index].wrongAnswers.toString()}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 21),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                              ],),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            buttonHeight: 52.0,
                            buttonMinWidth: 90.0,
                            children: <Widget>[
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                                onPressed: () {
                                  Navigator.pushNamed(context, "/myAnswers",
                                      arguments: AnswerID(
                                          snapshot.data[index].idanswers,
                                          snapshot.data[index].wrongAnswers,
                                          snapshot.data[index].correctAnswers,
                                          snapshot.data[index].emptyAnswers,
                                          snapshot.data[index].allAnswers,
                                          snapshot.data[index].date,
                                          snapshot.data[index].score));
                                },
                                child: Column(
                                  children: <Widget>[
                                    const Icon(Icons.info_outline, size: 30),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0),
                                    ),
                                    Text('Detaily'),
                                  ],
                                ),
                              ),
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                                onPressed: () {
                                  Flushbar(
                                    flushbarPosition: FlushbarPosition.BOTTOM,
                                    flushbarStyle: FlushbarStyle.FLOATING,
                                    reverseAnimationCurve: Curves.decelerate,
                                    forwardAnimationCurve:
                                        Curves.fastLinearToSlowEaseIn,
                                    backgroundColor: Colors.black12,
                                    blockBackgroundInteraction: true,
                                    boxShadows: [
                                      BoxShadow(
                                          color: Colors.black87,
                                          offset: Offset(0.0, 2.0),
                                          blurRadius: 1.0)
                                    ],
                                    leftBarIndicatorColor: Colors.indigoAccent,
                                    isDismissible: true,
                                    dismissDirection:
                                        FlushbarDismissDirection.HORIZONTAL,
                                    duration: Duration(seconds: 3),
                                    mainButton: OutlineButton(
                                      onPressed: () {
                                        setState(() {
                                          _isDel = true;
                                        });
                                        print("flushBar onPressed idanswers: " +
                                            (snapshot.data[index].idanswers)
                                                .toString());
                                        Navigator.of(context).pop();
                                        hideUserAnswers(
                                            snapshot.data[index].idanswers);
                                      },
                                      child: Icon(
                                        Icons.check_outlined,
                                        size: 50,
                                        color: ThemeData().accentColor,
                                      ),
                                      shape: new BeveledRectangleBorder(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomRight:
                                                  Radius.circular(10))),
                                      borderSide: BorderSide(
                                          color: Colors.indigoAccent,
                                          width: 1.3),
                                    ),
                                    titleText: Text(
                                      "Vymazanie",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22,
                                          color: Colors.white),
                                    ),
                                    messageText: Text(
                                      "Vymazať skúšku zo zoznamu?",
                                      style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 18),
                                    ),
                                  )..show(context);
                                },
                                child: Column(
                                  children: <Widget>[
                                    Icon(Icons.delete_forever, color: Colors.red.shade900, size: 30),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0),
                                    ),
                                    Text('Vymazať', style: TextStyle(color: Colors.red.shade900)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return new Text("${snapshot.error}");
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

class AnswerID {
  final int answerID;
  final int wrongAnswers;
  final int correctAnswers;
  final int emptyAnswers;
  final int allAnswers;
  final String date;
  final String score;

  AnswerID(this.answerID, this.wrongAnswers, this.correctAnswers,
      this.emptyAnswers, this.allAnswers, this.date, this.score);
}
