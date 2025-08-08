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
              foregroundColor: Colors.white, // <-- This makes the text white!
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 8 + 8 * _controller.value,
              textStyle: TextStyle(
                fontFamily: 'Algerian', // Or your fallback font
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.6),
                    offset: Offset(1, 2),
                  ),
                ],
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
