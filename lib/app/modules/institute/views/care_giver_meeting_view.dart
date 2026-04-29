import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../controllers/institute_controller.dart';

class CareGiverMeetingView extends GetView<InstituteController> {
  const CareGiverMeetingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch data when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCareGiverMeetingData();
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isCareGiverLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilters(),
                    const SizedBox(height: 24),
                    _buildStudentList(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 16, right: 24),
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
                  Text('Care Giver Meeting',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                      'Record and manage interactions with student caregivers.',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Filters",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Academic Year Dropdown
        _buildDropdownContainer(
          label: "Academic Year",
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedNiepidYear.value,
              hint: const Text('Select Academic Year'),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
              items: controller.availableNiepidYears
                  .map((year) => DropdownMenuItem(
                        value: year,
                        child: Text(year, style: const TextStyle(fontSize: 15)),
                      ))
                  .toList(),
              onChanged: (val) {
                controller.selectedNiepidYear.value = val;
                // You might want to re-fetch if the API depends on the year
              },
            ),
          )),
        ),
        
        const SizedBox(height: 16),
        
        // Teacher Dropdown
        _buildDropdownContainer(
          label: "Teacher List",
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: controller.selectedCareGiverTeacher.value,
              hint: const Text('Select Teacher'),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
              items: controller.availableCareGiverTeachers.map((teacher) {
                return DropdownMenuItem<String>(
                  value: teacher['teacherId']?.toString(),
                  child: Text(teacher['teacherName'] ?? 'Unknown Teacher', style: const TextStyle(fontSize: 15)),
                );
              }).toList(),
              onChanged: controller.onCareGiverTeacherChanged,
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildDropdownContainer({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return Obx(() {
      if (controller.selectedCareGiverTeacher.value == null) {
        return const Center(
          child: Column(
            children: [
              SizedBox(height: 60),
              Icon(Icons.person_search_outlined, size: 80, color: AppTheme.primaryColor),
              SizedBox(height: 24),
              Text(
                "Please select a teacher to view students",
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }

      final students = controller.filteredCareGiverStudents;
      
      if (students.isEmpty) {
        return Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text("No students found for this teacher", style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        );
      }

      // Get overall statuses from data
      final statusData = controller.careGiverMeetingData.value?['status'];
      final entryStatus = _formatOverallStatus(statusData?['entry']);
      final term1Status = _formatOverallStatus(statusData?['term1']);
      final term2Status = _formatOverallStatus(statusData?['term2']);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Student List",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                "${students.length} Students",
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Table-like Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text("Student Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                Expanded(
                  flex: 2,
                  child: _buildHeaderColumn("Meeting after\nIEP Approval"),
                ),
                Expanded(
                  flex: 2,
                  child: _buildHeaderColumn("Meeting after\n1st Term"),
                ),
                Expanded(
                  flex: 2,
                  child: _buildHeaderColumn("Meeting after\n2nd Term"),
                ),
              ],
            ),
          ),
          
          // Student Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
            itemBuilder: (context, index) {
              final student = students[index];
              return _buildStudentRow(student);
            },
          ),

          // Term States Summary with Rework/Approve buttons
          _buildTermStatesFooter(),
        ],
      );
    });
  }

  Widget _buildTermStatesFooter() {
    final data = controller.careGiverMeetingData.value;
    var meetingStatus = data?['meetingstatus'] ?? data?['status'];
    
    if (meetingStatus == null) {
      final List? students = data?['students'];
      if (students != null && students.isNotEmpty) {
        meetingStatus = students[0]['meetingstatus'];
      }
    }

    String formatState(dynamic termData) {
      if (termData == null) return "Pending";
      dynamic stateValue = (termData is Map) ? termData['state'] : termData;
      if (stateValue == null) return "Pending";
      
      String val = stateValue.toString().toLowerCase();
      if (val == "approve" || val == "approved" || val == "submitted") return "Approved";
      return stateValue.toString().capitalizeFirst ?? stateValue.toString();
    }

    final entryState = formatState(meetingStatus?['entry']);
    final term1State = formatState(meetingStatus?['term1']);
    final term2State = formatState(meetingStatus?['term2']);

    // Enable buttons only if the state is "Approved"
    bool entryEnabled = entryState == "Approved";
    bool term1Enabled = term1State == "Approved";
    bool term2Enabled = term2State == "Approved";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryColor),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildFooterColumn(entryState, entryEnabled, "entry"),
          ),
          SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: _buildFooterColumn(term1State, term1Enabled, "term1"),
          ),
          SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: _buildFooterColumn(term2State, term2Enabled, "term2"),
          ),
        ],
      ),
    );
  }

  

  Widget _buildFooterColumn(String status, bool isEnabled, String termKey) {
    return Column(
      children: [
        
        const SizedBox(height: 12),
        _buildActionButton("Rework", Colors.red, isEnabled, () {
          Get.snackbar("Action", "Rework requested for $termKey", snackPosition: SnackPosition.BOTTOM);
        }),
        const SizedBox(height: 8),
        _buildActionButton("Approve", Colors.green, isEnabled, () {
          Get.snackbar("Action", "Approved $termKey", snackPosition: SnackPosition.BOTTOM);
        }),
      ],
    );
  }

  

  
  

  

  Widget _buildActionButton(String label, Color color, bool isEnabled, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _formatOverallStatus(dynamic status) {
    if (status == null) return "Pending";
    final s = status.toString().toLowerCase();
    if (s == "submitted" || s == "approve" || s == "approved") return "Approved"; 
    if (s == "pending") return "Pending";
    return status.toString();
  }

  Widget _buildHeaderColumn(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title, 
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)
        ),
      ],
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> student) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              student['studentName'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            flex: 2,
            child: _buildMeetingStatus(student['meetingstatus']?['entry']),
          ),
          Expanded(
            flex: 2,
            child: _buildMeetingStatus(student['meetingstatus']?['term1']),
          ),
          Expanded(
            flex: 2,
            child: _buildMeetingStatus(student['meetingstatus']?['term2']),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingStatus(Map<String, dynamic>? statusData) {
    final status = statusData?['status'];
    final state = statusData?['state'];
    
    String statusText = "-";
    Color color = Colors.grey;

    if (status == "caregiver_met") {
      statusText = "Caregiver Met";
      
    } else if (status == "caregiver_not_attended") {
      statusText = "Caregiver didn't attend";
      
    } else if (status == "meeting_not_conducted") {
      statusText = "Meeting not conducted";
     
    }

    String stateText = "";
    if (state != null) {
      if (state == "approve" || state == "approved") {
        stateText = "Approved";
        color = Colors.green;
      } else if (state == "pending") {
        stateText = "Pending";
        color = Colors.orange;
      } else {
        stateText = state.toString().capitalizeFirst ?? state.toString();
        color = Colors.blue;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          statusText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.black,
            fontWeight: statusText == "-" ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        Text(
          stateText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: statusText == "-" ? FontWeight.normal : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
