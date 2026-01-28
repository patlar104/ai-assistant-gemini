import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:personal_ai_assistant/main.dart';
import 'package:personal_ai_assistant/services/chat_stream_client.dart';

class FakeChatStreamClient implements ChatStreamClient {
  FakeChatStreamClient(this._stream);

  final Stream<ChatStreamEvent> _stream;

  @override
  Stream<ChatStreamEvent> streamChat(String message) => _stream;
}

Future<void> _openChat(WidgetTester tester) async {
  await tester.tap(find.text('Open Chat'));
  await tester.pumpAndSettle();
}

Future<void> _sendMessage(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.byIcon(Icons.send));
  await tester.pump();
}

void main() {
  testWidgets('Streams assistant reply chunks', (tester) async {
    final controller = StreamController<ChatStreamEvent>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatStreamClientProvider
              .overrideWithValue(FakeChatStreamClient(controller.stream)),
        ],
        child: const MyApp(),
      ),
    );

    await _openChat(tester);
    await _sendMessage(tester, 'Hello');

    controller.add(ChatStreamEvent.chunk('Hi'));
    await tester.pump();
    controller.add(ChatStreamEvent.chunk(' there'));
    controller.add(ChatStreamEvent.done());
    await tester.pumpAndSettle();

    expect(find.text('Hi there'), findsOneWidget);
  });

  testWidgets('Shows error banner on stream error', (tester) async {
    final controller = StreamController<ChatStreamEvent>();
    addTearDown(controller.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          chatStreamClientProvider
              .overrideWithValue(FakeChatStreamClient(controller.stream)),
        ],
        child: const MyApp(),
      ),
    );

    await _openChat(tester);
    await _sendMessage(tester, 'Oops');

    controller.add(ChatStreamEvent.error('Stream failed'));
    await tester.pumpAndSettle();

    expect(find.text('Stream failed'), findsOneWidget);
    expect(find.text('Error'), findsOneWidget);
  });
}
