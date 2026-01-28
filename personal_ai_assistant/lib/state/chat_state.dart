import '../models/chat_message.dart';

class ChatState {
  const ChatState({
    required this.messages,
    this.isConnecting = true,
    this.isConnected = false,
    this.lastError,
  });

  final List<ChatMessage> messages;
  final bool isConnecting;
  final bool isConnected;
  final String? lastError;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isConnecting,
    bool? isConnected,
    String? lastError,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isConnecting: isConnecting ?? this.isConnecting,
      isConnected: isConnected ?? this.isConnected,
      lastError: lastError,
    );
  }
}
