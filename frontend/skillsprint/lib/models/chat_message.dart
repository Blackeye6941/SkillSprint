class ChatMessage {
  final String id;
  final String role; // 'user' or 'bot'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });
}
