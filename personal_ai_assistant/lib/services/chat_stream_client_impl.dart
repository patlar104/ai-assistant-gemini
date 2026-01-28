import 'chat_stream_client.dart';
import 'chat_stream_client_io.dart'
    if (dart.library.html) 'chat_stream_client_web.dart';

// The actual implementation is selected via conditional imports.
ChatStreamClient createChatStreamClient() => createChatStreamClientImpl();
