import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:letecky_testy/database/question_provider.dart';
import 'package:letecky_testy/model/user_answer_model.dart';
import 'package:letecky_testy/state/state_manager.dart';
import 'package:letecky_testy/utils/utils.dart';
import 'package:photo_view/photo_view.dart';

class QuestionBody extends StatelessWidget {
  QuestionBody(
      {Key key,
      this.context,
      this.userAnswers,
      this.carouselController,
      this.questions})
      : super(key: key);

  BuildContext context;
  List<UserAnswer> userAnswers;
  CarouselController carouselController;
  List<Question> questions;
  bool isInReadMode;
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        carouselController: carouselController,
        items: questions
            .asMap()
            .entries
            .map((e) => Builder(
                  builder: (context) {
                    return Consumer(builder: (context, watch, _) {
                      var userAnswerState = watch(userAnswerSelected).state;
                      var isShowAnswer = watch(isEnableShowAnswer).state;
                      isInReadMode = watch(isReadMode).state;
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceAround,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 25,
                                    child: Text(
                                      context.read(isTestMode).state
                                          ? '${e.key + 1}.'
                                          : '${e.value.questionId}',
                                      style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  VerticalDivider(),
                                  Expanded(
                                    child: AutoSizeText(
                                      context.read(isTestMode).state
                                          ? '${e.value.questionText}'
                                          : '${e.value.questionText}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18.5,
                                          color: Colors.white,
                                          fontFamily: 'Roboto'),
                                      textAlign: TextAlign.left,
                                      softWrap: true,
                                      wrapWords: true,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //otazka
                            Visibility(
                                visible: (e.value.isImageQuestion == null ||
                                    e.value.isImageQuestion == 0
                                    ? false
                                    : true),
                                child: Container(
                                  height:
                                  MediaQuery.of(context).size.height /
                                      15 *
                                      3,
                                  child: e.value.isImageQuestion == 0
                                      ? Container()
                                      : GestureDetector(
                                    child: Image.asset(
                                      "${e.value.questionImage}",
                                      fit: BoxFit.contain,
                                    ),
                                    onTap: () {
                                      showDialog(
                                        barrierDismissible: true,
                                        useSafeArea: true,
                                        context: context,
                                        builder:
                                            (BuildContext context) {
                                          return Dialog(
                                            child: Container(
                                              child: PhotoView(
                                                tightMode: true,
                                                imageProvider: AssetImage(
                                                    "${e.value.questionImage}"),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                )),
                            Padding(padding: EdgeInsets.only(top: 9)),
                            Divider(
                              thickness: 2,
                              height: 1,
                              endIndent: 2,
                              indent: 2,
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                  top: 10,
                                )),
                            Expanded(
                              flex: 0,
                              child: ListTile(
                                title: Text(
                                  '${e.value.answerA}',
                                  style: TextStyle(
                                      color: isShowAnswer
                                          ? e.value.correctAnswer == 'A'
                                          ? Colors.green
                                          : Colors.grey
                                          : Colors.white,
                                      fontSize: 18.5,
                                      fontWeight: isShowAnswer
                                          ? e.value.correctAnswer == 'A' ? FontWeight.bold : FontWeight.w300 : getGroupValue(isShowAnswer, e, userAnswerState) == 'A' ? FontWeight.w500 : FontWeight.w300,
                                      fontFamily: 'Roboto'),
                                  softWrap: true,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo[900],
                                  child: Text(
                                    "A",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                trailing: isInReadMode ? null : Transform.scale(
                                  scale: 1.35,
                                  child: Radio(
                                    activeColor: Colors.indigo[900],
                                    value: 'A',
                                    groupValue: getGroupValue(
                                        isShowAnswer,
                                        e,
                                        userAnswerState),
                                    onChanged: (value) => setUserAnswer(
                                        context, e, value),
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(4),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 5),
                            ),
                            Divider(
                              indent: 50,
                              endIndent: 50,
                            ),
                            Expanded(
                              flex: 0,
                              child: ListTile(
                                title: Text(
                                  '${e.value.answerB}',
                                  style: TextStyle(
                                      color: isShowAnswer
                                          ? e.value.correctAnswer == 'B'
                                          ? Colors.green
                                          : Colors.grey
                                          : Colors.white,
                                      fontSize: 18.5,
                                      fontWeight: isShowAnswer
                                          ? e.value.correctAnswer == 'B' ? FontWeight.bold : FontWeight.w300 : getGroupValue(isShowAnswer, e, userAnswerState) == 'B' ? FontWeight.w500 : FontWeight.w300,
                                      fontFamily: 'Roboto'),
                                  softWrap: true,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo[900],
                                  child: Text(
                                    "B",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                trailing: isInReadMode ? null : Transform.scale(
                                  scale: 1.35,
                                  child: Radio(
                                    activeColor: Colors.indigo[900],
                                    value: 'B',
                                    groupValue: getGroupValue(
                                        isShowAnswer,
                                        e,
                                        userAnswerState),
                                    onChanged: (value) => setUserAnswer(
                                        context, e, value),
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(4),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 5),
                            ),
                            Divider(
                              indent: 50,
                              endIndent: 50,
                            ),
                            Expanded(
                              flex: 0,
                                child: ListTile(
                                  title: Text(
                                    '${e.value.answerC}',
                                    style: TextStyle(
                                        color: isShowAnswer
                                            ? e.value.correctAnswer ==
                                            'C'
                                            ? Colors.green
                                            : Colors.grey
                                            : Colors.white,
                                        fontSize: 18.5,
                                        fontWeight: isShowAnswer
                                            ? e.value.correctAnswer == 'C' ? FontWeight.bold : FontWeight.w300 : getGroupValue(isShowAnswer, e, userAnswerState) == 'C' ? FontWeight.w500 : FontWeight.w300,
                                        fontFamily: 'Roboto'),
                                    softWrap: true,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                    Colors.indigo[900],
                                    child: Text(
                                      "C",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  trailing: isInReadMode ? null : Transform.scale(
                                    scale: 1.35,
                                    child: Radio(
                                      activeColor: Colors.indigo[900],
                                      value: 'C',
                                      groupValue: getGroupValue(
                                          isShowAnswer,
                                          e,
                                          userAnswerState),
                                      onChanged: (value) =>
                                          setUserAnswer(
                                              context, e, value),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(4),
                                )),
                            SizedBox(height: 10,),
                          ],
                        ),
                      );
                    });
                  },
                ))
            .toList(),
        options: CarouselOptions(
            autoPlay: false,
            enlargeCenterPage: true,
            enableInfiniteScroll: context.read(isReadMode).state ? true : false,
            viewportFraction: 1,
            initialPage: 0,
            height: MediaQuery.of(context).size.height,
            onPageChanged: (page, _) {
              context.read(isEnableShowAnswer).state = false;
              context.read(currentReadPage).state = page;
            }));
  }

  getGroupValue(bool isShowAnswer, MapEntry<int, Question> e,
      UserAnswer userAnswerState) {
    return isShowAnswer
        ? e.value.correctAnswer
        : (context.read(isTestMode).state
            ? context.read(userListAnswer).state[e.key].answered
            : '');
  }
}
