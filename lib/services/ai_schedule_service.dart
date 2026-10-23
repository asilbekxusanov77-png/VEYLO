import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AiScheduleService {
  final String apiKey; 

  AiScheduleService({required this.apiKey});

  Future<List<Map<String, String>>> generateSchedule(String userPrompt) async {
    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final prompt = '''
Siz kunlik reja tuzuvchi yordamchisiz.
Foydalanuvchi so'rovi: "$userPrompt"

DIQQAT: Faqat va faqat quyidagi JSON formatida javob bering, hech qanday ortiqcha matn, kirish yoki markdown (masalan ```json) YOZMANX.

[
  {"title": "Ertalabki badantarbbiya", "time": "07:00 - 07:30"},
  {"title": "Nonushta", "time": "07:30 - 08:00"}
]
Javobingiz faqatgina yuqoridagi formatda bo'lishi kerak.
''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          // Ixtiyoriy: OpenRouter uchun ilova nomi va vebsayt sarlavhasi
          'HTTP-Referer': '[https://veylo.uz](https://veylo.uz)', 
          'X-Title': 'Veylo App',
        },
        body: jsonEncode({
          'model': 'google/gemini-1.5-flash', // OpenRouter model formati
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final String? content = data['choices']?[0]?['message']?['content'];

        if (content != null && content.isNotEmpty) {
          // Markdown belgilarini tozalash
          String cleanJson = content
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();

          final List<dynamic> decodedList = jsonDecode(cleanJson);

          return decodedList.map((item) {
            return {
              'title': item['title']?.toString() ?? '',
              'time': item['time']?.toString() ?? '',
            };
          }).toList();
        }
      } else {
        debugPrint('OpenRouter xatosi status kodi: ${response.statusCode}');
        debugPrint('Xato matni: ${response.body}');
      }
    } catch (e) {
      debugPrint('AI reja tuzishda kutilmagan xatolik: $e');
    }

    return [];
  }
}