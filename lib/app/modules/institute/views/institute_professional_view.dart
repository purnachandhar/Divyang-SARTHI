import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/widgets/app_table.dart';

class InstituteProfessionalView extends GetView<InstituteController> {
  const InstituteProfessionalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ResponsiveLayout(
              mobile: _buildProfessionalList(isMobile: true),
              desktop: _buildProfessionalList(isMobile: false),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'prof_fab',
        onPressed: controller.goToAddProfessional,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Professionals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage educators and experts in your institute',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.educators.length} Members',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildProfessionalList({required bool isMobile}) {
    return Obx(() {
      if (controller.isEducatorsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.educators.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline,
                  size: 60, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 16),
              const Text('No professionals found',
                  style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.fetchEducators,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor),
                child: const Text('Refresh',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }

      if (isMobile) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.educators.length,
          itemBuilder: (context, index) {
            final educator = controller.educators[index];
            return _ProfessionalCard(
              educator: educator,
              onTap: () => controller
                  .viewProfessionalDetail(_toStringMap(educator)),
            );
          },
        );
      } else {
        final educators = controller.educators;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: AppTable(
            columns: const [
              'Name',
              'Role / Designation',
              'Qualification',
              'Email',
              'Mobile',
              'Students',
              'Status',
              'Actions'
            ],
            rows: educators.map((educator) {
              final fullName =
                  '${educator['firstName'] ?? ''} ${educator['lastName'] ?? ''}'
                      .trim();
              final roles = educator['roles'] is List
                  ? (educator['roles'] as List).join(', ')
                  : (educator['roles'] ?? 'N/A').toString();
              final designation =
                  (educator['designation'] ?? '').toString();
              final qualification =
                  (educator['qualification'] ?? '').toString();
              final email = (educator['email'] ?? '').toString();
              final mobile = (educator['mobile'] ?? '').toString();
              final studentCount =
                  (educator['studentCount'] ?? 0).toString();
              final isOnline = educator['isOnline'] == true;

              return DataRow(
                cells: [
                  DataCell(Row(
                    children: [
                      _buildAvatar(educator, radius: 16),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(fullName.isEmpty ? 'N/A' : fullName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                          Text(roles,
                              style: TextStyle(
                                  color: _roleColor(roles),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  )),
                  DataCell(Text(
                      designation.isEmpty ? roles : designation,
                      style: const TextStyle(fontSize: 12))),
                  DataCell(Text(
                      qualification.isEmpty ? 'N/A' : qualification,
                      style: const TextStyle(fontSize: 12))),
                  DataCell(Text(
                      email.isEmpty ? 'N/A' : email,
                      style: const TextStyle(fontSize: 12))),
                  DataCell(Text(
                      mobile.isEmpty ? 'N/A' : mobile,
                      style: const TextStyle(fontSize: 12))),
                  DataCell(Row(
                    children: [
                      const Icon(Icons.people, size: 14, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Text(studentCount,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  )),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOnline
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                              color: isOnline ? Colors.green : Colors.grey,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility,
                            color: AppTheme.primaryColor, size: 20),
                        onPressed: () => controller
                            .viewProfessionalDetail(_toStringMap(educator)),
                        tooltip: 'View',
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        );
      }
    });
  }

  Widget _buildAvatar(Map<String, dynamic> educator, {double radius = 25}) {
    final roles = educator['roles'] is List
        ? (educator['roles'] as List).join(', ')
        : (educator['roles'] ?? '').toString();
    return CircleAvatar(
      radius: radius,
      backgroundColor: _roleColor(roles).withOpacity(0.15),
      child: Icon(
        _roleIcon(roles),
        color: _roleColor(roles),
        size: radius * 0.9,
      ),
    );
  }

  Color _roleColor(String role) {
    if (role.contains('Educator')) return AppTheme.primaryColor;
    if (role.contains('SpeechTherapist')) return Colors.teal;
    if (role.contains('Parent')) return Colors.orange;
    if (role.contains('Institute')) return Colors.indigo;
    return Colors.blueGrey;
  }

  IconData _roleIcon(String role) {
    if (role.contains('Educator')) return Icons.school;
    if (role.contains('SpeechTherapist')) return Icons.record_voice_over;
    if (role.contains('Parent')) return Icons.family_restroom;
    if (role.contains('Institute')) return Icons.business;
    return Icons.person;
  }

  Map<String, String> _toStringMap(Map<String, dynamic> educator) {
    return educator.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }
}

class _ProfessionalCard extends StatelessWidget {
  final Map<String, dynamic> educator;
  final VoidCallback onTap;

  const _ProfessionalCard({required this.educator, required this.onTap});

  Color _roleColor(String role) {
    if (role.contains('Educator')) return AppTheme.primaryColor;
    if (role.contains('SpeechTherapist')) return Colors.teal;
    if (role.contains('Parent')) return Colors.orange;
    if (role.contains('Institute')) return Colors.indigo;
    return Colors.blueGrey;
  }

  IconData _roleIcon(String role) {
    if (role.contains('Educator')) return Icons.school;
    if (role.contains('SpeechTherapist')) return Icons.record_voice_over;
    if (role.contains('Parent')) return Icons.family_restroom;
    if (role.contains('Institute')) return Icons.business;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    final fullName =
        '${educator['firstName'] ?? ''} ${educator['lastName'] ?? ''}'.trim();
    final roles = educator['roles'] is List
        ? (educator['roles'] as List).join(', ')
        : (educator['roles'] ?? 'N/A').toString();
    final designation = (educator['designation'] ?? '').toString();
    final email = (educator['email'] ?? '').toString();
    final mobile = (educator['mobile'] ?? '').toString();
    final qualification = (educator['qualification'] ?? '').toString();
    final isOnline = educator['isOnline'] == true;
    final studentCount = educator['studentCount'] ?? 0;
    final address = educator['address'] is Map
        ? '${educator['address']['district'] ?? ''}, ${educator['address']['state'] ?? ''}'
            .trim()
            .replaceAll(RegExp(r'^,\s*'), '')
        : '';

    final roleColor = _roleColor(roles);
    final roleIcon = _roleIcon(roles);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar with online indicator
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: roleColor.withOpacity(0.12),
                        child: Icon(roleIcon, color: roleColor, size: 26),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? Colors.green : Colors.grey,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isEmpty ? 'N/A' : fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            roles,
                            style: TextStyle(
                              color: roleColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Students count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people,
                              size: 14, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '$studentCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const Text('Students',
                          style: TextStyle(
                              fontSize: 10, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              // Info row
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  if (designation.isNotEmpty)
                    _InfoChip(
                        icon: Icons.work_outline, label: designation),
                  if (qualification.isNotEmpty)
                    _InfoChip(
                        icon: Icons.school_outlined, label: qualification),
                  if (email.isNotEmpty)
                    _InfoChip(
                        icon: Icons.email_outlined, label: email),
                  if (mobile.isNotEmpty)
                    _InfoChip(
                        icon: Icons.phone_outlined, label: mobile),
                  if (address.isNotEmpty)
                    _InfoChip(
                        icon: Icons.location_on_outlined, label: address),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
