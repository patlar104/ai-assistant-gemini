import '../models/chat_message.dart';

class ChatState {
  const ChatState({
    required this.messages,
    this.isStreaming = false,
    this.lastError,
  });

  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? lastError;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? lastError,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      lastError: lastError,
    );
  }
}
