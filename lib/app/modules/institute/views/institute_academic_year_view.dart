import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../controllers/institute_controller.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../theme/app_gradients.dart';

class InstituteAcademicYearView extends GetView<InstituteController> {
  const InstituteAcademicYearView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isAcademicYearsLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                );
              }

              if (controller.academicYears.isEmpty) {
                return Center(
                  child: FadeInUp(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No Academic Years Found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'There are currently no IEP records available.',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: controller.fetchAcademicYears,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Refresh', style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchAcademicYears,
                color: AppTheme.primaryColor,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.academicYears.length,
                  itemBuilder: (context, index) {
                    final yearData = controller.academicYears[index];
                    final Map<String, dynamic>? yearlyIEP = yearData['yearlyIEP'];
                    final String title = 'Academic Year Record';
                    final String id = yearData['id'] ?? yearData['_id'] ?? '#${index + 1}';
                    
                    String _formatDate(String? isoString, String fallback) {
                      if (isoString == null || isoString.isEmpty) return fallback;
                      try {
                        DateTime dt = DateTime.parse(isoString);
                        return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
                      } catch (e) {
                        return isoString;
                      }
                    }

                    final String fromDate = _formatDate(yearlyIEP?['from'], '13-01-2026');
                    final String toDate = _formatDate(yearlyIEP?['to'], '13-01-2027');

                    List<dynamic> terms = yearData['termIEP'] ?? [];

                    return FadeInUp(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      child: Container(
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.date_range, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text('From : $fromDate', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const Spacer(),
                                  Text('To : $toDate', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              ...terms.asMap().entries.map((entry) {
                                int termIndex = entry.key;
                                var term = entry.value;
                                String termName = 'Term ${termIndex + 1}';
                                String tFrom = _formatDate(term['from'], '13-01-2026');
                                String tTo = _formatDate(term['to'], '30-06-2026');
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('$termName :', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text('From : $tFrom', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                          const Spacer(),
                                          Text('To : $tTo', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Get.toNamed('/institute-academic-year-detail', arguments: yearData);
                                    },
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      controller.deleteAcademicYear(id);
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
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
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Academic Years',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Manage IEP Records',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
