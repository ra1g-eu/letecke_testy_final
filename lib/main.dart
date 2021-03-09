import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/screens/app_dev.dart';
import 'package:letecky_testy/screens/home_page.dart';
import 'package:letecky_testy/screens/my_tests.dart';
import 'package:letecky_testy/screens/question_detail.dart';
import 'package:letecky_testy/screens/read_mode.dart';
import 'package:letecky_testy/screens/settings_screen.dart';
import 'package:letecky_testy/screens/show_all_mode.dart';
import 'package:letecky_testy/screens/show_result.dart';
import 'package:letecky_testy/screens/test_mode.dart';
import 'package:letecky_testy/screens/my_answers.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const/const.dart';
import 'database/db_helper.dart';

void main() async {
  bool isDeleted;
  var NBC, SBC;
  int NBB;
  //runApp(ProviderScope(child:MyApp()));
  runApp(MaterialApp(
    title: 'Letecké testy PPL(A)',
    home: MySplash(),
  ));
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isDeleted = prefs.getBool(deleteDbAtStart);
  //print("Before IF ${isDeleted}");
  if (isDeleted == null) {
    deleteAllUserAnswersAndDetails();
    prefs.setBool(deleteDbAtStart, false);
  }
  //print("After IF ${isDeleted}");
  if (prefs.getInt(navBarC) == null) NBC = null;
  if (prefs.getInt(navBarB) == null) NBB = null;
  if (prefs.getInt(statusBarC) == null)
    SBC = null;
  else {
    NBC = Color(prefs.getInt(navBarC));
    NBB = prefs.getInt(navBarB);
    SBC = Color(prefs.getInt(statusBarC));
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: NBC == null ? Colors.blue[400] : NBC,
    // navigation bar color
    statusBarColor: SBC == null ? Colors.transparent : SBC,
    // status bar color
    statusBarBrightness: Brightness.light,
    //status bar brigtness
    statusBarIconBrightness: Brightness.light,
    //status b//Navigation bar divider color
    systemNavigationBarIconBrightness: (NBB == null || NBB == 0)
        ? Brightness.light
        : Brightness.dark, //navigation bar icon
  ));
}

void deleteAllUserAnswersAndDetails() async {
  //vymazat UPLNE CELU DATABAZU ODPOVEDI A DETAILOV
  deleteEverythingFromDB();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Letecké testy PPL(A)',
      routes: {
        "/homePage": (context) => MyCategoryPage(title: 'Vyber si kategóriu'),
        "/readMode": (context) => MyReadModePage(),
        "/testMode": (context) => MyTestModePage(),
        "/showResult": (context) => MyResultPage(),
        "/questionDetail": (context) => MyQuestionDetailPage(),
        "/appDev": (context) => MyAppDevPage(title: 'Vývoj aplikácie'),
        "/myTests": (context) => MyTestsPage(title: 'Moje dokončené skúšky'),
        "/myAnswers": (context) => MyAnswersDetailPage(),
        "/mySettings": (context) => MySettingsPage(title: "Nastavenia"),
        "/showAllMode": (context) => MyShowAllModePage(title: "Všetky otázky"),
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF212121),
        accentColor: const Color(0xFF64ffda),
        canvasColor: const Color(0xFF303030),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyCategoryPage(title: 'Letecké testy PPL(A)'),
    );
  }
}

bool isLoading = true;
class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => new _MySplashState();
}

class _MySplashState extends State<MySplash> {
  PackageInfo _packageInfo = PackageInfo(
    version: 'Neznáme',
  );

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void startTimer() {
    int randomLoadNumber;
    Random random = new Random();
    randomLoadNumber = random.nextInt(500) + 500;
    print(randomLoadNumber);
    Timer.periodic(Duration(milliseconds: randomLoadNumber), (t) {
      setState(() {
        isLoading = false; //set loading to false
      });
      t.cancel(); //stops the timer
    });
  }

  @override
  void initState() {
    startTimer();
    _initPackageInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? new Material(
        child: Container(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                  Image(image: AssetImage("assets/images/logo3.png",),fit: BoxFit.contain,height: 125,width: 125,),
                  SizedBox(height: 15,),
                  AutoSizeText("${_packageInfo.appName}", style: TextStyle(fontSize: 25, fontFamily: 'Roboto',color: Colors.white,fontWeight: FontWeight.bold),),
                ],),
                LoadingBouncingGrid.square(
                  backgroundColor: Colors.blue[400],
                  borderColor: Colors.black,
                  inverted: true,
                  size: 70,
                  borderSize:5,
                ),
                Align(alignment: Alignment.bottomCenter, child: AutoSizeText("${_packageInfo.version} #${_packageInfo.buildNumber}",style: TextStyle(color: Colors.white, fontSize: 17),)),
              ],
            )))
        : ProviderScope(child: MyApp());
  }
}
