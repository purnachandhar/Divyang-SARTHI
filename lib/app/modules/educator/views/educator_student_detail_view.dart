import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class EducatorStudentDetailView extends GetView<EducatorController> {
  const EducatorStudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = Get.arguments ?? {};
    final bool isMale = data['gender']?.toString().toLowerCase() == 'male';
    final String fullName =
        data['fullName'] ?? data['name'] ?? 'Unknown Student';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(fullName, data),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileCard(data, isMale),
                  const SizedBox(height: 24),
                  _buildInfoSection('Personal Information', [
                    _InfoRow(label: 'Full Name', value: fullName),
                    _InfoRow(
                        label: 'Username',
                        value: data['userName'] ?? data['username'] ?? 'N/A'),
                    _InfoRow(
                        label: 'Gender',
                        value: data['gender']?.toString().capitalizeFirst ??
                            'N/A'),
                    _InfoRow(
                        label: 'Date of Birth',
                        value: _formatDate(data['dateOfBirth'] ?? data['dob'])),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Academic Details', [
                    _InfoRow(
                        label: 'Enrollment No.',
                        value: data['enrollmentNumber'] ??
                            data['enrollment'] ??
                            'N/A'),
                    _InfoRow(
                        label: 'Current Class', value: data['class'] ?? 'N/A'),
                    _InfoRow(
                        label: 'Admission Date',
                        value: _formatDate(data['admissionDate'])),
                    _InfoRow(
                        label: 'Added By', value: data['addedBy'] ?? 'N/A'),
                    _InfoRow(
                        label: 'Organisation ID',
                        value: data['organisation'] ?? 'N/A'),
                    if (data['classHistory'] != null &&
                        (data['classHistory'] as List).isNotEmpty)
                      _InfoRow(
                          label: 'Class History',
                          value: (data['classHistory'] as List).join(', ')),
                  ]),
                  const SizedBox(height: 20),
                  if (data['ParentDetails'] != null)
                    _buildInfoSection('Parent Information', [
                      _InfoRow(
                          label: 'Parent Name',
                          value: data['ParentDetails']['parentName'] ?? 'N/A'),
                      _InfoRow(
                          label: 'Relation',
                          value: data['parentRelation'] ?? 'N/A'),
                      _InfoRow(
                          label: 'Contact Number',
                          value:
                              data['ParentDetails']['contactNumber'] ?? 'N/A'),
                      _InfoRow(
                          label: 'Email ID',
                          value: data['ParentDetails']['email'] ?? 'N/A'),
                    ]),
                  const SizedBox(height: 20),
                  if (data['address'] != null)
                    _buildInfoSection('Address Details', [
                      _InfoRow(
                          label: 'Local Address',
                          value: data['address']['localAddress'] ?? 'N/A'),
                      _InfoRow(
                          label: 'Present Address',
                          value: data['address']['presentAddress'] ?? 'N/A'),
                      _InfoRow(
                          label: 'District',
                          value: data['address']['district'] ?? 'N/A'),
                      _InfoRow(
                          label: 'State',
                          value: data['address']['state'] ?? 'N/A'),
                      _InfoRow(
                          label: 'Pin Code',
                          value:
                              data['address']['pinCode']?.toString() ?? 'N/A'),
                      _InfoRow(
                          label: 'Country',
                          value: data['address']['country'] ?? 'N/A'),
                    ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Disability & Medical', [
                    if (data['disability'] != null &&
                        (data['disability'] as List).isNotEmpty)
                      _InfoRow(
                          label: 'Disability Type',
                          value: (data['disability'] as List).join(', ')),
                    if (data['udid'] != null) ...[
                      _InfoRow(
                          label: 'UDID Number',
                          value: data['udid']['numberUDID'] ?? 'N/A'),
                      _InfoRow(
                          label: 'UDID Certificate',
                          value: data['udid']['certificateUDID']
                                      ?.toString()
                                      .isNotEmpty ==
                                  true
                              ? 'Attached'
                              : 'Not Attached'),
                    ],
                    _InfoRow(
                        label: 'Verification Status',
                        value:
                            data['isVerified'] == true ? 'Verified' : 'Pending',
                        isStatus: true,
                        statusColor: data['isVerified'] == true
                            ? Colors.green
                            : Colors.orange),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('System Info', [
                    _InfoRow(
                        label: 'Created At',
                        value: _formatDateTime(data['createdAt'])),
                    _InfoRow(
                        label: 'Last Updated',
                        value: _formatDateTime(data['updatedAt'])),
                    _InfoRow(label: 'Student ID', value: data['_id'] ?? 'N/A'),
                  ]),
                  const SizedBox(height: 32),
                  // _buildActionButtons(data),
                  // const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, Map<String, dynamic> data) {
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
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.delete_outline, color: Colors.white),
          //   onPressed: () => _showDeleteConfirmation(data),
          // ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> data, bool isMale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: data['studentDP'] != null &&
                    data['studentDP'].toString().startsWith('http')
                ? ClipOval(
                    child: Image.network(data['studentDP'], fit: BoxFit.cover))
                : Icon(isMale ? Icons.face : Icons.face_retouching_natural,
                    size: 40, color: isMale ? Colors.blue : Colors.pink),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data['profileStatus']?.toString().toUpperCase() ?? 'ACTIVE',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['fullName'] ?? data['name'] ?? 'Unknown',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${data['enrollmentNumber'] ?? data['enrollment'] ?? 'N/A'}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showStudentLoginConfirmation(data),
            icon: const Icon(Icons.login, size: 20),
            label: const Text('Student Login'),
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
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () => Get.snackbar('Edit', 'Edit feature coming soon!'),
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }

  String _formatDateTime(dynamic date) {
    if (date == null || date.toString().isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }

  void _showStudentLoginConfirmation(Map<String, dynamic> data) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Student Login',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'Switch to the student portal for ${data['fullName'] ?? 'this student'}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoggingInStudent.value
                    ? null
                    : () {
                        Get.back();
                        controller.performStudentLogin(
                          data['userName']?.toString() ?? '',
                          data['dateOfBirth']?.toString() ?? '',
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: controller.isLoggingInStudent.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Enter Portal'),
              )),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> data) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Student',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text(
            'Are you sure you want to permanently delete ${data['fullName'] ?? 'this student'}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
              Get.snackbar('Deleted', 'Student record removed.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStatus;
  final Color? statusColor;

  const _InfoRow(
      {required this.label,
      required this.value,
      this.isStatus = false,
      this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isStatus
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: (statusColor ?? Colors.green).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                            color: statusColor ?? Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 11),
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    textAlign: TextAlign.left,
                  ),
          ),
        ],
      ),
    );
  }
}
