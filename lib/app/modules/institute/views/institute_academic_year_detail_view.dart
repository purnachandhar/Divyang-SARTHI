import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../controllers/institute_controller.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../theme/app_gradients.dart';

class InstituteAcademicYearDetailView extends StatefulWidget {
  const InstituteAcademicYearDetailView({super.key});

  @override
  State<InstituteAcademicYearDetailView> createState() => _InstituteAcademicYearDetailViewState();
}

class _InstituteAcademicYearDetailViewState extends State<InstituteAcademicYearDetailView> {
  final controller = Get.find<InstituteController>();
  late String id;
  DateTime? acStartDate;
  DateTime? acEndDate;
  List<Map<String, DateTime>> terms = [];

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> data = Get.arguments ?? {};
    id = data['id'] ?? data['_id'] ?? 'N/A';
    final Map<String, dynamic>? yearlyIEP = data['yearlyIEP'];
    if (yearlyIEP != null) {
      acStartDate = DateTime.tryParse(yearlyIEP['from'] ?? '');
      acEndDate = DateTime.tryParse(yearlyIEP['to'] ?? '');
    }
    final List<dynamic>? termList = data['termIEP'];
    if (termList != null) {
      for (var t in termList) {
        if (t is Map) {
          final from = DateTime.tryParse(t['from'] ?? '');
          final to = DateTime.tryParse(t['to'] ?? '');
          if (from != null && to != null) {
            terms.add({'from': from, 'to': to});
          }
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate, void Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
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
      onDateSelected(picked);
    }
  }

  void _saveChanges() {
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
      if (terms[i]['from'] == null || terms[i]['to'] == null) {
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

    String formatDate(DateTime dt) {
      return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
    }

    final termPayload = terms.map((t) => {
      'from': formatDate(t['from']!),
      'to': formatDate(t['to']!),
    }).toList();

    controller.updateAcademicYear(
      id: id,
      yearlyFrom: formatDate(acStartDate!),
      yearlyTo: formatDate(acEndDate!),
      terms: termPayload,
    );
  }

  void _showAddTermDialog() {
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
        setState(() {
          terms.add({
            "from": DateTime.now(),
            "to": DateTime.now().add(const Duration(days: 90)),
          });
        });
        Get.back();
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    const String title = 'Academic Year Record';
    const String status = 'Active';

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
                          Expanded(
                            child: _buildDatePicker(context, 'From', acStartDate, () {
                              _selectDate(context, acStartDate ?? DateTime.now(), (date) {
                                setState(() {
                                  acStartDate = date;
                                });
                              });
                            }),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePicker(context, 'To', acEndDate, () {
                              _selectDate(context, acEndDate ?? DateTime.now(), (date) {
                                setState(() {
                                  acEndDate = date;
                                });
                              });
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('Terms'),
                        TextButton.icon(
                          onPressed: _showAddTermDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Term'),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: terms.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var term = entry.value;
                        String tName = 'Term ${idx + 1}';
                        
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
                                        setState(() {
                                          terms.removeAt(idx);
                                        });
                                      },
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDatePicker(context, 'From', term['from'], () {
                                        _selectDate(context, term['from'] ?? DateTime.now(), (date) {
                                          setState(() {
                                            term['from'] = date;
                                          });
                                        });
                                      }),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildDatePicker(context, 'To', term['to'], () {
                                        _selectDate(context, term['to'] ?? DateTime.now(), (date) {
                                          setState(() {
                                            term['to'] = date;
                                          });
                                        });
                                      }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
          Obx(() {
            final isLoading = controller.isUpdatingAcademicYear.value;
            return IconButton(
              icon: isLoading 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : const Icon(Icons.check_circle, color: Colors.white, size: 30),
              onPressed: isLoading ? null : _saveChanges,
            );
          })
        ],
      ),
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

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date, VoidCallback onTap) {
    String dateStr = 'dd-mm-yyyy';
    if (date != null) {
      dateStr = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
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
        ),
      ],
    );
  }
}
