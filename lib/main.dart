import 'package:flutter/material.dart';
import 'package:sketch_app/view/drawing_page.dart';


void main() {
  runApp(const MyApp());

}

const Color kCanvasColor = Color(0xfff2f3f7);
const String kGithubRepo = 'https://github.com/JideGuru/sketch_app';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sketch Draw',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      debugShowCheckedModeBanner: false,
      home: const DrawingPage(),
    );
  }
}
