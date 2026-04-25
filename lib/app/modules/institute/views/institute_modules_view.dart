import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import 'iep_assessment_view.dart';
import 'goal_monitoring_view.dart';
import 'care_giver_meeting_view.dart';
import 'student_reports_view.dart';

class InstituteModulesView extends GetView<InstituteController> {
  const InstituteModulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
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
              Text('NIEPID Modules',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Access specialized NIEPID assessments',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _buildModuleTile(
                  icon: Icons.assignment_outlined,
                  title: 'IEP Assessment',
                  subtitle: 'Manage Individualized Education Programs',
                  onTap: () => Get.to(() => const IepAssessmentView())),
              _buildModuleTile(
                  icon: Icons.track_changes,
                  title: 'Goal Monitoring',
                  subtitle: 'Track student progress and goals',
                  onTap: () => Get.to(() => const GoalMonitoringView())),
              _buildModuleTile(
                  icon: Icons.groups_outlined,
                  title: 'Care Giver Meeting',
                  subtitle: 'Schedule and record caregiver interactions',
                  onTap: () => Get.to(() => const CareGiverMeetingView())),
              _buildModuleTile(
                  icon: Icons.description_outlined,
                  title: 'Student Reports',
                  subtitle: 'Generate and view assessment reports',
                  onTap: () => Get.to(() => const StudentReportsView())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModuleTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color? iconColor,
      Color? textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: ListTile(
        leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor ?? AppTheme.primaryColor)),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor ?? AppTheme.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
