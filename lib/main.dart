import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iskxpress/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}