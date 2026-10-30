import 'package:flutter/material.dart';
import 'planner_screen.dart';

void main() {
  runApp(const FitWithRahulApp());
}

class FitWithRahulApp extends StatelessWidget {
  const FitWithRahulApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fitwithRahul',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const PlannerScreen(),
    );
  }
}
