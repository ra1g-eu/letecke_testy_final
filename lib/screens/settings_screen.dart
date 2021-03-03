import 'dart:ui';
import 'package:chips_choice/chips_choice.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letecky_testy/const/const.dart';
import 'package:letecky_testy/database/db_helper.dart';
import 'package:letecky_testy/widgets/confirmation_flushbar.dart';
import 'package:o_color_picker/o_color_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MySettingsPage extends StatefulWidget {
  MySettingsPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage> {
  Color pickerColorStatus = Colors.transparent;
  Color pickerColorNav = Colors.blue[400];
  Color currentColor = Colors.blue[400];
  var statusBarIconSelected;
  var statusBarTextSelected;
  var navBarIconSelected;
  int navBarIconBrightness = 0;
  int statusBarIconBrightness = 0;
  int statusBarTextBrightness = 0;
  bool isDeleteFromDb = false;

  Future<Color> getNBCfromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(navBarC) == null
        ? Colors.blue[400]
        : Color(prefs.getInt(navBarC));
  }

  Future<Color> getSBCfromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(statusBarC) == null
        ? Colors.transparent
        : Color(prefs.getInt(statusBarC));
  }

  Future<int> getNBBfromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(navBarB) == null ? 0 : 1;
  }

// ValueChanged<Color> callback
  void changeColorStatusBar(Color color) {
    setState(() => pickerColorStatus = color);
  }

  void changeColorNavBar(Color color) {
    setState(() => pickerColorNav = color);
  }

  void deleteAllUserAnswersAndDetails() async {
    //vymazat UPLNE CELU DATABAZU ODPOVEDI A DETAILOV
    deleteEverythingFromDB();
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
              title: Text(widget.title),
              leading: GestureDetector(
                onTap: () {
                  if (isDeleteFromDb == true) {
                    isDeleteFromDb = false;
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, "/homePage");
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Icon(Icons.arrow_back),
              ),
            ),
            body: StatefulBuilder(
              builder: (context, setState) {
                return ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: ExpansionTileCard(
                        baseColor: Colors.blue[900].withOpacity(0.7),
                        expandedColor: Colors.blue[900],
                        leading: Icon(
                          Icons.save_alt_outlined,
                          size: 30,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Uložené preferencie",
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.normal),
                        ),
                        children: <Widget>[
                          Divider(
                            thickness: 1.0,
                            height: 1.0,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                  'Uložené preferencie môžu byť:\n\n\u2022 vyskakovacie okná s tipmi\n\u2022 úvodná obrazovka s oboznámením sa s aplikáciou\n\nVymazaním sa znova zobrazia.\nUložením sa skryjú.',
                                  style: TextStyle(fontSize: 18.0)),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            buttonHeight: 52.0,
                            buttonMinWidth: 90.0,
                            children: <Widget>[
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('is_first_loaded', null);
                                  prefs.setBool('show_home_page_tip', null);
                                  prefs.setBool(
                                      'show_first_time_answers_tip', null);
                                  prefs.setBool(
                                      'show_first_time_tests_tip', null);
                                  prefs.setBool(
                                      'show_first_time_question_detail_tip',
                                      null);
                                  showConfirmationFlushBar(context,
                                      "Preferencie", "Úspešne vymazané.");
                                },
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.delete_forever,
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    ),
                                    Text(
                                      'Vymazať',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setBool('is_first_loaded', false);
                                  prefs.setBool('show_home_page_tip', false);
                                  prefs.setBool(
                                      'show_first_time_answers_tip', false);
                                  prefs.setBool(
                                      'show_first_time_tests_tip', false);
                                  prefs.setBool(
                                      'show_first_time_question_detail_tip',
                                      false);
                                  showConfirmationFlushBar(context,
                                      "Preferencie", "Úspešne uložené.");
                                },
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.save,
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    ),
                                    Text(
                                      'Uložiť',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1.2,
                      thickness: 0.5,
                      color: Colors.transparent,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: ExpansionTileCard(
                        baseColor: Colors.blue[900].withOpacity(0.7),
                        expandedColor: Colors.blue[900],
                        leading: Icon(
                          Icons.delete_forever,
                          size: 30,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Uložené skúšky",
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.normal),
                        ),
                        children: <Widget>[
                          Divider(
                            thickness: 1.0,
                            height: 1.0,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                  'Vymazaním všetkých uložených skúšok sa všetky údaje stratia natrvalo a nebude ich možné obnoviť.',
                                  style: TextStyle(fontSize: 18.0)),
                            ),
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
                                  showDialog(
                                      context: context,
                                      useRootNavigator: false,
                                      builder: (_) => new AlertDialog(
                                            title: Text('Vymazať'),
                                            content:
                                                Text('Vymazať všetky skúšky?'),
                                            actions: [
                                              OutlineButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  'Nie',
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                                shape: new BeveledRectangleBorder(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10))),
                                                color: Colors.indigoAccent,
                                              ),
                                              OutlineButton(
                                                onPressed: () async {
                                                  deleteAllUserAnswersAndDetails();
                                                  isDeleteFromDb = true;
                                                  Navigator.of(context).pop();
                                                  showConfirmationFlushBar(
                                                      context,
                                                      "Skúšky",
                                                      "Úspešne vymazané.",
                                                      1600,
                                                      false);
                                                },
                                                child: Text(
                                                  'Áno',
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: ThemeData()
                                                          .accentColor),
                                                ),
                                                shape: new BeveledRectangleBorder(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10))),
                                                borderSide: BorderSide(
                                                    color: Colors.indigoAccent,
                                                    width: 1.3),
                                                color: Colors.indigoAccent,
                                              ),
                                            ],
                                          ));
                                },
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.delete_forever,
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    ),
                                    Text(
                                      'Vymazať',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1.2,
                      thickness: 0.5,
                      color: Colors.transparent,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6),
                      child: ExpansionTileCard(
                        baseColor: Colors.blue[900].withOpacity(0.7),
                        expandedColor: Colors.blue[900],
                        leading: Icon(
                          Icons.format_color_fill,
                          size: 30,
                          color: Colors.white,
                        ),
                        title: Text(
                          "Zmeniť farby",
                          style: TextStyle(
                              fontSize: 23, fontWeight: FontWeight.normal),
                        ),
                        children: <Widget>[
                          Divider(
                            thickness: 1.0,
                            height: 1.0,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Text(
                                  'Môžeš zmeniť farbu nasledovným:\n\n\u2022 farba navigačného baru (dole)\n\u2022 farba stavovej lišty (hore)\n\u2022 svetlosť ikon navigačného baru',
                                  style: TextStyle(fontSize: 18.0)),
                            ),
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            buttonHeight: 52.0,
                            buttonMinWidth: 90.0,
                            children: <Widget>[
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                                onPressed: () async {
                                  Color nBColor = await getNBCfromPrefs();
                                  Color sBColor = await getSBCfromPrefs();
                                  int nBb = await getNBBfromPrefs();
                                  pickerColorNav = nBColor;
                                  pickerColorStatus = sBColor;
                                  navBarIconBrightness = nBb;
                                  showDialog(
                                    context: context,
                                    useRootNavigator: false,
                                    barrierDismissible: true,
                                    useSafeArea: true,
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return AlertDialog(
                                          shape: new BeveledRectangleBorder(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10)),
                                              side: BorderSide(
                                                  color: Colors.black,
                                                  width: 1.3)),
                                          titlePadding:
                                              const EdgeInsets.all(0.0),
                                          contentPadding:
                                              const EdgeInsets.all(0.0),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Center(
                                                    heightFactor: 2.5,
                                                    child: Text(
                                                        'Farba stavovej lišty',
                                                        style: TextStyle(
                                                            fontSize: 20.0))),
                                                FlatButton(
                                                  color: sBColor,
                                                  textColor: Colors.black,
                                                  child: Text('Vyber farbu'),
                                                  onPressed: () =>
                                                      showDialog<void>(
                                                    useRootNavigator: false,
                                                    barrierDismissible: true,
                                                    barrierColor:
                                                        Colors.black45,
                                                    context: context,
                                                    builder: (_) => Material(
                                                      elevation: 3,
                                                      color: Colors.transparent,
                                                      child: Center(
                                                        child: OColorPicker(
                                                            selectedColor:
                                                                pickerColorStatus,
                                                            colors:
                                                                accentColorsPalette,
                                                            onColorChange:
                                                                (color) {
                                                              setState(() {
                                                                pickerColorStatus =
                                                                    color;
                                                                sBColor = color;
                                                              });
                                                            }),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Divider(
                                                  thickness: 1.5,
                                                ),
                                                Center(
                                                    heightFactor: 2.5,
                                                    child: Text(
                                                        'Farba navigácie',
                                                        style: TextStyle(
                                                            fontSize: 20.0))),
                                                FlatButton(
                                                  color: nBColor,
                                                  textColor: Colors.black,
                                                  child: Text('Vyber farbu'),
                                                  onPressed: () =>
                                                      showDialog<void>(
                                                    useRootNavigator: false,
                                                    barrierDismissible: true,
                                                    barrierColor:
                                                        Colors.black45,
                                                    context: context,
                                                    builder: (_) => Material(
                                                      elevation: 3,
                                                      color: Colors.transparent,
                                                      child: Center(
                                                        child: OColorPicker(
                                                            selectedColor:
                                                                pickerColorNav,
                                                            colors:
                                                                primaryColorsPalette,
                                                            onColorChange:
                                                                (color) {
                                                              setState(() {
                                                                pickerColorNav =
                                                                    color;
                                                                nBColor = color;
                                                              });
                                                            }),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Divider(
                                                  thickness: 1.5,
                                                ),
                                                Center(
                                                    heightFactor: 2.5,
                                                    child: Text(
                                                        'Svetlé ikony navigácie?',
                                                        style: TextStyle(
                                                            fontSize: 20.0))),
                                                Wrap(
                                                  children: [
                                                    ChipsChoice<int>.single(
                                                      wrapped: false,
                                                      value: nBb,
                                                      onChanged: (val) =>
                                                          setState(() {
                                                        navBarIconBrightness =
                                                            val;
                                                        nBb = val;
                                                        print(
                                                            navBarIconBrightness);
                                                      }),
                                                      choiceItems: <
                                                          C2Choice<int>>[
                                                        C2Choice<int>(
                                                            value: 0,
                                                            label: 'Áno'),
                                                        C2Choice<int>(
                                                            value: 1,
                                                            label: 'Nie'),
                                                      ],
                                                      choiceStyle:
                                                          C2ChoiceStyle(
                                                        borderShape: BeveledRectangleBorder(
                                                            borderRadius: const BorderRadius
                                                                    .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10))),
                                                        borderColor: Colors
                                                            .lightBlueAccent,
                                                        labelStyle: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white70,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        borderWidth: 2,
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        elevation: 1,
                                                        margin: const EdgeInsets
                                                            .all(8),
                                                        color: Colors.black26,
                                                        brightness:
                                                            Brightness.dark,
                                                      ),
                                                      choiceActiveStyle:
                                                          C2ChoiceStyle(
                                                        borderShape: BeveledRectangleBorder(
                                                            borderRadius: const BorderRadius
                                                                    .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10))),
                                                        borderColor:
                                                            Colors.black,
                                                        labelStyle: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                        borderWidth: 5,
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        elevation: 1,
                                                        color:
                                                            Colors.indigoAccent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                /*Center(
                                              heightFactor: 2.5,
                                              child: Text('Svetlé ikony stav. lišty?',
                                                  style: TextStyle(
                                                      fontSize: 20.0))),
                                          Wrap(
                                            children: [
                                              ChipsChoice<int>.single(
                                                wrapped: false,
                                                value: statusBarIconBrightness,
                                                onChanged: (val) =>
                                                    setState(() {
                                                      statusBarIconBrightness = val;
                                                    }),
                                                choiceItems: <C2Choice<int>>[
                                                  C2Choice<int>(
                                                      value: 0, label: 'Áno'),
                                                  C2Choice<int>(
                                                      value: 1, label: 'Nie'),
                                                ],
                                                choiceStyle: C2ChoiceStyle(
                                                  borderShape: BeveledRectangleBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          bottomRight:
                                                          Radius
                                                              .circular(
                                                              10))),
                                                  borderColor:
                                                  Colors.lightBlueAccent,
                                                  labelStyle: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white70,
                                                      fontWeight:
                                                      FontWeight.normal),
                                                  borderWidth: 2,
                                                  padding: EdgeInsets.all(10),
                                                  elevation: 1,
                                                  margin:
                                                  const EdgeInsets.all(8),
                                                  color: Colors.black26,
                                                  brightness: Brightness.dark,
                                                ),
                                                choiceActiveStyle:
                                                C2ChoiceStyle(
                                                  borderShape: BeveledRectangleBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          bottomRight:
                                                          Radius
                                                              .circular(
                                                              10))),
                                                  borderColor: Colors.black,
                                                  labelStyle: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.w500),
                                                  borderWidth: 5,
                                                  padding: EdgeInsets.all(10),
                                                  elevation: 1,
                                                  color: Colors.indigoAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Center(
                                              heightFactor: 2.5,
                                              child: Text('Svetlý text stav. lišty?',
                                                  style: TextStyle(
                                                      fontSize: 20.0))),
                                          Wrap(
                                            children: [
                                              ChipsChoice<int>.single(
                                                wrapped: false,
                                                value: statusBarTextBrightness,
                                                onChanged: (val) =>
                                                    setState(() {
                                                      statusBarTextBrightness = val;
                                                    }),
                                                choiceItems: <C2Choice<int>>[
                                                  C2Choice<int>(
                                                      value: 0, label: 'Áno'),
                                                  C2Choice<int>(
                                                      value: 1, label: 'Nie'),
                                                ],
                                                choiceStyle: C2ChoiceStyle(
                                                  borderShape: BeveledRectangleBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          bottomRight:
                                                          Radius
                                                              .circular(
                                                              10))),
                                                  borderColor:
                                                  Colors.lightBlueAccent,
                                                  labelStyle: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white70,
                                                      fontWeight:
                                                      FontWeight.normal),
                                                  borderWidth: 2,
                                                  padding: EdgeInsets.all(10),
                                                  elevation: 1,
                                                  margin:
                                                  const EdgeInsets.all(8),
                                                  color: Colors.black26,
                                                  brightness: Brightness.dark,
                                                ),
                                                choiceActiveStyle:
                                                C2ChoiceStyle(
                                                  borderShape: BeveledRectangleBorder(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                          topLeft: Radius
                                                              .circular(10),
                                                          bottomRight:
                                                          Radius
                                                              .circular(
                                                              10))),
                                                  borderColor: Colors.black,
                                                  labelStyle: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                      fontWeight:
                                                      FontWeight.w500),
                                                  borderWidth: 5,
                                                  padding: EdgeInsets.all(10),
                                                  elevation: 1,
                                                  color: Colors.indigoAccent,
                                                ),
                                              ),
                                            ],
                                          ),*/
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            OutlineButton(
                                              onPressed: () async {
                                                statusBarIconBrightness == 0
                                                    ? statusBarIconSelected =
                                                        Brightness.light
                                                    : statusBarIconSelected =
                                                        Brightness.dark;
                                                statusBarTextBrightness == 0
                                                    ? statusBarTextSelected =
                                                        Brightness.light
                                                    : statusBarTextSelected =
                                                        Brightness.dark;
                                                navBarIconBrightness == 0
                                                    ? navBarIconSelected =
                                                        Brightness.light
                                                    : navBarIconSelected =
                                                        Brightness.dark;
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.setInt(statusBarC,
                                                    pickerColorStatus.value);
                                                prefs.setInt(navBarC,
                                                    pickerColorNav.value);
                                                prefs.setInt(navBarB,
                                                    navBarIconBrightness);
                                                SystemChrome
                                                    .setSystemUIOverlayStyle(
                                                        SystemUiOverlayStyle(
                                                  systemNavigationBarColor:
                                                      pickerColorNav,
                                                  // navigation bar color
                                                  statusBarColor:
                                                      pickerColorStatus,
                                                  // status bar color
                                                  statusBarBrightness:
                                                      statusBarTextSelected,
                                                  //status bar brigtness
                                                  statusBarIconBrightness:
                                                      statusBarIconSelected,
                                                  //status b//Navigation bar divider color
                                                  systemNavigationBarIconBrightness:
                                                      navBarIconBrightness == 0
                                                          ? Brightness.light
                                                          : Brightness
                                                              .dark, //navigation bar icon
                                                ));
                                                Navigator.of(context).pop();
                                                showConfirmationFlushBar(
                                                    context,
                                                    "Farby",
                                                    "Farby úspešne zmenené.",
                                                    1600,
                                                    false);
                                              },
                                              child: Text(
                                                'Uložiť',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    color: ThemeData()
                                                        .accentColor),
                                              ),
                                              shape: new BeveledRectangleBorder(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  10),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  10))),
                                              borderSide: BorderSide(
                                                  color: Colors.indigoAccent,
                                                  width: 1.3),
                                            ),
                                          ],
                                        );
                                      });
                                    },
                                  );
                                },
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.colorize,
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    ),
                                    Text(
                                      'Vybrať',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                              FlatButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.0)),
                                onPressed: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setInt(statusBarC, 0);
                                  prefs.setInt(navBarC, 4282557941);
                                  prefs.setInt(navBarB, 0);
                                  print(Colors.blue[400].value);
                                  SystemChrome.setSystemUIOverlayStyle(
                                      SystemUiOverlayStyle(
                                    systemNavigationBarColor: Colors.blue[400],
                                    // navigation bar color
                                    statusBarColor: Colors.transparent,
                                    // status bar color
                                    statusBarBrightness: Brightness.light,
                                    //status bar brigtness
                                    statusBarIconBrightness: Brightness.dark,
                                    //status b//Navigation bar divider color
                                    systemNavigationBarIconBrightness:
                                        Brightness.light, //navigation bar icon
                                  ));
                                  showConfirmationFlushBar(context, "Farby",
                                      "Pôvodné farby úspešne obnovené.");
                                },
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.settings_backup_restore,
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    ),
                                    Text(
                                      'Základné farby',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1.2,
                      thickness: 0.5,
                      color: Colors.transparent,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        onWillPop: () async {
          if (isDeleteFromDb == true) {
            isDeleteFromDb = false;
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, "/homePage");
          } else {
            Navigator.pop(context);
          }
          return true;
        });
  }
}
