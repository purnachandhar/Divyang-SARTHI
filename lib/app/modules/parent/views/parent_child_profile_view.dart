import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class ParentChildProfileView extends StatelessWidget {
  const ParentChildProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null) {
      return const Scaffold(body: Center(child: Text('No profile data found')));
    }
    final Map<String, String> child = Get.arguments as Map<String, String>;
    final bool isMale = child['gender'] == 'male';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(child, isMale),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ResponsiveLayout(
                mobile: _buildProfileLayout(child, isMobile: true),
                desktop: _buildProfileLayout(child, isMobile: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLayout(Map<String, String> child, {required bool isMobile}) {
    return Column(
      children: [
        if (isMobile)
          Column(
            children: [
              _buildInfoSection('Academic Information', [
                _buildInfoRow('Class', child['class'] ?? 'N/A'),
                _buildInfoRow('Enrollment ID', child['id'] ?? 'N/A'),
                _buildInfoRow('Attendance', '95%'),
              ]),
              const SizedBox(height: 20),
              _buildInfoSection('Personal Information', [
                _buildInfoRow('Age', child['age'] ?? 'N/A'),
                _buildInfoRow('Gender', child['gender']?.capitalizeFirst ?? 'N/A'),
                _buildInfoRow('Date of Birth', '15-05-2018'),
              ]),
              const SizedBox(height: 20),
              _buildInfoSection('Health & Support', [
                _buildInfoRow('Disability Type', 'Visual Impairment'),
                _buildInfoRow('UDID Number', 'UDID12345678'),
                _buildInfoRow('Conditions', 'None'),
              ]),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInfoSection('Academic Information', [
                      _buildInfoRow('Class', child['class'] ?? 'N/A'),
                      _buildInfoRow('Enrollment ID', child['id'] ?? 'N/A'),
                      _buildInfoRow('Attendance', '95%'),
                    ]),
                    const SizedBox(height: 20),
                    _buildInfoSection('Health & Support', [
                      _buildInfoRow('Disability Type', 'Visual Impairment'),
                      _buildInfoRow('UDID Number', 'UDID12345678'),
                      _buildInfoRow('Conditions', 'None'),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildInfoSection('Personal Information', [
                      _buildInfoRow('Age', child['age'] ?? 'N/A'),
                      _buildInfoRow('Gender', child['gender']?.capitalizeFirst ?? 'N/A'),
                      _buildInfoRow('Date of Birth', '15-05-2018'),
                    ]),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        if (isMobile) ...[
          const SizedBox(height: 30),
          _buildActionButtons(),
        ],
      ],
    );
  }

  Widget _buildHeader(Map<String, String> child, bool isMale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Child Profile',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: Icon(
              isMale ? Icons.face : Icons.face_retouching_natural,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            child['name']!,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Enrollment: ${child['id']}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 15),
           ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(Icons.calendar_month, 'Report Card', Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionCard(Icons.analytics, 'Growth Hub', Colors.orange),
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
