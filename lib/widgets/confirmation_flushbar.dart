import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showConfirmationFlushBar(BuildContext context, String title, String messageBody, [int milliseconds, bool showButton = true]) {
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
    isDismissible: true,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
    duration: Duration(milliseconds: milliseconds == null ? 60000 : milliseconds),
    mainButton: showButton == false ? null : OutlinedButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Icon(
        Icons.check_outlined,
        size: 50,
        color: ThemeData().accentColor,
      ),
      style: OutlinedButton.styleFrom(
      shape: new BeveledRectangleBorder(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomRight: Radius.circular(10))),
      side: BorderSide(color: Colors.indigoAccent, width: 1.3),),
    ),
    titleText: Text(
      title,
      style: TextStyle(
          fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
    ),
    messageText: Text(
      messageBody,
      style: TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
    ),
  )..show(context);
}