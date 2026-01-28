import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal AI Assistant'),
      ),
      body: Center(
        child: FilledButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/chat'),
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Open Chat'),
        ),
      ),
    );
  }
}
