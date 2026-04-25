import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class EducatorMoodBoardSubmissionView extends StatefulWidget {
  const EducatorMoodBoardSubmissionView({super.key});

  @override
  State<EducatorMoodBoardSubmissionView> createState() => _EducatorMoodBoardSubmissionViewState();
}

class _EducatorMoodBoardSubmissionViewState extends State<EducatorMoodBoardSubmissionView> {
  final EducatorController controller = Get.find<EducatorController>();
  late Map<String, String> student;
  
  String? selectedBehavior;
  String? selectedMood;
  String? selectedOnTask;
  String? selectedLearningBehavior;
  final TextEditingController sessionController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Get.arguments == null) {
      Get.back();
      return;
    }
    student = Get.arguments as Map<String, String>;
  }

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null) return const Scaffold();
    final bool isMale = student['gender'] == 'male';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(isMale),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ResponsiveLayout(
                mobile: _buildFormLayout(isMobile: true),
                desktop: _buildFormLayout(isMobile: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLayout({required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isMobile)
          _buildMobileForm()
        else
          _buildDesktopForm(),
        
        const SizedBox(height: 32),
        Center(
          child: SizedBox(
            width: isMobile ? double.infinity : 300,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.snackbar('Success', 'Mood board updated for ${student['name']}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    colorText: Colors.green);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: const Text('Submit Mood Board', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMobileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Session'),
        _buildTextField(sessionController, 'Enter session...'),
        
        const SizedBox(height: 20),
        _buildLabel('Behavior'),
        _buildChoiceChips(
          ['Attentive', 'Initiate Given Task', 'Concentrate'],
          selectedBehavior,
          (val) => setState(() => selectedBehavior = val),
        ),
        
        const SizedBox(height: 20),
        _buildLabel('General Mood'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildMoodIcon(Icons.sentiment_very_satisfied, 'Happy', Colors.green),
            _buildMoodIcon(Icons.sentiment_dissatisfied, 'Sad', Colors.orange),
            _buildMoodIcon(Icons.sentiment_very_dissatisfied, 'Irritable', Colors.red),
          ],
        ),
        
        const SizedBox(height: 20),
        _buildLabel('On-Task Behavior'),
        _buildChoiceChips(
          ['Adequate', 'Inadequate'],
          selectedOnTask,
          (val) => setState(() => selectedOnTask = val),
        ),
        
        const SizedBox(height: 20),
        _buildLabel('Behavior in Learning'),
        _buildChoiceChips(
          ['Interfered In Learning', 'Shows Curiosity To Learn'],
          selectedLearningBehavior,
          (val) => setState(() => selectedLearningBehavior = val),
        ),
        
        const SizedBox(height: 20),
        _buildLabel('Remarks'),
        _buildTextField(remarksController, 'Enter remarks...', maxLines: 3),
      ],
    );
  }

  Widget _buildDesktopForm() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Session'),
                  _buildTextField(sessionController, 'Enter session...'),
                  const SizedBox(height: 24),
                  _buildLabel('Behavior'),
                  _buildChoiceChips(
                    ['Attentive', 'Initiate Given Task', 'Concentrate'],
                    selectedBehavior,
                    (val) => setState(() => selectedBehavior = val),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('General Mood'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMoodIcon(Icons.sentiment_very_satisfied, 'Happy', Colors.green),
                      _buildMoodIcon(Icons.sentiment_dissatisfied, 'Sad', Colors.orange),
                      _buildMoodIcon(Icons.sentiment_very_dissatisfied, 'Irritable', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('On-Task Behavior'),
                  _buildChoiceChips(
                    ['Adequate', 'Inadequate'],
                    selectedOnTask,
                    (val) => setState(() => selectedOnTask = val),
                  ),
                  const SizedBox(height: 24),
                  _buildLabel('Behavior in Learning'),
                  _buildChoiceChips(
                    ['Interfered In Learning', 'Shows Curiosity To Learn'],
                    selectedLearningBehavior,
                    (val) => setState(() => selectedLearningBehavior = val),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Remarks'),
                  _buildTextField(remarksController, 'Enter remarks...', maxLines: 5),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(bool isMale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              const Expanded(
                child: Text(
                  'Record Mood',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    isMale ? Icons.face : Icons.face_retouching_natural,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name']!,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Enrollment: ${student['enrollment']}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
      ),
    );
  }

  Widget _buildChoiceChips(List<String> options, String? selectedValue, Function(String) onSelected) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final bool isSelected = selectedValue == option;
        return InkWell(
          onTap: () => onSelected(option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMoodIcon(IconData icon, String label, Color color) {
    final bool isSelected = selectedMood == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedMood = label),
        child: Column(
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 40,
                color: isSelected ? color : Colors.grey[300],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
