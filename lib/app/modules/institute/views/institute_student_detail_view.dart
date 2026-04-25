import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class InstituteStudentDetailView extends StatelessWidget {
  const InstituteStudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> data = Get.arguments ?? {};
    final bool isMale = data['gender'] == 'male';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(data['name'] ?? 'Student Detail'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileHeader(data, isMale),
                  const SizedBox(height: 32),
                  _buildInfoSection('Academic Information', [
                    _InfoRow(
                        label: 'Enrollment Number',
                        value: data['enrollment'] ?? 'N/A'),
                    _InfoRow(label: 'Class', value: data['class'] ?? 'N/A'),
                    _InfoRow(
                        label: 'Username', value: data['username'] ?? 'N/A'),
                    _InfoRow(
                        label: 'Status',
                        value: data['status'] ?? 'N/A',
                        isStatus: true),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection('Personal Details', [
                    _InfoRow(
                        label: 'Gender',
                        value: data['gender']?.capitalizeFirst ?? 'N/A'),
                    _InfoRow(
                        label: 'Date of Birth', value: data['dob'] ?? 'N/A'),
                    const _InfoRow(
                        label: 'Father\'s Name', value: 'Manish Kumar'),
                    const _InfoRow(label: 'Category', value: 'General'),
                  ]),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name) {
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, String> data, bool isMale) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor:
              (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
          child: Icon(
            isMale ? Icons.face : Icons.face_retouching_natural,
            size: 70,
            color: isMale ? Colors.blue : Colors.pink,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data['name'] ?? 'Unknown',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Student - ${data['enrollment']}',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () =>
                Get.snackbar('Action', 'Edit feature coming soon!'),
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 54,
          width: 54,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () =>
                Get.snackbar('Chat', 'Opening chat with Parent...'),
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.green),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;

  const _InfoRow(
      {required this.label, required this.value, this.isStatus = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: isStatus
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        value,
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.right,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
