import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlarmSettingScreen extends StatefulWidget {
  const AlarmSettingScreen({super.key});

  @override
  State<AlarmSettingScreen> createState() => _AlarmSettingScreenState();
}

class _AlarmSettingScreenState extends State<AlarmSettingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  // Fayldan audio tanlash
  // Fayldan audio tanlash
  // Fayldan audio tanlash
 // Fayldan audio tanlash
  Future<void> _pickAudioFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav'],
    );

    if (result.isNotEmpty) {
      final path = result.first.path;
      if (path != null) {
        await _saveAudioPath(path);
      }
    }
  }
  // Ovoz yozib olish
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      if (path != null) {
        await _saveAudioPath(path);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            '${dir.path}/motivation_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() {
          _isRecording = true;
        });
      }
    }
  }

  Future<void> _saveAudioPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_audio_path', path);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Motivatsiya signali saqlandi!")),
      );
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signal va Motivatsiya Audiolari")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.audio_file, color: Colors.cyan),
              title: const Text("Xotiradan audio tanlash"),
              subtitle: const Text(".mp3, .m4a yoki .wav fayllarini ko'rsating"),
              onTap: _pickAudioFile,
            ),
            const Divider(),
            ListTile(
              leading: Icon(_isRecording ? Icons.stop : Icons.mic,
                  color: Colors.red),
              title: Text(_isRecording
                  ? "Yozib olishni to'xtatish"
                  : "O'z ovozingiz bilan motivatsiya yozish"),
              subtitle: Text(_isRecording
                  ? "Yozib olinmoqda..."
                  : "Tugmani bosib yozishni boshlang"),
              onTap: _toggleRecording,
            ),
          ],
        ),
      ),
    );
  }
}