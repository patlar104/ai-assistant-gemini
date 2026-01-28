import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';
import 'chat_state.dart';

final chatControllerProvider =
    NotifierProvider<ChatController, ChatState>(ChatController.new);

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() {
    ref.onDispose(() {
      _streamSubscription?.cancel();
      _client?.close(force: true);
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

  static const _streamUrl = 'http://localhost:3001/api/chat/stream';
  HttpClient? _client;
  StreamSubscription<String>? _streamSubscription;

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
    _client?.close(force: true);
    _client = HttpClient();

    try {
      final request = await _client!.postUrl(Uri.parse(_streamUrl));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      request.add(utf8.encode(jsonEncode({'message': message})));

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        final body = await response.transform(utf8.decoder).join();
        throw HttpException(
          'Stream failed: ${response.statusCode} $body',
        );
      }

      String? currentEvent;
      String? currentData;

      _streamSubscription = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.isEmpty) {
          _handleSseEvent(currentEvent, currentData);
          currentEvent = null;
          currentData = null;
          return;
        }
        if (line.startsWith('event:')) {
          currentEvent = line.substring(6).trim();
          return;
        }
        if (line.startsWith('data:')) {
          currentData = line.substring(5).trim();
        }
      }, onError: (error) {
        state = state.copyWith(isStreaming: false, lastError: error.toString());
      }, onDone: () {
        state = state.copyWith(isStreaming: false);
      });
    } catch (error) {
      state = state.copyWith(isStreaming: false, lastError: error.toString());
    }
  }

  void _handleSseEvent(String? event, String? data) {
    if (event == null) {
      return;
    }
    switch (event) {
      case 'chunk':
        if (data == null || data.isEmpty) {
          return;
        }
        final payload = jsonDecode(data) as Map<String, dynamic>;
        _appendAssistantChunk(payload['text']?.toString() ?? '');
        return;
      case 'done':
        _finishAssistantMessage();
        return;
      case 'error':
        state = state.copyWith(isStreaming: false, lastError: data);
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

}
