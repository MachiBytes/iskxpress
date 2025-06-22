import 'package:flutter/material.dart';

 noAnimationRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

class NavHelper {
  static void navigateTo(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, noAnimationRoute(page));
  }
}