import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shuffling Keyboard Challenge")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Choose Your Challenge", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GameScreen(shuffleInterval: 0)), // No shuffle
              ),
              child: Text("Level 1: Normal Keyboard"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GameScreen(shuffleInterval: 3)), // Shuffle every 3s
              ),
              child: Text("Level 2: Shuffle every 3s"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GameScreen(shuffleInterval: 1)), // Shuffle every 1s
              ),
              child: Text("Level 3: Shuffle every second"),
            ),
          ],
        ),
      ),
    );
  }
}
