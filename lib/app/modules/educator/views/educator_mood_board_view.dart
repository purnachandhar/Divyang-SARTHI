import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class EducatorMoodBoardView extends GetView<EducatorController> {
  const EducatorMoodBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> students = [
      {'name': 'test1111', 'enrollment': '2026DIVG055219', 'gender': 'male'},
      {'name': 'speechtherapist', 'enrollment': '2026DIVG053404', 'gender': 'female'},
      {'name': 'Physio', 'enrollment': '2025DIVG008665', 'gender': 'male'},
      {'name': 'occupationalstudent', 'enrollment': '2026DIVG050795', 'gender': 'female'},
      {'name': 'DishaNiepid', 'enrollment': '2026DIVG049544', 'gender': 'female'},
      {'name': 'MohitTestssssssss', 'enrollment': '2026DIVG047807', 'gender': 'female'},
      {'name': 'Abdu555FACP', 'enrollment': '2026DIVG041627', 'gender': 'male'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ResponsiveLayout(
              mobile: _buildMobileLayout(students),
              desktop: _buildDesktopLayout(students),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<Map<String, String>> students) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildStudentCard(students[index]);
      },
    );
  }

  Widget _buildDesktopLayout(List<Map<String, String>> students) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 100,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: students.length,
      itemBuilder: (context, index) {
        return _buildStudentCard(students[index]);
      },
    );
  }

  Widget _buildStudentCard(Map<String, String> student) {
    final bool isMale = student['gender'] == 'male';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
          child: Icon(
            isMale ? Icons.face : Icons.face_retouching_natural,
            color: isMale ? Colors.blue : Colors.pink,
          ),
        ),
        title: Text(
          student['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'ID: ${student['enrollment']}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textSecondary),
        onTap: () => controller.goToMoodBoardSubmission(student),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Board',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select a student to record mood',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
