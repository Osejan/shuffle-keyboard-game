import 'dart:math';
import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedLettersBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Choose Your Challenge",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Algerian', // Make sure this font is added to your assets!
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 8, color: Colors.black)],
                  ),
                ),
                SizedBox(height: 40),
                LiveButton(
                  text: "Level 1: Normal Keyboard",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GameScreen(shuffleInterval: 0)),
                  ),
                ),
                SizedBox(height: 20),
                LiveButton(
                  text: "Level 2: Shuffle every 3s",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GameScreen(shuffleInterval: 3)),
                  ),
                ),
                SizedBox(height: 20),
                LiveButton(
                  text: "Level 3: Shuffle every second",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GameScreen(shuffleInterval: 1)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Animated floating letters background
class AnimatedLettersBackground extends StatefulWidget {
  @override
  _AnimatedLettersBackgroundState createState() => _AnimatedLettersBackgroundState();
}

class _AnimatedLettersBackgroundState extends State<AnimatedLettersBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _letters = List.generate(26, (i) => String.fromCharCode(65 + i)); // A-Z

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: size,
          painter: LettersPainter(_controller.value, _letters),
        );
      },
    );
  }
}

class LettersPainter extends CustomPainter {
  final double progress;
  final List<String> letters;

  LettersPainter(this.progress, this.letters);

  @override
  void paint(Canvas canvas, Size size) {
    final int letterCount = 18;
    for (int i = 0; i < letterCount; i++) {
      final double x = (size.width) * ((i * 0.07 + progress + i * 0.13) % 1.0);
      final double y = (size.height) * (((i * 0.11 + progress * 1.2 + i * 0.19) % 1.0));
      final String letter = letters[i % letters.length];
      final double fontSize = 32 + 32 * sin(progress * 2 * pi + i);
      final Color color = Colors.primaries[i % Colors.primaries.length]
          .withOpacity(0.5 + 0.5 * sin(progress * 2 * pi + i));
      final textStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Algerian', // Make sure this font is added to your assets!
        color: color,
      );
      final textSpan = TextSpan(text: letter, style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant LettersPainter oldDelegate) => true;
}

// Animated "live" button
class LiveButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const LiveButton({required this.text, required this.onTap});

  @override
  _LiveButtonState createState() => _LiveButtonState();
}

class _LiveButtonState extends State<LiveButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double scale = 1 + 0.05 * sin(_controller.value * 2 * pi);
        return Transform.scale(
          scale: scale,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.withOpacity(0.8 + 0.2 * _controller.value),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 8 + 8 * _controller.value,
              textStyle: TextStyle(
                fontFamily: 'Algerian', // Make sure this font is added to your assets!
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            onPressed: widget.onTap,
            child: Text(widget.text),
          ),
        );
      },
    );
  }
}
