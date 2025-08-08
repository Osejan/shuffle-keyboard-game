import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() => runApp(ShuffleKeyboardApp());

class ShuffleKeyboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shuffling Keyboard Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
