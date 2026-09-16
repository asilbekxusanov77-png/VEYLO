import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsScreen extends StatefulWidget {
  const TtsScreen({super.key});

  @override
  State<TtsScreen> createState() => _TtsScreenState();
}

class _TtsScreenState extends State<TtsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();

  double _rate = 0.5;   // Tezlik (0.0 - 1.0)
  double _pitch = 1.0;  // Ovoz toni (0.5 - 2.0) — Erkak/Ayol ovozi uchun
  double _volume = 1.0; // Ovoz balandligi (0.0 - 1.0)

  List<dynamic> _voices = [];
  Map<String, String>? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(_rate);
    await flutterTts.setPitch(_pitch);
    await flutterTts.setVolume(_volume);

    try {
      final voices = await flutterTts.getVoices;
      if (voices != null) {
        setState(() {
          _voices = voices as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint("Ovozlarni yuklashda xato: $e");
    }
  }

  Future<void> _speak() async {
    if (_textController.text.trim().isEmpty) return;

    await flutterTts.setSpeechRate(_rate);
    await flutterTts.setPitch(_pitch);
    await flutterTts.setVolume(_volume);

    if (_selectedVoice != null) {
      await flutterTts.setVoice(_selectedVoice!);
    }

    await flutterTts.speak(_textController.text);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Text → Audio", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Matn kiritish maydoni
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _textController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Matnni kiriting...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // O'qish va To'xtatish tugmalari
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _speak,
                  icon: const Icon(Icons.volume_up, color: Colors.black),
                  label: const Text("O'qish", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00F5D4),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _stop,
                  icon: const Icon(Icons.stop_circle, color: Colors.redAccent, size: 38),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sozlamalar bloki
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tezlik: ${_rate.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: _rate,
                    min: 0.0,
                    max: 1.0,
                    activeColor: const Color(0xFF00F5D4),
                    onChanged: (val) => setState(() => _rate = val),
                  ),
                  Text("Ovoz toni (Pitch): ${_pitch.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    activeColor: const Color(0xFF00F5D4),
                    onChanged: (val) => setState(() => _pitch = val),
                  ),
                  Text("Ovoz balandligi: ${_volume.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: const Color(0xFF00F5D4),
                    onChanged: (val) => setState(() => _volume = val),
                  ),
                  if (_voices.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text("Ovoz turi (Erkak/Ayol):", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 4),
                    DropdownButton<Map<String, String>>(
                      dropdownColor: const Color(0xFF1B263B),
                      isExpanded: true,
                      value: _selectedVoice,
                      hint: const Text("Ovozni tanlang", style: TextStyle(color: Colors.white54)),
                      items: _voices.map<DropdownMenuItem<Map<String, String>>>((dynamic voice) {
                        final Map<String, String> v = Map<String, String>.from(voice as Map);
                        return DropdownMenuItem<Map<String, String>>(
                          value: v,
                          child: Text(
                            "${v['name']} (${v['locale']})",
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedVoice = val),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}