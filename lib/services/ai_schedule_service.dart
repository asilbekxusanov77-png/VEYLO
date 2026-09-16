import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AiScheduleService {
  final String apiKey;

  AiScheduleService({required this.apiKey});

  Future<List<Map<String, String>>> generateSchedule(String userPrompt) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );

    final prompt = '''
Siz aqlli rejalashtiruvchi yordamchisiz. Foydalanuvchi quyidagi matnda nimani rejalashtirmoqchi ekanligini aytdi:
"$userPrompt"

Vazifangiz: Foydalanuvchi so'rovini tahlil qilib, darslar yoki vazifalar ro'yxatini JSON massiv holatida qaytarish.
Har bir obyekt quyidagi kalitlarga ega bo'lishi SHART:
- "title": Vazifa yoki dars nomi.
- "time": Bajarilish vaqti (Masalan: "09:00 - 10:00" yoki "Bugun kechki payt").

Faqat va faqat JSON massivini qaytaring. Boshqa matn yoki izoh yoza ko'rmang.
Misol format:
[
  {"title": "Matematika darsi", "time": "09:00 - 10:00"},
  {"title": "Ingliz tili so'zlarini yodlash", "time": "11:00 - 12:00"}
]
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final String? responseText = response.text;

      if (responseText != null && responseText.isNotEmpty) {
        final List<dynamic> decodedList = jsonDecode(responseText);
        return decodedList
            .map((item) => {
                  'title': item['title']?.toString() ?? '',
                  'time': item['time']?.toString() ?? '',
                })
            .toList();
      }
    } catch (e) {
      debugPrint('AI reja tuzishda xatolik: $e');
    }
    return [];
  }
}