import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class EducatorCareGiverMeetingView extends GetView<EducatorController> {
  const EducatorCareGiverMeetingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Care Giver Meeting', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAcademicYearDropdown(),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.selectedCareGiverYearId.value.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.calendar_today_outlined,
                  message: 'Please select an academic year to view meeting data.',
                );
              }
              if (controller.isLoadingCareGiverMeeting.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (controller.careGiverStudents.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.people_outline,
                  message: 'No meeting data available for this year.',
                );
              }
              return _buildStudentList();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
              textAlign: TextAlign.center,
            ),
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
          RichText(
            text: const TextSpan(
              text: 'Academic Year',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.textSecondary),
              children: [
                TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select Year',
                    style: TextStyle(color: AppTheme.textSecondary)),
                value: controller.selectedCareGiverYearId.value.isNotEmpty
                    ? controller.selectedCareGiverYearId.value
                    : null,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppTheme.primaryColor),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedCareGiverYearId.value = newValue;
                    controller.fetchCareGiverMeetingData();
                  }
                },
                items:
                    years.map<DropdownMenuItem<String>>((Map<String, dynamic> iep) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.careGiverStudents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final student =
                    controller.careGiverStudents[index] as Map<String, dynamic>;
                return _StudentMeetingCard(student: student);
              },
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-student card — each meeting type is an independent row with its own
// status dropdown + "Status: …" label + Save / Submit buttons.
// ─────────────────────────────────────────────────────────────────────────────

class _StudentMeetingCard extends StatefulWidget {
  final Map<String, dynamic> student;
  const _StudentMeetingCard({required this.student});

  @override
  State<_StudentMeetingCard> createState() => _StudentMeetingCardState();
}

class _StudentMeetingCardState extends State<_StudentMeetingCard> {
  // Local selections per term, initialised from API data
  final Map<String, String?> _selectedStatuses = {
    'entry': null,
    'term1': null,
    'term2': null,
  };

  static const _termKeys = ['entry', 'term1', 'term2'];

  static const _termLabels = {
    'entry': 'Meeting after IEP Approval',
    'term1': 'Meeting after 1st Term',
    'term2': 'Meeting after 2nd Term',
  };

  static const _statusOptions = [
    {'value': 'caregiver_met', 'label': 'Caregiver Met'},
    {'value': 'not_met', 'label': 'Not Met'},
  ];

  @override
  void initState() {
    super.initState();
    _refreshSelections();
  }

  void _refreshSelections() {
    final yearId = Get.find<EducatorController>().selectedCareGiverYearId.value;
    final meetingMap = widget.student['meetingstatus'] as Map?;
    
    // Check if it's nested by year or flat
    Map<String, dynamic> actualMeeting;
    if (meetingMap != null && meetingMap.containsKey(yearId)) {
      actualMeeting = Map<String, dynamic>.from(meetingMap[yearId]);
    } else {
      actualMeeting = Map<String, dynamic>.from(meetingMap ?? {});
    }

    for (final term in _termKeys) {
      final termData = actualMeeting[term] as Map<String, dynamic>? ?? {};
      final status = termData['status']?.toString();
      _selectedStatuses[term] =
          (status != null && status.isNotEmpty && status != 'null')
              ? status
              : null;
    }
  }

  Map<String, dynamic> _termData(String term) {
    final yearId = Get.find<EducatorController>().selectedCareGiverYearId.value;
    final meetingMap = widget.student['meetingstatus'] as Map?;
    
    final Map<String, dynamic> actualMeeting;
    if (meetingMap != null && meetingMap.containsKey(yearId)) {
      actualMeeting = Map<String, dynamic>.from(meetingMap[yearId]);
    } else {
      actualMeeting = Map<String, dynamic>.from(meetingMap ?? {});
    }
    
    return actualMeeting[term] as Map<String, dynamic>? ?? {};
  }

  bool _isSubmitted(String term) {
    final state = _termData(term)['state']?.toString().toLowerCase() ?? '';
    return state == 'submitted' || state == 'approve' || state == 'approved';
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.student['studentName']?.toString() ?? 'Unknown';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Student name header ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.07),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person,
                      color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // ── One row per meeting type ──────────────────────────────────
          for (int i = 0; i < _termKeys.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
            _buildMeetingSection(_termKeys[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildMeetingSection(String term) {
    final submitted = _isSubmitted(term);
    final state = _termData(term)['state']?.toString().toLowerCase() ?? 'pending';
    final stateLabel = _capitalize(state);
    
    Color stateColor = Colors.orange.shade700;
    if (state == 'submitted' || state == 'approve' || state == 'approved') {
      stateColor = Colors.green.shade600;
    } else if (state == 'rework') {
      stateColor = Colors.red.shade700;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting label
          Text(
            _termLabels[term]!,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Status dropdown
          _buildStatusDropdown(term, submitted),
          const SizedBox(height: 10),

          // Status label + action buttons on the same row
          Row(
            children: [
              Icon(
                submitted
                    ? Icons.check_circle_outline
                    : Icons.schedule_outlined,
                size: 14,
                color: stateColor,
              ),
              const SizedBox(width: 4),
              Text(
                'Status: $stateLabel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: stateColor,
                ),
              ),
              const Spacer(),
              _ActionButton(
                label: 'Save',
                enabled: !submitted,
                color: Colors.grey.shade700,
                onPressed: () => _onSave(term),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Submit',
                enabled: !submitted,
                color: AppTheme.primaryColor,
                onPressed: () => _onSubmit(term),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(String term, bool enabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            'Select',
            style: TextStyle(
                fontSize: 14,
                color: enabled ? AppTheme.textSecondary : Colors.grey.shade400),
          ),
          value: _selectedStatuses[term],
          icon: Icon(Icons.keyboard_arrow_down,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400),
          onChanged: enabled
              ? (String? newValue) {
                  setState(() => _selectedStatuses[term] = newValue);
                }
              : null,
          items: _statusOptions.map<DropdownMenuItem<String>>((opt) {
            return DropdownMenuItem<String>(
              value: opt['value']!,
              child: Text(opt['label']!,
                  style: const TextStyle(
                      fontSize: 14, color: AppTheme.textPrimary)),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onSave(String term) {
    if (_selectedStatuses[term] == null) {
      Get.snackbar('Validation', 'Please select a meeting status before saving.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    // TODO: wire up save API with term + selectedStatuses[term]
    Get.snackbar('Saved', 'Meeting status saved as draft.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey.shade700,
        colorText: Colors.white);
  }

  void _onSubmit(String term) {
    if (_selectedStatuses[term] == null) {
      Get.snackbar(
          'Validation', 'Please select a meeting status before submitting.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }
    // TODO: wire up submit API with term + selectedStatuses[term]
    Get.snackbar('Submitted', 'Meeting status submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Small Save / Submit button that handles enabled / disabled styling cleanly
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? color : Colors.grey.shade200,
        disabledBackgroundColor: Colors.grey.shade200,
        foregroundColor: enabled ? Colors.white : Colors.grey.shade400,
        disabledForegroundColor: Colors.grey.shade400,
        elevation: enabled ? 1 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      child: Text(label),
    );
  }
}
