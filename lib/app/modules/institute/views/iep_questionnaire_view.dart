import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../controllers/institute_controller.dart';

class IepQuestionnaireView extends GetView<InstituteController> {
  const IepQuestionnaireView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        final domains = controller.filteredNiepidDomains;
        if (domains.isEmpty) {
          return const Center(child: Text("No questions found for this age group"));
        }

        return Column(
          children: [
            Container(
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
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assessment Questions',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Obx(() {
                          final studentName = controller.selectedNiepidStudent.value ?? "Student";
                          final age = controller.calculateAge(
                            controller.selectedStudentData.value?['dateOfBirth'] ??
                            controller.selectedStudentData.value?['dob'] ?? 
                            controller.selectedStudentData.value?['age']
                          );
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('$studentName • Age: $age',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildStatBadge(Icons.quiz, 'Qs: ${controller.totalQuestionsCount}', Colors.white),
                                    const SizedBox(width: 8),
                                    _buildStatBadge(Icons.check_circle, 'Questions: ${controller.totalAnsweredCount}', Colors.white),
                                    const SizedBox(width: 8),
                                    _buildStatBadge(Icons.star, 'Goals: ${controller.totalGoalsCount}', Colors.orangeAccent),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: domains.length + 1,
                itemBuilder: (context, index) {
                  if (index == domains.length) {
                    return _buildSubjectLevelsSection();
                  }
                  final domain = domains[index];
                  return _buildDomainCard(domain);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSubjectLevelsSection() {
    return Obx(() {
      final goals = controller.niepidStudentGoals.value;
      final List subjects = (goals?['subject'] as List?) ?? [];

      if (subjects.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.menu_book, color: AppTheme.primaryColor),
            ),
            title: const Text(
              'Subject Levels',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppTheme.textPrimary,
              ),
            ),
            subtitle: const Text(
              'Selected level for each subject',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            children: [
              const Divider(height: 1),
              ...subjects.map((s) => _buildSubjectLevelRow(
                    s is Map ? Map<String, dynamic>.from(s) : {},
                  )),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSubjectLevelRow(Map<String, dynamic> subjectData) {
    final subject = subjectData['subject']?.toString() ?? '';
    final level = subjectData['Level']?.toString() ?? '';
    final hasLevel = level.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
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
                    subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hasLevel
                    ? AppTheme.primaryColor.withOpacity(0.08)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasLevel
                      ? AppTheme.primaryColor.withOpacity(0.25)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Text(
                hasLevel ? level : 'Not selected',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hasLevel ? FontWeight.w600 : FontWeight.normal,
                  color: hasLevel
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainCard(Map<String, dynamic> domain) {
    final List questions = domain['questions'] ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: domain['domainIcon'] != null 
              ? Image.network(domain['domainIcon'], width: 30, height: 30, errorBuilder: (c, e, s) => const Icon(Icons.category, color: AppTheme.primaryColor))
              : const Icon(Icons.category, color: AppTheme.primaryColor),
          ),
          title: Text(
            domain['domainName'] ?? 'Unnamed Domain',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: AppTheme.textPrimary,
            ),
          ),
          subtitle: Obx(() {
            final total = controller.getDomainTotalQuestionsCount(domain);
            final answered = controller.getDomainAnsweredCount(domain);
            final goals = controller.getDomainGoalsCount(domain);
            
            return Row(
              children: [
                Text(
                  'Questions: $answered/$total',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (goals > 0) ...[
                  const Text(' • ', style: TextStyle(color: Colors.grey)),
                  Text(
                    'Goals: $goals',
                    style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            );
          }),
          children: [
            const Divider(height: 1),
            if (questions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildQuestionCardsWithSubdomains(questions),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No questions available.',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildQuestionCardsWithSubdomains(List<dynamic> questions) {
    final widgets = <Widget>[];

    // Extract numerical value for sorting
    int extractNumber(dynamic q) {
      if (q is! Map) return 0;
      final str = q['priority']?.toString() ?? q['code']?.toString() ?? q['questionCode']?.toString() ?? '';
      final match = RegExp(r'\d+').firstMatch(str);
      return match != null ? int.tryParse(match.group(0)!) ?? 0 : 0;
    }

    // Question text used as a secondary A–Z sort key.
    String questionText(dynamic q) =>
        (q is Map ? q['question']?.toString() : null) ?? '';

    // Sort by priority ascending; when priorities are equal, order A–Z by text.
    final sortedQuestions = questions.toList();
    sortedQuestions.sort((a, b) {
      final priorityCompare = extractNumber(a).compareTo(extractNumber(b));
      if (priorityCompare != 0) return priorityCompare;
      return questionText(a).toLowerCase().compareTo(questionText(b).toLowerCase());
    });

    // Group questions by subdomain
    final Map<String, List<dynamic>> groupedQuestions = {};
    for (var q in sortedQuestions) {
      final qMap = q as Map<String, dynamic>;
      final subdomain = qMap['subdomain']?.toString().trim() ?? '';
      final key = subdomain.isEmpty ? 'Other' : subdomain;
      if (!groupedQuestions.containsKey(key)) {
        groupedQuestions[key] = [];
      }
      groupedQuestions[key]!.add(qMap);
    }

    // Get sorted keys in reverse alphabetical order
    final sortedSubdomains = groupedQuestions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Build widgets grouped by subdomain
    for (var subdomain in sortedSubdomains) {
      final subQuestions = groupedQuestions[subdomain]!;
      
      if (subdomain != 'Other') {
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
                    subdomain,
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

      for (var q in subQuestions) {
        widgets.add(_buildQuestionItem(q as Map<String, dynamic>));
      }
    }

    return widgets;
  }

  Widget _buildQuestionItem(Map<String, dynamic> question) {
    final List options = question['options'] ?? [];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Q${question['priority'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['question'] ?? 'No question text',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    Obx(() {
                      final questionId = question['_id']?.toString() ?? question['id']?.toString() ?? "";
                      final isGoal = controller.isGoalForQuestion(questionId);
                      final score = controller.getScoreForQuestion(questionId);
                      
                      if (!isGoal && (score == null || score.isEmpty)) {
                        return const SizedBox.shrink();
                      }
                      
                      return Wrap(
                        spacing: 8,
                        children: [
                          if (isGoal)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star, color: Colors.orange, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'GOAL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (score != null && score.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline, color: AppTheme.primaryColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Score: $score',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final questionId = question['_id']?.toString() ?? question['id']?.toString() ?? "";
            final savedAnswer = controller.getAnswerForQuestion(questionId);
            
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: options.map((option) {
                final optionStr = option.toString();
                final isSelected = savedAnswer == optionStr;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.grey[200]!
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Text(
                    optionStr,
                    style: TextStyle(
                      fontSize: 13, 
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
