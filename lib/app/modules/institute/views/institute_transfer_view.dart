import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/widgets/app_table.dart';

class InstituteTransferView extends GetView<InstituteController> {
  const InstituteTransferView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ResponsiveLayout(
              mobile: _buildTransferList(isMobile: true),
              desktop: _buildTransferList(isMobile: false),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'transfer_fab',
        onPressed: controller.goToSearchTransfer,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.search, color: Colors.white),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Transfer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage and track student module transfers',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferList({required bool isMobile}) {
    final List<Map<String, String>> transfers = [
      {
        'sNo': '1',
        'username': '-',
        'studentName': 'Student',
        'enrollment': '2026DIVG053175',
        'class': 'N/A',
        'status': 'Approved'
      },
      {
        'sNo': '2',
        'username': 'speechtherapist',
        'studentName': 'Speech Therapist',
        'enrollment': '2026DIVG053404',
        'class': 'Preprimary',
        'status': 'Approved'
      },
      {
        'sNo': '3',
        'username': 'test1010',
        'studentName': 'Test1010',
        'enrollment': '2026DIVG053176',
        'class': 'Primary-I',
        'status': 'Approved'
      },
    ];

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: transfers.length,
        itemBuilder: (context, index) {
          final data = transfers[index];
          return _StudentTransferCard(
            data: data,
            onTap: () => controller.viewTransferDetail(data),
          );
        },
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: AppTable(
          columns: const ['S.No', 'Student Name', 'Enrollment', 'Username', 'Class', 'Status', 'Actions'],
          rows: transfers.map((data) {
            return DataRow(
              cells: [
                DataCell(Text(data['sNo']!)),
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(data['studentName']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                DataCell(Text(data['enrollment']!)),
                DataCell(Text(data['username']!)),
                DataCell(Text(data['class']!)),
                DataCell(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(data['status']!, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                )),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: AppTheme.primaryColor, size: 20),
                      onPressed: () => controller.viewTransferDetail(data),
                      tooltip: 'View',
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      );
    }
  }
}

class _StudentTransferCard extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onTap;

  const _StudentTransferCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    color: AppTheme.primaryColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['studentName']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enrollment: ${data['enrollment']}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Class: ${data['class']}',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment:  CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['status']!,
                      style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: AppTheme.textSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
