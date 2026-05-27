import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class EducatorStudentReportsView extends GetView<EducatorController> {
  const EducatorStudentReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Student Report', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAcademicYearDropdown(),
            const SizedBox(height: 12),
            const Text(
              'Note: The report will be generated in the language chosen on the portal; to change the language, go to the top right corner and select the language of your choice.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildStudentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicYearDropdown() {
    return Obx(() {
      final years = controller.iepAcademicYears;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Academic Year*',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select Academic Year'),
                value: controller.selectedStudentReportYearId.value.isNotEmpty
                    ? controller.selectedStudentReportYearId.value
                    : null,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.primaryColor),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedStudentReportYearId.value = newValue;
                  }
                },
                items: years.map<DropdownMenuItem<String>>((Map<String, dynamic> iep) {
                  return DropdownMenuItem<String>(
                    value: iep['id']?.toString() ?? '',
                    child: Text(controller.formatIepYear(iep)),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStudentList() {
    return Obx(() {
      final isYearSelected = controller.selectedStudentReportYearId.value.isNotEmpty;
      final students = controller.niepidStudentAssessments;
      if (students.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No students found.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index] as Map<String, dynamic>;
          return _buildStudentCard(student, index + 1, isYearSelected);
        },
      );
    });
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int sNo, bool isYearSelected) {
    final studentName = student['studentName']?.toString() ?? 'Unknown';
    
    final statusMap = student['status'] as Map<String, dynamic>? ?? {};

    final iepStatus = statusMap['entry']?.toString().toLowerCase() ?? '';
    final goalListStatus = statusMap['entry']?.toString().toLowerCase() ?? '';
    final term1Status = statusMap['term1']?.toString().toLowerCase() ?? '';
    final term2Status = statusMap['term2']?.toString().toLowerCase() ?? '';
    
    final studentId = student['studentId']?.toString() ?? student['id']?.toString() ?? student['_id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Header with S.No and Student Name
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 14,
                  child: Text(
                    sNo.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Body with Download links
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDownloadItem('IEP', iepStatus, isYearSelected, studentId, 'entry'),
                _buildDownloadItem('Goal List', goalListStatus, isYearSelected, studentId, 'entry'),
                _buildDownloadItem('1st Term', term1Status, isYearSelected, studentId, 'term1'),
                _buildDownloadItem('2nd Term', term2Status, isYearSelected, studentId, 'term2'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(String title, String status, bool isYearSelected, String studentId, String term) {
    final isApproved = isYearSelected && (status.contains('approve') || status.contains('submit'));

    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        isApproved
            ? InkWell(
                onTap: () {
                  final yearId = controller.selectedStudentReportYearId.value;
                  if (yearId.isNotEmpty && studentId.isNotEmpty) {
                    if (title == 'Goal List') {
                      _showGoalListDownloadDialog(studentId, yearId, term, title);
                    } else if (title.contains('Term')) {
                      _showTermDownloadDialog(studentId, yearId, term, title);
                    } else {
                      controller.downloadStudentReport(studentId, yearId, term, title);
                    }
                  }
                },
                child: const Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : const Text(
                '-',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ],
    );
  }

  void _showGoalListDownloadDialog(String studentId, String yearId, String term, String title) {
    bool withGoalDetails = true;
    String goalType = 'Both';
    bool withRemarks = true;

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Goal List Options', style: TextStyle(color: AppTheme.primaryColor)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Print Report With Goal Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Yes'),
                        value: true,
                        groupValue: withGoalDetails,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => withGoalDetails = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('No'),
                        value: false,
                        groupValue: withGoalDetails,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => withGoalDetails = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Print Report With Goal Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                DropdownButtonFormField<String>(
                  value: goalType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ['Both', 'School', 'Home'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) => setState(() => goalType = val!),
                ),
                const SizedBox(height: 16),
                const Text('Print Report With Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Yes'),
                        value: true,
                        groupValue: withRemarks,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => withRemarks = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('No'),
                        value: false,
                        groupValue: withRemarks,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setState(() => withRemarks = val!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Get.back();
                // Pass these parameters to the API or controller if needed in the future
                // Currently just triggering the download with the same API
                controller.downloadStudentReport(
                  studentId, 
                  yearId, 
                  term, 
                  title,
                  withGoalDetails: withGoalDetails,
                  goalType: goalType,
                  withRemarks: withRemarks,
                );
              },
              child: const Text('Download', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  void _showTermDownloadDialog(String studentId, String yearId, String term, String title) {
    bool withRemarks = true;

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('$title Options', style: const TextStyle(color: AppTheme.primaryColor)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Print Report With Remarks:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Yes'),
                      value: true,
                      groupValue: withRemarks,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => withRemarks = val!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No'),
                      value: false,
                      groupValue: withRemarks,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => withRemarks = val!),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Get.back();
                controller.downloadStudentReport(
                  studentId, 
                  yearId, 
                  term, 
                  title,
                  withRemarks: withRemarks,
                );
              },
              child: const Text('Download', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }
}
