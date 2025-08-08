import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final String paragraph;
  final int shuffleInterval; // seconds

  GameScreen({required this.paragraph, required this.shuffleInterval});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<String> keysRow1 = [];
  List<String> keysRow2 = [];
  List<String> keysRow3 = [];

  String typedText = "";

  Timer? _shuffleTimer;
  Timer? _countdownTimer;
  int _timeLeft = 30; // countdown start

  bool gameOver = false;

  @override
  void initState() {
    super.initState();
    _generateKeyboard();
    _startCountdown();

    if (widget.shuffleInterval > 0) {
      _shuffleTimer = Timer.periodic(
        Duration(seconds: widget.shuffleInterval),
        (_) => _shuffleKeyboard(),
      );
    }
  }

  void _generateKeyboard() {
    // Row 1
    List<String> letters1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
    // Row 2
    List<String> letters2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
    // Row 3 with punctuation fixed at ends
    List<String> letters3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

    String period = '.';
    String comma = ',';
    String apostrophe = "'";
    String question = '?';

    letters1.shuffle(Random());
    letters2.shuffle(Random());
    letters3.shuffle(Random());

    keysRow1 = List.from(letters1);
    keysRow2 = List.from(letters2);
    keysRow3 = [comma, ...letters3, period, apostrophe, question];
  }

  void _shuffleKeyboard() {
    if (!gameOver) {
      setState(() {
        _generateKeyboard();
      });
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!gameOver) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
            if (typedText == widget.paragraph) {
              // Finished typing early
              _showCongratsDialog();
            }
          } else {
            timer.cancel();
            _shuffleTimer?.cancel();
            _showGameOverDialog();
          }
        });
      }
    });
  }

  void _onKeyTap(String key) {
    if (!gameOver) {
      setState(() {
        typedText += key;
        if (typedText == widget.paragraph) {
          _showCongratsDialog();
        }
      });
    }
  }

  void _showGameOverDialog() {
    gameOver = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("⏳ Time's Up!"),
        content: Text("You typed: \n$typedText"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to home
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  void _showCongratsDialog() {
    gameOver = true;
    _countdownTimer?.cancel();
    _shuffleTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("🎉 Congratulations!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("You have successfully wasted your time."),
            SizedBox(height: 6),
            Text(
              "(even though you have good reaction time)",
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to home
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Widget _buildKey(String label) {
    return InkWell(
      onTap: () => _onKeyTap(label),
      child: Container(
        margin: EdgeInsets.all(2),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: row.map((k) => _buildKey(k)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Typing Game"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                "$_timeLeft s",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(widget.paragraph,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              typedText,
              style: TextStyle(
                  fontSize: 18,
                  color: typedText ==
                          widget.paragraph.substring(0, typedText.length)
                      ? Colors.black
                      : Colors.red),
            ),
          ),
          Spacer(),
          _buildKeyboardRow(keysRow1),
          SizedBox(height: 8),
          _buildKeyboardRow(keysRow2),
          SizedBox(height: 8),
          _buildKeyboardRow(keysRow3),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
