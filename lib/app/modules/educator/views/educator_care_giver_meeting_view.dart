import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class EducatorCareGiverMeetingView extends StatefulWidget {
  const EducatorCareGiverMeetingView({super.key});

  @override
  State<EducatorCareGiverMeetingView> createState() => _EducatorCareGiverMeetingViewState();
}

class _EducatorCareGiverMeetingViewState extends State<EducatorCareGiverMeetingView> {
  final EducatorController controller = Get.find<EducatorController>();

  // Key: studentId, Value: { 'entry': status, 'term1': status, 'term2': status }
  final Map<String, Map<String, String?>> _selectedStatuses = {};

  static const _statusOptions = [
    {'value': 'caregiver_met', 'label': 'Caregiver Met'},
    {'value': 'caregiver_not_attended', 'label': 'Caregiver Not Attended'},
    {'value': 'meeting_not_conducted', 'label': 'Meeting Not Conducted'},
    {'value': 'not_met', 'label': 'Not Met'},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch data when view is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCareGiverMeetingData().then((_) {
        _refreshSelections();
      });
    });
  }

  void _refreshSelections() {
    if (!mounted) return;
    setState(() {
      _selectedStatuses.clear();
      final yearId = controller.selectedCareGiverYearId.value;
      for (var student in controller.careGiverStudents) {
        final studentId = student['studentId']?.toString() ??
                          student['id']?.toString() ??
                          student['_id']?.toString() ?? '';
        if (studentId.isEmpty) continue;

        final meetingMap = student['meetingstatus'] as Map?;
        Map<String, dynamic> actualMeeting;
        if (meetingMap != null && meetingMap.containsKey(yearId)) {
          actualMeeting = Map<String, dynamic>.from(meetingMap[yearId]);
        } else {
          actualMeeting = Map<String, dynamic>.from(meetingMap ?? {});
        }

        final Map<String, String?> studentTerms = {};
        for (final term in ['entry', 'term1', 'term2']) {
          final termData = actualMeeting[term] as Map<String, dynamic>? ?? {};
          final status = termData['status']?.toString();
          final hasMatchingOption = _statusOptions.any((opt) => opt['value'] == status);
          studentTerms[term] =
              (status != null && status.isNotEmpty && status != 'null' && hasMatchingOption)
                  ? status
                  : null;
        }
        _selectedStatuses[studentId] = studentTerms;
      }
    });
  }

  // Get status details for a student
  Map<String, dynamic> _termData(Map<String, dynamic> student, String term) {
    final yearId = controller.selectedCareGiverYearId.value;
    final meetingMap = student['meetingstatus'] as Map?;

    final Map<String, dynamic> actualMeeting;
    if (meetingMap != null && meetingMap.containsKey(yearId)) {
      actualMeeting = Map<String, dynamic>.from(meetingMap[yearId]);
    } else {
      actualMeeting = Map<String, dynamic>.from(meetingMap ?? {});
    }

    return actualMeeting[term] as Map<String, dynamic>? ?? {};
  }

  bool _isSubmitted(Map<String, dynamic> student, String term) {
    final state = _termData(student, term)['state']?.toString().toLowerCase() ?? '';
    return state == 'submitted' || state == 'approve' || state == 'approved';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoadingCareGiverMeeting.value) {
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
              value: controller.selectedCareGiverYearId.value.isNotEmpty
                  ? controller.selectedCareGiverYearId.value
                  : null,
              hint: const Text('Select Academic Year'),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
              items: controller.iepAcademicYears
                  .map((iep) => DropdownMenuItem<String>(
                        value: iep['id']?.toString() ?? '',
                        child: Text(controller.formatIepYear(iep), style: const TextStyle(fontSize: 15)),
                      ))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.selectedCareGiverYearId.value = val;
                  controller.fetchCareGiverMeetingData().then((_) {
                    _refreshSelections();
                  });
                }
              },
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
    if (controller.selectedCareGiverYearId.value.isEmpty) {
      return const Center(
        child: Column(
          children: [
            SizedBox(height: 60),
            Icon(Icons.calendar_today_outlined, size: 80, color: AppTheme.primaryColor),
            SizedBox(height: 24),
            Text(
              "Please select an academic year to view meeting data",
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final students = controller.careGiverStudents;
    
    if (students.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.person_off_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("No student caregiver meeting data found", style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

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

        // Term States Summary with Save/Submit buttons
        _buildTermStatesFooter(),
      ],
    );
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
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
            child: _buildMeetingStatusDropdown(student, 'entry'),
          ),
          Expanded(
            flex: 2,
            child: _buildMeetingStatusDropdown(student, 'term1'),
          ),
          Expanded(
            flex: 2,
            child: _buildMeetingStatusDropdown(student, 'term2'),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingStatusDropdown(Map<String, dynamic> student, String term) {
    final studentId = student['studentId']?.toString() ??
                      student['id']?.toString() ??
                      student['_id']?.toString() ?? '';
    final submitted = _isSubmitted(student, term);
    final currentVal = _selectedStatuses[studentId]?[term];

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: currentVal,
        hint: const Text("-", style: TextStyle(fontSize: 12, color: Colors.grey)),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, size: 16),
        style: const TextStyle(fontSize: 12, color: Colors.black),
        items: _statusOptions.map((opt) {
          return DropdownMenuItem<String>(
            value: opt['value'],
            child: Text(
              opt['label']!,
              style: const TextStyle(fontSize: 11, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: submitted
            ? null
            : (val) {
                setState(() {
                  if (_selectedStatuses[studentId] == null) {
                    _selectedStatuses[studentId] = {};
                  }
                  _selectedStatuses[studentId]![term] = val;
                });
              },
      ),
    );
  }

  Widget _buildTermStatesFooter() {
    final students = controller.careGiverStudents;
    if (students.isEmpty) return const SizedBox.shrink();

    // Take meeting status from the first student in the list
    final meetingStatus = students[0]['meetingstatus'];

    String formatState(dynamic termData) {
      if (termData == null) return "Draft";
      final yearId = controller.selectedCareGiverYearId.value;
      dynamic stateValue;
      if (termData is Map) {
        if (termData.containsKey(yearId)) {
          stateValue = termData[yearId]?['state'];
        } else {
          stateValue = termData['state'];
        }
      } else {
        stateValue = termData;
      }
      if (stateValue == null) return "Draft";
      
      String val = stateValue.toString().toLowerCase();
      if (val == "approve" || val == "approved") return "Approved";
      if (val == "submitted") return "Submitted";
      if (val == "rework") return "Rework";
      if (val == "pending") return "Pending";
      return stateValue.toString().capitalizeFirst ?? stateValue.toString();
    }

    final entryState = formatState(meetingStatus?['entry']);
    final term1State = formatState(meetingStatus?['term1']);
    final term2State = formatState(meetingStatus?['term2']);

    bool isEnabled(String state) {
      final s = state.toLowerCase();
      return s == "draft" || s == "rework" || s == "pending" || s == "";
    }

    bool entryEnabled = isEnabled(entryState);
    bool term1Enabled = isEnabled(term1State);
    bool term2Enabled = isEnabled(term2State);

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
          const SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: _buildFooterColumn(term1State, term1Enabled, "term1"),
          ),
          const SizedBox(width: 2),
          Expanded(
            flex: 2,
            child: _buildFooterColumn(term2State, term2Enabled, "term2"),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String status, bool isEnabled, String termKey) {
    Color statusColor = Colors.grey;
    if (status == "Approved") {
      statusColor = Colors.green;
    } else if (status == "Submitted") {
      statusColor = Colors.green.shade700;
    } else if (status == "Rework") {
      statusColor = Colors.red;
    } else if (status == "Pending") {
      statusColor = Colors.orange;
    }

    return Column(
      children: [
        Text(
          status,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildActionButton("Save", Colors.grey.shade700, isEnabled, () {
          _onSave(termKey);
        }),
        const SizedBox(height: 8),
        _buildActionButton("Submit", AppTheme.primaryColor, isEnabled, () {
          _onSubmit(termKey);
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

  void _onSave(String term) {
    // Collect selected statuses for the students
    final Map<String, String?> termStatuses = {};
    _selectedStatuses.forEach((studentId, studentTerms) {
      termStatuses[studentId] = studentTerms[term];
    });

    if (termStatuses.isEmpty) {
      Get.snackbar('Validation', 'No student meeting data to save.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    controller.saveCareGiverMeetingDraft(term: term, studentStatuses: termStatuses).then((_) {
      _refreshSelections();
    });
  }

  void _onSubmit(String term) {
    // Collect selected statuses for the students
    final Map<String, String?> termStatuses = {};
    _selectedStatuses.forEach((studentId, studentTerms) {
      termStatuses[studentId] = studentTerms[term];
    });

    if (termStatuses.isEmpty) {
      Get.snackbar('Validation', 'No student meeting data to submit.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Verify all students have a selected status before submitting
    bool allAnswered = true;
    termStatuses.forEach((studentId, status) {
      if (status == null) {
        allAnswered = false;
      }
    });

    if (!allAnswered) {
      Get.snackbar('Validation', 'Please select a meeting status for all students before submitting.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    controller.submitCareGiverMeeting(term: term, studentStatuses: termStatuses).then((_) {
      _refreshSelections();
    });
  }
}
