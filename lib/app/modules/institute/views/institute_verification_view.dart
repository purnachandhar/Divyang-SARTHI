import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class InstituteVerificationView extends GetView<InstituteController> {
  const InstituteVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ResponsiveLayout(
                mobile: _buildTabBarView(isMobile: true),
                desktop: _buildTabBarView(isMobile: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBarView({required bool isMobile}) {
    return TabBarView(
      children: [
        _ProfessionalVerificationList(isMobile: isMobile),
        _StudentVerificationList(isMobile: isMobile),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 0),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Verification Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: [
              Tab(text: 'Professionals'),
              Tab(text: 'Students'),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ProfessionalVerificationList extends GetView<InstituteController> {
  final bool isMobile;
  const _ProfessionalVerificationList({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pendingProfs = [
      {
        'name': 'Rahul Kumar',
        'type': 'Educator',
        'email': 'rahul.k@example.com',
        'date': '2026-03-12',
        'crr': 'A5362371625312'
      },
      {
        'name': 'Priya Sharma',
        'type': 'Specialist',
        'email': 'priya.s@example.com',
        'date': '2026-03-13',
        'crr': 'A9876543210987'
      },
    ];

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: pendingProfs.length,
        itemBuilder: (context, index) {
          final prof = pendingProfs[index];
          return _VerificationCard(
            title: prof['name']!,
            subtitle: prof['type']!,
            info: prof['email']!,
            date: prof['date']!,
            onTap: () => controller.viewProfVerificationDetail(prof),
          );
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 110,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: pendingProfs.length,
        itemBuilder: (context, index) {
          final prof = pendingProfs[index];
          return _VerificationCard(
            title: prof['name']!,
            subtitle: prof['type']!,
            info: prof['email']!,
            date: prof['date']!,
            onTap: () => controller.viewProfVerificationDetail(prof),
          );
        },
      );
    }
  }
}

class _StudentVerificationList extends GetView<InstituteController> {
  final bool isMobile;
  const _StudentVerificationList({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pendingStudents = [
      {
        'name': 'Aryan Singh',
        'class': 'Primary-I',
        'parent': 'Manish Singh',
        'date': '2026-03-11',
        'enrollment': '2026DIVG099887'
      },
      {
        'name': 'Isha Verma',
        'class': 'Preprimary',
        'parent': 'Suresh Verma',
        'date': '2026-03-13',
        'enrollment': '2026DIVG088776'
      },
    ];

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: pendingStudents.length,
        itemBuilder: (context, index) {
          final student = pendingStudents[index];
          return _VerificationCard(
            title: student['name']!,
            subtitle: student['class']!,
            info: 'Parent: ${student['parent']}',
            date: student['date']!,
            onTap: () => controller.viewStudentVerificationDetail(student),
          );
        },
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 110,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: pendingStudents.length,
        itemBuilder: (context, index) {
          final student = pendingStudents[index];
          return _VerificationCard(
            title: student['name']!,
            subtitle: student['class']!,
            info: 'Parent: ${student['parent']}',
            date: student['date']!,
            onTap: () => controller.viewStudentVerificationDetail(student),
          );
        },
      );
    }
  }
}

class _VerificationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String info;
  final String date;
  final VoidCallback onTap;

  const _VerificationCard({
    required this.title,
    required this.subtitle,
    required this.info,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pending_actions,
                    color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
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
