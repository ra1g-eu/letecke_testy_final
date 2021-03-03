import 'package:auto_size_text/auto_size_text.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boom_menu/flutter_boom_menu.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:letecky_testy/database/category_provider.dart';
import 'package:letecky_testy/database/db_helper.dart';
import 'package:letecky_testy/state/state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/widgets/confirmation_flushbar.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/utils.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MyCategoryPage extends StatefulWidget {
  MyCategoryPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MyCategoryPageState();
}

Future<String> sendEmail(String userMessage) async {
  String username = emailUsername;
  String password = emailPassword;
  String messageMail;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  final PackageInfo info = await PackageInfo.fromPlatform();
  final smtpServer = SmtpServer(emailSmtpServer,
      username: username, password: password, port: 465, ssl: true);
  // Use the SmtpServer class to configure an SMTP server:
  // final smtpServer = SmtpServer('smtp.domain.com');
  // See the named arguments of SmtpServer for further configuration
  // options.

  // Create our message.
  final message = Message()
    ..from = Address(username,
        'Nahlásenie chyby v aplikácii <Letecké testy> #${((DateTime.now().millisecondsSinceEpoch) / 10000).round().toString()}')
    ..recipients.add(username)
    ..subject =
        '[LTReport]Nahlásenie chyby v aplikácii v čase: ${DateFormat("dd.MM.yyyy, HH:mm").format(DateTime.now())}'
    ..html = "<h2>Používateľ aplikácie nahlásil chybu v aplikácií.</h2>"
        "\n<p>Detaily zariadenia:<ul><li>Výrobca: ${androidInfo.manufacturer}</li><li>Značka: ${androidInfo.brand} / Model: ${androidInfo.model} / Board: ${androidInfo.board} / Codename: ${androidInfo.version.codename}</li><li>Verzia androidu: ${androidInfo.version.release}</li><li>Bezpečnostná záplata: ${androidInfo.version.securityPatch}</li>"
        "<li>Hardware: ${androidInfo.hardware}</li></ul>"
        "\n<p>Detaily aplikácie:<ul><li>Verzia: ${info.version}</li><li>Názov appky: ${info.appName} / Číslo zostavy: #${info.buildNumber} / Názov balíka: ${info.packageName}</li></ul>"
        "<p>Popis od používateľa:</p>\n<p><ul><li>${userMessage.trim()}</li></ul></p>";

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

class _MyCategoryPageState extends State<MyCategoryPage> {
  PackageInfo _packageInfo = PackageInfo(
    version: 'Neznáme',
  );
  int _numberOfTests;
  ShapeBorder signatureBorder = new BeveledRectangleBorder(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
      side: BorderSide(color: Colors.black, width: 1.3));

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    final numberOfTestsGlobal = await countNonHiddenTestsInDb();
    setState(() {
      _packageInfo = info;
      _numberOfTests = numberOfTestsGlobal;
    });
  }
  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  List<int> userCategoryID;
  int userNumberOfQuestions;
  double userSelectedTestTime;
  int tag = 0;
  int tagTime = 0;
  int numberOfQ = 5;
  List<String> options = [
    'hidden',
    'Letecké právo a postupy ATC',
    'Všeobecné znalosti o lietadle',
    'Letové výkony lietadla a plánovanie letov',
    'Ľudská výkonnosť a obmedzenia',
    'Meteorológia',
    'Navigácia',
    'Prevádzkové postupy',
    'Základy letu (aerodynamika)',
    'Komunikácia',
    'Všetky kategórie',
  ];
  List<int> multipleCategories = [];
  final StoryController controller = StoryController();
  final myController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return InnerDrawer(
      key: _innerDrawerKey,
      onTapClose: true,
      // default false
      swipe: true,
      // default true
      colorTransitionChild: Colors.indigoAccent.shade700.withOpacity(0.3),
      // default Color.black54
      colorTransitionScaffold: Colors.black54,
      // default Color.black54
      //When setting the vertical offset, be sure to use only top or bottom
      offset: IDOffset.only(bottom: 0, right: 1, left: 1),
      scale: IDOffset.horizontal(1),
      swipeChild: true,
      velocity: 0.1,
      // set the offset in both directions

      proportionalChildArea: true,
      // default true
      borderRadius: 0,
      // default 0
      leftAnimationType: InnerDrawerAnimation.quadratic,
      // default static
      rightAnimationType: InnerDrawerAnimation.quadratic,
      // default  Theme.of(context).backgroundColor

      //when a pointer that is in contact with the screen and moves to the right or left
      onDragUpdate: (double val, InnerDrawerDirection direction) {
        // return values between 1 and 0
        //print(val);
        // check if the swipe is to the right or to the left
        //print(direction==InnerDrawerDirection.start);
      },
      //innerDrawerCallback: (a) => print(a),
      // return  true (open) or false (close)
      leftChild: Container(
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
          body: SafeArea(
            child: FutureBuilder<List<Category>>(
              future: getCategories(),
              builder: (context, snapshot) {
                Future.delayed(
                    Duration.zero, () => showDialogIfFirstLoaded(context));
                if (snapshot.hasError)
                  return Center(
                    child: Text('${snapshot.error}'),
                  );
                else if (snapshot.hasData) {
                  return Container(
                      child: Column(
                    verticalDirection: VerticalDirection.down,
                    children: [
                      Divider(
                        color: Colors.transparent,
                      ),
                      Expanded(
                        child: GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                          padding: const EdgeInsets.all(8.5),
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          children: snapshot.data.map((category) {
                            return Card(
                              margin: EdgeInsets.all(0.5),
                              color: Colors.transparent,
                              elevation: 3,
                              shadowColor: Colors.black54,
                              clipBehavior: Clip.antiAlias,
                              shape: BeveledRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              child: InkWell(
                                splashColor: Colors.indigoAccent,
                                highlightColor: Colors.indigoAccent,
                                onTap: () async {
                                  context.read(questionCategoryState).state =
                                      category;
                                  context.read(isTestMode).state = false;
                                  context.read(isEnableShowAnswer).state =
                                      false;
                                  context.read(isReadMode).state = true;
                                  Navigator.pushNamed(context, "/readMode");
                                },
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                                child: Center(
                                  child: ListTile(
                                    title: AutoSizeText(
                                      '${category.name}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20.5),
                                      maxLines: 10,
                                      softWrap: true,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ));
                } else
                  return Center(
                    child: LoadingBouncingGrid.square(
                      backgroundColor: Colors.indigoAccent,
                      inverted: true,
                      borderColor: Colors.black,
                      size: 60,
                      borderSize: 1,
                      duration: Duration(milliseconds: 1500),
                    ),
                  );
              },
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.indigoAccent,
            child: Icon(Icons.bug_report, color: Colors.white, size: 28),
            elevation: 4,
            highlightElevation: 6,
            tooltip: "Problém s aplikáciou?",
            onPressed: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                barrierColor: Colors.black54,
                barrierDismissible: true,
                useSafeArea: true,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: signatureBorder,
                    titlePadding: const EdgeInsets.all(0.0),
                    contentPadding: const EdgeInsets.all(0.0),
                    backgroundColor: Colors.indigo[500],
                    content: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 10, bottom: 8, left: 11, right: 11),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Nahlásenie chyby',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(top: 15)),
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
                            Text('\u2022 Popis chyby'),
                            Text(
                                '\u2022 Informácie o nainštalovanej aplikácií'),
                            Text(
                                '\u2022 Informácie o zariadení:\n  Model, výrobca, operačný systém, verzia OS.'),
                            Padding(padding: EdgeInsets.only(top: 15)),
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
                          messageMail = await sendEmail(myController.text);
                          Navigator.pop(context);
                          showConfirmationFlushBar(context, "Nahlásenie",
                              "$messageMail", 2500, false);
                          Future.delayed(
                              Duration.zero, () => myController.clear());
                        },
                        shape: new BeveledRectangleBorder(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        borderSide:
                            BorderSide(color: Colors.white38, width: 1.3),
                        child: Text(
                          'Nahlásiť chybu',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      // required if rightChild is not set
      rightChild: Container(
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
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    children: [
                      Divider(
                        color: Colors.transparent,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          heightFactor: 1.2,
                          child: AutoSizeText(
                            'Vytvoriť skúšku',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.greenAccent,
                                letterSpacing: 2,
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
                                ]),
                            softWrap: true,
                            wrapWords: true,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black54,
                        thickness: 2,
                        height: 2,
                        indent: 15,
                        endIndent: 15,
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        child: new AutoSizeText(
                          "Kategória",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Wrap(
                        children: [
                          ChipsChoice<int>.multiple(
                            wrapped: true,
                            value: multipleCategories,
                            onChanged: (val) => setState(() {
                              multipleCategories = val;
                            }),
                            choiceItems: C2Choice.listFrom<int, String>(
                              source: options,
                              value: (i, v) => i,
                              label: (i, v) => v,
                              hidden: (i, v) => [0].contains(i),
                            ),
                            choiceStyle: C2ChoiceStyle(
                              borderShape: BeveledRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              borderColor: Colors.black,
                              clipBehavior: Clip.antiAlias,
                              pressElevation: 6,
                              labelStyle: TextStyle(
                                  fontSize: 16.5,
                                  letterSpacing: -0.3,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.normal),
                              borderWidth: 10,
                              padding: EdgeInsets.all(7),
                              elevation: 3,
                              margin: const EdgeInsets.all(2),
                              color: Colors.indigo[600],
                              brightness: Brightness.dark,
                            ),
                            choiceActiveStyle: C2ChoiceStyle(
                              borderShape: BeveledRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              borderColor: Colors.black,
                              labelStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800),
                              borderWidth: 10,
                              showCheckmark: true,
                              clipBehavior: Clip.antiAlias,
                              padding: EdgeInsets.all(8),
                              elevation: 6,
                              color: Colors.indigo[900],
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(8)),
                      Divider(
                        color: Colors.black54,
                        thickness: 2,
                        height: 2,
                        indent: 15,
                        endIndent: 15,
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        child: new Text(
                          "Počet otázok",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Wrap(
                        children: [
                          ChipsChoice<int>.single(
                            wrapped: true,
                            value: numberOfQ,
                            onChanged: (val) => setState(() {
                              numberOfQ = val;
                              print("TAG Otazka: " +
                                  numberOfQ.toString() +
                                  "| VAL Otazka: " +
                                  numberOfQ.toString());
                            }),
                            choiceItems: <C2Choice<int>>[
                              C2Choice<int>(value: 5, label: '5'),
                              C2Choice<int>(value: 10, label: '10'),
                              C2Choice<int>(value: 15, label: '15'),
                              C2Choice<int>(value: 20, label: '20'),
                              C2Choice<int>(value: 25, label: '25'),
                              C2Choice<int>(value: 30, label: '30'),
                              C2Choice<int>(value: 35, label: '35'),
                              C2Choice<int>(value: 40, label: '40'),
                              C2Choice<int>(value: 45, label: '45'),
                              C2Choice<int>(value: 50, label: '50'),
                              C2Choice<int>(value: 55, label: '55'),
                              C2Choice<int>(value: 60, label: '60'),
                              C2Choice<int>(value: 70, label: '70'),
                              C2Choice<int>(value: 80, label: '80'),
                              C2Choice<int>(value: 90, label: '90'),
                              C2Choice<int>(value: 100, label: '100'),
                              C2Choice<int>(value: 110, label: '110'),
                              C2Choice<int>(value: 120, label: '120'),
                            ],
                            choiceStyle: C2ChoiceStyle(
                              borderShape: BeveledRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              borderColor: Colors.black,
                              clipBehavior: Clip.antiAlias,
                              pressElevation: 6,
                              labelStyle: TextStyle(
                                  fontSize: 16.5,
                                  letterSpacing: -0.3,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.normal),
                              borderWidth: 10,
                              padding: EdgeInsets.all(7),
                              elevation: 3,
                              margin: const EdgeInsets.all(2),
                              color: Colors.indigo[600],
                              brightness: Brightness.dark,
                            ),
                            choiceActiveStyle: C2ChoiceStyle(
                              borderShape: BeveledRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              borderColor: Colors.black,
                              labelStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800),
                              borderWidth: 10,
                              showCheckmark: true,
                              clipBehavior: Clip.antiAlias,
                              padding: EdgeInsets.all(8),
                              elevation: 6,
                              color: Colors.indigo[900],
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(8)),
                      Divider(
                        color: Colors.black54,
                        thickness: 2,
                        height: 2,
                        indent: 15,
                        endIndent: 15,
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        child: new Column(
                          children: [
                            Text(
                              "Čas skúšky",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              tagTime == 0
                                  ? "Dynamický čas: 1 otázka = 72 sekúnd"
                                  : "Fixný čas: ${tagTime.toString()} minút",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        children: [
                          ChipsChoice<int>.single(
                            wrapped: true,
                            value: tagTime,
                            onChanged: (val) => setState(() {
                              tagTime = val;
                            }),
                            choiceItems: <C2Choice<int>>[
                              C2Choice<int>(
                                  value: 0,
                                  label:
                                      '${(numberOfQ * 1.2).toStringAsFixed(0)} minút'),
                              C2Choice<int>(value: 5, label: '5 minút'),
                              C2Choice<int>(value: 15, label: '15 minút'),
                              C2Choice<int>(value: 50, label: '50 minút'),
                              C2Choice<int>(value: 75, label: '75 minút'),
                              C2Choice<int>(value: 90, label: '90 minút'),
                              C2Choice<int>(value: 150, label: '150 minút'),
                            ],
                            choiceStyle: C2ChoiceStyle(
                              borderShape: BeveledRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              borderColor: Colors.black,
                              clipBehavior: Clip.antiAlias,
                              pressElevation: 6,
                              labelStyle: TextStyle(
                                  fontSize: 16.5,
                                  letterSpacing: -0.3,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.normal),
                              borderWidth: 10,
                              padding: EdgeInsets.all(7),
                              elevation: 3,
                              margin: const EdgeInsets.all(2),
                              color: Colors.indigo[600],
                              brightness: Brightness.dark,
                            ),
                            choiceActiveStyle: C2ChoiceStyle(
                              borderShape: BeveledRectangleBorder(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10))),
                              borderColor: Colors.black,
                              labelStyle: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800),
                              borderWidth: 10,
                              showCheckmark: true,
                              clipBehavior: Clip.antiAlias,
                              padding: EdgeInsets.all(8),
                              elevation: 6,
                              color: Colors.indigo[900],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.check, color: Colors.black, size: 28),
            elevation: 4,
            highlightElevation: 6,
            tooltip: "Spustiť skúšku",
            onPressed: () async {
              if (multipleCategories.length == 0)
                return showConfirmationFlushBar(
                    context, "Chyba", "Vyber si kategóriu.", 1700, false);
              if (multipleCategories.length > 2 ||
                  multipleCategories.length < 1)
                return showConfirmationFlushBar(context, "Chyba",
                    "Vybrať si môžeš 1 alebo 2 kategórie.", 1700, false);
              if (multipleCategories.length > 1 &&
                  (multipleCategories.first == 10 ||
                      multipleCategories.last == 10))
                return showConfirmationFlushBar(
                    context,
                    "Chyba",
                    "Všetky kategórie môžeš vybrať len samostatne.",
                    1700,
                    false);

              print(
                  'spustit skusku ${multipleCategories.length} $multipleCategories');
              userCategoryID = multipleCategories;
              userSelectedTestTime = tagTime == 0
                  ? ((numberOfQ * 1.2) * 60)
                  : ((tagTime * 1.0) * 60);
              userNumberOfQuestions = numberOfQ;
              if (userCategoryID != null &&
                  userNumberOfQuestions != null &&
                  userSelectedTestTime != null) {
                context.read(isEnableShowAnswer).state = false;
                context.read(isReadMode).state = false;
                context.read(isTestMode).state = true;
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/testMode",
                    arguments: UserTestModeInfo(userCategoryID,
                        userNumberOfQuestions, userSelectedTestTime));
              }
            },
          ),
        ),
      ),
      // required if leftChild is not set

      //  A Scaffold is generally used but you are free to use other widgets
      // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar

      scaffold: Container(
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
          body: SafeArea(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (OverscrollIndicatorNotification overScroll) {
                overScroll.disallowGlow();
                return false;
              },
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Divider(
                      color: Colors.transparent,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.86,
                      child: ListView(
                        padding: EdgeInsets.all(4),
                        children: [
                          Image(
                            image: AssetImage(
                              "assets/images/logo_test.png",
                            ),
                            fit: BoxFit.scaleDown,
                            width: 360,
                            height: 125,
                          ),
                          Divider(
                            color: Colors.transparent,
                          ),
                          Card(
                            color: Colors.transparent,
                            elevation: 3,
                            shadowColor: Colors.black54,
                            clipBehavior: Clip.antiAlias,
                            shape: BeveledRectangleBorder(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: InkWell(
                              splashColor: Colors.indigoAccent,
                              highlightColor: Colors.indigoAccent,
                              onTap: () {
                                _innerDrawerKey.currentState.toggle(
                                    direction: InnerDrawerDirection.end);
                              },
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              child: Column(
                                children: [
                                  ListTile(
                                    trailing: Image.asset(
                                      'assets/images/logo3.png',
                                      height: 40,
                                      width: 40,
                                    ),
                                    leading: Text(
                                      'Vytvoriť skúšku',
                                      style: TextStyle(
                                          fontSize: 27,
                                          color: Colors.greenAccent,
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                                // bottomLeft
                                                offset: Offset(-1.5, -1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // bottomRight
                                                offset: Offset(1.5, -1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // topRight
                                                offset: Offset(1.5, 1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // topLeft
                                                offset: Offset(-1.5, 1.5),
                                                color: Colors.black),
                                          ]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Môžeš si vytvoriť vlastnú skúšku (potiahnutím doľava alebo kliknutím sem), kde si vyberieš kategóriu, počet otázok a čas.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.transparent,
                            elevation: 3,
                            shadowColor: Colors.black54,
                            clipBehavior: Clip.antiAlias,
                            shape: BeveledRectangleBorder(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: InkWell(
                              splashColor: Colors.indigoAccent,
                              highlightColor: Colors.indigoAccent,
                              onTap: () {
                                _innerDrawerKey.currentState.toggle(
                                    direction: InnerDrawerDirection.start);
                              },
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ListTile(
                                    trailing: FaIcon(FontAwesomeIcons.lightbulb,
                                        size: 30),
                                    leading: const Text(
                                      'Precvičiť vedomosti',
                                      style: TextStyle(
                                          fontSize: 27,
                                          color: Colors.amber,
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                                // bottomLeft
                                                offset: Offset(-1.5, -1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // bottomRight
                                                offset: Offset(1.5, -1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // topRight
                                                offset: Offset(1.5, 1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // topLeft
                                                offset: Offset(-1.5, 1.5),
                                                color: Colors.black),
                                          ]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Predtým ako začneš skúšku si môžeš precvičiť svoje vedomosti zo všetkých dostupných kategórií kliknutím sem alebo potiahnutím doprava.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            color: Colors.transparent,
                            elevation: 3,
                            shadowColor: Colors.black54,
                            clipBehavior: Clip.antiAlias,
                            shape: BeveledRectangleBorder(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: InkWell(
                              splashColor: Colors.indigoAccent,
                              highlightColor: Colors.indigoAccent,
                              onTap: () {
                                context.read(isReadMode).state = true;
                                context.read(isEnableShowAnswer).state = false;
                                context.read(isTestMode).state = false;
                                Navigator.pushNamed(context, "/showAllMode");
                              },
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ListTile(
                                    trailing: FaIcon(
                                        FontAwesomeIcons.wpexplorer,
                                        size: 30),
                                    leading: const Text(
                                      'Preskúmať otázky',
                                      style: TextStyle(
                                          fontSize: 27,
                                          color: Colors.yellowAccent,
                                          fontWeight: FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                                // bottomLeft
                                                offset: Offset(-1.5, -1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // bottomRight
                                                offset: Offset(1.5, -1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // topRight
                                                offset: Offset(1.5, 1.5),
                                                color: Colors.black),
                                            Shadow(
                                                // topLeft
                                                offset: Offset(-1.5, 1.5),
                                                color: Colors.black),
                                          ]),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'Ak si nevieš vybrať jednu z kategórií, tak tu môžeš preskúmať vyše 900 otázok a to všetko na jednom mieste.',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              enabled: false,
                              title: Center(
                                  child: Text(
                                _packageInfo.version +
                                    "#" +
                                    _packageInfo.buildNumber.toString(),
                                style: TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.normal),
                              )),
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 16.0),
                              selected: false,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: BoomMenu(
            animatedIcon: AnimatedIcons.menu_close,
            animatedIconTheme: IconThemeData(size: 28.0),
            //child: Icon(Icons.add),
            onClose: () => print('DIAL CLOSED'),
            overlayColor: Colors.black,
            backgroundColor: Colors.indigoAccent,
            foregroundColor: Colors.white,
            overlayOpacity: 0.75,
            children: [
              MenuItem(
                child: (_numberOfTests == 0 || _numberOfTests == null)
                    ? Icon(Icons.history, color: Colors.black, size: 32)
                    : CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Text(
                          _numberOfTests.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        foregroundColor: Colors.white,
                        radius: (_numberOfTests <= 99 || _numberOfTests == null)
                            ? 15
                            : 20,
                      ),
                title: (_numberOfTests == 0 || _numberOfTests == null)
                    ? "Skúšky (zatiaľ žiadne)"
                    : "Moje skúšky",
                titleColor: Colors.white,
                subtitle: "Pozri si všetky dokončené skúšky",
                subTitleColor: Colors.white,
                backgroundColor: Colors.indigo.shade600,
                onTap: () async {
                  return _numberOfTests == 0 || _numberOfTests == null
                      ? false
                      : Navigator.pushNamed(context, "/myTests");
                },
              ),
              MenuItem(
                child: Icon(Icons.settings, color: Colors.black, size: 32),
                title: "Nastavenia",
                titleColor: Colors.white,
                subtitle: "Prispôsob si aplikáciu podľa seba",
                subTitleColor: Colors.white,
                backgroundColor: Colors.indigo.shade500,
                onTap: () => Navigator.pushNamed(context, "/mySettings"),
              ),
              MenuItem(
                child: Icon(Icons.track_changes, color: Colors.black, size: 32),
                title: "Zmeny v aplikácií",
                titleColor: Colors.white,
                subtitle: "Všetky predošlé aktualizácie",
                subTitleColor: Colors.white,
                backgroundColor: Colors.indigo.shade400,
                onTap: () => Navigator.pushNamed(context, "/appDev"),
              ),
              MenuItem(
                child: Icon(Icons.web, color: Colors.black, size: 32),
                title: "Webstránka",
                titleColor: Colors.white,
                subtitle: "Odkaz na oficiálnu webstránku",
                subTitleColor: Colors.white,
                backgroundColor: Colors.indigo.shade300,
                onTap: () async {
                  const url = 'https://lt.ra1g.eu';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Odkaz nenájdený: $url';
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  Future<List<Category>> getCategories() async {
    var db = await copyDB();
    var result = await CategoryProvider().getCategories(db);
    context.read(categoryListProvider).state = result;
    return result;
  }

  showDialogIfFirstLoaded(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLoaded = prefs.getBool(keyIsFirstLoaded);
    if (isFirstLoaded == null) {
      return showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return Material(
                  child: StoryView(
                controller: controller,
                storyItems: [
                  StoryItem.text(
                    title:
                        "Vitaj!\n\n\n\n V nasledujúcich storkách zistíš čo sa naučíš používaním aplikácie.\n\nPokračuj ťuknutím.",
                    backgroundColor: Colors.lightBlue,
                    roundedTop: false,
                    textStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                    duration: Duration(seconds: 5),
                  ),
                  StoryItem.text(
                    title:
                        "\u2022 získaš nové ale aj si precvičíš staré vedomosti o lietaní súkromnými lietadlami",
                    backgroundColor: Colors.lightBlue.shade400,
                    roundedTop: false,
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    duration: Duration(seconds: 5),
                  ),
                  StoryItem.text(
                    title:
                        "\u2022 zlepšíš si svoje navigačné schopnosti pri zlých podmienkach",
                    backgroundColor: Colors.lightBlue.shade500,
                    roundedTop: false,
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    duration: Duration(seconds: 5),
                  ),
                  StoryItem.text(
                    title:
                        "\u2022 budeš vedieť ako a kedy komunikovať s ostatnými na oblohe",
                    backgroundColor: Colors.lightBlue.shade600,
                    roundedTop: false,
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    duration: Duration(seconds: 5),
                  ),
                  StoryItem.text(
                    title:
                        "\u2022 získaš lepší prehľad o tom, ako sa zachovať, keď sa zhorší počasie",
                    backgroundColor: Colors.lightBlue.shade700,
                    roundedTop: false,
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    duration: Duration(seconds: 5),
                  ),
                  StoryItem.text(
                    title:
                        "\u2022 základy letu a aerodynamika ťa už nikdy nezaskočia nepripraveného",
                    backgroundColor: Colors.lightBlue.shade800,
                    roundedTop: false,
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    duration: Duration(seconds: 5),
                  ),
                  StoryItem.text(
                    title: "a kopa ďalšieho.",
                    backgroundColor: Colors.lightBlue.shade900,
                    roundedTop: false,
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.normal),
                    duration: Duration(seconds: 3),
                  ),
                  StoryItem.text(
                    title: "Poďme na to!",
                    backgroundColor: Colors.lightBlue.shade900,
                    roundedTop: false,
                    textStyle: TextStyle(
                        fontSize: 25,
                        color: Colors.black,
                        fontWeight: FontWeight.w300),
                    duration: Duration(seconds: 3),
                  ),
                ],
                onComplete: () {
                  prefs.setBool(keyIsFirstLoaded, false);
                  Navigator.of(context).pop();
                },
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    prefs.setBool(keyIsFirstLoaded, false);
                    Navigator.pop(context);
                  }
                },
                progressPosition: ProgressPosition.top,
                repeat: false,
                inline: false,
              ));
            });
          });
    }
  }
}

class UserTestModeInfo {
  final List<int> userCategoryID;
  final int userNumberOfQuestions;
  final double userSelectedTestTime;

  UserTestModeInfo(this.userCategoryID, this.userNumberOfQuestions,
      this.userSelectedTestTime);
}
