import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class EducatorIepAssessmentView extends GetView<EducatorController> {
  const EducatorIepAssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('IEP Assessment', style: TextStyle(color: Colors.white)),
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
            _buildSectionTitle('Select Assessment Details'),
            const SizedBox(height: 16),
            _buildAcademicYearDropdown(),
            const SizedBox(height: 16),
            _buildStudentDropdown(),
            const SizedBox(height: 32),
            Obx(() {
              if (controller.selectedIepAssessmentStudentId.value.isEmpty) {
                return const Center(
                  child: Text('Please select a student to view details.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
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
                        onPressed: controller.fetchAssessmentQuestions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Obx(() => controller.isLoadingQuestions.value
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
                  _buildDomainsList(),
                ],
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Obx(() {
        final status = controller.selectedIepStudentDetails?['status']?['entry']?.toString().toLowerCase() ?? '';
        if (controller.assessmentDomains.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: controller.isSavingDraft.value ? null : controller.saveDraft,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isSavingDraft.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Draft',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
                _buildActionButton('Review', Colors.blue, controller.isAllIepQuestionsAnswered ? () {
                  controller.reviewAssessment();
                } : null),
                Obx(() => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      onPressed: (controller.isReviewComplete.value && !controller.isSubmitting.value)
                          ? controller.submitAssessment
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: controller.isSubmitting.value
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Submit',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                    ),
                  ),
                )),
                _buildActionButton('Reset', Colors.red, null),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback? onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
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
                value: controller.selectedIepYearId.value.isNotEmpty ? controller.selectedIepYearId.value : null,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedIepYearId.value = newValue;
                    // Reset selected student when year changes
                    controller.selectedIepAssessmentStudentId.value = '';
                    controller.selectedIepLevel.value = '';
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
      final isYearSelected = controller.selectedIepYearId.value.isNotEmpty;
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
                value: controller.selectedIepAssessmentStudentId.value.isNotEmpty
                    ? controller.selectedIepAssessmentStudentId.value
                    : null,
                icon: Icon(Icons.keyboard_arrow_down, color: isYearSelected ? AppTheme.primaryColor : Colors.grey),
                onChanged: isYearSelected
                    ? (String? newValue) {
                        if (newValue != null) {
                          controller.selectedIepAssessmentStudentId.value = newValue;
                          controller.autoSetIepLevel();
                        }
                      }
                    : null,
                items: students.asMap().entries.map<DropdownMenuItem<String>>((entry) {
                  final index = entry.key;
                  final student = entry.value as Map<String, dynamic>;
                  // Use multiple fallbacks to ensure a unique ID is captured.
                  // If no ID is present, fallback to index to avoid duplicate value errors.
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
            'Student IEP Details',
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
          _buildIepLevelDropdown(),
          const Divider(height: 32),
          _buildDetailRow('Age :', _getStudentAge()),
          const Divider(height: 32),
          _buildDetailRow('Teacher :', controller.currentEducator.value?.fullName ?? 'N/A'),
          const Divider(height: 32),
          _buildDetailRow('IEP Status :', _getIepStatus()),
        ],
      ),
    );
  }

  String _getStudentName() {
    final details = controller.selectedIepStudentDetails;
    return details?['studentName']?.toString() ?? 'N/A';
  }

  String _getFormattedAcademicYear() {
    final yearId = controller.selectedIepYearId.value;
    final yearMap = controller.iepAcademicYears.firstWhere(
      (y) => y['id']?.toString() == yearId,
      orElse: () => <String, dynamic>{},
    );
    if (yearMap.isNotEmpty) {
      return controller.formatIepYear(yearMap);
    }
    return 'N/A';
  }

  Widget _buildIepLevelDropdown() {
    return Obx(() {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 120,
            child: Text(
              'IEP Level * :',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select IEP Level'),
                  value: controller.selectedIepLevel.value.isNotEmpty ? controller.selectedIepLevel.value : null,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      // Check age and enforce rule
                      final details = controller.selectedIepStudentDetails;
                      final dob = details?['dateOfBirth']?.toString() ??
                                  details?['dob']?.toString() ??
                                  details?['date_of_birth']?.toString() ??
                                  details?['DOB']?.toString();
                      final age = controller.calculateAge(dob);
                      
                      if (age > 0) {
                        if (age < 14 && newValue == '14-18 years') {
                          Get.snackbar('Invalid Selection', 'Student age is $age. Please select "3-14 years".',
                              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
                          return;
                        }
                        if (age >= 14 && newValue == '3-14 years') {
                          Get.snackbar('Invalid Selection', 'Student age is $age. Please select "14-18 years".',
                              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
                          return;
                        }
                      }
                      
                      controller.selectedIepLevel.value = newValue;
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: '3-14 years', child: Text('3-14 years')),
                    DropdownMenuItem(value: '14-18 years', child: Text('14-18 years')),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  String _getStudentAge() {
    final details = controller.selectedIepStudentDetails;
    final dob = details?['dateOfBirth']?.toString();
    final age = controller.calculateAge(dob);
    return age > 0 ? '$age Years' : 'N/A';
  }

  String _getIepStatus() {
    final details = controller.selectedIepStudentDetails;
    final statusMap = details?['status'] as Map<String, dynamic>?;
    if (statusMap != null) {
      final entry = statusMap['entry']?.toString() ?? 'Pending';
      return entry.toUpperCase();
    }
    return 'PENDING';
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

  Widget _buildDomainsList() {
    return Obx(() {
      if (controller.isLoadingQuestions.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final domains = controller.assessmentDomains;
      final allDomains = controller.allAssessmentDomains;
      final ageGroup = controller.selectedIepLevel.value;

      // Domains fetched but nothing visible after filter
      if (allDomains.isNotEmpty && domains.isEmpty && ageGroup.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Assessment Domains'),
            const SizedBox(height: 12),
            _buildAgeGroupBadge(ageGroup),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(Icons.filter_list_off, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No questions found for "$ageGroup".',
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      }

      if (domains.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Assessment Domains'),
          const SizedBox(height: 12),
          if (ageGroup.isNotEmpty) _buildAgeGroupBadge(ageGroup),
          const SizedBox(height: 12),
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

  Widget _buildAgeGroupBadge(String ageGroup) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.child_care, size: 15, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            'Age Group: $ageGroup',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
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
        subtitle: Obx(() {
          final answered = controller.getDomainAnsweredCount(domain);
          final total = controller.getDomainTotalQuestionsCount(domain);
          final goals = controller.getDomainGoalsCount(domain);
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text('Questions :', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text(' $answered/$total', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryColor, fontSize: 12)),
                const Text('  •  ', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                Text('Goals: $goals', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange, fontSize: 12)),
              ],
            ),
          );
        }),
        children: [
          if (questions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildQuestionCardsWithSubdomains(questions),
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

  List<Widget> _buildQuestionCardsWithSubdomains(List<dynamic> questions) {
    final widgets = <Widget>[];
    String currentSubdomain = '';
    
    // Reverse the questions list as requested
    final reversedQuestions = questions.reversed.toList();

    for (int i = 0; i < reversedQuestions.length; i++) {
      final q = reversedQuestions[i];
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
      widgets.add(_buildQuestionCard(q, i));
    }
    return widgets;
  }

  Widget _buildQuestionCard(dynamic questionData, int index) {
    final questionId = questionData['_id']?.toString() ?? 'q_$index';
    final questionText = questionData['question']?.toString() ?? 'Unknown Question';
    final options = questionData['options'] as List<dynamic>? ?? [];

    return Obx(() {
      final answerData = controller.assessmentAnswers[questionId] ?? {};
      final selectedMainOption = answerData['mainOption'] as String?;
      final selectedScore = answerData['score'] as String?;
      final isGoal = answerData['isGoal'] as bool? ?? false;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isGoal
                ? Colors.green.shade300
                : Colors.grey.shade200,
            width: isGoal ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Question header: number + text + goal flag ────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      questionText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => controller.toggleGoal(questionId),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isGoal
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (isGoal) ...[
                            GestureDetector(
                              onTap: () => controller.toggleGoalType(questionId),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (answerData['goalType'] ?? 'School') == 'School'
                                      ? Colors.blue.shade50
                                      : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: (answerData['goalType'] ?? 'School') == 'School'
                                        ? Colors.blue.shade200
                                        : Colors.green.shade200,
                                  ),
                                ),
                                child: Text(
                                  (answerData['goalType'] ?? 'School') == 'School' ? 'SCH' : 'HM',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: (answerData['goalType'] ?? 'School') == 'School'
                                        ? Colors.blue
                                        : Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Icon(
                            isGoal ? Icons.flag : Icons.flag_outlined,
                            color: isGoal ? Colors.green.shade600 : Colors.grey,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (options.isNotEmpty) ...[
              Divider(height: 1, color: Colors.grey.shade100),

              // ── Grade options ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grade',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: options.map((opt) {
                        final isSelected = selectedMainOption == opt.toString();
                        return GestureDetector(
                          onTap: () =>
                              controller.setAnswer(questionId, opt.toString()),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              opt.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            // ── Score sub-options (Partially Independent only) ────────
            if (selectedMainOption == 'Partially Independent') ...[
              Divider(height: 1, color: Colors.orange.shade100),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, size: 13, color: Colors.orange.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...['Rarely(<35%)', 'Sometimes(36-70%)', 'Often(71-99%)']
                        .map((scoreOpt) {
                      final isScoreSelected = selectedScore == scoreOpt;
                      return GestureDetector(
                        onTap: () => controller.setScore(questionId, scoreOpt),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(
                                isScoreSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: isScoreSelected
                                    ? Colors.orange.shade600
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                scoreOpt,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isScoreSelected
                                      ? Colors.orange.shade800
                                      : AppTheme.textSecondary,
                                  fontWeight: isScoreSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
