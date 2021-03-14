import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:letecky_testy/database/db_helper.dart';
import 'package:letecky_testy/database/question_provider.dart';
import 'package:letecky_testy/model/category_model.dart';
import 'package:letecky_testy/model/user_answer_model.dart';
import 'package:letecky_testy/state/state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/utils/utils.dart';
import 'package:letecky_testy/widgets/question_body.dart';
import 'package:loading_animations/loading_animations.dart';

class MyShowAllModePage extends StatefulWidget {
  MyShowAllModePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MyShowAllModePageState();
}

class _MyShowAllModePageState extends State<MyShowAllModePage> {
  CarouselController buttonCarouselController = CarouselController();
  List<UserAnswer> userAnswers = <UserAnswer>[];
  List<UserCategory> userCategory = <UserCategory>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                title: Text(widget.title),
                leading: GestureDetector(
                    onTap: () => showCloseDialog(),
                    child: Icon(Icons.arrow_back))),
            body: Column(
              children: [
                Expanded(
                    child: FutureBuilder<List<Question>>(
                        future: getEverything(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return Center(
                              child: Text('${snapshot.error}'),
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
                OutlinedButton(
                  onPressed: () => showAnswer(context),
                  child: AutoSizeText('Ukáž správnu odpoveď',
                      style: TextStyle(fontSize: 19, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                      shape: new BeveledRectangleBorder(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      side: BorderSide(color: Colors.indigoAccent, width: 1.3)),
                ),
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      useRootNavigator: false,
                      barrierDismissible: false,
                      barrierColor: Colors.black54,
                      builder: (_) => new WillPopScope(
                        onWillPop: () async {
                          return true;
                        }, child: new AlertDialog(
                        backgroundColor: Colors.indigo[500],
                        shape: new BeveledRectangleBorder(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10)),
                            side: BorderSide(
                                color: Colors.black, width: 1.3)),
                        elevation: 5,
                        title: Text('Všetky otázky z kategórií'),
                        content: Container(
                            width:
                            MediaQuery.of(context).size.width,
                            child: GridView.count(
                              crossAxisCount: 2,
                              childAspectRatio: 1.5,
                              padding: const EdgeInsets.all(4.0),
                              mainAxisSpacing: 10.0,
                              crossAxisSpacing: 10.0,
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
                                            'otázka ${e.value.questionId}',
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.w300,
                                                fontSize: 19),
                                          ),
                                        ),
                                        Divider(),
                                        Center(
                                          child: AutoSizeText(
                                            'kategória ${e.value.categoryId}',
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.w300,
                                                fontSize: 19),
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
                          OutlinedButton.icon(
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
                            style: OutlinedButton.styleFrom(
                                shape: new BeveledRectangleBorder(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10))),
                                side: BorderSide(color: Colors.indigoAccent, width: 1.3)),
                          ),
                        ],
                      ),
                      ),
                    );
                  },
                  child: AutoSizeText('Otázky',
                      style: TextStyle(fontSize: 19, color: Colors.white)),
                  style: OutlinedButton.styleFrom(
                    shape: new BeveledRectangleBorder(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10))),
                    side: BorderSide(color: Colors.indigoAccent, width: 1.2),
                  ),
                ),
              ],)
        ),),
        onWillPop: () async{
          showCloseDialog();
          return true;
        });
  }

  showCloseDialog() {
    showDialog(
        barrierColor: Colors.black54,
        context: context,
        useRootNavigator: false,
        builder: (_) => new AlertDialog(
          backgroundColor: Colors.indigo[500],
          title: Text('Opustiť'),
          content: Text('Chceš sa vrátiť naspäť?'),
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Nie',
                style:
                TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
              ),
              style: OutlinedButton.styleFrom(
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)))),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop(); // zatvoriť dialogove okno
                Navigator.pop(context); // zatvorit celu obrazovku
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProviderScope(child:MyApp())),
                );*/
              },
              child: Text(
                'Áno',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: ThemeData().accentColor),
              ),
              style: OutlinedButton.styleFrom(
                  shape: new BeveledRectangleBorder(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10))),
                  side: BorderSide(color: Colors.indigoAccent, width: 1.3)),
            ),
          ],
        ));
  }

  Future<List<Question>> getEverything() async {
    var db = await copyDB();
    var result = await QuestionProvider().getAllQuestions(db);
    userCategory.clear();
    result.forEach((element) {
      userCategory.add(new UserCategory(
          questionId: element.questionId, categoryId: element.categoryId));
    });
    context.read(userListQuestion).state = userCategory;
    return result;
  }
}
