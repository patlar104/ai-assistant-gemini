import 'dart:async';
import 'dart:convert';
import 'dart:html';

import '../config/api_config.dart';
import 'chat_stream_client.dart';

ChatStreamClient createChatStreamClientImpl() => const WebChatStreamClient();

class WebChatStreamClient implements ChatStreamClient {
  const WebChatStreamClient();

  @override
  Stream<ChatStreamEvent> streamChat(String message) {
    final controller = StreamController<ChatStreamEvent>();
    final uri = ApiConfig.chatStreamUri(message);
    final source = EventSource(uri.toString());

    void close() {
      source.close();
      if (!controller.isClosed) {
        controller.close();
      }
    }

    source.addEventListener('chunk', (event) {
      final data = (event as MessageEvent).data?.toString();
      if (data == null) return;
      try {
        final payload = jsonDecode(data) as Map<String, dynamic>;
        final text = payload['text']?.toString() ?? '';
        if (text.isNotEmpty) {
          controller.add(ChatStreamEvent.chunk(text));
        }
      } catch (_) {
        controller.add(ChatStreamEvent.error('Invalid chunk payload'));
      }
    });

    source.addEventListener('done', (_) {
      controller.add(ChatStreamEvent.done());
      close();
    });

    source.addEventListener('error', (event) {
      final message = (event as MessageEvent).data?.toString();
      controller.add(ChatStreamEvent.error(message ?? 'Stream error'));
      close();
    });

    controller.onCancel = close;
    return controller.stream;
  }
}
