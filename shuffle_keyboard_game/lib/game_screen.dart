import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'paragraphs.dart';

class GameScreen extends StatefulWidget {
  final int shuffleInterval; // in seconds, 0 means no shuffle
  final String? paragraph;   // optional: allow HomeScreen to provide a first-round paragraph
  const GameScreen({
    Key? key,
    required this.shuffleInterval,
    this.paragraph,
  }) : super(key: key);

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

  // Background colors
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

  // Paragraph cycling
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

      // Paragraph selection:
      // Use the provided paragraph only on the first round (when history is empty).
      String newParagraph;
      if (widget.paragraph != null && _paragraphHistory.isEmpty) {
        newParagraph = widget.paragraph!;
      } else {
        List<String> available = funnyParagraphs
            .where((p) => !_paragraphHistory.contains(p))
            .toList();

        // If we've exhausted the no-repeat pool, clear history and start over.
        if (available.isEmpty) {
          _paragraphHistory.clear();
          available = List.from(funnyParagraphs);
        }

        // Optionally avoid picking the same as the immediate last paragraph if possible
        if (available.length > 1 && _paragraphHistory.isNotEmpty) {
          available.remove(_paragraphHistory.last);
        }

        available.shuffle(_random);
        newParagraph = available.first;
      }

      targetText = newParagraph;
      _paragraphHistory.add(newParagraph);
      if (_paragraphHistory.length > _historyLimit) {
        _paragraphHistory.removeAt(0);
      }

      // Reset game state
      typedText = "";
      timeLeft = 30; // each round lasts 30s
      gameOver = false;
      keys = _generateKeys();
    });

    // Cancel any previous timer and start a new one
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
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (widget.shuffleInterval > 0 && timeLeft > 0 && timeLeft % widget.shuffleInterval == 0) {
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

    // Restart the game after a short delay, only if still mounted
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _startNewGame();
      }
    });
  }

  double _accuracy() {
    int correct = 0;
    for (int i = 0; i < typedText.length && i < targetText.length; i++) {
      if (typedText[i] == targetText[i]) correct++;
    }
    if (targetText.isEmpty) return 0;
    return (correct / targetText.length) * 100;
  }

  Widget _buildKeyboard() {
    // Defensive: ensure we have enough keys for the splits
    final List<String> k = List.of(keys);
    if (k.length < 20) {
      // Fallback to avoid range errors if keys list changes
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: k
            .map((key) => ElevatedButton(
                  onPressed: gameOver ? null : () {
                    setState(() {
                      typedText += key;
                      if (typedText.length >= targetText.length) {
                        _endGame();
                      }
                    });
                  },
                  child: Text(key.toUpperCase()),
                ))
            .toList(),
      );
    }

    List<List<String>> rows = [
      k.sublist(0, 10),
      k.sublist(10, 19),
      k.sublist(19),
    ];

    return Column(
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(40, 50)),
                onPressed: gameOver
                    ? null
                    : () {
                        setState(() {
                          typedText += key;
                          // If finished typing, end game early
                          if (typedText.length >= targetText.length) {
                            _endGame();
                          }
                        });
                      },
                child: Text(key.toUpperCase(), style: const TextStyle(fontSize: 18)),
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
      appBar: AppBar(title: const Text("Typing Challenge")),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        color: currentBackground,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text("Type this:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(targetText, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 10),
            Text("Time Left: $timeLeft s", style: const TextStyle(fontSize: 20, color: Colors.red)),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              width: double.infinity,
              child: Text(typedText, style: const TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildKeyboard(),
              ),
            ),
            if (gameOver) ...[
              const SizedBox(height: 10),
              const Text("Game Over!", style: TextStyle(fontSize: 22, color: Colors.red)),
              Text("Accuracy: ${_accuracy().toStringAsFixed(2)}%"),
              Text("Characters Typed: ${typedText.length}"),
              const Text("Restarting...", style: TextStyle(fontSize: 16, color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }
}
