import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chat_stream_client_impl.dart';

enum ChatStreamEventType { chunk, done, error }

class ChatStreamEvent {
  const ChatStreamEvent._(this.type, {this.text, this.message});

  final ChatStreamEventType type;
  final String? text;
  final String? message;

  factory ChatStreamEvent.chunk(String text) =>
      ChatStreamEvent._(ChatStreamEventType.chunk, text: text);

  factory ChatStreamEvent.done() =>
      const ChatStreamEvent._(ChatStreamEventType.done);

  factory ChatStreamEvent.error(String message) =>
      ChatStreamEvent._(ChatStreamEventType.error, message: message);
}

abstract class ChatStreamClient {
  Stream<ChatStreamEvent> streamChat(String message);
}

final chatStreamClientProvider = Provider<ChatStreamClient>((ref) {
  return createChatStreamClient();
});
