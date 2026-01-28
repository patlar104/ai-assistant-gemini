import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/chat_message.dart';
import 'chat_state.dart';

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  return ChatController();
});

class ChatController extends StateNotifier<ChatState> {
  ChatController()
      : super(
          ChatState(
            messages: const [
              ChatMessage(
                text: 'Hello! Ask me anything to get started.',
                isUser: false,
              ),
            ],
          ),
        ) {
    _connect();
  }

  static const _defaultWsUrl = 'ws://localhost:3001/ws';
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  void _connect() {
    state = state.copyWith(isConnecting: true, isConnected: false);
    _channel = WebSocketChannel.connect(Uri.parse(_defaultWsUrl));
    _subscription = _channel?.stream.listen(
      _handleEvent,
      onError: (error) {
        state = state.copyWith(
          isConnecting: false,
          isConnected: false,
          lastError: error.toString(),
        );
      },
      onDone: () {
        state = state.copyWith(isConnecting: false, isConnected: false);
      },
    );
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) {
      return;
    }
    final updated = [...state.messages, ChatMessage(text: message, isUser: true)];
    state = state.copyWith(messages: updated);

    final payload = jsonEncode({
      'type': 'user_message',
      'message': message,
    });
    _channel?.sink.add(payload);
  }

  void _handleEvent(dynamic event) {
    if (event is! String) {
      return;
    }
    final Map<String, dynamic> data = jsonDecode(event) as Map<String, dynamic>;
    switch (data['type']) {
      case 'ready':
        state = state.copyWith(isConnecting: false, isConnected: true);
        return;
      case 'chunk':
        _appendAssistantChunk(data['text']?.toString() ?? '');
        return;
      case 'done':
        _finishAssistantMessage();
        return;
      case 'error':
        state = state.copyWith(
          isConnecting: false,
          isConnected: false,
          lastError: data['message']?.toString(),
        );
        return;
      default:
        return;
    }
  }

  void _appendAssistantChunk(String chunk) {
    if (chunk.isEmpty) {
      return;
    }
    final messages = [...state.messages];
    if (messages.isNotEmpty &&
        !messages.last.isUser &&
        messages.last.isStreaming) {
      final last = messages.last;
      messages[messages.length - 1] =
          last.copyWith(text: '${last.text}$chunk');
    } else {
      messages.add(ChatMessage(text: chunk, isUser: false, isStreaming: true));
    }
    state = state.copyWith(messages: messages);
  }

  void _finishAssistantMessage() {
    final messages = [...state.messages];
    if (messages.isNotEmpty &&
        !messages.last.isUser &&
        messages.last.isStreaming) {
      final last = messages.last;
      messages[messages.length - 1] = last.copyWith(isStreaming: false);
      state = state.copyWith(messages: messages);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
