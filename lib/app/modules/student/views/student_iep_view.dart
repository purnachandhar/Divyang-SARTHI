import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/iep_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../data/models/iep_model.dart';

class StudentIepView extends GetView<IepController> {
  const StudentIepView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<IepController>()) {
      Get.put(IepController());
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('IEP Assessment',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
            decoration:
                const BoxDecoration(gradient: AppGradients.primaryGradient)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.fetchIepAssessment,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Failed to load IEP',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(controller.error.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: controller.fetchIepAssessment,
                      child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        final assessment = controller.assessment.value;
        if (assessment == null || assessment.domains.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in_outlined,
                    size: 70, color: Colors.grey),
                SizedBox(height: 16),
                Text('No assessment data found',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: assessment.domains.length,
          itemBuilder: (context, index) {
            final domain = assessment.domains[index];
            return _DomainExpansionTile(domain: domain, index: index);
          },
        );
      }),
    );
  }
}

class _DomainExpansionTile extends StatelessWidget {
  final IepDomain domain;
  final int index;

  const _DomainExpansionTile({required this.domain, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IepController>();
    final themeColor = controller.getCategoryColor(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.category, color: themeColor, size: 24),
          ),
          title: Text(
            domain.domainName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryColor),
          ),
          subtitle: Text(
            '${domain.questions.length} Questions • ${domain.subdomain}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: domain.questions
                    .map((q) =>
                        _QuestionItem(question: q, themeColor: themeColor))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionItem extends StatelessWidget {
  final IepQuestion question;
  final Color themeColor;

  const _QuestionItem({required this.question, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IepController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.question,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  question.agegroup,
                  style: TextStyle(
                      color: themeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (question.subdomain.isNotEmpty)
            Text(
              question.subdomain,
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 12),
          Obx(() {
            final selectedValue = controller.selectedAnswers[question.id];
            return Column(
              children: question.options.map((option) {
                final isSelected = selectedValue == option;
                return InkWell(
                  onTap: () => controller.selectedAnswers[question.id] = option,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeColor.withOpacity(0.05)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? themeColor : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Transform.scale(
                          scale: 0.9,
                          child: Radio<String>(
                            value: option,
                            groupValue: selectedValue,
                            activeColor: themeColor,
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedAnswers[question.id] = value;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? themeColor : Colors.black87,
                            ),
                          ),
                        ),
                      ],
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
}
