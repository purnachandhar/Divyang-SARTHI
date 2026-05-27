import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import 'institute_edit_student_view.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class InstituteStudentDetailView extends StatelessWidget {
  const InstituteStudentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InstituteController>();
    final Map<String, dynamic> data = Get.arguments ?? {};
    final bool isMale = data['gender']?.toString().toLowerCase() == 'male';
    final String fullName = data['fullName'] ?? 'N/A';
    final String userName = data['userName'] ?? 'N/A';
    final String enrollment = data['enrollmentNumber'] ?? 'N/A';
    final String dob =
        data['dateOfBirth']?.toString().split('T').first ?? 'N/A';
    final String admissionDate =
        data['admissionDate']?.toString().split('T').first ?? 'N/A';
    final bool isVerified = data['isVerified'] ?? false;
    final String studentClass = data['class']?.toString() ?? 'N/A';

    final String parentName =
        data['parentName'] ?? data['ParentDetails']?['parentName'] ?? 'N/A';
    final String parentEmail = data['email'] ??
        data['parentEmail'] ??
        data['contactDetails']?['email'] ??
        data['ParentDetails']?['email'] ??
        data['ParentDetails']?['parentEmail'] ??
        'N/A';
    final String parentMobile = data['contactNumber'] ??
        data['parentMobile'] ??
        data['contactDetails']?['contactNumber'] ??
        data['ParentDetails']?['contactNumber'] ??
        data['ParentDetails']?['parentMobile'] ??
        'N/A';
    final String parentRelation = data['parentRelation'] ?? 'N/A';

    final String permanentAddress = data['localAddress'] ??
        data['address']?['localAddress'] ??
        data['address']?['addressLine1'] ??
        data['address']?['permanentAddress'] ??
        'N/A';
    final String presentAddress = data['presentAddress'] ??
        data['address']?['addressLine2'] ??
        data['address']?['presentAddress'] ??
        'N/A';
    final String district =
        data['district'] ?? data['address']?['district'] ?? 'N/A';
    final String state = data['state'] ?? data['address']?['state'] ?? 'N/A';
    final String pinCode = data['pinCode']?.toString() ??
        data['address']?['pinCode']?.toString() ??
        'N/A';

    final String udidNumber =
        data['numberUDID'] ?? data['udid']?['numberUDID'] ?? 'N/A';

    // Disability
    dynamic apiDisabilities = data['disability'];
    List rawDisabilities = [];
    if (apiDisabilities is List) {
      rawDisabilities = apiDisabilities;
    } else if (apiDisabilities != null) {
      rawDisabilities = [apiDisabilities];
    }
    List<String> disabilityLabels = [];
    for (var d in rawDisabilities) {
      String valStr = (d is Map)
          ? ((d['value'] ?? d['label'] ?? d['_id'])?.toString() ?? '')
          : d.toString();
      try {
        final type = controller.disabilityTypesList
            .firstWhere((e) => e['value'] == valStr || e['label'] == valStr);
        disabilityLabels.add(type['label'].toString());
      } catch (_) {
        if (valStr.isNotEmpty) disabilityLabels.add(valStr);
      }
    }
    final String disabilitiesStr =
        disabilityLabels.isNotEmpty ? disabilityLabels.join(', ') : 'N/A';

    // Educators
    dynamic accessIdData = data['accessId'];
    List rawAccessIds = [];
    if (accessIdData is List) {
      rawAccessIds = accessIdData;
    } else if (accessIdData is Map) {
      for (var val in accessIdData.values) {
        if (val is List) rawAccessIds.addAll(val);
      }
    } else if (accessIdData is String && accessIdData.contains(',')) {
      rawAccessIds = accessIdData.split(',').map((e) => e.trim()).toList();
    } else if (accessIdData != null) {
      rawAccessIds = [accessIdData];
    }
    List<String> assignedProfessionals = [];
    for (var item in rawAccessIds) {
      String id = (item is Map)
          ? (item['user']?['_id'] ??
                  item['user']?['id'] ??
                  item['_id'] ??
                  item['id'] ??
                  '')
              .toString()
          : item.toString();
      if (id.isNotEmpty) {
        try {
          final prof = controller.educators.firstWhere(
              (e) => e['_id']?.toString() == id || e['id']?.toString() == id);
          final pName =
              "${prof['firstName'] ?? ''} ${prof['lastName'] ?? ''}".trim();
          if (pName.isNotEmpty && !assignedProfessionals.contains(pName)) {
            assignedProfessionals.add(pName);
          }
        } catch (_) {}
      }
    }
    final String professionalsStr = assignedProfessionals.isNotEmpty
        ? assignedProfessionals.join(', ')
        : 'None Assigned';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(fullName == 'N/A' ? userName : fullName),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileHeader(data, isMale),
                  const SizedBox(height: 32),
                  _buildInfoSection('Academic Information', [
                    _InfoRow(label: 'Enrollment Number', value: enrollment),
                    _InfoRow(label: 'Class', value: studentClass),
                    _InfoRow(label: 'Admission Date', value: admissionDate),
                    _InfoRow(
                        label: 'Assign Professional', value: professionalsStr),
                    _InfoRow(
                        label: 'Status',
                        value: isVerified ? 'Verified' : 'Pending',
                        isStatus: true),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection('Personal Details', [
                    _InfoRow(label: 'Username', value: userName),
                    _InfoRow(label: 'Full Name', value: fullName),
                    _InfoRow(
                        label: 'Gender',
                        value: data['gender']?.toString().capitalizeFirst ??
                            'N/A'),
                    _InfoRow(label: 'Date of Birth', value: dob),
                    _InfoRow(label: 'Disability Type', value: disabilitiesStr),
                    _InfoRow(label: 'UDID Number', value: udidNumber),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection('Parent / Guardian Details', [
                    _InfoRow(label: 'Parent Name', value: parentName),
                    _InfoRow(label: 'Relation', value: parentRelation),
                    _InfoRow(label: 'Email Address', value: parentEmail),
                    _InfoRow(label: 'Mobile Number', value: parentMobile),
                  ]),
                  const SizedBox(height: 24),
                  _buildInfoSection('Address Details', [
                    _InfoRow(
                        label: 'Permanent Address', value: permanentAddress),
                    _InfoRow(label: 'Present Address', value: presentAddress),
                    _InfoRow(label: 'Pin Code', value: pinCode),
                    _InfoRow(label: 'District', value: district),
                    _InfoRow(label: 'State', value: state),
                    const _InfoRow(label: 'Country', value: 'India'),
                  ]),
                  const SizedBox(height: 32),
                  _buildActionButtons(data),
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

  Widget _buildProfileHeader(Map<String, dynamic> data, bool isMale) {
    final String studentName =
        data['fullName'] ?? data['userName'] ?? 'Unknown';
    final String enrollment = data['enrollmentNumber'] ?? 'N/A';
    final String studentDP = data['studentDP'] ?? '';

    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor:
              (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
          backgroundImage:
              studentDP.isNotEmpty ? NetworkImage(studentDP) : null,
          child: studentDP.isEmpty
              ? Icon(
                  isMale ? Icons.face : Icons.face_retouching_natural,
                  size: 70,
                  color: isMale ? Colors.blue : Colors.pink,
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          studentName,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Student - $enrollment',
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

  Widget _buildActionButtons(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () =>
                Get.to(() => const InstituteEditStudentView(), arguments: data),
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
