import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class EducatorProfileView extends StatelessWidget {
  const EducatorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildProfileDetails(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.psychology, size: 50, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rahul Sharma',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Special Educator',
                  style: TextStyle(fontSize: 16, color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          _buildSectionTitle('Personal Information'),
          _buildInfoRow(Icons.email_outlined, 'Email', 'rahuleducator@gmail.com'),
          _buildInfoRow(Icons.phone_outlined, 'Phone', '+91 9044481395'),
          _buildInfoRow(Icons.calendar_today_outlined, 'Date of Birth', '15th May 1990'),
          _buildInfoRow(Icons.location_on_outlined, 'Address', '123 Education Lane, Learning City, IN'),
          const SizedBox(height: 24),
          _buildSectionTitle('Professional Information'),
          _buildInfoRow(Icons.school_outlined, 'Institute', 'Divyang Sarthi Academy'),
          _buildInfoRow(Icons.badge_outlined, 'CRR Number', 'CRR-12345-DL'),
          _buildInfoRow(Icons.history_edu_outlined, 'Qualification', 'M.Ed. in Special Education'),
          _buildInfoRow(Icons.work_outline, 'Experience', '8 Years'),
          _buildInfoRow(Icons.group_outlined, 'Assigned Students', '45 Students'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
