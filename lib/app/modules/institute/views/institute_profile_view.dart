import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../controllers/institute_controller.dart';

class InstituteProfileView extends GetView<InstituteController> {
  const InstituteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Institute Profile'),
        flexibleSpace: Container(
          decoration:
              const BoxDecoration(gradient: AppGradients.primaryGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isProfileLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.profileData.value;
        if (data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No profile data found',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.fetchCurrentProfile,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        // --- Parse User Fields ---
        final firstName = (data['firstName'] ?? '').toString().trim();
        final lastName = (data['lastName'] ?? '').toString().trim();
        final fullName = '$firstName $lastName'.trim();
        final email = (data['email'] ?? '').toString();
        final mobile = (data['mobile'] ?? '').toString();
        final uniqueNumber = (data['uniqueNumber'] ?? '').toString();
        final designation = (data['designation'] ?? '').toString();
        final crrNumber = (data['cRRNumber'] ?? '').toString();
        final userDP = (data['userDP'] ?? '').toString();

        // User Address
        String userAddress = 'Not Available';
        if (data['address'] is Map) {
          final addr = data['address'] as Map;
          final parts = [
            addr['district']?.toString() ?? '',
            addr['state']?.toString() ?? '',
            addr['pinCode']?.toString() ?? '',
            addr['country']?.toString() ?? '',
          ].where((p) => p.isNotEmpty).toList();
          if (parts.isNotEmpty) userAddress = parts.join(', ');
        }

        // --- Parse Organisation Fields ---
        String schoolName = 'Not Available';
        String instituteAddress = 'Not Available';
        if (data['organisation'] is Map) {
          final org = data['organisation'] as Map;
          schoolName = (org['schoolName'] ?? '').toString();
          if (schoolName.isEmpty) schoolName = 'Not Available';

          final parts = [
            org['address']?.toString() ?? '',
            org['state']?.toString() ?? '',
            org['pinCode']?.toString() ?? '',
          ].where((p) => p.isNotEmpty).toList();
          if (parts.isNotEmpty) instituteAddress = parts.join(', ');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Header Card ──
              _buildProfileHeader(
                fullName: fullName,
                designation: designation,
                userDP: userDP,
              ),
              const SizedBox(height: 24),

              // ── User Details ──
              _buildSectionCard(
                title: 'User Details',
                icon: Icons.person_outline,
                children: [
                  _buildDetailRow('Name', fullName.isEmpty ? 'Not Available' : fullName),
                  _buildDetailRow('Mobile', mobile.isEmpty ? 'Not Available' : mobile),
                  _buildDetailRow('Email', email.isEmpty ? 'Not Available' : email),
                  _buildDetailRow('Unique Number', uniqueNumber.isEmpty ? 'Not Available' : uniqueNumber),
                  _buildDetailRow('Address', userAddress),
                ],
              ),
              const SizedBox(height: 16),

              // ── Institute Details ──
              _buildSectionCard(
                title: 'Institute Detail',
                icon: Icons.business_outlined,
                children: [
                  _buildDetailRow(
                    'CRR Number',
                    crrNumber.isEmpty ? 'CRR No: Not available' : crrNumber,
                  ),
                  _buildDetailRow('Institute', schoolName),
                  _buildDetailRow('Institute Address', instituteAddress),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader({
    required String fullName,
    required String designation,
    required String userDP,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white.withOpacity(0.3),
            backgroundImage: userDP.isNotEmpty && !userDP.contains('/')
                ? null
                : null,
            child: const Icon(Icons.business, size: 44, color: Colors.white),
          ),
          const SizedBox(height: 14),
          Text(
            fullName.isEmpty ? 'N/A' : fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (designation.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                designation,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(':  ',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not Available' : value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
