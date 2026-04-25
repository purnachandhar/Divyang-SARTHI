import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class EducatorAttendanceView extends GetView<EducatorController> {
  const EducatorAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildDateSelector(),
          Expanded(
            child: ResponsiveLayout(
              mobile: _buildStudentAttendanceList(isMobile: true),
              desktop: _buildStudentAttendanceList(isMobile: false),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: Icon(Icons.search, color: Colors.white70),
                hintText: 'Search Students',
                hintStyle: TextStyle(color: Colors.white60),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              controller.updateSelectedDate(
                controller.selectedDate.value.subtract(const Duration(days: 1)),
              );
            },
            icon: const Icon(Icons.chevron_left, color: AppTheme.primaryColor),
          ),
          Obx(() => Column(
                children: [
                  Text(
                    DateFormat('EEEE, d MMM yyyy').format(controller.selectedDate.value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Marking attendance for today',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              )),
          IconButton(
            onPressed: () {
              controller.updateSelectedDate(
                controller.selectedDate.value.add(const Duration(days: 1)),
              );
            },
            icon: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentAttendanceList({required bool isMobile}) {
    final List<Map<String, String>> students = [
      {'username': 'test1111', 'gender': 'male', 'id': '2026DIVG055219'},
      {'username': 'speechtherapist', 'gender': 'female', 'id': '2026DIVG053404'},
      {'username': 'Physio', 'gender': 'male', 'id': '2025DIVG008665'},
      {'username': 'occupationalstudent', 'gender': 'female', 'id': '2026DIVG050795'},
      {'username': 'DishaNiepid', 'gender': 'female', 'id': '2026DIVG049544'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        return _AttendanceCard(student: students[index]);
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Get.snackbar(
            'Success',
            'Attendance submitted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Submit Attendance',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatefulWidget {
  final Map<String, String> student;

  const _AttendanceCard({required this.student});

  @override
  State<_AttendanceCard> createState() => _AttendanceCardState();
}

enum AttendanceStatus { present, absent, leave }

class _AttendanceCardState extends State<_AttendanceCard> {
  AttendanceStatus? status;

  @override
  Widget build(BuildContext context) {
    final bool isMale = widget.student['gender'] == 'male';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
            child: Icon(
              isMale ? Icons.face : Icons.face_retouching_natural,
              color: isMale ? Colors.blue : Colors.pink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student['username']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'ID: ${widget.student['id']}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildStatusButton(AttendanceStatus.present, 'P', Colors.green),
              const SizedBox(width: 8),
              _buildStatusButton(AttendanceStatus.absent, 'A', Colors.red),
              const SizedBox(width: 8),
              _buildStatusButton(AttendanceStatus.leave, 'L', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(AttendanceStatus targetStatus, String label, Color color) {
    final bool isSelected = status == targetStatus;
    return GestureDetector(
      onTap: () {
        setState(() {
          status = targetStatus;
        });
      },
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
