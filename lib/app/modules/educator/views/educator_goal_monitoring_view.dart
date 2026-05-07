import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class EducatorGoalMonitoringView extends GetView<EducatorController> {
  const EducatorGoalMonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Goal Monitoring', style: TextStyle(color: Colors.white)),
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
            _buildSectionTitle('Select Monitoring Details'),
            const SizedBox(height: 16),
            _buildAcademicYearDropdown(),
            const SizedBox(height: 16),
            _buildStudentDropdown(),
            const SizedBox(height: 32),
            Obx(() {
              if (controller.selectedGoalMonitoringStudentId.value.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: Text('Please select a student to monitor goals.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentDetailsCard(),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.fetchGoalMonitoringQuestions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Obx(() => controller.isLoadingGoalMonitoringQuestions.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                            : const Text('Get Assessment',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildTermSelector(),
                  const SizedBox(height: 24),
                  _buildDomainsList(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSelector() {
    return Container(
      height: 64, // Increased height for status
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTermTab('Baseline', 'entry'),
          _buildTermTab('1st Term', 'term1'),
          _buildTermTab('2nd Term', 'term2'),
        ],
      ),
    );
  }

  Widget _buildTermTab(String label, String termKey) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedGoalMonitoringTerm.value == termKey;
        final status = controller.goalMonitoringStatuses[termKey] ?? 'N/A';
        print('Status: $status');
        
        Color statusColor = AppTheme.textSecondary;
        if (status.toLowerCase() == 'approve') {
          statusColor = Colors.green;
        } else if (status.toLowerCase() == 'pending') {
          statusColor = Colors.orange;
        }

        return GestureDetector(
          onTap: () => controller.selectedGoalMonitoringTerm.value = termKey,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                if (status != 'N/A')
                  Text(
                    status.capitalizeFirst ?? status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTermPlaceholder(String termName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.assessment_outlined, size: 64, color: AppTheme.primaryColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            '$termName Assessment',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'The assessment data for this term will be available here once implemented.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainsList() {
    return Obx(() {
      if (controller.isLoadingGoalMonitoringQuestions.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      final domains = controller.goalMonitoringDomains;
      if (domains.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Goal Monitoring Domains'),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: domains.length,
            itemBuilder: (context, index) {
              final domain = domains[index];
              return _buildDomainCard(domain);
            },
          ),
        ],
      );
    });
  }

  Widget _buildDomainCard(Map<String, dynamic> domain) {
    final domainName = domain['domainName']?.toString() ?? 'Unknown Domain';
    final questionsCount = domain['questionsCount']?.toString() ?? '0';
    final iconUrl = domain['domainIcon']?.toString() ?? '';
    final List<dynamic> questions = domain['questions'] ?? [];

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
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: iconUrl.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    iconUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.assessment, color: AppTheme.primaryColor),
                  ),
                )
              : const Icon(Icons.assessment, color: AppTheme.primaryColor),
        ),
        title: Text(
          domainName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
        ),
        subtitle: Text('Questions: $questionsCount', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        children: [
          if (questions.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTableHeader(),
                  ..._buildQuestionRowsWithSubdomains(questions),
                ],
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No questions available.', style: TextStyle(color: AppTheme.textSecondary)),
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    final isTermView = controller.selectedGoalMonitoringTerm.value != 'entry';
    final totalWidth = isTermView ? 1000.0 : 852.0;
    return Container(
      width: totalWidth,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40, child: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(width: 250, child: Text('Question', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          SizedBox(
            width: isTermView ? 300 : 150,
            child: Text(isTermView ? 'Options' : 'Grade', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
          const SizedBox(width: 150, child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(width: 200, child: Text('Goal Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
        ],
      ),
    );
  }

  List<Widget> _buildQuestionRowsWithSubdomains(List<dynamic> questions) {
    final rows = <Widget>[];
    String currentSubdomain = '';

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final subdomain = q['subdomain']?.toString() ?? '';

      if (subdomain.isNotEmpty && subdomain != currentSubdomain) {
        currentSubdomain = subdomain;
        rows.add(
          Container(
            width: controller.selectedGoalMonitoringTerm.value != 'entry' ? 1000 : 852,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppTheme.primaryColor.withOpacity(0.05),
            child: Text(
              currentSubdomain,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
            ),
          ),
        );
      }
      rows.add(_buildQuestionRow(q, i));
    }
    return rows;
  }

  Widget _buildQuestionRow(dynamic questionData, int index) {
    final questionId = questionData['_id']?.toString() ?? 'q_$index';
    final questionText = questionData['question']?.toString() ?? 'Unknown Question';
    final List<dynamic> options = questionData['options'] ?? [];

    return Container(
      width: controller.selectedGoalMonitoringTerm.value != 'entry' ? 1000 : 852,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Obx(() {
        final isTermView = controller.selectedGoalMonitoringTerm.value != 'entry';
        final answerData = controller.goalMonitoringAnswers[questionId] ?? {};
        final grade = answerData['mainOption']?.toString() ?? 'N/A';
        final score = answerData['score']?.toString() ?? 'N/A';
        final goalType = answerData['goalType'] is List 
            ? (answerData['goalType'] as List).join(', ') 
            : (answerData['goalType']?.toString() ?? 'N/A');

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 40,
              child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
            ),
            SizedBox(
              width: 250,
              child: Text(questionText, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary)),
            ),
            SizedBox(
              width: isTermView ? 300 : 150,
              child: isTermView
                  ? Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: options.map((opt) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            opt.toString(),
                            style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary),
                          ),
                        );
                      }).toList(),
                    )
                  : Text(grade, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ),
            SizedBox(
              width: 150,
              child: Text(score, style: const TextStyle(fontSize: 13, color: Colors.orange)),
            ),
            SizedBox(
              width: 200,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: goalType != 'N/A' ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  goalType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: goalType != 'N/A' ? FontWeight.bold : FontWeight.normal,
                    color: goalType != 'N/A' ? AppTheme.primaryColor : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildAcademicYearDropdown() {
    return Obx(() {
      final years = controller.iepAcademicYears;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Academic Year', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
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
                value: controller.selectedGoalMonitoringYearId.value.isNotEmpty 
                    ? controller.selectedGoalMonitoringYearId.value 
                    : (controller.selectedIepYearId.value.isNotEmpty ? controller.selectedIepYearId.value : null),
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedGoalMonitoringYearId.value = newValue;
                    // Reset selected student when year changes
                    controller.selectedGoalMonitoringStudentId.value = '';
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

  Widget _buildStudentDropdown() {
    return Obx(() {
      final isYearSelected = controller.selectedGoalMonitoringYearId.value.isNotEmpty || controller.selectedIepYearId.value.isNotEmpty;
      final students = controller.niepidStudentAssessments;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isYearSelected ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                hint: const Text('Select Student'),
                value: controller.selectedGoalMonitoringStudentId.value.isNotEmpty
                    ? controller.selectedGoalMonitoringStudentId.value
                    : null,
                icon: Icon(Icons.keyboard_arrow_down, color: isYearSelected ? AppTheme.primaryColor : Colors.grey),
                onChanged: isYearSelected
                    ? (String? newValue) {
                        if (newValue != null) {
                          controller.selectedGoalMonitoringStudentId.value = newValue;
                        }
                      }
                    : null,
                items: students.asMap().entries.map<DropdownMenuItem<String>>((entry) {
                  final index = entry.key;
                  final student = entry.value as Map<String, dynamic>;
                  final id = student['studentId']?.toString() ??
                             student['id']?.toString() ??
                             student['_id']?.toString() ??
                             'index_$index';
                  final name = student['studentName']?.toString() ?? 'Unknown Student';
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text(name),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStudentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Student Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow('Student :', _getStudentName()),
          const Divider(height: 32),
          _buildDetailRow('Academic Year :', _getFormattedAcademicYear()),
          const Divider(height: 32),
          _buildDetailRow('Age :', _getStudentAge()),
          const Divider(height: 32),
          _buildDetailRow('Teacher :', controller.currentEducator.value?.fullName ?? 'N/A'),
          const Divider(height: 32),
          // Status section
          Obx(() {
            final statuses = controller.goalMonitoringStatuses;
            if (statuses.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusBadge('Baseline', statuses['entry'] ?? 'N/A'),
                    const SizedBox(width: 8),
                    _buildStatusBadge('1st Term', statuses['term1'] ?? 'N/A'),
                    const SizedBox(width: 8),
                    _buildStatusBadge('2nd Term', statuses['term2'] ?? 'N/A'),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String termName, String status) {
    Color bg;
    Color fg;
    IconData icon;
    if (status.toLowerCase() == 'approve') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
      icon = Icons.check_circle_outline;
    } else if (status.toLowerCase() == 'pending') {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
      icon = Icons.schedule;
    } else {
      bg = Colors.grey.shade100;
      fg = AppTheme.textSecondary;
      icon = Icons.remove_circle_outline;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: fg.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(height: 4),
            Text(
              termName,
              style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            Text(
              status.capitalizeFirst ?? status,
              style: TextStyle(fontSize: 10, color: fg),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getStudentName() {
    final details = controller.selectedGoalMonitoringStudentDetails;
    return details?['studentName']?.toString() ?? 'N/A';
  }

  String _getFormattedAcademicYear() {
    final yearId = controller.selectedGoalMonitoringYearId.value.isNotEmpty 
        ? controller.selectedGoalMonitoringYearId.value 
        : controller.selectedIepYearId.value;
    final yearMap = controller.iepAcademicYears.firstWhere(
      (y) => y['id']?.toString() == yearId,
      orElse: () => <String, dynamic>{},
    );
    if (yearMap.isNotEmpty) {
      return controller.formatIepYear(yearMap);
    }
    return 'N/A';
  }

  String _getStudentAge() {
    final details = controller.selectedGoalMonitoringStudentDetails;
    final dob = details?['dateOfBirth']?.toString();
    final age = controller.calculateAge(dob);
    return age > 0 ? '$age Years' : 'N/A';
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}
