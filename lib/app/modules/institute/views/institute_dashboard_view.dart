import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/institute_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class InstituteDashboardView extends GetView<InstituteController> {
  const InstituteDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Obx(() {
                if (controller.isNiepidDashboardLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (controller.isNipiedDisha.value) {
                  return _buildNiepidDashboard();
                }
                
                return ResponsiveLayout(
                  mobile: _buildMobileLayout(),
                  desktop: _buildDesktopLayout(),
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: controller.openMessages,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(),
        const SizedBox(height: 24),
        _buildSectionTitle('Student Overview'),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: _DashboardStatCard(title: 'Total Students', value: '16', icon: Icons.people)),
            SizedBox(width: 16),
            Expanded(
                child: _DashboardStatCard(
                    title: 'Avg. Attendance', value: '85%', icon: Icons.calendar_today, color: Colors.blue)),
          ],
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Gender Ratio'),
        const SizedBox(height: 16),
        _buildGenderPieChart(),
        const SizedBox(height: 24),
        _buildSectionTitle('Age Ratio'),
        const SizedBox(height: 16),
        _buildAgePieChart(),
        const SizedBox(height: 24),
        _buildSectionTitle('Baseline Assessment Status'),
        const SizedBox(height: 16),
        _buildAssessmentBarChart(),
        const SizedBox(height: 24),
        _buildSectionTitle('Annual Registrations'),
        const SizedBox(height: 16),
        _buildRegistrationLineChart(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(),
        const SizedBox(height: 32),
        _buildSectionTitle('Student Overview'),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: _DashboardStatCard(title: 'Total Students', value: '16', icon: Icons.people)),
            SizedBox(width: 16),
            Expanded(child: _DashboardStatCard(title: 'Active Educators', value: '8', icon: Icons.supervisor_account, color: Colors.orange)),
            SizedBox(width: 16),
            Expanded(
                child: _DashboardStatCard(
                    title: 'Avg. Attendance', value: '85%', icon: Icons.calendar_today, color: Colors.blue)),
            SizedBox(width: 16),
            Expanded(child: _DashboardStatCard(title: 'Reports Generated', value: '42', icon: Icons.assessment, color: Colors.green)),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Gender Ratio'),
                  const SizedBox(height: 16),
                  _buildGenderPieChart(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Age Ratio'),
                  const SizedBox(height: 16),
                  _buildAgePieChart(),
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
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Baseline Assessment Status'),
                  const SizedBox(height: 16),
                  _buildAssessmentBarChart(),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Annual Registrations'),
                  const SizedBox(height: 16),
                  _buildRegistrationLineChart(),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() {
                final rolesData = controller.profileData.value?['roles'];
                String rolesStr = 'Institute Overview';
                if (rolesData is List) {
                  rolesStr = rolesData.join(', ');
                } else if (rolesData is String) {
                  rolesStr = rolesData;
                }
                return Text(
                  rolesStr,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                );
              }),
            ],
          ),
          GestureDetector(
            onTap: controller.goToProfile,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_circle,
                  color: Colors.white, size: 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Obx(() {
      final String name = controller.profileData.value?['name'] ?? 'Institute';
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome $name',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your institute has 16 students with an average attendance. Keep up the great work!',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildGenderPieChart() {
    return _ChartContainer(
      height: 250,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                      color: Colors.blueAccent,
                      value: 60,
                      title: '60%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(
                      color: Colors.pinkAccent,
                      value: 40,
                      title: '40%',
                      radius: 50,
                      titleStyle: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChartIndicator(color: Colors.blueAccent, text: 'Male'),
              SizedBox(height: 8),
              _ChartIndicator(color: Colors.pinkAccent, text: 'Female'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgePieChart() {
    return _ChartContainer(
      height: 280,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                      color: Colors.orange,
                      value: 15,
                      title: '15%',
                      radius: 45,
                      titleStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  PieChartSectionData(
                      color: Colors.purple,
                      value: 25,
                      title: '25%',
                      radius: 45,
                      titleStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  PieChartSectionData(
                      color: Colors.green,
                      value: 30,
                      title: '30%',
                      radius: 45,
                      titleStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  PieChartSectionData(
                      color: Colors.blue,
                      value: 20,
                      title: '20%',
                      radius: 45,
                      titleStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  PieChartSectionData(
                      color: Colors.red,
                      value: 10,
                      title: '10%',
                      radius: 45,
                      titleStyle: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChartIndicator(color: Colors.orange, text: '3-6 Yrs'),
              SizedBox(height: 4),
              _ChartIndicator(color: Colors.purple, text: '7-10 Yrs'),
              SizedBox(height: 4),
              _ChartIndicator(color: Colors.green, text: '11-14 Yrs'),
              SizedBox(height: 4),
              _ChartIndicator(color: Colors.blue, text: '15-18 Yrs'),
              SizedBox(height: 4),
              _ChartIndicator(color: Colors.red, text: '18+ Yrs'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentBarChart() {
    return _ChartContainer(
      height: 250,
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
                  const style = TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10);
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Pending', style: style);
                    case 1:
                      return const Text('In Progress', style: style);
                    case 2:
                      return const Text('Completed', style: style);
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(
                  toY: 30,
                  color: Colors.redAccent,
                  width: 22,
                  borderRadius: BorderRadius.circular(6))
            ]),
            BarChartGroupData(x: 1, barRods: [
              BarChartRodData(
                  toY: 50,
                  color: Colors.orangeAccent,
                  width: 22,
                  borderRadius: BorderRadius.circular(6))
            ]),
            BarChartGroupData(x: 2, barRods: [
              BarChartRodData(
                  toY: 80,
                  color: Colors.greenAccent,
                  width: 22,
                  borderRadius: BorderRadius.circular(6))
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationLineChart() {
    return _ChartContainer(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const style =
                      TextStyle(color: AppTheme.textSecondary, fontSize: 10);
                  switch (value.toInt()) {
                    case 0:
                      return const Text('2020', style: style);
                    case 1:
                      return const Text('2021', style: style);
                    case 2:
                      return const Text('2022', style: style);
                    case 3:
                      return const Text('2023', style: style);
                    case 4:
                      return const Text('2024', style: style);
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 20),
                FlSpot(1, 35),
                FlSpot(2, 28),
                FlSpot(3, 45),
                FlSpot(4, 60),
              ],
              isCurved: true,
              gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Colors.blueAccent]),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.3),
                    Colors.transparent
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNiepidDashboard() {
    final dashboard = controller.niepidDashboardData.value?['dashboard'];
    if (dashboard == null) {
      return const Center(child: Text('No dashboard data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeSection(),
        const SizedBox(height: 24),
        _buildNiepidSection('Initial Entry Status', dashboard['entry']),
        const SizedBox(height: 24),
        _buildNiepidSection('Term 1 Assessment Status', dashboard['term1']),
        const SizedBox(height: 24),
        _buildNiepidSection('Term 2 Assessment Status', dashboard['term2']),
        const SizedBox(height: 24),
        _buildNiepidFilters(),
        const SizedBox(height: 24),
        _buildNiepidStudentAssessments(),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildNiepidSection(String title, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: Get.width > 600 ? 3 : 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _NiepidStatCard(
              title: 'Not Started',
              value: data['notStarted']?.toString() ?? '0',
              color: Colors.grey,
              icon: Icons.hourglass_empty,
            ),
            _NiepidStatCard(
              title: 'Draft',
              value: data['draft']?.toString() ?? '0',
              color: Colors.orange,
              icon: Icons.edit_note,
            ),
            _NiepidStatCard(
              title: 'Submitted',
              value: data['submitted']?.toString() ?? '0',
              color: Colors.blue,
              icon: Icons.send,
            ),
            _NiepidStatCard(
              title: 'Rework',
              value: data['rework']?.toString() ?? '0',
              color: Colors.red,
              icon: Icons.assignment_return,
            ),
            _NiepidStatCard(
              title: 'Approved',
              value: data['approved']?.toString() ?? '0',
              color: Colors.green,
              icon: Icons.check_circle,
            ),
            _NiepidStatCard(
              title: 'Caregivers',
              value: data['caregivers']?.toString() ?? '0',
              color: Colors.purple,
              icon: Icons.family_restroom,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNiepidStudentAssessments() {
    return Obx(() {
      if (controller.isNiepidStudentAssessmentsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.niepidStudentAssessments.value == null) {
        return const SizedBox.shrink();
      }

      final data = controller.filteredNiepidStudents;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Student Assessments'),
              Text(
                '${data.length} Students',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (data.isEmpty)
            const Center(child: Text('No students match the filters'))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final student = data[index];
                return _StudentAssessmentCard(student: student);
              },
            ),
        ],
      );
    });
  }

  Widget _buildNiepidFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filters',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Academic Year Dropdown
            Expanded(
              child: Obx(() {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.selectedNiepidYear.value,
                      hint: const Text('Select Year'),
                      items: controller.availableNiepidYears
                          .map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year),
                              ))
                          .toList(),
                      onChanged: (val) {
                        controller.selectedNiepidYear.value = val;
                        print('Selected Academic Year: $val');
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: null,
                      hint: Text(
                        controller.selectedNiepidTeachers.isEmpty
                            ? 'All Teachers'
                            : '${controller.selectedNiepidTeachers.length} Selected',
                        style: const TextStyle(fontSize: 14),
                      ),
                      items: controller.availableNiepidTeachers.map((teacher) {
                        return DropdownMenuItem<String>(
                          value: teacher,
                          child: Obx(() {
                            final isSelected = controller.selectedNiepidTeachers
                                .contains(teacher);
                            return Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (val) {
                                      controller.toggleTeacherFilter(teacher);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    teacher,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            );
                          }),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          controller.toggleTeacherFilter(val);
                          print('Selected Teacher: $val');
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final Widget child;
  final double height;

  const _ChartContainer({required this.child, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
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
      child: child,
    );
  }
}

class _ChartIndicator extends StatelessWidget {
  final Color color;
  final String text;

  const _ChartIndicator({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  const _DashboardStatCard(
      {required this.title,
      required this.value,
      required this.icon,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color ?? AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _NiepidStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _NiepidStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentAssessmentCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const _StudentAssessmentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final status = student['status'] as Map<String, dynamic>?;
    
    return Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['studentName'] ?? 'Unknown Student',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Teacher: ${student['teacherName'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  student['dateOfBirth'] ?? '',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusIndicator('', "baseline"),
              const SizedBox(width: 8),
              _buildStatusIndicator('IEP', status?['entry']),
              const SizedBox(width: 8),
              _buildStatusIndicator('Term 1', status?['term1']),
              const SizedBox(width: 8),
              _buildStatusIndicator('Term 2', status?['term2']),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, String? status) {
    Color color;
    switch (status?.toLowerCase()) {
      case 'approve':
      case 'approved':
      case 'baseline':
        color = Colors.green;
        break;
      case 'submitted':
        color = Colors.blue;
        break;
      case 'rework':
        color = Colors.red;
        break;
      case 'draft':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status?.capitalizeFirst ?? 'Pending',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

