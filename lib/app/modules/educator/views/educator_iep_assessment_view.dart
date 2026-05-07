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
                _buildActionButton('Review', Colors.blue, () {
                  Get.snackbar('Review', 'Reviewing assessment.');
                }),
                _buildActionButton('Submit', Colors.green, () {
                  Get.snackbar('Submit', 'Assessment submitted successfully.');
                }),
                _buildActionButton('Reset', Colors.red, () {
                  controller.assessmentAnswers.clear();
                  Get.snackbar('Reset', 'Assessment cleared.');
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
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
      if (domains.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Assessment Domains'),
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
    return Container(
      width: 752, // 40 + 250 + 200 + 150 + 80 + 32 (padding)
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
          top: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 40, child: Text('No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          SizedBox(width: 250, child: Text('Questions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          SizedBox(width: 200, child: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          SizedBox(width: 150, child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          SizedBox(width: 80, child: Center(child: Text('Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
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
            width: 752,
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
    final options = questionData['options'] as List<dynamic>? ?? [];

    return Container(
      width: 752,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Obx(() {
        final answerData = controller.assessmentAnswers[questionId] ?? {};
        final selectedMainOption = answerData['mainOption'] as String?;
        final selectedScore = answerData['score'] as String?;
        final isGoal = answerData['isGoal'] as bool? ?? false;

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
              width: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: options.map((opt) {
                  final isSelected = selectedMainOption == opt.toString();
                  return InkWell(
                    onTap: () => controller.setAnswer(questionId, opt.toString()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                            size: 18,
                            color: isSelected ? AppTheme.primaryColor : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              opt.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              width: 150,
              child: selectedMainOption == 'Partially Independent'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: ['Rarely (<35%)', 'Sometimes (36-70%)', 'Often (71-99%)'].map((scoreOpt) {
                        final isScoreSelected = selectedScore == scoreOpt;
                        return InkWell(
                          onTap: () => controller.setScore(questionId, scoreOpt),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isScoreSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                  size: 16,
                                  color: isScoreSelected ? Colors.orange : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    scoreOpt,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isScoreSelected ? Colors.orange[800] : AppTheme.textSecondary,
                                      fontWeight: isScoreSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  : const SizedBox(),
            ),
            SizedBox(
              width: 80,
              child: InkWell(
                onTap: () => controller.toggleGoal(questionId),
                child: Center(
                  child: Icon(
                    isGoal ? Icons.flag : Icons.flag_outlined,
                    color: isGoal ? Colors.green : Colors.grey,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
