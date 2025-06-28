import 'package:flutter/material.dart';

 noAnimationRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

class NavHelper {
  static void replacePageTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, noAnimationRoute(page));
  }

  static void pushPageTo(BuildContext context, Widget page) {
    Navigator.push(context, noAnimationRoute(page));
  }

  static void popPage(BuildContext context) {
    Navigator.pop(context);
  }
}