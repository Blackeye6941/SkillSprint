import 'package:flutter/material.dart';
import 'goals_screen.dart';
import 'dart:ui';
import 'dart:math' as math;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// Added TickerProviderStateMixin for the animations
class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final List<Map<String, String>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late AnimationController _floatController;
  bool showWelcome = true;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    // Animation controller for the Up/Down floating effect
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      if (showWelcome) showWelcome = false;
      _addMessage('user', _controller.text);
      Future.delayed(const Duration(milliseconds: 800), () {
        _addMessage(
          'bot',
          'Great goal! I’m creating a learning plan for you 🚀',
        );
      });
      _controller.clear();
      isListening = false;
    });
  }

  void _addMessage(String role, String text) {
    messages.add({'role': role, 'text': text});
    _listKey.currentState?.insertItem(
      messages.length - 1,
      duration: const Duration(milliseconds: 500),
    );
  }

  void toggleListening() {
    setState(() {
      isListening = !isListening;
      if (isListening) _controller.text = "I want to learn Flutter";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF001F3F), Color(0xFF000814)],
          ),
        ),
        child: Column(
          children: [
            // ANIMATED FLOATING TITLE AREA
            SafeArea(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, child) {
                  return Transform.translate(
                    // Moves the title up and down by 10 pixels
                    offset: Offset(
                      0,
                      10 * math.sin(_floatController.value * 2 * math.pi),
                    ),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: _buildOnePieceStyleTitle(),
                ),
              ),
            ),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: showWelcome ? _buildWelcomeScreen() : _buildChatList(),
              ),
            ),

            _buildGlassInput(),
            _buildNavigationRow(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOnePieceStyleTitle() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Text(
          'SkillSprint',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8
              ..color = Colors.orange.withOpacity(0.2),
          ),
        ),
        Text(
          'SkillSprint',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = const Color(0xFF1A1A1A),
          ),
        ),
        Text(
          'SkillSprint',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFFFFEA00),
                  Color(0xFFFF9500),
                  Color(0xFFD84315),
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 250, 50)),
          ),
        ),
        Positioned(
          top: -35,
          left: -25,
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            curve: Curves.elasticOut,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Transform.rotate(
                  angle: -0.15,
                  child: CustomPaint(
                    size: const Size(75, 45),
                    painter: PeakStrawHatPainter(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlassInput() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ask the Captain...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isListening ? Icons.mic : Icons.mic_none,
                      color: isListening
                          ? Colors.redAccent
                          : Colors.orangeAccent,
                    ),
                    onPressed: toggleListening,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.orangeAccent,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 18,
                        ),
                        onPressed: sendMessage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatList() {
    return AnimatedList(
      key: _listKey,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      initialItemCount: messages.length,
      itemBuilder: (context, index, animation) {
        final message = messages[index];
        final isUser = message['role'] == 'user';
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(
              Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero),
            ),
            child: Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? const LinearGradient(
                          colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
                        )
                      : LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 0),
                    bottomRight: Radius.circular(isUser ? 0 : 20),
                  ),
                  border: isUser
                      ? null
                      : Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  message['text'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.anchor,
            size: 80,
            color: Colors.orangeAccent.withOpacity(0.8),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ready to set sail?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Tell me your learning goal!',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Changed bottom left icon to explore/compass for navigation
          _navIcon(
            Icons.explore_outlined,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GoalsScreen()),
            ),
          ),
          _navIcon(Icons.home, () {}),
        ],
      ),
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 28),
      onPressed: onTap,
    );
  }
}

class PeakStrawHatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strawColor = const Color(0xFFEBC934);
    final darkStraw = const Color(0xFFC49A00);
    final ribbonRed = const Color(0xFFB71C1C);

    canvas.drawOval(
      Rect.fromLTWH(5, size.height * 0.7, size.width, size.height * 0.3),
      Paint()
        ..color = Colors.black45
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    final brimPaint = Paint()
      ..color = strawColor
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      brimPaint,
    );

    Path crown = Path();
    crown.moveTo(size.width * 0.2, size.height * 0.7);
    crown.cubicTo(
      size.width * 0.2,
      size.height * 0.05,
      size.width * 0.8,
      size.height * 0.05,
      size.width * 0.8,
      size.height * 0.7,
    );
    canvas.drawPath(crown, brimPaint);

    final linePaint = Paint()
      ..color = darkStraw.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(crown, linePaint);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.75,
        size.width * 0.8,
        size.height * 0.1,
      ),
      linePaint,
    );

    Path ribbon = Path();
    ribbon.moveTo(size.width * 0.205, size.height * 0.55);
    ribbon.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.45,
      size.width * 0.795,
      size.height * 0.55,
    );
    ribbon.lineTo(size.width * 0.8, size.height * 0.68);
    ribbon.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.58,
      size.width * 0.2,
      size.height * 0.68,
    );
    ribbon.close();
    canvas.drawPath(ribbon, Paint()..color = ribbonRed);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}
