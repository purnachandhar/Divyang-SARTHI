import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'video_player_view.dart';

class LearningResourcesView extends StatefulWidget {
  const LearningResourcesView({super.key});

  @override
  State<LearningResourcesView> createState() => _LearningResourcesViewState();
}

class _LearningResourcesViewState extends State<LearningResourcesView> {
  final EducatorController controller = Get.find<EducatorController>();
  String _selectedLanguageFilter = 'English';

  @override
  Widget build(BuildContext context) {
    // If a student is already selected but data is empty, trigger fetch on load
    if (controller.selectedLearningResourcesStudentId.value.isNotEmpty &&
        controller.learningResourcesData.isEmpty &&
        !controller.isLoadingLearningResources.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchStudentLearningResources();
      });
    }

    if (controller.languageVideosData.isEmpty && !controller.isLoadingLanguageVideos.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchLanguageVideos();
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildDropdownCard(),
          Expanded(
            child: Obx(() {
              if (controller.selectedLearningResourcesStudentId.value.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Please select an Academic Year and a Student to view learning resources.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.isLoadingLearningResources.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.learningResourcesData.isEmpty) {
                return const Center(
                  child: Text(
                    'No learning resources found for this student.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              // Parse data from controller
              final data = controller.learningResourcesData;
              final school = data['school'] ?? {};
              final home = data['home'] ?? {};

              // 1. Concepts
              final List<Map<String, dynamic>> concepts = [];
              final schoolConcepts = school['conceptsList'] as List? ?? [];
              for (var c in schoolConcepts) {
                if (c is Map) {
                  concepts.add({
                    'goalName': c['goalName']?.toString() ?? '',
                    'type': 'School',
                  });
                }
              }
              final homeConcepts = home['conceptsList'] as List? ?? [];
              for (var c in homeConcepts) {
                if (c is Map) {
                  concepts.add({
                    'goalName': c['goalName']?.toString() ?? '',
                    'type': 'Home',
                  });
                }
              }

              // 2. Prerequisites
              final List<String> prerequisites = [];
              final schoolPrereqs = school['preRequisiteList'] as List? ?? [];
              for (var p in schoolPrereqs) {
                if (p is Map) {
                  final prList = p['preRequisite'] as List? ?? [];
                  for (var item in prList) {
                    if (item is Map) {
                      final name = item['name']?.toString() ?? '';
                      if (name.isNotEmpty && !prerequisites.contains(name)) {
                        prerequisites.add(name);
                      }
                    }
                  }
                }
              }
              final homePrereqs = home['preRequisiteList'] as List? ?? [];
              for (var p in homePrereqs) {
                if (p is Map) {
                  final prList = p['preRequisite'] as List? ?? [];
                  for (var item in prList) {
                    if (item is Map) {
                      final name = item['name']?.toString() ?? '';
                      if (name.isNotEmpty && !prerequisites.contains(name)) {
                        prerequisites.add(name);
                      }
                    }
                  }
                }
              }

              // 3. Task Analysis
              final List<String> taskAnalysisSteps = [];
              final schoolTasks = school['taskAnalysisList'] as List? ?? [];
              for (var t in schoolTasks) {
                if (t is Map) {
                  final taList = t['taskAnalysis'] as List? ?? [];
                  for (var item in taList) {
                    if (item is Map) {
                      final name = item['name']?.toString() ?? '';
                      if (name.isNotEmpty && !taskAnalysisSteps.contains(name)) {
                        taskAnalysisSteps.add(name);
                      }
                    }
                  }
                }
              }
              final homeTasks = home['taskAnalysisList'] as List? ?? [];
              for (var t in homeTasks) {
                if (t is Map) {
                  final taList = t['taskAnalysis'] as List? ?? [];
                  for (var item in taList) {
                    if (item is Map) {
                      final name = item['name']?.toString() ?? '';
                      if (name.isNotEmpty && !taskAnalysisSteps.contains(name)) {
                        taskAnalysisSteps.add(name);
                      }
                    }
                  }
                }
              }

              // 4. Resources (Videos)
              final List<Map<String, dynamic>> videoResources = [];
              final schoolResources = school['resources'] as List? ?? [];
              for (var r in schoolResources) {
                if (r is Map) {
                  final video = r['video'] as Map?;
                  videoResources.add({
                    'title': r['resourceName']?.toString() ?? 'Drinking Water',
                    'language': r['language']?.toString() ?? 'English',
                    'videoURL': video?['videoURL']?.toString() ?? '',
                    'duration': video?['minRequireDuration']?.toString() ?? '',
                  });
                }
              }
              final homeResources = home['resources'] as List? ?? [];
              for (var r in homeResources) {
                if (r is Map) {
                  final video = r['video'] as Map?;
                  videoResources.add({
                    'title': r['resourceName']?.toString() ?? 'Drinking Water',
                    'language': r['language']?.toString() ?? 'English',
                    'videoURL': video?['videoURL']?.toString() ?? '',
                    'duration': video?['minRequireDuration']?.toString() ?? '',
                  });
                }
              }

              if (concepts.isEmpty &&
                  prerequisites.isEmpty &&
                  taskAnalysisSteps.isEmpty &&
                  videoResources.isEmpty) {
                return const Center(
                  child: Text(
                    'No resources found in this category.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Concepts Section
                    if (concepts.isNotEmpty) ...[
                      _buildSectionHeader(
                        icon: Icons.menu_book,
                        iconColor: Colors.purple,
                        title: 'Concepts',
                      ),
                      const SizedBox(height: 12),
                      ...concepts.map((c) => _buildConceptCard(c)),
                      const SizedBox(height: 24),
                    ],

                    // 2. Task Analysis & Prerequisites Section
                    if (prerequisites.isNotEmpty || taskAnalysisSteps.isNotEmpty) ...[
                      _buildSectionHeader(
                        icon: Icons.assignment_turned_in_outlined,
                        iconColor: Colors.teal,
                        title: 'Task Analysis & Prerequisites',
                      ),
                      const SizedBox(height: 12),
                      _buildTaskAnalysisAndPrereqCard(prerequisites, taskAnalysisSteps),
                      const SizedBox(height: 24),
                    ],

                    // 3. Concept Resource (Videos) Section
                    if (videoResources.isNotEmpty) ...[
                      _buildSectionHeader(
                        icon: Icons.play_circle_outline,
                        iconColor: Colors.red,
                        title: 'Concept Resource',
                      ),
                      const SizedBox(height: 12),
                      _buildConceptResourceGrid(videoResources),
                      const SizedBox(height: 24),
                    ],

                    // 4. General Resources (Language Videos) Section
                    _buildLanguageVideosSection(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Learning Resources',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Access specialized professional training materials, worksheets, and guides.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildAcademicYearDropdown()),
          const SizedBox(width: 12),
          Expanded(child: _buildStudentDropdown()),
        ],
      ),
    );
  }

  Widget _buildAcademicYearDropdown() {
    return Obx(() {
      final years = controller.iepAcademicYears;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Year',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                hint: const Text('Select Year', style: TextStyle(fontSize: 13)),
                value: controller.selectedLearningResourcesYearId.value.isNotEmpty
                    ? controller.selectedLearningResourcesYearId.value
                    : (controller.selectedIepYearId.value.isNotEmpty
                        ? controller.selectedIepYearId.value
                        : null),
                icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primaryColor, size: 18),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.selectedLearningResourcesYearId.value = newValue;
                    controller.selectedLearningResourcesStudentId.value = '';
                    controller.learningResourcesData.clear();
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
      final isYearSelected =
          controller.selectedLearningResourcesYearId.value.isNotEmpty ||
              controller.selectedIepYearId.value.isNotEmpty;
      final students = controller.niepidStudentAssessments;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Student',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: isYearSelected ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                hint: const Text('Select Student', style: TextStyle(fontSize: 13)),
                value: controller.selectedLearningResourcesStudentId.value.isNotEmpty
                    ? controller.selectedLearningResourcesStudentId.value
                    : null,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: isYearSelected ? AppTheme.primaryColor : Colors.grey,
                  size: 18,
                ),
                onChanged: isYearSelected
                    ? (String? newValue) {
                        if (newValue != null) {
                          controller.selectedLearningResourcesStudentId.value = newValue;
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

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildConceptCard(Map<String, dynamic> concept) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            concept['goalName'] ?? '',
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            concept['type'] ?? 'School',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskAnalysisAndPrereqCard(
    List<String> prereqs,
    List<String> steps,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (prereqs.isNotEmpty) ...[
            const Text(
              'Prerequisites',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...prereqs.map((prereq) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          prereq,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            if (steps.isNotEmpty) const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1),
            ),
          ],
          if (steps.isNotEmpty) ...[
            const Text(
              'Task Analysis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isHeader = step.startsWith('Part ');

                if (isHeader) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConceptResourceGrid(List<Map<String, dynamic>> videos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final title = video['title'] ?? 'Drinking Water';
    final lang = video['language'] ?? 'English';
    final videoURL = video['videoURL'] ?? '';

    return GestureDetector(
      onTap: () {
        if (videoURL.isNotEmpty) {
          _openVideoDialog('$title ($lang)', videoURL);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade300,
                      AppTheme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(11),
                    topRight: Radius.circular(11),
                  ),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white30,
                      radius: 18,
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVideoDialog(String title, String videoURL) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_circle_fill, color: Colors.red, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Video Resource Link:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  videoURL,
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: videoURL));
                      Get.snackbar(
                        'Success',
                        'Video URL copied to clipboard!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                    label: const Text('Copy URL', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageVideosSection() {
    return Obx(() {
      if (controller.isLoadingLanguageVideos.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      final data = controller.languageVideosData;
      if (data.isEmpty) {
        return const SizedBox.shrink();
      }

      final key = _selectedLanguageFilter.toLowerCase();
      final videosList = data[key] as List? ?? [];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.video_library_outlined,
            iconColor: Colors.blueAccent,
            title: 'General Resources',
          ),
          const SizedBox(height: 12),
          // Language selector ChoiceChips
          Row(
            children: [
              _buildLanguageChip('English'),
              const SizedBox(width: 10),
              _buildLanguageChip('Hindi'),
            ],
          ),
          const SizedBox(height: 16),
          if (videosList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No videos available in this language.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: videosList.length,
              itemBuilder: (context, index) {
                final video = videosList[index] as Map<String, dynamic>;
                return _buildLanguageVideoCard(video);
              },
            ),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildLanguageChip(String language) {
    final isSelected = _selectedLanguageFilter == language;
    return ChoiceChip(
      label: Text(
        language,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryColor,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedLanguageFilter = language;
          });
        }
      },
    );
  }

  Widget _buildLanguageVideoCard(Map<String, dynamic> video) {
    final title = video['title']?.toString() ?? 'Untitled Resource';
    final gifUrl = video['gif']?.toString() ?? '';
    final videoUrl = video['video']?.toString() ?? '';
    final category = video['category']?.toString() ?? 'Self Help';
    final isNew = video['isNewVideo']?.toString() == 'true';
    final lang = video['language']?.toString() ?? 'English';

    return GestureDetector(
      onTap: () {
        if (videoUrl.isNotEmpty) {
          Get.to(() => VideoPlayerView(
                title: title,
                videoUrl: videoUrl,
                category: category,
                language: lang,
              ));
        } else {
          Get.snackbar(
            'Error',
            'No playback URL found for this video.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Thumbnail
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (gifUrl.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: gifUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                        ),
                      )
                    else
                      Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.video_library_outlined, color: Colors.grey, size: 36),
                      ),
                    // Dark overlay
                    Container(
                      color: Colors.black.withOpacity(0.15),
                    ),
                    // Play Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                    // "NEW" Badge
                    if (isNew)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Video Details (Bottom)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 8,
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
