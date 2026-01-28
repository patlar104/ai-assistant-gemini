import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';
import 'chat_stream_client.dart';

ChatStreamClient createChatStreamClientImpl() => const HttpChatStreamClient();

class HttpChatStreamClient implements ChatStreamClient {
  const HttpChatStreamClient();

  @override
  Stream<ChatStreamEvent> streamChat(String message) {
    final controller = StreamController<ChatStreamEvent>();
    final client = HttpClient();

    Future<void>(() async {
      try {
        final request = await client.postUrl(ApiConfig.chatStreamPostUri());
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
        request.add(utf8.encode(jsonEncode({'message': message})));

        final response = await request.close();
        if (response.statusCode != HttpStatus.ok) {
          final body = await response.transform(utf8.decoder).join();
          controller.add(ChatStreamEvent.error(
            'Stream failed: ${response.statusCode} $body',
          ));
          return;
        }

        String? currentEvent;
        String? currentData;

        await for (final line
            in response.transform(utf8.decoder).transform(const LineSplitter())) {
          if (line.isEmpty) {
            _emitEvent(controller, currentEvent, currentData);
            currentEvent = null;
            currentData = null;
            continue;
          }
          if (line.startsWith('event:')) {
            currentEvent = line.substring(6).trim();
            continue;
          }
          if (line.startsWith('data:')) {
            currentData = line.substring(5).trim();
          }
        }
      } catch (error) {
        controller.add(ChatStreamEvent.error(error.toString()));
      } finally {
        client.close(force: true);
        await controller.close();
      }
    });

    controller.onCancel = () {
      client.close(force: true);
    };

    return controller.stream;
  }

  void _emitEvent(StreamController<ChatStreamEvent> controller, String? event,
      String? data) {
    if (event == null) {
      return;
    }
    switch (event) {
      case 'chunk':
        if (data == null || data.isEmpty) {
          return;
        }
        try {
          final payload = jsonDecode(data) as Map<String, dynamic>;
          final text = payload['text']?.toString() ?? '';
          if (text.isNotEmpty) {
            controller.add(ChatStreamEvent.chunk(text));
          }
        } catch (_) {
          controller.add(ChatStreamEvent.error('Invalid chunk payload'));
        }
        return;
      case 'done':
        controller.add(ChatStreamEvent.done());
        return;
      case 'error':
        controller.add(ChatStreamEvent.error(data ?? 'Unknown error'));
        return;
      default:
        return;
    }
  }
}
