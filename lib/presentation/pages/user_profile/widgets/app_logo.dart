import 'package:flutter/material.dart';
import 'package:iskxpress/core/constants/image_strings.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Image.asset(
        TImages.appLogo,
        height: 35, // Added a specific height for the image
      ),
    );
  }
}