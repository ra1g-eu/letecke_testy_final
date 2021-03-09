import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letecky_testy/database/category_provider.dart';
import 'package:letecky_testy/database/db_helper.dart';
import 'package:letecky_testy/database/question_provider.dart';
import 'package:letecky_testy/model/category_model.dart';
import 'package:letecky_testy/model/user_answer_model.dart';
import 'package:letecky_testy/state/state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/utils/utils.dart';
import 'package:letecky_testy/widgets/question_body.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyReadModePage extends StatefulWidget {
  MyReadModePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MyReadModePageState();
}

class _MyReadModePageState extends State<MyReadModePage> {
  SharedPreferences prefs;
  int indexPage = 0;
  CarouselController buttonCarouselController = CarouselController();
  List<UserAnswer> userAnswers = new List<UserAnswer>();
  List<UserCategory> userCategory = new List<UserCategory>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      prefs = await SharedPreferences.getInstance();
      indexPage = prefs.getInt(
              '${context.read(questionCategoryState).state.name}_${context.read(questionCategoryState).state.ID}') ??
          0;
      print(indexPage);
      if(indexPage != null){
      Future.delayed(Duration(milliseconds: 500)).then((value) =>
          buttonCarouselController.animateToPage(
              indexPage));} //ak sa ulozili otazky, pouzivatel sa vrati na otazku ktoru naposledy ulozil a ukoncil obrazovku
    });
  }

  @override
  Widget build(BuildContext context) {
    var questionModule = context.read(questionCategoryState).state;
    return WillPopScope(
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
          child: Scaffold(
              backgroundColor: Colors.transparent,
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                toolbarHeight: 45,
                title: Text(questionModule.name),
                leading: GestureDetector(
                    onTap: () => showCloseDialog(questionModule),
                    child: Icon(Icons.arrow_back))),
            body: Column(
              children: [
                Expanded(
                    child: FutureBuilder<List<Question>>(
                        future: getQuestionByCategory(questionModule.ID),
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return Center(
                              child: Text('Kategória pravdepodobne ešte neobsahuje otázky.\nChyba: ${snapshot.error}'),
                            );
                          else if (snapshot.hasData) {
                            if (snapshot.data.length > 0) {
                              return Container(
                                margin: const EdgeInsets.all(0.2),
                                child: Card(
                                  color: Colors.transparent,
                                  elevation: 3,
                                  shape: new BeveledRectangleBorder(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                  shadowColor: Colors.black54,
                                  clipBehavior: Clip.hardEdge,
                                  margin: const EdgeInsets.all(4),
                                  child: QuestionBody(
                                    context: context,
                                    carouselController:
                                        buttonCarouselController,
                                    questions: snapshot.data,
                                    userAnswers: userAnswers,
                                  ),
                                ),
                              );
                            } else
                              return Center(
                                  child: Text(
                                      'Kategória zatiaľ neobsahuje otázky'));
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
                        })),
              ],
            ),
          bottomNavigationBar:
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                OutlineButton(
                  onPressed: () => showAnswer(context),
                  child: AutoSizeText('Ukáž správnu odpoveď',
                      style: TextStyle(fontSize: 19, color: Colors.white)),
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  borderSide:
                  BorderSide(color: Colors.indigoAccent, width: 1.3),
                ),
                  OutlineButton(
                    onPressed: () {
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
                                  title: Text('${questionModule.name}'),
                                  content: Container(
                                      width:
                                      MediaQuery.of(context).size.width,
                                      child: GridView.count(
                                        crossAxisCount: 2,
                                        childAspectRatio: 1.7,
                                        padding: const EdgeInsets.all(2.0),
                                        mainAxisSpacing: 8.0,
                                        crossAxisSpacing: 8.0,
                                        children: context
                                            .read(userListQuestion)
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
                                              color: Colors.transparent,
                                              //farba karty testu - farba karty kategorie
                                              child: Column(
                                                verticalDirection:
                                                VerticalDirection.down,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Center(
                                                    child: AutoSizeText(
                                                      'otázka',
                                                      textAlign:
                                                      TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w300,
                                                          fontSize: 22),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: AutoSizeText(
                                                      '${e.value.questionId}',
                                                      textAlign:
                                                      TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.w300,
                                                          fontSize: 22),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              buttonCarouselController
                                                  .animateToPage(e.key);
                                            },
                                          );
                                        }).toList(),
                                      )),
                                  actions: [
                                    OutlineButton.icon(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop();
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
                              return true;
                            }),
                      );
                    },
                  child: AutoSizeText('Otázky',
                      style: TextStyle(fontSize: 19, color: Colors.white)),
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  borderSide:
                  BorderSide(color: Colors.indigoAccent, width: 1.2),
                  ),
              ],)
        ),),
        onWillPop: () async {
          showCloseDialog(questionModule);
          return true;
        });
  }

  showCloseDialog(Category questionModule) {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        useRootNavigator: false,
        builder: (_) => new AlertDialog(
          backgroundColor: Colors.indigo[500],
              title: Text('Zatvoriť'),
              content: Text('Chceš uložiť aktuálnu otázku?'),
              actions: [
                OutlineButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // zatvoriť dialogove okno
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Nie',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
                  ),
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  color: Colors.indigoAccent,
                ),
                OutlineButton(
                  onPressed: () {
                    prefs.setInt(
                        '${context.read(questionCategoryState).state.name}_${context.read(questionCategoryState).state.ID}',
                        context.read(currentReadPage).state);
                    Navigator.of(context).pop(); // zatvoriť dialogove okno
                    Navigator.pop(context); // zatvorit celu obrazovku
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

  Future<List<Question>> getQuestionByCategory(int id) async {
    var db = await copyDB();
    var result = await QuestionProvider().getQuestionByCategoryId(db, id);
    userCategory.clear();
    result.forEach((element) {
      userCategory.add(new UserCategory(
          questionId: element.questionId, categoryId: element.categoryId));
    });
    context.read(userListQuestion).state = userCategory;
    return result;
  }
}
