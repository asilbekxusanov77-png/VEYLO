import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _controller = TextEditingController();
  
  bool _isPlaying = false;
  double _pitch = 1.0;       // Ovoz toni (0.5 - 2.0)
  double _speechRate = 0.5;  // Ovoz tezligi (0.0 - 1.0)
  double _volume = 1.0;      // Ovoz balandligi (0.0 - 1.0)

  List<dynamic> _voices = [];
  Map<String, String>? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    
    _flutterTts.setStartHandler(() => setState(() => _isPlaying = true));
    _flutterTts.setCompletionHandler(() => setState(() => _isPlaying = false));
    _flutterTts.setErrorHandler((msg) => setState(() => _isPlaying = false));

    try {
      final voices = await _flutterTts.getVoices;
      if (voices != null) {
        setState(() {
          _voices = voices as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint("Ovoz shakllarini olishda xato: $e");
    }
  }

  Future<void> _speak() async {
    if (_controller.text.trim().isNotEmpty) {
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);

      if (_selectedVoice != null) {
        await _flutterTts.setVoice(_selectedVoice!);
      }

      await _flutterTts.speak(_controller.text);
    }
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101B35),
        title: const Text('Text → Audio', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ovozga aylantirish uchun matn kiriting...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF101B35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying ? Colors.orangeAccent : Colors.cyanAccent,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              onPressed: _isPlaying ? _stop : _speak,
              icon: Icon(_isPlaying ? Icons.stop : Icons.volume_up, color: Colors.black),
              label: Text(
                _isPlaying ? 'To\'xtatish' : 'O\'qish',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // Sozlamalar paneli (Tezlik, Ton va Erkak/Ayol ovozlari)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF101B35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tezlik: ${_speechRate.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: _speechRate,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) => setState(() => _speechRate = val),
                  ),
                  Text("Ovoz toni / Pitch: ${_pitch.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: _pitch,
                    min: 0.5,
                    max: 2.0,
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) => setState(() => _pitch = val),
                  ),
                  Text("Ovoz balandligi: ${_volume.toStringAsFixed(1)}", style: const TextStyle(color: Colors.white)),
                  Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) => setState(() => _volume = val),
                  ),
                  if (_voices.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text("Ovoz turi (Erkak / Ayol):", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 6),
                    DropdownButton<Map<String, String>>(
                      dropdownColor: const Color(0xFF101B35),
                      isExpanded: true,
                      value: _selectedVoice,
                      hint: const Text("Ovozni tanlang", style: TextStyle(color: Colors.grey)),
                      items: _voices.map<DropdownMenuItem<Map<String, String>>>((dynamic voice) {
                        final Map<String, String> v = Map<String, String>.from(voice as Map);
                        return DropdownMenuItem<Map<String, String>>(
                          value: v,
                          child: Text(
                            "${v['name']} (${v['locale']})",
                            style: const TextStyle(color: Colors.white, fontSize: 13),
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