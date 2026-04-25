import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/parent_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';
import '../../../utils/widgets/app_table.dart';

class ParentChildListView extends GetView<ParentController> {
  const ParentChildListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildChildList(context, isMobile: true),
      desktop: _buildChildList(context, isMobile: false),
    );
  }

  Widget _buildChildList(BuildContext context, {required bool isMobile}) {
    final List<Map<String, String>> children = [
      {'name': 'Arjun Singh', 'id': '2026DIVG055219', 'gender': 'male', 'age': '8 Years', 'class': 'Grade 3', 'status': 'Excellent', 'attendance': '95%'},
      {'name': 'Riya Singh', 'id': '2026DIVG053404', 'gender': 'female', 'age': '6 Years', 'class': 'Preschool', 'status': 'Good', 'attendance': '92%'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.goToAddChild(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: isMobile
                ? ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      return _ChildCard(child: child, controller: controller);
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppTable(
                      columns: const ['Photo', 'Name', 'Child ID', 'Age', 'Class', 'Status', 'Attendance', 'Actions'],
                      rows: children.map((child) {
                        final bool isMale = child['gender'] == 'male';
                        return DataRow(
                          cells: [
                            DataCell(
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
                                child: Icon(
                                  isMale ? Icons.face : Icons.face_retouching_natural,
                                  color: isMale ? Colors.blue : Colors.pink,
                                  size: 16,
                                ),
                              ),
                            ),
                            DataCell(Text(child['name']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(child['id']!)),
                            DataCell(Text(child['age']!)),
                            DataCell(Text(child['class']!)),
                            DataCell(Text(child['status']!)),
                            DataCell(Text(child['attendance']!)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility, color: AppTheme.primaryColor, size: 20),
                                onPressed: () => controller.goToChildProfile(child),
                                tooltip: 'View Profile',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Child List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage and track your children',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final Map<String, String> child;
  final ParentController controller;

  const _ChildCard({required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isMale = child['gender'] == 'male';
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      (isMale ? Colors.blue : Colors.pink).withOpacity(0.1),
                  child: Icon(
                    isMale ? Icons.face : Icons.face_retouching_natural,
                    color: isMale ? Colors.blue : Colors.pink,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child['name']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        'ID: ${child['id']}',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    child['class']!,
                    style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(Icons.cake_outlined, child['age']!, 'Age'),
                _buildInfoItem(Icons.bar_chart, 'Excellent', 'Status'),
                _buildInfoItem(
                    Icons.check_circle_outline, '95%', 'Attendance'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.goToChildProfile(child),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('View Full Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }
}
