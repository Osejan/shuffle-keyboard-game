import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'paragraphs.dart';

class GameScreen extends StatefulWidget {
  final int shuffleInterval; // in seconds, 0 means no shuffle
  GameScreen({required this.shuffleInterval});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late String targetText;
  String typedText = "";
  int timeLeft = 30;
  Timer? gameTimer;
  List<String> keys = [];
  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    targetText = (funnyParagraphs..shuffle()).first;
    keys = _generateKeys();
    _startGame();
  }

  List<String> _generateKeys() {
    return [
      ...List.generate(26, (i) => String.fromCharCode(97 + i)),
      ' ', '.', ',', '?'
    ];
  }

  void _startGame() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (widget.shuffleInterval > 0 && timeLeft % widget.shuffleInterval == 0) {
          keys.shuffle(Random());
        }
        if (timeLeft <= 0) _endGame();
      });
    });
  }

  void _endGame() {
    gameTimer?.cancel();
    setState(() => gameOver = true);
  }

  double _accuracy() {
    int correct = 0;
    for (int i = 0; i < typedText.length && i < targetText.length; i++) {
      if (typedText[i] == targetText[i]) correct++;
    }
    return (correct / targetText.length) * 100;
  }

  Widget _buildKeyboard() {
    List<List<String>> rows = [
      keys.sublist(0, 10),
      keys.sublist(10, 19),
      keys.sublist(19),
    ];

    return Column(
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: Size(40, 50)),
                onPressed: gameOver ? null : () {
                  setState(() {
                    typedText += key;
                  });
                },
                child: Text(key.toUpperCase(), style: TextStyle(fontSize: 18)),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Typing Challenge")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text("Type this:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(targetText, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 10),
            Text("Time Left: $timeLeft s", style: TextStyle(fontSize: 20, color: Colors.red)),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.all(8),
              color: Colors.grey[200],
              width: double.infinity,
              child: Text(typedText, style: TextStyle(fontSize: 18)),
            ),
            Expanded(child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildKeyboard(),
            )),
            if (gameOver) ...[
              SizedBox(height: 10),
              Text("Game Over!", style: TextStyle(fontSize: 22, color: Colors.red)),
              Text("Accuracy: ${_accuracy().toStringAsFixed(2)}%"),
              Text("Characters Typed: ${typedText.length}"),
            ]
          ],
        ),
      ),
    );
  }
}
