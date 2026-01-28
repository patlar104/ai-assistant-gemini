import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../config/api_config.dart';
import 'chat_stream_client.dart';

ChatStreamClient createChatStreamClientImpl() => const WebChatStreamClient();

class WebChatStreamClient implements ChatStreamClient {
  const WebChatStreamClient();

  @override
  Stream<ChatStreamEvent> streamChat(String message) {
    final controller = StreamController<ChatStreamEvent>();
    final uri = ApiConfig.chatStreamUri(message);
    final source = web.EventSource(uri.toString());

    void close() {
      source.close();
      if (!controller.isClosed) {
        controller.close();
      }
    }

    final web.EventListener onChunk = ((web.Event event) {
      final data = (event as web.MessageEvent).data?.toString();
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
    }).toJS;

    final web.EventListener onDone = ((web.Event _) {
      controller.add(ChatStreamEvent.done());
      close();
    }).toJS;

    final web.EventListener onError = ((web.Event event) {
      final message = (event as web.MessageEvent).data?.toString();
      controller.add(ChatStreamEvent.error(message ?? 'Stream error'));
      close();
    }).toJS;

    source.addEventListener('chunk', onChunk);
    source.addEventListener('done', onDone);
    source.addEventListener('error', onError);

    controller.onCancel = close;
    return controller.stream;
  }
}
