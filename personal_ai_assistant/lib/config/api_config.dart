class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );

  static Uri chatStreamUri(String message) {
    return Uri.parse('$baseUrl/api/chat/stream')
        .replace(queryParameters: {'message': message});
  }

  static Uri chatStreamPostUri() {
    return Uri.parse('$baseUrl/api/chat/stream');
  }
}
