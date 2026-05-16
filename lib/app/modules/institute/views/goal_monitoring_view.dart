import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../controllers/institute_controller.dart';

class GoalMonitoringView extends GetView<InstituteController> {
  const GoalMonitoringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Goal Monitoring', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primaryGradient),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
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
              if (controller.isGoalMonitoringLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 50.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (controller.selectedGoalMonitoringStudent.value == null) {
                return _buildEmptyState('Please select a student to monitor goals.');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.activeGoalTab.value = 0;
                          controller.fetchGoalMonitoring();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Get Assessment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (controller.showGoalMonitoringDetails.value) ...[
                    _buildStudentDetailsCard(),
                    const SizedBox(height: 24),
                    _buildTermSelector(),
                    const SizedBox(height: 24),
                    _buildDomainsList(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ] else if (!controller.isGoalMonitoringLoading.value)
                    _buildEmptyState('Click "Get Assessment" to view results.'),
                ],
              );
            }),
          ],
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
      final years = controller.availableNiepidYears;
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
                value: controller.selectedGoalMonitoringYear.value,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
                onChanged: (v) => controller.selectedGoalMonitoringYear.value = v,
                items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStudentDropdown() {
    return Obx(() {
      final students = controller.availableNiepidStudents;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
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
                hint: const Text('Select Student'),
                value: controller.selectedGoalMonitoringStudent.value,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor),
                onChanged: (v) => controller.selectedGoalMonitoringStudent.value = v,
                items: students.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Icon(Icons.assessment_outlined, size: 64, color: AppTheme.primaryColor.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 20),
          _buildDetailRow('Student :', controller.getStudentName()),
          const Divider(height: 32),
          _buildDetailRow('Academic Year :', controller.selectedGoalMonitoringYear.value ?? 'N/A'),
          const Divider(height: 32),
          _buildDetailRow('Age :', controller.getStudentAge()),
          const Divider(height: 32),
          _buildDetailRow('Teacher :', controller.getGoalMonitoringStudentDetails()?['teacherName'] ?? 'N/A'),
          const Divider(height: 32),
          _buildIepStatusRow(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildIepStatusRow() {
    final termKeys = ['entry', 'term1', 'term2'];
    final currentTerm = termKeys[controller.activeGoalTab.value];
    final status = controller.getGoalStatus(currentTerm);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('IEP Status :', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        _buildStatusBadge(status),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approve': color = Colors.green; break;
      case 'submitted': color = Colors.blue; break;
      case 'rework': color = Colors.red; break;
      case 'pending': color = Colors.orange; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTermSelector() {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTermTab('Baseline', 0, 'entry'),
          _buildTermTab('1st Term', 1, 'term1'),
          _buildTermTab('2nd Term', 2, 'term2'),
        ],
      ),
    );
  }

  Widget _buildTermTab(String label, int index, String termKey) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.activeGoalTab.value == index;
        bool isEnabled = true;
        if (index == 1) { // Term 1
          isEnabled = controller.getGoalStatus('entry').contains('approve');
        } else if (index == 2) { // Term 2
          isEnabled = controller.getGoalStatus('term1').contains('approve');
        }

        return GestureDetector(
          onTap: isEnabled ? () => controller.activeGoalTab.value = index : null,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : (isEnabled ? Colors.transparent : Colors.grey.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected
                  ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                  : [],
            ),
            child: Opacity(
              opacity: isEnabled ? 1.0 : 0.4,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDomainsList() {
    return Obx(() {
      final domains = controller.goalMonitoringDomains;
      if (domains.isEmpty) {
        return _buildEmptyState('No domains found for this term.');
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
              return _buildDomainCard(domains[index]);
            },
          ),
        ],
      );
    });
  }

  Widget _buildDomainCard(Map<String, dynamic> domain) {
    final domainName = domain['domainName']?.toString() ?? 'Unknown Domain';
    final List<dynamic> questions = domain['questions'] ?? [];
    final iconUrl = domain['domainIcon']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                  child: Image.network(iconUrl, fit: BoxFit.cover, 
                    errorBuilder: (c, e, s) => const Icon(Icons.assessment, color: AppTheme.primaryColor)))
              : const Icon(Icons.assessment, color: AppTheme.primaryColor),
        ),
        title: Text(domainName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
        subtitle: Text('${questions.length} Goals', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        children: [
          if (questions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildGoalQuestionCardsWithSubdomains(questions),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No goals available.', style: TextStyle(color: AppTheme.textSecondary)),
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
    final questionText = questionData['question']?.toString() ?? 'Unknown Question';
    final answer = questionData['assessmentAnswer'];
    final goal = questionData['goalData'];

    final grade = answer?['checkboxValue']?.toString() ?? '';
    final score = answer?['options']?.toString() ?? '';
    final goalType = goal?['goalType'] is List
        ? (goal?['goalType'] as List).join(', ')
        : (goal?['goalType']?.toString() ?? '');

    final hasGrade = grade.isNotEmpty && grade != 'N/A' && grade != 'null';
    final hasScore = score.isNotEmpty && score != 'N/A' && score != 'null' && score != '0';
    final hasGoalType = goalType.isNotEmpty && goalType != 'N/A' && goalType != 'null';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(questionText,
                      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.4)),
                ),
              ],
            ),
          ),
          if (hasGrade || hasScore || hasGoalType) ...[
            Divider(height: 1, color: Colors.grey.shade100),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (hasGrade)
                    _buildResultChip(label: 'Grade', value: grade,
                        bgColor: AppTheme.primaryColor.withOpacity(0.08),
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
        ],
      ),
    );
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
          Text('$label: ', style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.8), fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final termKeys = ['entry', 'term1', 'term2'];
    final currentTerm = termKeys[controller.activeGoalTab.value];
    final status = controller.getGoalStatus(currentTerm).toLowerCase();

    if (status != 'submitted') return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showReworkDialog(), 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              elevation: 0,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Rework', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.submitApprove(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _showReworkDialog() {
    final TextEditingController remarksController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rework Remarks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Remarks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: remarksController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter your remarks here...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final remarks = remarksController.text.trim();
                        if (remarks.isEmpty) {
                          Get.snackbar('Error', 'Please enter remarks', 
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red);
                          return;
                        }
                        controller.submitRework(remarks);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
