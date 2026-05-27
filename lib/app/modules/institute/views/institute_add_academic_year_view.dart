import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../controllers/institute_controller.dart';

class TermData {
  String? startDate;
  String? endDate;
}

class InstituteAddAcademicYearView extends StatefulWidget {
  const InstituteAddAcademicYearView({super.key});

  @override
  State<InstituteAddAcademicYearView> createState() => _InstituteAddAcademicYearViewState();
}

class _InstituteAddAcademicYearViewState extends State<InstituteAddAcademicYearView> {
  final controller = Get.find<InstituteController>();
  String? acStartDate;
  String? acEndDate;
  List<TermData> terms = [TermData()];

  Future<void> _selectDate(BuildContext context, void Function(String) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final dateStr = '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      onDateSelected(dateStr);
    }
  }

  void _addTerm() {
    setState(() {
      terms.add(TermData());
    });
  }

  void _removeTerm(int index) {
    setState(() {
      terms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                          'Academic Year Duration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(
                          label: 'Academic year start date*',
                          value: acStartDate,
                          onTap: () => _selectDate(context, (date) {
                            setState(() {
                              acStartDate = date;
                              // Auto-compute end date: same day, next year
                              final parts = date.split('-');
                              final day = parts[0];
                              final month = parts[1];
                              final year = int.parse(parts[2]) + 1;
                              acEndDate = '$day-$month-$year';
                            });
                          }),
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(
                          label: 'Academic year end date*',
                          value: acEndDate,
                          onTap: () {},
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Terms',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addTerm,
                        icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor),
                        label: const Text('Add Term', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...terms.asMap().entries.map((entry) {
                    int index = entry.key;
                    TermData term = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Term ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (terms.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _removeTerm(index),
                                  tooltip: 'Remove Term',
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDateField(
                            label: 'Term start date*',
                            value: term.startDate,
                            onTap: () => _selectDate(context, (date) => setState(() => term.startDate = date)),
                          ),
                          const SizedBox(height: 16),
                          _buildDateField(
                            label: 'Term end date*',
                            value: term.endDate,
                            onTap: () => _selectDate(context, (date) => setState(() => term.endDate = date)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 30),
                  Obx(() {
                    final isLoading = controller.isAddingAcademicYear.value;
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () {
                          if (acStartDate == null || acEndDate == null) {
                            Get.snackbar(
                              'Validation Error',
                              'Please select Academic Year start and end dates.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }
                          for (int i = 0; i < terms.length; i++) {
                            if (terms[i].startDate == null || terms[i].endDate == null) {
                              Get.snackbar(
                                'Validation Error',
                                'Please complete the dates for Term ${i + 1}.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              return;
                            }
                          }

                          final termPayload = terms.map((t) => {
                            'from': t.startDate!,
                            'to': t.endDate!,
                          }).toList();

                          controller.addAcademicYear(
                            yearlyFrom: acStartDate!,
                            yearlyTo: acEndDate!,
                            terms: termPayload,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Academic Year',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Academic Year',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Create new academic sessions and terms',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({required String label, required String? value, required VoidCallback onTap, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: enabled ? Colors.grey.shade300 : Colors.grey.shade200),
              borderRadius: BorderRadius.circular(10),
              color: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? 'dd-mm-yyyy',
                  style: TextStyle(
                    color: value == null ? Colors.grey.shade400 : (enabled ? Colors.black87 : Colors.grey.shade600),
                    fontSize: 15,
                  ),
                ),
                Icon(Icons.calendar_month, size: 20, color: enabled ? AppTheme.primaryColor.withOpacity(0.7) : Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
