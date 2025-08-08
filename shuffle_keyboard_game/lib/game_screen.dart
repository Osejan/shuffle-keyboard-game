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

  // For background color cycling
  final List<Color> backgroundColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.pink.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
    Colors.yellow.shade100,
    Colors.red.shade100,
    Colors.cyan.shade100,
    Colors.lime.shade100,
    Colors.indigo.shade100,
    Colors.amber.shade100,
    Colors.deepOrange.shade100,
    Colors.deepPurple.shade100,
    Colors.lightGreen.shade100,
    Colors.brown.shade100,
    Colors.grey.shade300,
    Colors.blueGrey.shade100,
  ];
  Color currentBackground = Colors.blue.shade100;

  // For paragraph cycling
  final List<String> _paragraphHistory = [];
  final int _historyLimit = 15;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      // Pick a new background color (not the same as last)
      Color newColor;
      do {
        newColor = backgroundColors[_random.nextInt(backgroundColors.length)];
      } while (newColor == currentBackground);
      currentBackground = newColor;

      // Pick a new paragraph not in recent history
      String newParagraph;
      List<String> available = funnyParagraphs
          .where((p) => !_paragraphHistory.contains(p))
          .toList();
      if (available.isEmpty) {
        _paragraphHistory.clear();
        available = List.from(funnyParagraphs);
      }
      newParagraph = (available..shuffle(_random)).first;
      targetText = newParagraph;
      _paragraphHistory.add(newParagraph);
      if (_paragraphHistory.length > _historyLimit) {
        _paragraphHistory.removeAt(0);
      }

      // Reset game state
      typedText = "";
      timeLeft = 30;
      gameOver = false;
      keys = _generateKeys();
    });

    // Cancel any previous timer
    gameTimer?.cancel();
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
          keys.shuffle(_random);
        }
        if (timeLeft <= 0) {
          _endGame();
        }
      });
    });
  }

  void _endGame() {
    gameTimer?.cancel();
    setState(() => gameOver = true);

    // Restart the game after a short delay
    Future.delayed(Duration(seconds: 2), () {
      _startNewGame();
    });
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
                    // If finished typing, end game early
                    if (typedText.length >= targetText.length) {
                      _endGame();
                    }
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
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Typing Challenge")),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        color: currentBackground,
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
              Text("Restarting...", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }
}
