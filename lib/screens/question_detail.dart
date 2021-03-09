import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:letecky_testy/state/state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/widgets/confirmation_flushbar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'my_answers.dart';

class MyQuestionDetailPage extends StatefulWidget {
  MyQuestionDetailPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MyQuestionDetailPageState();
}

Future<String> sendEmail(int questionNumber, int questionCategory,
    String answeredAnswer, String correctAnswer, String userMessage) async {
  String username = emailUsername;
  String password = emailPassword;
  String messageMail;
  final smtpServer = SmtpServer(emailSmtpServer,
      username: username, password: password, port: 465, ssl: true);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()
    ..from = Address(username,
        'Nahlásenie otázky <Letecké testy> #${((DateTime.now().millisecondsSinceEpoch) / 10000).round().toString()}')
    ..recipients.add(username)
    ..subject =
        '[LTReport]Nahlásenie chybnej otázky v čase: ${DateFormat("dd.MM.yyyy, HH:mm").format(DateTime.now())}'
    ..html = "<h2>Používateľ aplikácie nahlásil chybu v otázke číslo $questionNumber</h2>"
        "\n<p>Detaily nahlásenia:<ul><li>Presný čas: ${DateFormat("dd.MM.yyyy, HH:mm:ss").format(DateTime.now())}</li><li>Číslo otázky v DB: $questionNumber</li>"
        "<li>Kategória otázky v DB: $questionCategory</li><li>Používateľova odpoveď: $answeredAnswer</li><li>Správna odpoveď: $correctAnswer</li></ul></p>"
        "<p>Popis od používateľa:</p>\n<p>${userMessage.trim()}</p>";

  try {
    final sendReport = await send(message, smtpServer);
    //print('Message sent: ' + sendReport.toString());
    return messageMail = 'Úspešne odoslané';
  } on MailerException catch (e) {
    print('Message not sent.');
    for (var p in e.problems) {
      //print('Problem: ${p.code}: ${p.msg}\n');
      return messageMail = ('\nChyba: ${p.code}: ${p.msg}\n Správa neodoslaná!');
    }
  }
  return messageMail;
}

class _MyQuestionDetailPageState extends State<MyQuestionDetailPage> {
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AnswerAndQuestionNumber aA =
        ModalRoute.of(context).settings.arguments;
    return Consumer(builder: (context, watch, _) {
      var currentQuestion = watch(userViewQuestionState).state;
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
                  title: Text('Otázka ${aA.questionNumber}'),
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back),
                  ),
                  actions: [
                    IconButton(
                        icon: Icon(Icons.bug_report_outlined),
                        tooltip: "Problém s otázkou?",
                        onPressed: () {
                          showDialog(
                            context: context,
                            useRootNavigator: false,
                            barrierDismissible: true,
                            useSafeArea: true,
                            barrierColor: Colors.black54,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                backgroundColor: Colors.indigo[500],
                                shape: new BeveledRectangleBorder(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    side: BorderSide(
                                        color: Colors.black, width: 1.3)),
                                titlePadding: const EdgeInsets.all(0.0),
                                contentPadding: const EdgeInsets.all(0.0),
                                content: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 10, bottom: 8, left: 11, right: 11),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            'Nahlásenie chybnej otázky',
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold),textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(top: 15)),
                                        Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Divider(
                                            thickness: 2,
                                            height: 1,
                                            endIndent: 2,
                                            indent: 2,
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            'Údaje ktoré sa odošlú vývojárovi:',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Divider(
                                            endIndent: 50,
                                            indent: 50,
                                          ),
                                        ),
                                        Text(
                                            '\u2022 Číslo otázky: ${currentQuestion.questionId} (v databáze)'),
                                        Text(
                                            '\u2022 Číslo kategórie: ${currentQuestion.categoryId.toString()} (v databáze)'),
                                        Text(
                                            '\u2022 Tvoja odpoveď na otázku: ${aA.aA == '' ? 'otázka nezodpovedaná' : aA.aA}'),
                                        Text(
                                            '\u2022 Správna odpoveď na otázku: ${currentQuestion.correctAnswer}'),
                                        Padding(
                                            padding: EdgeInsets.only(top: 15)),
                                        TextField(
                                          controller: myController,
                                          maxLines: 4,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              hintText: 'Vlož popis chyby'),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Divider(
                                            endIndent: 50,
                                            indent: 50,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Divider(
                                            thickness: 2,
                                            height: 1,
                                            endIndent: 2,
                                            indent: 2,
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            'Žiadne tvoje osobné údaje nebudú odoslané (a ani nie sú uložené v aplikácií)',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  OutlineButton(
                                    onPressed: () async {
                                      String messageMail;
                                      messageMail = await sendEmail(
                                          currentQuestion.questionId,
                                          currentQuestion.categoryId,
                                          aA.aA == ''
                                              ? 'otázka nezodpovedaná'
                                              : aA.aA,
                                          currentQuestion.correctAnswer,
                                          myController.text);
                                      Navigator.pop(context);
                                      showConfirmationFlushBar(
                                          context,
                                          "Nahlásenie",
                                          "$messageMail",
                                          2500,
                                          false);
                                      myController.clear();
                                    },
                                    shape: new BeveledRectangleBorder(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10)),
                                        side: BorderSide(
                                            color: Colors.indigoAccent,
                                            width: 1.3)),
                                    child: Text(
                                      'Nahlásiť chybu',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: ThemeData().accentColor),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        }),
                  ],
                ),
                body: SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                                AutoSizeText(
                                  '${currentQuestion.questionText}',
                                  style: TextStyle(fontSize: 19.5, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.left,
                                ),
                                //otazka
                                Visibility(
                                    visible:
                                    (currentQuestion.isImageQuestion == null ||
                                        currentQuestion.isImageQuestion == 0
                                        ? false
                                        : true),
                                    child: Container(
                                      height:
                                      MediaQuery.of(context).size.height / 15 * 3,
                                      child: currentQuestion.isImageQuestion == 0
                                          ? Container()
                                          : GestureDetector(
                                        child: Image.asset(
                                          currentQuestion.questionImage,
                                          fit: BoxFit.contain,
                                        ),
                                        onTap: () {
                                          showDialog(
                                            barrierDismissible: true,
                                            useSafeArea: true,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                child: Container(
                                                  child: PhotoView(
                                                    tightMode: true,
                                                    imageProvider: AssetImage(
                                                        currentQuestion
                                                            .questionImage),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    )),
                                Padding(padding: EdgeInsets.only(top: 15)),
                                Divider(
                                  thickness: 2,
                                  height: 1,
                                  endIndent: 2,
                                  indent: 2,
                                ),
                                Padding(padding: EdgeInsets.only(top: 15)),
                                Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Expanded(
                                          flex: 0,
                                          child: Card(
                                            shape: BeveledRectangleBorder(
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(10),
                                                    bottomRight: Radius.circular(10))),
                                            color: Colors.transparent,
                                            child: ListTile(
                                              title: Text(
                                                '${currentQuestion.answerA}',
                                                style: TextStyle(
                                                  color: ((currentQuestion.correctAnswer ==
                                                      'A' &&
                                                      aA.aA == 'A') ||
                                                      currentQuestion.correctAnswer == 'A')
                                                      ? Colors.green.shade200
                                                      : ((currentQuestion.correctAnswer ==
                                                      'A') !=
                                                      (aA.aA == 'A'))
                                                      ? Colors.deepOrange.shade600
                                                      : Colors.white,
                                                  fontSize: ((currentQuestion.correctAnswer ==
                                                      'A' &&
                                                      aA.aA == 'A') ||
                                                      currentQuestion.correctAnswer == 'A')
                                                      ? 21
                                                      : ((currentQuestion.correctAnswer ==
                                                      'A') !=
                                                      (aA.aA == 'A'))
                                                      ? 20
                                                      : 17.5,
                                                  fontWeight: ((currentQuestion.correctAnswer ==
                                                      'A' &&
                                                      aA.aA == 'A') ||
                                                      currentQuestion.correctAnswer == 'A')
                                                      ? FontWeight.bold
                                                      : ((currentQuestion.correctAnswer ==
                                                      'A') !=
                                                      (aA.aA == 'A'))
                                                      ? FontWeight.w900
                                                      : FontWeight.w400,),
                                              ),
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.indigo[900],
                                                child: Text(
                                                  "A",
                                                  style: TextStyle(
                                                      fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                foregroundColor: Colors.white,
                                              ),
                                              trailing: Transform.scale(
                                                scale: 1.3,
                                                child: Radio(
                                                    activeColor: Colors.indigo[900],
                                                    value: 'A',
                                                    groupValue: aA.aA,
                                                    onChanged: null),
                                              ),
                                            ),
                                          ),),
                                      ),
                                      SizedBox(height: 15,),
                                      Container(
                                        child: Expanded(
                                          flex: 0,
                                          child: Card(
                                            shape: BeveledRectangleBorder(
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(10),
                                                    bottomRight: Radius.circular(10))),
                                            color: Colors.transparent,
                                            child: ListTile(
                                              title: Text(
                                                '${currentQuestion.answerB}',
                                                style: TextStyle(
                                                    color: ((currentQuestion.correctAnswer ==
                                                        'B' &&
                                                        aA.aA == 'B') ||
                                                        currentQuestion.correctAnswer == 'B')
                                                        ? Colors.green.shade200
                                                        : ((currentQuestion.correctAnswer ==
                                                        'B') !=
                                                        (aA.aA == 'B'))
                                                        ? Colors.deepOrange.shade600
                                                        : Colors.white,
                                                    fontSize: ((currentQuestion.correctAnswer ==
                                                        'B' &&
                                                        aA.aA == 'B') ||
                                                        currentQuestion.correctAnswer == 'B')
                                                        ? 21
                                                        : ((currentQuestion.correctAnswer ==
                                                        'B') !=
                                                        (aA.aA == 'B'))
                                                        ? 19
                                                        : 17.5,
                                                    fontWeight: ((currentQuestion.correctAnswer ==
                                                        'B' &&
                                                        aA.aA == 'B') ||
                                                        currentQuestion.correctAnswer == 'B')
                                                        ? FontWeight.bold
                                                        : ((currentQuestion.correctAnswer ==
                                                        'B') !=
                                                        (aA.aA == 'B'))
                                                        ? FontWeight.w900
                                                        : FontWeight.w400),
                                              ),
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.indigo[900],
                                                child: Text(
                                                  "B",
                                                  style: TextStyle(
                                                      fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                foregroundColor: Colors.white,
                                              ),
                                              trailing: Transform.scale(
                                                scale: 1.3,
                                                child: Radio(
                                                    activeColor: Colors.indigo[900],
                                                    value: 'B',
                                                    groupValue: aA.aA,
                                                    onChanged: null),
                                              ),
                                            ),
                                          ),),
                                      ),
                                      SizedBox(height: 15,),
                                      Container(
                                        child: Expanded(
                                          flex: 0,
                                          child: Card(
                                            shape: BeveledRectangleBorder(
                                                borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(10),
                                                    bottomRight: Radius.circular(10))),
                                            color: Colors.transparent,
                                            child: ListTile(
                                              title: Text(
                                                '${currentQuestion.answerC}',
                                                style: TextStyle(
                                                  color: ((currentQuestion.correctAnswer ==
                                                      'C' &&
                                                      aA.aA == 'C') ||
                                                      currentQuestion.correctAnswer == 'C')
                                                      ? Colors.green.shade200
                                                      : ((currentQuestion.correctAnswer ==
                                                      'C') !=
                                                      (aA.aA == 'C'))
                                                      ? Colors.deepOrange.shade600
                                                      : Colors.white,
                                                  fontSize: ((currentQuestion.correctAnswer ==
                                                      'C' &&
                                                      aA.aA == 'C') ||
                                                      currentQuestion.correctAnswer == 'C')
                                                      ? 21
                                                      : ((currentQuestion.correctAnswer ==
                                                      'C') !=
                                                      (aA.aA == 'C'))
                                                      ? 19
                                                      : 17.5,
                                                  fontWeight: ((currentQuestion.correctAnswer ==
                                                      'C' &&
                                                      aA.aA == 'C') ||
                                                      currentQuestion.correctAnswer == 'C')
                                                      ? FontWeight.bold
                                                      : ((currentQuestion.correctAnswer ==
                                                      'C') !=
                                                      (aA.aA == 'C'))
                                                      ? FontWeight.w900
                                                      : FontWeight.w400,),
                                              ),
                                              leading: CircleAvatar(
                                                backgroundColor: Colors.indigo[900],
                                                child: Text(
                                                  "C",
                                                  style: TextStyle(
                                                      fontSize: 20, fontWeight: FontWeight.bold),
                                                ),
                                                foregroundColor: Colors.white,
                                              ),
                                              trailing: Transform.scale(
                                                scale: 1.3,
                                                child: Radio(
                                                    activeColor: Colors.indigo[900],
                                                    value: 'C',
                                                    groupValue: aA.aA,
                                                    onChanged: null),
                                              ),
                                            ),
                                          ),),
                                      )
                                    ],
                                  ),
                                ),
                      ],
                    ))),
          ),
          onWillPop: () async {
            Navigator.pop(context);
            return true;
          });
    });
  }
}
