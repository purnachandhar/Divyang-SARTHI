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
                  Obx(() {
                    if (!controller.isGoalMonitoringDataLoaded.value && !controller.isLoadingGoalMonitoringQuestions.value) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStudentDetailsCard(),
                        const SizedBox(height: 24),
                        _buildTermSelector(),
                        const SizedBox(height: 24),
                        _buildDomainsList(),
                      ],
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.goalMonitoringDomains.isEmpty) return const SizedBox.shrink();
        final termStatus = (controller.goalMonitoringStatuses[controller.selectedGoalMonitoringTerm.value] ?? '').toLowerCase();
        final isEditable = termStatus == 'pending' || termStatus == 'rework';
        
        if (!isEditable) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isSavingGoalMonitoringDraft.value
                          ? null
                          : controller.saveGoalMonitoringDraft,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isSavingGoalMonitoringDraft.value
                          ? const SizedBox(height: 16, width: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Draft',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                    )),
                  ),
                ),
                Obx(() => _buildActionButton('Review', Colors.blue, controller.isAllGoalMonitoringAnswered ? () {
                  controller.reviewGoalMonitoring();
                } : null)),
                Obx(() => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: (controller.isGoalMonitoringReviewComplete.value && !controller.isSubmittingGoalMonitoring.value)
                          ? controller.submitGoalMonitoring
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (controller.isGoalMonitoringReviewComplete.value && !controller.isSubmittingGoalMonitoring.value)
                            ? Colors.green
                            : Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isSubmittingGoalMonitoring.value
                          ? const SizedBox(height: 16, width: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Submit',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                )),
                _buildActionButton('Reset', Colors.red, controller.resetGoalMonitoring),
              ],
            ),
          ),
        );
      }),
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
        final isEnabled = controller.isTermTabEnabled(termKey);
        final status = controller.goalMonitoringStatuses[termKey] ?? 'N/A';

        Color statusColor = AppTheme.textSecondary;
        if (status.toLowerCase() == 'approve') statusColor = Colors.green;
        else if (status.toLowerCase() == 'pending') statusColor = Colors.orange;
        else if (status.toLowerCase() == 'rework') statusColor = Colors.red;

        return GestureDetector(
          onTap: isEnabled ? () => controller.selectedGoalMonitoringTerm.value = termKey : null,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white
                  : (isEnabled ? Colors.transparent : Colors.grey.shade100),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEnabled)
                      const Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Icon(Icons.lock, size: 10, color: Colors.grey),
                      ),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isEnabled
                            ? (isSelected ? AppTheme.primaryColor : AppTheme.textSecondary)
                            : Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (status != 'N/A')
                  Text(
                    status.capitalizeFirst ?? status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isEnabled ? statusColor : Colors.grey,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildGoalQuestionCardsWithSubdomains(questions),
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

  List<Widget> _buildGoalQuestionCardsWithSubdomains(List<dynamic> questions) {
    final widgets = <Widget>[];
    String currentSubdomain = '';

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final subdomain = q['subdomain']?.toString() ?? '';

      if (subdomain.isNotEmpty && subdomain != currentSubdomain) {
        currentSubdomain = subdomain;
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentSubdomain,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      widgets.add(_buildGoalQuestionCard(q, i));
    }
    return widgets;
  }

  Widget _buildGoalQuestionCard(dynamic questionData, int index) {
    final questionId = questionData['_id']?.toString() ?? 'q_$index';
    final questionText = questionData['question']?.toString() ?? 'Unknown Question';
    final List<dynamic> options = questionData['options'] ?? [];

    return Obx(() {
      final termStatus = (controller.goalMonitoringStatuses[controller.selectedGoalMonitoringTerm.value] ?? '').toLowerCase();
      final isPending = termStatus == 'pending' || termStatus == 'rework';
      final answerData = controller.goalMonitoringAnswers[questionId] ?? {};
      final grade = answerData['mainOption']?.toString() ?? '';
      final score = answerData['score']?.toString() ?? '';
      final goalType = answerData['goalType'] is List
          ? (answerData['goalType'] as List).join(', ')
          : (answerData['goalType']?.toString() ?? '');

      final hasGrade = grade.isNotEmpty && grade != 'N/A';
      final hasScore = score.isNotEmpty && score != 'N/A';
      final hasGoalType = goalType.isNotEmpty && goalType != 'N/A';
      final remarks = answerData['remarks']?.toString() ?? '';
      final hasRemarks = remarks.isNotEmpty && remarks != 'null';

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPending ? AppTheme.primaryColor.withValues(alpha: 0.2) : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Question header ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(questionText,
                              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4)),
                        ),
                        if (isPending || controller.getGoalRemarksFromAllTerms(questionId).isNotEmpty) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => controller.showGoalMonitoringRemarksDialog(questionId, questionText),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(isPending ? Icons.add : Icons.visibility, size: 16, color: AppTheme.primaryColor),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Editable options (when term is pending) ───────────────
            if (isPending && options.isNotEmpty) ...[
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SELECT GRADE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary, letterSpacing: 0.8)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: options.map((opt) {
                        final optStr = opt.toString();
                        final isSelected = grade == optStr;
                        return GestureDetector(
                          onTap: () => controller.setGoalMonitoringAnswer(questionId, optStr),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(optStr,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.white : AppTheme.textPrimary)),
                          ),
                        );
                      }).toList(),
                    ),
                    // Score sub-options when Partially Independent is selected
                    if (grade == 'Partially Independent') ...[
                      const SizedBox(height: 10),
                      const Text('SELECT SCORE',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                              color: AppTheme.textSecondary, letterSpacing: 0.8)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ['Rarely(<35%)', 'Sometimes(36-70%)', 'Often(71-99%)'].map((s) {
                          final isSelected = score == s;
                          return GestureDetector(
                            onTap: () => controller.setGoalMonitoringScore(questionId, s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orange.shade600 : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? Colors.orange.shade600 : Colors.orange.shade200,
                                ),
                              ),
                              child: Text(s,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : Colors.orange.shade700)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // ── Read-only result chips ────────────────────────────────
            if (!isPending && (hasGrade || hasScore || hasGoalType)) ...[
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (hasGrade)
                      _buildResultChip(label: 'Grade', value: grade,
                          bgColor: AppTheme.primaryColor.withValues(alpha: 0.08),
                          textColor: AppTheme.primaryColor, icon: Icons.grade_outlined),
                    if (hasScore)
                      _buildResultChip(label: 'Score', value: score,
                          bgColor: Colors.orange.shade50,
                          textColor: Colors.orange.shade700, icon: Icons.tune),
                    if (hasGoalType)
                      _buildResultChip(label: 'Goal Type', value: goalType,
                          bgColor: Colors.green.shade50,
                          textColor: Colors.green.shade700, icon: Icons.flag_outlined),
                  ],
                ),
              ),
            ],

            // ── Show current selection while editing ──────────────────
            if (isPending && (hasGrade || hasScore)) ...[
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (hasGrade)
                      _buildResultChip(label: 'Grade', value: grade,
                          bgColor: AppTheme.primaryColor.withValues(alpha: 0.08),
                          textColor: AppTheme.primaryColor, icon: Icons.grade_outlined),
                    if (hasScore)
                      _buildResultChip(label: 'Score', value: score,
                          bgColor: Colors.orange.shade50,
                          textColor: Colors.orange.shade700, icon: Icons.tune),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildResultChip({
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
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
          // const Divider(height: 32),
          // // Overall IEP Assessment Status
          // Obx(() {
          //   if (controller.selectedGoalMonitoringStudentId.value.isEmpty) return const SizedBox.shrink();
          //   final status = _getOverallIepStatus();
          //   return Column(
          //     children: [
          //       _buildDetailRow('IEP Status :', status, isStatus: true),
                
          //     ],
          //   );
          // }),
          
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

  String _getOverallIepStatus() {
    final studentId = controller.selectedGoalMonitoringStudentId.value;
    final student = controller.niepidStudentAssessments.firstWhere(
      (s) => (s['studentId']?.toString() ?? s['id']?.toString() ?? s['_id']?.toString()) == studentId,
      orElse: () => <String, dynamic>{},
    );
    final statusMap = student['status'] as Map?;
    if (statusMap != null) {
      return (statusMap['entry']?.toString() ?? 'PENDING').toUpperCase();
    }
    return 'PENDING';
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
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
          child: isStatus 
              ? _buildStatusBadgeUI(value)
              : Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
        ),
      ],
    );
  }

  Widget _buildStatusBadgeUI(String status) {
    Color bg;
    Color fg;
    if (status == 'SUBMITTED' || status == 'APPROVE') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    } else if (status == 'PENDING') {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
    } else if (status == 'REWORK') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
    } else {
      bg = Colors.grey.shade100;
      fg = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
        textAlign: TextAlign.center,
      ),
    );
  }
  Widget _buildActionButton(String text, Color color, VoidCallback? onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null ? color : Colors.grey.shade400,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }


}
