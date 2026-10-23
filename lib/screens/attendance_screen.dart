import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  void _showAddStudentDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16192E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Yangi talaba qo\'shish',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Ism va familiya',
              hintStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF5B4CE6)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF6C5CE7)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Bekor qilish',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
              ),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Provider.of<AttendanceProvider>(
                    context,
                    listen: false,
                  ).addStudent(nameController.text);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Qo\'shish',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendance = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F1D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ustozlar uchun davomat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0C0F1D),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // Yuqori statistika kartochkasi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16192E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat(
                        'Jami',
                        '${attendance.students.length} ta',
                        Colors.white,
                      ),
                      _buildHeaderStat(
                        'Darsda',
                        '${attendance.presentCount} ta',
                        const Color(0xFF4CD97B),
                      ),
                      _buildHeaderStat(
                        'Yo\'q',
                        '${attendance.absentCount} ta',
                        const Color(0xFFE55656),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Color(0xFF2A2E45), thickness: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Davomat ko\'rsatkichi:',
                        style: TextStyle(
                          color: Color(0xFFA0A7C2),
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${attendance.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 253, 254, 254),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Talabalar ro'yxati
            Expanded(
              child: ListView.builder(
                itemCount: attendance.students.length,
                itemBuilder: (context, index) {
                  final student = attendance.students[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: Key(student.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        attendance.removeStudent(index);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE55656),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16192E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Tartib raqami
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E266E),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // O'quvchi ismi
                            Expanded(
                              child: Text(
                                student.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Davomat holati tugmasi
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => attendance.toggleAttendance(index),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: student.isPresent
                                      ? const Color(0xFF1E3A2F)
                                      : const Color(0xFF3D232A),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: student.isPresent
                                        ? const Color(0xFF4CD97B)
                                        : const Color(0xFFE55656),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  student.isPresent ? 'Darsda' : 'Yo\'q',
                                  style: TextStyle(
                                    color: student.isPresent
                                        ? const Color(0xFF4CD97B)
                                        : const Color(0xFFE55656),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C5CE7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showAddStudentDialog(context),
        child: const Icon(Icons.person_add_alt_1, color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderStat(String title, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFFA0A7C2), fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
