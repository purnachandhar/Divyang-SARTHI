import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class InstituteStudentVerificationDetailView extends StatelessWidget {
  const InstituteStudentVerificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> data = Get.arguments ?? {};

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(data['name'] ?? 'Student Verification'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Student Personal Details'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _InfoRow(label: 'Full Name', value: data['name'] ?? 'N/A'),
                    _InfoRow(label: 'Class', value: data['class'] ?? 'N/A'),
                    _InfoRow(
                        label: 'Enrollment Number',
                        value: data['enrollment'] ?? 'N/A'),
                    const _InfoRow(label: 'Date of Birth', value: '2021-05-15'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Guardian Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _InfoRow(
                        label: 'Parent Name', value: data['parent'] ?? 'N/A'),
                    const _InfoRow(
                        label: 'Mobile Number', value: '+91 9876543210'),
                    const _InfoRow(label: 'Relation', value: 'Father'),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Submitted Documents'),
                  const SizedBox(height: 12),
                  _buildDocumentCard('Child_Photo.jpg', isImage: true),
                  const SizedBox(height: 8),
                  _buildDocumentCard('UDID_Certificate.pdf'),
                  const SizedBox(height: 8),
                  _buildDocumentCard('Income_Certificate.pdf'),
                  const SizedBox(height: 40),
                  _buildActionButtons(),
                  const SizedBox(height: 40),
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

  Widget _buildStatusBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.assignment_ind_outlined, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'New student enrollment pending review. Please verify documents and academic details.',
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
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
    );
  }

  Widget _buildDocumentCard(String fileName, {bool isImage = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(isImage ? Icons.image_outlined : Icons.description_outlined,
              color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () => Get.snackbar('View', 'Previewing document...'),
            child: const Text('Preview'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Rejected', 'Student enrollment rejected.',
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Reject',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                  'Approved', 'Student enrollment approved successfully!',
                  backgroundColor: Colors.green.withOpacity(0.1),
                  colorText: Colors.green);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Approve',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
