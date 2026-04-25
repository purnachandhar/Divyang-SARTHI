import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../controllers/institute_controller.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../theme/app_gradients.dart';

class InstituteAcademicYearDetailView extends GetView<InstituteController> {
  const InstituteAcademicYearDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = Get.arguments ?? {};
    
    final Map<String, dynamic>? yearlyIEP = data['yearlyIEP'];
    const String title = 'Academic Year Record';
    const String status = 'Active';
    final String id = data['id'] ?? data['_id'] ?? 'N/A';
    
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

    final RxList<dynamic> terms = RxList<dynamic>.from(data['termIEP'] ?? []);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: FadeInUp(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('General Information'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Column(
                        children: [
                          _buildTextField('Title', title),
                          const Divider(height: 24),
                          Row(
                            children: [
                              Expanded(child: _buildTextField('Status', status)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildTextField('ID', id, enabled: false)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Duration'),
                    const SizedBox(height: 12),
                    _buildCard(
                      child: Row(
                        children: [
                          Expanded(child: _buildDatePicker('From', fromDate)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDatePicker('To', toDate)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Terms'),
                        TextButton.icon(
                          onPressed: () {
                            _showAddTermDialog(terms);
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Term'),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Column(
                      children: terms.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var term = entry.value;
                        String tName = 'Term ${idx + 1}';
                        String tFrom = _formatDate(term['from'], '13-01-2026');
                        String tTo = _formatDate(term['to'], '30-06-2026');
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor)),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        terms.removeAt(idx);
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: _buildDatePicker('From', tFrom)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildDatePicker('To', tTo)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                  ],
                ),
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
                  'Edit Academic Year',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Update IEP configurations',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.white, size: 30),
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'Changes saved successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white);
            },
          )
        ],
      ),
    );
  }

  void _showAddTermDialog(RxList<dynamic> terms) {
    Get.defaultDialog(
      title: 'Add New Term',
      content: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('A new term will be added to the academic year.'),
            SizedBox(height: 16),
            Text('You can adjust the dates after adding it.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      textConfirm: 'Add Term',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.primaryColor,
      textCancel: 'Cancel',
      onConfirm: () {
        terms.add({
          "from": DateTime.now().toIso8601String(),
          "to": DateTime.now().add(const Duration(days: 90)).toIso8601String(),
        });
        Get.back();
      }
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTextField(String label, String value, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          enabled: enabled,
          style: TextStyle(color: enabled ? AppTheme.textPrimary : Colors.grey.shade500),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, String dateStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dateStr, style: const TextStyle(color: AppTheme.textPrimary)),
              Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey.shade500),
            ],
          ),
        ),
      ],
    );
  }
}
