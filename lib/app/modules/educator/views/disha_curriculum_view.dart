import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class DishaCurriculumView extends StatefulWidget {
  final bool showBackButton;
  const DishaCurriculumView({super.key, this.showBackButton = false});

  @override
  State<DishaCurriculumView> createState() => _DishaCurriculumViewState();
}

class _DishaCurriculumViewState extends State<DishaCurriculumView> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Nursery',
    'Level 1',
    'Level 2',
    'Level 3',
    'Prevocational',
    'Adaptive',
    'Assessment'
  ];

  final List<Map<String, String>> _nurseryPdfs = [
    {
      "name": "Nursery Academic Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+Academic+Workbook+English.pdf"
    },
    {
      "name": "Nursery Art & Craft Workbook 1 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+Art+%26+Craft+Workbook+1+English.pdf"
    },
    {
      "name": "Nursery Art & Craft Workbook 2 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+Art+%26+Craft+Workbook+2+English.pdf"
    },
    {
      "name": "Nursery Colouring Book English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+Colouring+Book+English.pdf"
    },
    {
      "name": "Nursery Pre Writing Book English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+Pre+Writing+Book+English.pdf"
    },
    {
      "name": "Nursery English Manual",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+English+Manual.pdf"
    },
    {
      "name": "Nursery EVS Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+EVS+Manual+English.pdf"
    },
    {
      "name": "Nursery Functional Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+Functional+Manual+English.pdf"
    },
    {
      "name": "Nursery Maths Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Nursery/English/Nursery+Maths+Manual+English.pdf"
    }
  ];

  final List<Map<String, String>> _level1Pdfs = [
    {
      "name": "Level 1 Art & Craft Workbook 1 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+Art+%26+Craft+Workbook+1+English.pdf"
    },
    {
      "name": "Level 1 Art & Craft Workbook 2 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+Art+%26+Craft+Workbook+2+English.pdf"
    },
    {
      "name": "Level 1 Art Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+Art+Manual+English.pdf"
    },
    {
      "name": "Level 1 English Manual",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+English+Manual+(1).pdf"
    },
    {
      "name": "Level 1 English Workbook 1 2023",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+English+Workbook+1+2023.pdf"
    },
    {
      "name": "Level 1 English Workbook 2",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+English+Workbook+2.pdf"
    },
    {
      "name": "Level 1 EVS Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+EVS+Manual+English.pdf"
    },
    {
      "name": "Level 1 EVS Workbook 1 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+EVS+Workbook+1+English.pdf"
    },
    {
      "name": "Level 1 EVS Workbook 2 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+EVS+Workbook+2+English.pdf"
    },
    {
      "name": "Level 1 Maths Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+Maths+Manual+English.pdf"
    },
    {
      "name": "Level 1 Maths Workbook 1 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+Maths+Workbook+1+English.pdf"
    },
    {
      "name": "Level 1 Maths Workbook 2 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level1_6-14_years/English/Level+1+Maths+Workbook+2+English.pdf"
    }
  ];

  final List<Map<String, String>> _level2Pdfs = [
    {
      "name": "Level 2 Art Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+Art+Manual+English.pdf"
    },
    {
      "name": "Level 2 Art Workbook 2 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+Art+Workbook+2+English.pdf"
    },
    {
      "name": "Level 2 Art Workbook 1 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+Art+Workbook1+English.pdf"
    },
    {
      "name": "Level 2 Digital Curriculum Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+Digital+Curriculum+Workbook+English.pdf"
    },
    {
      "name": "Level 2 English Manual",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+English+Manual.pdf"
    },
    {
      "name": "Level 2 English Workbook",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+English+Workbook.pdf"
    },
    {
      "name": "Level 2 EVS Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+EVS+Manual+English.pdf"
    },
    {
      "name": "Level 2 EVS Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+EVS+Workbook+English.pdf"
    },
    {
      "name": "Level 2 Maths Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+Maths+Manual+English.pdf"
    },
    {
      "name": "Level 2 Maths Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level2_6-14+_years_(on_completion_of_Level1)/English/Level+2+Maths+Workbook+English.pdf"
    }
  ];

  final List<Map<String, String>> _level3Pdfs = [
    {
      "name": "Level 3 Digital Curriculum Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level3_6-14_years_(on_completion_of_level_2)/English/Level+3+Digital+Curriculum+Manual+English.pdf"
    },
    {
      "name": "Level 3 Digital Curriculum Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level3_6-14_years_(on_completion_of_level_2)/English/Level+3+Digital+Curriculum+Workbook+English.pdf"
    },
    {
      "name": "Level 3 English Manual",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level3_6-14_years_(on_completion_of_level_2)/English/Level+3+English+Manual.pdf"
    },
    {
      "name": "Level 3 English Workbook",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level3_6-14_years_(on_completion_of_level_2)/English/Level+3+English+Workbook.pdf"
    },
    {
      "name": "Level 3 EVS Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level3_6-14_years_(on_completion_of_level_2)/English/Level+3+EVS+Manual+English.pdf"
    },
    {
      "name": "Level 3 EVS Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level3_6-14_years_(on_completion_of_level_2)/English/Level+3+EVS+Workbook+English.pdf"
    },
    {
      "name": "Level 3 Maths Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level3_6-14_years_(on_completion_of_level_2)/English/Level+3+Maths+Manual+English.pdf"
    },
    {
      "name": "Level 3 Maths Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Level3_6-14_years_(on_completion_of_level_2)/English/Level+3+Maths+Workbook+English.pdf"
    }
  ];

  final List<Map<String, String>> _prevocationalPdfs = [
    {
      "name": "Prevocational Art & Craft Workbook 1 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Art+%26+Craft+Workbook+1+English.pdf"
    },
    {
      "name": "Prevocational Art & Craft Workbook 2 English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Art+%26+Craft+Workbook+2+English.pdf"
    },
    {
      "name": "Prevocational Art Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Art+Manual+English.pdf"
    },
    {
      "name": "Prevocational Communication Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Communication+Manual+English.pdf"
    },
    {
      "name": "Prevocational Communication Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Communication+Workbook+English.pdf"
    },
    {
      "name": "Prevocational EVS Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+EVS+Manual+English.pdf"
    },
    {
      "name": "Prevocational EVS Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+EVS+Workbook+English.pdf"
    },
    {
      "name": "Prevocational Kitchen Basics Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Kitchen+Basics+Manual+English.pdf"
    },
    {
      "name": "Prevocational Life Skills Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Life+Skills+Manual+English.pdf"
    },
    {
      "name": "Prevocational Maths 1 Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Maths+1+Manual+English.pdf"
    },
    {
      "name": "Prevocational Maths 1 Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Maths+1+Workbook+English.pdf"
    },
    {
      "name": "Prevocational Maths 2 Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Maths+2+Manual+English.pdf"
    },
    {
      "name": "Prevocational Maths 2 Workbook English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Prevocational_14-18_years/English/Pre+voc+Maths+2+Workbook+English.pdf"
    }
  ];

  final List<Map<String, String>> _adaptivePdfs = [
    {
      "name": "Adaptive Communication Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Adaptive_Curriculum/English/Adaptive+Communication+Manual+English.pdf"
    },
    {
      "name": "Adaptive Life Skills Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Adaptive_Curriculum/English/Adaptive+Life+Skills+Manual+English.pdf"
    },
    {
      "name": "Adaptive Social Adaptive Behaviour Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Adaptive_Curriculum/English/Adaptive+Social+Adaptive+Behaviour+Manual+English.pdf"
    },
    {
      "name": "Adaptive ADL and Motor Skills Manual English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Adaptive_Curriculum/English/Adaptive+ADL+and+Motor+Skills+Manual+English.pdf"
    }
  ];

  final List<Map<String, String>> _assessmentPdfs = [
    {
      "name": "Assessment Checklist IEP 3-14 Years English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Assessment_checklist_for_IEP/English/Assesement+Checklist+of+IEP+3-14+Years+English+(2).pdf"
    },
    {
      "name": "Assessment Checklist IEP 14-18 Years English",
      "url": "https://d3k7awunuymwvz.cloudfront.net/portal-content/NIEPID_Disha_Curriculum/Assessment_checklist_for_IEP/English/Assesement+Checklist+of+IEP+14-18+Years+English+(2).pdf"
    }
  ];

  List<Map<String, String>> get _filteredPdfs {
    switch (_selectedCategory) {
      case 'Nursery':
        return _nurseryPdfs;
      case 'Level 1':
        return _level1Pdfs;
      case 'Level 2':
        return _level2Pdfs;
      case 'Level 3':
        return _level3Pdfs;
      case 'Prevocational':
        return _prevocationalPdfs;
      case 'Adaptive':
        return _adaptivePdfs;
      case 'Assessment':
        return _assessmentPdfs;
      default:
        return [
          ..._nurseryPdfs,
          ..._level1Pdfs,
          ..._level2Pdfs,
          ..._level3Pdfs,
          ..._prevocationalPdfs,
          ..._adaptivePdfs,
          ..._assessmentPdfs,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdfList = _filteredPdfs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildCategorySelector(),
          Expanded(
            child: pdfList.isEmpty
                ? const Center(child: Text("No PDF files found"))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: pdfList.length,
                    itemBuilder: (context, index) {
                      final item = pdfList[index];
                      return _buildPdfCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.showBackButton) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
              ],
              const Text(
                'Disha Curriculum',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Access educational curriculum materials and workbooks.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: ChoiceChip(
              label: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryColor,
              backgroundColor: Colors.white,
              elevation: isSelected ? 4 : 0,
              pressElevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPdfCard(Map<String, String> item) {
    final name = item['name'] ?? 'Untitled';
    final url = item['url'] ?? '';

    // Determine category based on name
    Color startColor = Colors.blue;
    Color endColor = Colors.purple;
    IconData icon = Icons.menu_book;

    if (name.contains("Nursery")) {
      startColor = const Color(0xFFFF5E62);
      endColor = const Color(0xFFFF9966);
      icon = Icons.child_care;
    } else if (name.contains("Level 1")) {
      startColor = const Color(0xFF1A2980);
      endColor = const Color(0xFF26D0CE);
      icon = Icons.looks_one;
    } else if (name.contains("Level 2")) {
      startColor = const Color(0xFFF3904F);
      endColor = const Color(0xFF3B4371);
      icon = Icons.looks_two;
    } else if (name.contains("Level 3")) {
      startColor = const Color(0xFF11998e);
      endColor = const Color(0xFF38ef7d);
      icon = Icons.looks_3;
    } else if (name.contains("Prevocational")) {
      startColor = const Color(0xFF4568DC);
      endColor = const Color(0xFFB06AB3);
      icon = Icons.work_outline;
    } else if (name.contains("Adaptive")) {
      startColor = const Color(0xFF795548);
      endColor = const Color(0xFFFF9800);
      icon = Icons.accessibility_new;
    } else if (name.contains("Assessment")) {
      startColor = const Color(0xFF673AB7);
      endColor = const Color(0xFF9C27B0);
      icon = Icons.assignment_outlined;
    }

    return GestureDetector(
      onTap: () {
        if (url.isNotEmpty) {
          Get.to(() => PdfViewScreen(title: name, url: url));
        } else {
          Get.snackbar('Error', 'Invalid PDF link.');
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
            // Book Cover Graphic (Top)
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      top: -20,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Icon(
                        icon,
                        color: Colors.white.withOpacity(0.15),
                        size: 60,
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.menu_book, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "NIEPID",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Book Info (Bottom)
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "English PDF",
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: startColor,
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

class PdfViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const PdfViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<PdfViewScreen> createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.primaryGradient,
          ),
        ),
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.url,
            onDocumentLoaded: (details) {
              setState(() {
                _isLoading = false;
              });
            },
            onDocumentLoadFailed: (details) {
              setState(() {
                _isLoading = false;
              });
              Get.snackbar(
                'Error',
                'Failed to load PDF: ${details.description}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
