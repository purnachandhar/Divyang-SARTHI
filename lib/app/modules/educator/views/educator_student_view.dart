import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/widgets/app_table.dart';
import '../../../data/models/student_model.dart';

class EducatorStudentView extends GetView<EducatorController> {
  const EducatorStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingStudents.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                      SizedBox(height: 16),
                      Text('Loading students...',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              }

              if (controller.studentsError.value.isNotEmpty &&
                  controller.students.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 60, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      const Text('Failed to load students',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(controller.studentsError.value,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.fetchStudents,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                );
              }

              if (controller.students.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined,
                          size: 70, color: AppTheme.textSecondary),
                      SizedBox(height: 16),
                      Text('No students found',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 8),
                      Text('No students assigned to your access ID yet.',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              }

              return ResponsiveLayout(
                mobile: _buildStudentList(isMobile: true),
                desktop: _buildStudentList(isMobile: false),
              );
            }),
          ),
        ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Students',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
                controller.isLoadingStudents.value
                    ? 'Fetching students...'
                    : '${controller.students.length} student(s) assigned',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStudentList({required bool isMobile}) {
    if (isMobile) {
      return RefreshIndicator(
        onRefresh: controller.fetchStudents,
        color: AppTheme.primaryColor,
        child: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: controller.students.length,
              itemBuilder: (context, index) {
                final student = controller.students[index];
                return _StudentCard(
                  student: student,
                  onTap: () =>
                      controller.viewStudentDetail(student.toFullMap()),
                );
              },
            )),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() => AppTable(
              columns: const [
                'Name',
                'Enrollment',
                'Class',
                'Gender',
                'Status',
                'Actions'
              ],
              rows: controller.students.map((student) {
                final bool isMale = student.gender.toLowerCase() == 'male';
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 15,
                            backgroundColor:
                                (isMale ? Colors.blue : Colors.pink)
                                    .withOpacity(0.1),
                            child: Icon(
                              isMale
                                  ? Icons.face
                                  : Icons.face_retouching_natural,
                              color: isMale ? Colors.blue : Colors.pink,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(student.displayName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    DataCell(Text(student.enrollmentId)),
                    DataCell(Text(student.className)),
                    DataCell(Text(student.gender.capitalizeFirst!)),
                    DataCell(Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        student.status,
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                    DataCell(Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility,
                              color: AppTheme.primaryColor, size: 20),
                          onPressed: () =>
                              controller.viewStudentDetail(student.toFullMap()),
                          tooltip: 'View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.history,
                              color: Colors.blue, size: 20),
                          onPressed: () {},
                          tooltip: 'Attendance History',
                        ),
                      ],
                    )),
                  ],
                );
              }).toList(),
            )),
      );
    }
  }
}

class _StudentCard extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _StudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isMale = student.gender.toLowerCase() == 'male';

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
                child: student.profilePhoto != null &&
                        student.profilePhoto!.startsWith('http')
                    ? ClipOval(
                        child: Image.network(
                          student.profilePhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            isMale ? Icons.face : Icons.face_retouching_natural,
                            color: isMale ? Colors.blue : Colors.pink,
                            size: 30,
                          ),
                        ),
                      )
                    : Icon(
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
                      student.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${student.username} · ID: ${student.enrollmentId}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            student.className,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isMale ? Icons.male : Icons.female,
                          size: 14,
                          color: isMale ? Colors.blue : Colors.pink,
                        ),
                      ],
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
                      student.status,
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
