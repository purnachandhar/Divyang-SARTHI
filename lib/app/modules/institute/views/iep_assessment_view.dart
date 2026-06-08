import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../controllers/institute_controller.dart';

class IepAssessmentView extends GetView<InstituteController> {
  const IepAssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    // Handle auto-fetch deep link from dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.arguments != null &&
          Get.arguments is Map &&
          Get.arguments['autoFetch'] == true) {
        final studentName = Get.arguments['studentName']?.toString();
        final year = Get.arguments['year']?.toString();
        if (studentName != null) {
          controller.handleAutoFetchIepAssessment(studentName, year);
          // Set to false to prevent repeat fetches if the view rebuilds
          Get.arguments['autoFetch'] = false;
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(top: 60, bottom: 30, left: 16, right: 24),
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
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('IEP Assessment',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(
                            'Individualized Education Program management module.',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Details",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Academic Year Dropdown
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                          color: AppTheme.primaryColor.withOpacity(0.1)),
                    ),
                    child: Obx(() => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: controller.selectedNiepidYear.value,
                            hint: const Text('Select Academic Year'),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AppTheme.primaryColor),
                            items: controller.availableNiepidYears
                                .map((year) => DropdownMenuItem(
                                      value: year,
                                      child: Text(year,
                                          style: const TextStyle(fontSize: 15)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              controller.selectedNiepidYear.value = val;
                              controller.selectedNiepidStudent.value =
                                  null; // Reset student on year change
                              controller.showAssessmentResult.value = false;
                              print('Selected Academic Year: $val');
                            },
                          ),
                        )),
                  ),

                  const SizedBox(height: 20),

                  // Student Dropdown (Conditional)
                  Obx(() {
                    final bool isYearSelected =
                        controller.selectedNiepidYear.value != null;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: isYearSelected ? Colors.white : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                            color: isYearSelected
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : Colors.transparent),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: controller.selectedNiepidStudent.value,
                          hint: Text(
                            isYearSelected
                                ? 'Select Student'
                                : 'Select Year First',
                            style: TextStyle(
                              fontSize: 15,
                              color:
                                  isYearSelected ? Colors.black54 : Colors.grey,
                            ),
                          ),
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: isYearSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey),
                          items: isYearSelected
                              ? controller.availableNiepidStudents
                                  .map((student) {
                                  return DropdownMenuItem<String>(
                                    value: student,
                                    child: Text(student,
                                        style: const TextStyle(fontSize: 15)),
                                  );
                                }).toList()
                              : null,
                          onChanged: isYearSelected
                              ? (val) {
                                  controller.updateSelectedStudent(val);
                                  print('Selected Student: $val');
                                }
                              : null,
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 30),

                  // Get Assessment Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => controller.getAssessment(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                      ),
                      child: Obx(() => controller.isQuestionsLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Get Assessment',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            )),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Assessment Result Section
                  Obx(() {
                    if (!controller.showAssessmentResult.value)
                      return const SizedBox.shrink();

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                        border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person,
                                    color: AppTheme.primaryColor),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Assessment Details",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          _buildDetailItem("Student",
                              controller.selectedNiepidStudent.value ?? "-"),
                          _buildDetailItem("Academic Year",
                              controller.selectedNiepidYear.value ?? "-"),

                          // IEP Level Dropdown
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "IEP Level *",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: controller
                                              .selectedIepLevel.value ??
                                          controller.availableIepLevels.first,
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: AppTheme.primaryColor),
                                      items: controller.availableIepLevels
                                          .map((level) {
                                        return DropdownMenuItem(
                                          value: level,
                                          child: Text(level,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textPrimary)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        controller.selectedIepLevel.value = val;
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _buildDetailItem(
                              "Age",
                              controller.calculateAge(controller
                                      .selectedStudentData
                                      .value?['dateOfBirth'] ??
                                  controller
                                      .selectedStudentData.value?['dob'] ??
                                  controller
                                      .selectedStudentData.value?['age'])),
                          _buildDetailItem(
                              "Teacher",
                              controller.selectedStudentData
                                      .value?['teacherName'] ??
                                  "-"),
                          _buildDetailItem("IEP Status", "-"),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
