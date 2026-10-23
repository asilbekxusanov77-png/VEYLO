import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class AlarmSettingScreen extends StatefulWidget {
  const AlarmSettingScreen({super.key});

  @override
  State<AlarmSettingScreen> createState() => _AlarmSettingScreenState();
}

class _AlarmSettingScreenState extends State<AlarmSettingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRecording = false;
  List<String> _audioPaths = [];
  List<String> _audioNames = [];
  String? _selectedAudioPath;
  String? _playingPath;

  @override
  void initState() {
    super.initState();
    _loadAudios();
  }

  Future<void> _loadAudios() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _audioPaths = prefs.getStringList('saved_audio_paths') ?? [];
      _audioNames = prefs.getStringList('saved_audio_names') ?? [];
      _selectedAudioPath = prefs.getString('selected_audio_path') ?? (_audioPaths.isNotEmpty ? _audioPaths.first : null);
    });
  }

  Future<void> _saveNewAudio(String path, String name) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!_audioPaths.contains(path)) {
      _audioPaths.add(path);
      _audioNames.add(name);
      
      await prefs.setStringList('saved_audio_paths', _audioPaths);
      await prefs.setStringList('saved_audio_names', _audioNames);
    }
    
    if (_selectedAudioPath == null) {
      _selectedAudioPath = path;
      await prefs.setString('selected_audio_path', path);
    }

    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio muvaffaqiyatli saqlandi!")),
      );
    }
  }

  Future<void> _selectAudio(String path) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedAudioPath = path;
    });
    await prefs.setString('selected_audio_path', path);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signal uchun tanlandi!")),
      );
    }
  }

  Future<void> _deleteAudio(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final path = _audioPaths[index];

    setState(() {
      _audioPaths.removeAt(index);
      _audioNames.removeAt(index);
      if (_selectedAudioPath == path) {
        _selectedAudioPath = _audioPaths.isNotEmpty ? _audioPaths.first : null;
      }
    });

    await prefs.setStringList('saved_audio_paths', _audioPaths);
    await prefs.setStringList('saved_audio_names', _audioNames);
    if (_selectedAudioPath != null) {
      await prefs.setString('selected_audio_path', _selectedAudioPath!);
    } else {
      await prefs.remove('selected_audio_path');
    }
  }

  Future<void> _playPauseAudio(String path) async {
    try {
      if (_playingPath == path) {
        await _audioPlayer.stop();
        setState(() => _playingPath = null);
      } else {
        await _audioPlayer.stop();
        
        if (kIsWeb) {
          await _audioPlayer.play(UrlSource(path));
        } else {
          await _audioPlayer.play(DeviceFileSource(path));
        }

        setState(() => _playingPath = path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb 
                ? "Brauzerda fayl xavfsizligi tufayli bu faylni to'g'ridan-to'g'ri ijro etib bo'lmadi."
                : "Audioni ijro etishda xatolik: $e",
            ),
          ),
        );
      }
      setState(() => _playingPath = null);
    }
  }

  // result != null tekshiruvi olib tashlandi (unnecessary_null_comparison xatosi oldi olindi)
  Future<void> _pickAudioFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav'],
    );

    if (result.isNotEmpty) {
      final file = result.first;
      final path = file.path ?? file.name;
      
      if (path.isNotEmpty) {
        await _saveNewAudio(path, file.name);
      }
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        final name = "Yozib olingan audio_${DateTime.now().millisecondsSinceEpoch}.m4a";
        await _saveNewAudio(path, name);
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        String filePath = '';
        if (kIsWeb) {
          filePath = 'motivation_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        } else {
          final dir = await getApplicationDocumentsDirectory();
          filePath = '${dir.path}/motivation_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }
        await _audioRecorder.start(const RecordConfig(), path: filePath);
        setState(() => _isRecording = true);
      }
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101B35),
        title: const Text("Signal va Motivatsiya Audiolari", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.audio_file, color: Colors.cyanAccent),
              title: const Text("Xotiradan audio tanlash", style: TextStyle(color: Colors.white)),
              subtitle: const Text(".mp3, .m4a yoki .wav fayllarini ko'rsating", style: TextStyle(color: Colors.grey)),
              onTap: _pickAudioFile,
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: Icon(_isRecording ? Icons.stop : Icons.mic, color: _isRecording ? Colors.red : Colors.cyanAccent),
              title: Text(_isRecording ? "Yozib olishni to'xtatish" : "O'z ovozingiz bilan motivatsiya yozish", style: const TextStyle(color: Colors.white)),
              subtitle: Text(_isRecording ? "Yozib olinmoqda..." : "Tugmani bosib yozishni boshlang", style: TextStyle(color: Colors.grey)),
              onTap: _toggleRecording,
            ),
            const SizedBox(height: 20),
            const Text(
              "Saqlangan Audiolar Ro'yxati:",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _audioPaths.isEmpty
                  ? const Center(
                      child: Text("Hozircha audiolar yo'q. Qo'shing yoki yozib oling.", style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      itemCount: _audioPaths.length,
                      itemBuilder: (context, index) {
                        final path = _audioPaths[index];
                        final name = _audioNames.length > index ? _audioNames[index] : path.split('/').last;
                        final isSelected = _selectedAudioPath == path;
                        final isPlaying = _playingPath == path;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131B2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.cyanAccent : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: ListTile(
                            leading: IconButton(
                              icon: Icon(
                                isPlaying ? Icons.pause_circle : Icons.play_circle,
                                color: Colors.cyanAccent,
                                size: 30,
                              ),
                              onPressed: () => _playPauseAudio(path),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              isSelected ? "Signal uchun tanlangan" : "Bosib signal uchun tanlang",
                              style: TextStyle(color: isSelected ? Colors.greenAccent : Colors.grey, fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _deleteAudio(index),
                            ),
                            onTap: () => _selectAudio(path),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}