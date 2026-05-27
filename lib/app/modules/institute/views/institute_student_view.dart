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
    return Obx(() {
      if (controller.isStudentsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final students = controller.students;

      if (students.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No students found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: controller.fetchStudents,
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      }

      if (isMobile) {
        return RefreshIndicator(
          onRefresh: controller.fetchStudents,
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return _StudentCard(
                student: student,
                onTap: () => controller.viewStudentDetail(student),
              );
            },
          ),
        );
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: Get.width - 48),
              child: AppTable(
                columns: const [
                  'S.No',
                  'Photo',
                  'Username',
                  'Student Name',
                  'Enrollment Number',
                  'Class',
                  'Gender',
                  'Date Of Birth',
                  'Status',
                  'Action'
                ],
                rows: List<DataRow>.generate(students.length, (index) {
                  final student = students[index];
                  final bool isMale =
                      student['gender']?.toString().toLowerCase() == 'male';
                  final String studentName =
                      student['fullName'] ?? student['userName'] ?? 'N/A';
                  final String enrollment =
                      student['enrollmentNumber'] ?? 'N/A';
                  final String userName = student['userName'] ?? 'N/A';
                  final String className = student['class'] ?? 'N/A';
                  final String gender =
                      student['gender']?.toString().capitalizeFirst ?? 'N/A';
                  final String dob =
                      student['dateOfBirth']?.toString().split('T').first ??
                          'N/A';
                  final bool isVerified = student['isVerified'] ?? false;
                  final String studentDP = student['studentDP'] ?? '';

                  return DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: (isMale ? Colors.blue : Colors.pink)
                              .withOpacity(0.1),
                          backgroundImage: studentDP.isNotEmpty
                              ? NetworkImage(studentDP)
                              : null,
                          child: studentDP.isEmpty
                              ? Icon(
                                  isMale
                                      ? Icons.face
                                      : Icons.face_retouching_natural,
                                  color: isMale ? Colors.blue : Colors.pink,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                      DataCell(Text(userName)),
                      DataCell(Text(studentName,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(enrollment)),
                      DataCell(Text(className)),
                      DataCell(Text(gender)),
                      DataCell(Text(dob)),
                      DataCell(Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isVerified ? Colors.green : Colors.orange)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isVerified ? 'Verified' : 'Pending',
                          style: TextStyle(
                            color: isVerified ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility,
                                color: AppTheme.primaryColor, size: 20),
                            onPressed: () =>
                                controller.viewStudentDetail(student),
                            tooltip: 'View',
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.blue, size: 20),
                            onPressed: () {},
                            tooltip: 'Edit',
                          ),
                        ],
                      )),
                    ],
                  );
                }),
              ),
            ),
          ),
        );
      }
    });
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onTap;

  const _StudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isMale = student['gender']?.toString().toLowerCase() == 'male';
    final String studentName =
        student['fullName'] ?? student['userName'] ?? 'N/A';
    final String enrollment = student['enrollmentNumber'] ?? 'N/A';
    final String className = student['class'] ?? 'N/A';
    final bool isVerified = student['isVerified'] ?? false;
    final String studentDP = student['studentDP'] ?? '';

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
                  image: studentDP.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(studentDP), fit: BoxFit.cover)
                      : null,
                ),
                child: studentDP.isEmpty
                    ? Icon(
                        isMale ? Icons.face : Icons.face_retouching_natural,
                        color: isMale ? Colors.blue : Colors.pink,
                        size: 30,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $enrollment',
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
                        className,
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
                      color: (isVerified ? Colors.green : Colors.orange)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        color: isVerified ? Colors.green : Colors.orange,
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
