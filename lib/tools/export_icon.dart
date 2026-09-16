import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../widgets/app_icon_painter.dart';

class IconExporter extends StatelessWidget {
  const IconExporter({super.key});

  Future<void> _exportIcon(BuildContext context) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = AppIconPainter();
    const size = Size(512, 512);

    painter.paint(canvas, size);
    final picture = recorder.endRecording();
    final image = await picture.toImage(512, 512);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null && context.mounted) {
      final buffer = byteData.buffer.asUint8List();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PNG rasm tayyorlandi! Hajmi: ${buffer.length} bytes'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(title: const Text('Icon Generator')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(painter: AppIconPainter()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _exportIcon(context),
              child: const Text('Ikonkani yaratish'),
            ),
          ],
        ),
      ),
    );
  }
}