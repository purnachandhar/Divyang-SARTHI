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
        final questionsData = controller.niepidQuestions.value;
        if (questionsData == null) {
          return const Center(child: Text("No questions found"));
        }

        final List domains = questionsData['domains'] ?? [];

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assessment Questions',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Complete the assessment below',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: domains.length,
                itemBuilder: (context, index) {
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
          subtitle: Text(
            '${questions.length} Questions',
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          children: [
            const Divider(height: 1),
            ...questions.map((q) => _buildQuestionItem(q)).toList(),
          ],
        ),
      ),
    );
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
                child: Text(
                  question['question'] ?? 'No question text',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((option) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  option.toString(),
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              );
            }).toList(),
          ),
          if (question['subdomain'] != null) ...[
            const SizedBox(height: 12),
            Text(
              'Subdomain: ${question['subdomain']}',
              style: TextStyle(fontSize: 11, color: Colors.black, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
