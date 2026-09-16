import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message_model.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  // GROQ API Kalitingizni shu yerga qo'ying:
  static const String _apiKey = ""; 

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessageModel(
      text: text,
      isUser: true,
      time: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "openai/gpt-oss-20b",
          "messages": [
            {"role": "system", "content": "Siz aqlli va xushmuomala yordamchisiz."},
            ..._messages.map((m) => m.toJson()),
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = data['choices'][0]['message']['content'];
        _messages.add(ChatMessageModel(
          text: reply,
          isUser: false,
          time: DateTime.now(),
        ));
      } else {
        _messages.add(ChatMessageModel(
          text: "Xatolik yuz berdi (Status: ${response.statusCode}). API kalitni tekshiring.",
          isUser: false,
          time: DateTime.now(),
        ));
      }
    } catch (e) {
      _messages.add(ChatMessageModel(
        text: "Tarmoq ulanishida xatolik yuz berdi.",
        isUser: false,
        time: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}