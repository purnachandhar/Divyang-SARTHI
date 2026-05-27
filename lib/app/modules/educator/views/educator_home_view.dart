import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/educator_controller.dart';
import 'educator_dashboard_view.dart';
import 'educator_student_view.dart';
import 'educator_attendance_view.dart';
import 'educator_mood_board_view.dart';
import 'disha_curriculum_view.dart';
import 'learning_resources_view.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class EducatorHomeView extends GetView<EducatorController> {
  const EducatorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileHome(context),
      desktop: _buildDesktopHome(context),
    );
  }

  Widget _buildMobileHome(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: _buildMainContent(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDesktopHome(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      final isNiepid = controller.currentEducator.value?.isNipiedDisha == true;
      return IndexedStack(
        index: controller.currentIndex.value,
        children: [
          const EducatorDashboardView(),
          const EducatorStudentView(),
          isNiepid ? _buildModules() : const EducatorAttendanceView(),
          isNiepid ? _buildDishaCurriculum() : const EducatorMoodBoardView(),
          isNiepid ? const LearningResourcesView() : _buildMore(),
        ],
      );
    });
  }

  Widget _buildBottomNav() {
    return Obx(() {
      final isNiepid = controller.currentEducator.value?.isNipiedDisha == true;
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Student',
            ),
            if (isNiepid)
              const BottomNavigationBarItem(
                icon: Icon(Icons.view_module_outlined),
                activeIcon: Icon(Icons.view_module),
                label: 'Modules',
              )
            else
              const BottomNavigationBarItem(
                icon: Icon(Icons.how_to_reg_outlined),
                activeIcon: Icon(Icons.how_to_reg),
                label: 'Attendance',
              ),
            if (isNiepid) ...[
              const BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book),
                label: 'Disha Curriculum',
              ),
              // const BottomNavigationBarItem(
              //   icon: Icon(Icons.library_books_outlined),
              //   activeIcon: Icon(Icons.library_books),
              //   label: 'Learning Resources',
              // ),
            ] else ...[
              const BottomNavigationBarItem(
                icon: Icon(Icons.mood_outlined),
                activeIcon: Icon(Icons.mood),
                label: 'Mood Board',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.menu_outlined),
                activeIcon: Icon(Icons.menu),
                label: 'More',
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSidebar() {
    return Obx(() {
      final isNiepid = controller.currentEducator.value?.isNipiedDisha == true;
      return Container(
        width: 250,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Educator Portal',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
            _buildSidebarItem(1, Icons.school_outlined, Icons.school, 'Students'),
            if (isNiepid)
              _buildSidebarItem(2, Icons.view_module_outlined, Icons.view_module, 'Modules')
            else
              _buildSidebarItem(2, Icons.how_to_reg_outlined, Icons.how_to_reg, 'Attendance'),
            if (isNiepid) ...[
              _buildSidebarItem(3, Icons.book_outlined, Icons.book, 'Disha Curriculum'),
              // _buildSidebarItem(4, Icons.library_books_outlined, Icons.library_books, 'Learning Resources'),
            ] else ...[
              _buildSidebarItem(3, Icons.mood_outlined, Icons.mood, 'Mood Board'),
              _buildSidebarItem(4, Icons.menu_outlined, Icons.menu, 'All Services'),
            ],
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _showLogoutDialog,
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _buildSidebarItem(int index, IconData icon, IconData activeIcon, String label) {
    final bool isSelected = controller.currentIndex.value == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppTheme.primaryColor : Colors.grey,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => controller.changeTabIndex(index),
      ),
    );
  }

  Widget _buildModules() {
    return Column(
      children: [
        Container(
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
              Text('Modules',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Access specialized modules',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _buildMoreTile(
                  icon: Icons.assessment_outlined,
                  title: 'IEP Assessment',
                  subtitle: 'Manage IEP Assessments',
                  onTap: () => controller.goToIepAssessment()),
              _buildMoreTile(
                  icon: Icons.flag_outlined,
                  title: 'Goal Monitoring',
                  subtitle: 'Monitor student goals',
                  onTap: () => controller.goToGoalMonitoring()),
              _buildMoreTile(
                  icon: Icons.people_outline,
                  title: 'Care Giver Meeting',
                  subtitle: 'Schedule and manage meetings',
                  onTap: () => controller.goToCareGiverMeeting()),
              _buildMoreTile(
                  icon: Icons.summarize_outlined,
                  title: 'Student Reports',
                  subtitle: 'View and generate reports',
                  onTap: () => controller.goToStudentReports()),
              _buildMoreTile(
                  icon: Icons.library_books_outlined,
                  title: 'Learning Resources',
                  subtitle: 'Access learning materials',
                  onTap: () => Get.to(() => const LearningResourcesView())),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDishaCurriculum() {
    return const DishaCurriculumView();
  }

  Widget _buildMore() {
    return Column(
      children: [
        Container(
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
              Text('More Options',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Access additional services',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _buildMoreTile(
                  icon: Icons.chat_outlined,
                  title: 'Chat',
                  subtitle: 'Messages',
                  onTap: () => controller.goToChatList()),
              _buildMoreTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Learning Content',
                  subtitle: 'Materials',
                  onTap: () {}),
              _buildMoreTile(
                  icon: Icons.videogame_asset_outlined,
                  title: 'Gamified Content',
                  subtitle: 'Learning games',
                  onTap: () {}),
              const Divider(height: 32),
              _buildMoreTile(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () => _showLogoutDialog()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color? iconColor,
      Color? textColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: ListTile(
        leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor ?? AppTheme.primaryColor)),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor ?? AppTheme.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                Get.back();
                controller.logout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text('Logout', style: TextStyle(color: Colors.white)))
        ]));
  }
}
