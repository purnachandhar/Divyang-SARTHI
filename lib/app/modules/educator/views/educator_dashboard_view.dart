import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/educator_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class EducatorDashboardView extends GetView<EducatorController> {
  const EducatorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshDashboardData(),
              color: AppTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: ResponsiveLayout(
                  mobile: _buildMobileLayout(),
                  desktop: _buildDesktopLayout(),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToChatList,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNiepidDashboardSection(),
        _buildNiepidStudentAssessmentsSection(),
        Obx(() {
          final isNiepid =
              controller.currentEducator.value?.isNipiedDisha == true;
          if (isNiepid) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Age Ratio'),
              const SizedBox(height: 16),
              _buildAgeRatioChart(),
              const SizedBox(height: 32),
              _buildSectionTitle('Baseline Assessment Status'),
              const SizedBox(height: 16),
              _buildBaselineAssessmentChart(),
              const SizedBox(height: 40),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNiepidDashboardSection(),
        _buildNiepidStudentAssessmentsSection(),
        Obx(() {
          final isNiepid =
              controller.currentEducator.value?.isNipiedDisha == true;
          if (isNiepid) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Age Ratio'),
                        const SizedBox(height: 16),
                        _buildAgeRatioChart(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Baseline Assessment Status'),
                        const SizedBox(height: 16),
                        _buildBaselineAssessmentChart(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHeader() {
    final isNiepid = controller.currentEducator.value?.isNipiedDisha == true;
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final educator = controller.currentEducator.value;
            final name = educator?.fullName.isNotEmpty == true
                ? educator!.fullName
                : 'Loading...';
            final schoolName =
                educator?.organisation?.schoolName ?? 'Loading Institute...';

            String addressStr = '';
            if (educator?.organisation?.address != null) {
              addressStr = educator!.organisation!.address!;
              if (educator.organisation?.district != null) {
                addressStr += ', ${educator.organisation!.district!}';
              }
              if (educator.organisation?.state != null) {
                addressStr += ', ${educator.organisation!.state!}';
              }
            } else {
              addressStr = 'Loading Address...';
            }

            return Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (!isNiepid)
                  //   Text(
                  //   'Welcome $name',
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome $schoolName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addressStr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
          InkWell(
            onTap: controller.goToProfile,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildAgeRatioChart() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Colors.blue,
                    value: 25,
                    title: '25%',
                    radius: 40,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.orange,
                    value: 35,
                    title: '35%',
                    radius: 40,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: 20,
                    title: '20%',
                    radius: 40,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.purple,
                    value: 20,
                    title: '20%',
                    radius: 40,
                    titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLegendItem(Colors.blue, '3-6 Years'),
                const SizedBox(height: 8),
                _buildLegendItem(Colors.orange, '7-10 Years'),
                const SizedBox(height: 8),
                _buildLegendItem(Colors.green, '11-14 Years'),
                const SizedBox(height: 8),
                _buildLegendItem(Colors.purple, '15-18 Years'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBaselineAssessmentChart() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
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
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const titles = ['Completed', 'Pending', 'In Progress'];
                  if (value.toInt() >= 0 && value.toInt() < titles.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        titles[value.toInt()],
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  );
                },
                reservedSize: 30,
                interval: 20,
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                    toY: 65,
                    color: Colors.green,
                    width: 20,
                    borderRadius: BorderRadius.circular(4))
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                    toY: 20,
                    color: Colors.orange,
                    width: 20,
                    borderRadius: BorderRadius.circular(4))
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                    toY: 15,
                    color: Colors.blue,
                    width: 20,
                    borderRadius: BorderRadius.circular(4))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNiepidDashboardSection() {
    return Obx(() {
      final isNiepid = controller.currentEducator.value?.isNipiedDisha == true;
      if (!isNiepid) return const SizedBox.shrink();

      if (controller.isLoadingDashboard.value) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 32.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final dashboardData =
          controller.niepidDashboardData['dashboard'] as Map<String, dynamic>?;
      if (dashboardData == null) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('NIEPID Assessment Dashboard'),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: const Icon(Icons.person, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.currentEducator.value?.fullName ??
                            'Educator Name',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Students: ${controller.niepidStudentsCount.value > 0 ? controller.niepidStudentsCount.value : controller.students.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (controller.iepAcademicYears.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: controller.selectedIepYearId.value.isNotEmpty
                      ? controller.selectedIepYearId.value
                      : controller.iepAcademicYears.first['id']?.toString(),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppTheme.primaryColor),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedIepYearId.value = newValue;
                    }
                  },
                  items: controller.iepAcademicYears
                      .map<DropdownMenuItem<String>>(
                          (Map<String, dynamic> iep) {
                    return DropdownMenuItem<String>(
                      value: iep['id']?.toString() ?? '',
                      child: Text('${controller.formatIepYear(iep)}'),
                    );
                  }).toList(),
                ),
              ),
            ),
          _buildNiepidTermCard('Entry Baseline', dashboardData['entry']),
          const SizedBox(height: 16),
          _buildNiepidTermCard('Term 1 Assessment', dashboardData['term1']),
          const SizedBox(height: 16),
          _buildNiepidTermCard('Term 2 Assessment', dashboardData['term2']),
          const SizedBox(height: 32),
        ],
      );
    });
  }

  Widget _buildNiepidTermCard(String title, dynamic data) {
    if (data == null) return const SizedBox.shrink();

    final map = data as Map<String, dynamic>;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatItem('Not Started', map['notStarted'], Colors.grey),
              //_buildStatItem('Draft', map['draft'], Colors.orange),
              _buildStatItem('Submitted', map['submitted'], Colors.blue),
              //_buildStatItem('Rework', map['rework'], Colors.redAccent),
              _buildStatItem('Approved', map['approved'], Colors.green),
              _buildStatItem('Caregivers', map['caregivers'], Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${value ?? 0}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNiepidStudentAssessmentsSection() {
    return Obx(() {
      final isNiepid = controller.currentEducator.value?.isNipiedDisha == true;
      if (!isNiepid) return const SizedBox.shrink();

      if (controller.isLoadingAssessments.value) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 32.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final students = controller.niepidStudentAssessments;
      final yearId = controller.selectedIepYearId.value;
      if (students.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Student Assessments List'),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index] as Map<String, dynamic>;
              return _buildStudentAssessmentCard(student, yearId);
            },
          ),
          const SizedBox(height: 32),
        ],
      );
    });
  }

  Widget _buildStudentAssessmentCard(
      Map<String, dynamic> student, String yearId) {
    final status = student['status'] as Map<String, dynamic>? ?? {};
    final studentId = student['studentId']?.toString() ??
        student['id']?.toString() ??
        student['_id']?.toString() ??
        '';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  student['studentName'] ?? 'Unknown Student',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
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
                  'DOB: ${student['dateOfBirth'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _buildAssessmentStatusBadge(
                      'Baseline', status['entry'],
                      studentId: studentId, yearId: yearId)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildAssessmentStatusBadge('IEP', status['entry'],
                      studentId: studentId, yearId: yearId)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildAssessmentStatusBadge('Term 1', status['term1'],
                      studentId: studentId, yearId: yearId)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildAssessmentStatusBadge('Term 2', status['term2'],
                      studentId: studentId, yearId: yearId)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentStatusBadge(String title, String? statusStr,
      {String? studentId, String? yearId}) {
    final String status = statusStr?.toLowerCase() ?? 'pending';

    Color bgColor = Colors.grey.withOpacity(0.1);
    Color textColor = Colors.grey[700]!;

    if (status == 'approve' || status == 'approved') {
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green;
    } else if (status == 'submitted') {
      bgColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue;
    } else if (status == 'draft') {
      bgColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
    } else if (status == 'rework') {
      bgColor = Colors.redAccent.withOpacity(0.1);
      textColor = Colors.redAccent;
    }

    return GestureDetector(
      onTap: () {
        if (studentId != null && yearId != null) {
          if (title == 'Baseline') {
            Get.toNamed('/educator-iep-assessment', arguments: {
              'studentId': studentId,
              'yearId': yearId,
              'autoFetch': true,
            });
          } else if (title == 'IEP' || title == 'Term 1' || title == 'Term 2') {
            final termMap = {
              'IEP': 'entry',
              'Term 1': 'term1',
              'Term 2': 'term2',
            };
            Get.toNamed('/educator-goal-monitoring', arguments: {
              'studentId': studentId,
              'yearId': yearId,
              'term': termMap[title],
              'autoFetch': true,
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: textColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (statusStr ?? 'Pending').toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
