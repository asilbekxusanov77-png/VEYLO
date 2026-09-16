import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/schedule_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(_controller.text);
      _controller.clear();
    }
  }

  // AI orqali avtomatik dars/vazifa rejasini tuzish va jadvalga qo'shish
  Future<void> _generateSchedule() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final scheduleProvider = Provider.of<ScheduleProvider>(context, listen: false);
    
    // API kalitni bu yerga joylashtiring
    const apiKey = '';

    _controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("AI rejalaringizni tuzmoqda, kuting..."),
        duration: Duration(seconds: 2),
      ),
    );

    final success = await scheduleProvider.addTasksFromAi(text, apiKey);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Rejalar muvaffaqiyatli dars jadvaliga qo'shildi!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reja tuzishda xatolik yuz berdi."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101B35),
        title: const Text('AI Chat', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                final msg = chatProvider.messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.cyan.shade900 : const Color(0xFF101B35),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          if (chatProvider.isLoading || scheduleProvider.isLoadingAi)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF101B35),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Xabar yozing yoki reja tuzishni so\'rang...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // AI Reja tuzish tugmasi
                IconButton(
                  tooltip: 'AI orqali reja tuzish',
                  icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
                  onPressed: _generateSchedule,
                ),
                // Oddiy xabar yuborish tugmasi
                IconButton(
                  tooltip: 'Yuborish',
                  icon: const Icon(Icons.send, color: Colors.cyanAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}