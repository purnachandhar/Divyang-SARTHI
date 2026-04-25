import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/widgets/app_table.dart';

class InstituteStudentView extends GetView<InstituteController> {
  const InstituteStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ResponsiveLayout(
              mobile: _buildStudentList(isMobile: true),
              desktop: _buildStudentList(isMobile: false),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'student_fab',
        onPressed: controller.goToAddStudent,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
            'Students',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage and track all students in your institute',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList({required bool isMobile}) {
    final List<Map<String, String>> students = [
      {
        'name': 'Arjun Singh',
        'enrollment': '2026DIVG055219',
        'gender': 'male',
        'class': 'Grade 3',
        'status': 'Active'
      },
      {
        'name': 'Riya Singh',
        'enrollment': '2026DIVG053404',
        'gender': 'female',
        'class': 'Preprimary',
        'status': 'Active'
      },
      {
        'name': 'Karan Gupta',
        'enrollment': '2026DIVG055754',
        'gender': 'male',
        'class': 'Grade 1',
        'status': 'Active'
      },
      {
        'name': 'Sandeep',
        'enrollment': '2025DIVG008674',
        'class': 'Secondary',
        'gender': 'male',
        'status': 'Active'
      },
      {
        'name': 'Test Niepid Disha',
        'enrollment': '2026DIVG050799',
        'class': 'Preprimary',
        'gender': 'female',
        'status': 'Active'
      },
    ];

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return _StudentCard(
            student: student,
            onTap: () => controller.viewStudentDetail(student),
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: AppTable(
          columns: const ['Name', 'Enrollment', 'Class', 'Gender', 'Status', 'Actions'],
          rows: students.map((student) {
            final bool isMale = student['gender'] == 'male';
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
                        child: Icon(
                          isMale ? Icons.face : Icons.face_retouching_natural,
                          color: isMale ? Colors.blue : Colors.pink,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(student['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                DataCell(Text(student['enrollment']!)),
                DataCell(Text(student['class']!)),
                DataCell(Text(student['gender']!.capitalizeFirst!)),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(student['status']!, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: AppTheme.primaryColor, size: 20),
                      onPressed: () => controller.viewStudentDetail(student),
                      tooltip: 'View',
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                      onPressed: () {},
                      tooltip: 'Edit',
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      );
    }
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, String> student;
  final VoidCallback onTap;

  const _StudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isMale = student['gender'] == 'male';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMale ? Icons.face : Icons.face_retouching_natural,
                  color: isMale ? Colors.blue : Colors.pink,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${student['enrollment']}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        student['class']!,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      student['status']!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppTheme.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
