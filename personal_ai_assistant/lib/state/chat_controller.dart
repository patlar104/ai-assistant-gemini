import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import '../services/chat_stream_client.dart';
import 'chat_state.dart';

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() {
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    return const ChatState(
      messages: [
        ChatMessage(
          text: 'Hello! Ask me anything to get started.',
          isUser: false,
        ),
      ],
    );
  }

  StreamSubscription<ChatStreamEvent>? _streamSubscription;

  void sendMessage(String message) {
    if (message.trim().isEmpty) {
      return;
    }
    final updated = [...state.messages, ChatMessage(text: message, isUser: true)];
    state = state.copyWith(messages: updated);
    _startStream(message);
  }

  Future<void> _startStream(String message) async {
    state = state.copyWith(isStreaming: true, lastError: null);
    await _streamSubscription?.cancel();
    final stream = ref.read(chatStreamClientProvider).streamChat(message);
    _streamSubscription = stream.listen(
      _handleStreamEvent,
      onError: (error) {
        state = state.copyWith(isStreaming: false, lastError: error.toString());
      },
      onDone: () {
        state = state.copyWith(isStreaming: false);
      },
    );
  }

  void _handleStreamEvent(ChatStreamEvent event) {
    switch (event.type) {
      case ChatStreamEventType.chunk:
        _appendAssistantChunk(event.text ?? '');
        return;
      case ChatStreamEventType.done:
        _finishAssistantMessage();
        state = state.copyWith(isStreaming: false);
        return;
      case ChatStreamEventType.error:
        state = state.copyWith(
          isStreaming: false,
          lastError: event.message ?? 'Unknown error',
        );
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

}
