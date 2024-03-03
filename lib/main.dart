import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketch_app/view/drawing_canvas/controller/canvasProvider.dart';
import 'package:sketch_app/view/drawing_page.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => CanvasProvider()),
    ],
    child: const MyApp(),
  ));
}
const Color kCanvasColor = Color(0xfff2f3f7);
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
