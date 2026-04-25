import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import 'comeing_soon_screen.dart';
import 'institute_dashboard_view.dart';
import 'institute_transfer_view.dart';
import 'institute_modules_view.dart';
import 'institute_professional_view.dart';
import 'institute_student_view.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class InstituteHomeView extends GetView<InstituteController> {
  const InstituteHomeView({super.key});

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
    return Obx(() => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const InstituteDashboardView(),
            controller.isNipiedDisha.value
                ? const InstituteModulesView()
                : InstituteTransferView(),
            InstituteProfessionalView(),
            InstituteStudentView(),
            _buildMore(),
          ],
        ));
  }

  Widget _buildBottomNav() {
    return Obx(() => Container(
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
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(controller.isNipiedDisha.value
                    ? Icons.grid_view_outlined
                    : Icons.swap_horiz_outlined),
                activeIcon: Icon(controller.isNipiedDisha.value
                    ? Icons.grid_view
                    : Icons.swap_horiz),
                label: controller.isNipiedDisha.value ? 'Modules' : 'Transfer',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.psychology_outlined),
                activeIcon: Icon(Icons.psychology),
                label: 'Professional',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'Student',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.menu_outlined),
                activeIcon: Icon(Icons.menu),
                label: 'More',
              ),
            ],
          ),
        ));
  }

  Widget _buildSidebar() {
    return Obx(() => Container(
          width: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Institute Portal',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSidebarItem(
                  0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
              controller.isNipiedDisha.value
                  ? _buildSidebarItem(1, Icons.grid_view_outlined,
                      Icons.grid_view, 'Modules')
                  : _buildSidebarItem(1, Icons.swap_horiz_outlined,
                      Icons.swap_horiz, 'Transfers'),
              _buildSidebarItem(2, Icons.psychology_outlined, Icons.psychology,
                  'Professionals'),
              _buildSidebarItem(3, Icons.school_outlined, Icons.school, 'Students'),
              _buildSidebarItem(4, Icons.menu_outlined, Icons.menu, 'All Services'),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: _showLogoutDialog,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
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

  Widget _buildMore() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
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
                  icon: Icons.verified_user_outlined,
                  title: 'Verification Center',
                  subtitle: 'Verify details',
                  onTap: () => controller.goToVerificationCenter()),
              _buildMoreTile(
                  icon: Icons.calendar_month_outlined,
                  title: 'Academic Year',
                  subtitle: 'Manage academic years',
                  onTap: () => controller.goToAcademicYear()),
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
              _buildMoreTile(
                  icon: Icons.calendar_today_outlined,
                  title: 'Academic Year',
                  subtitle: 'Schedules',
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

  Widget _buildTabContent(
      {required String title,
      required IconData icon,
      required String content}) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
          decoration: const BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30))),
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              Icon(icon,
                  size: 80, color: AppTheme.primaryColor.withOpacity(0.2)),
              const SizedBox(height: 24),
              Text(content,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 40),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Feature Coming Soon',
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold)))
            ]))),
      ],
    );
  }
}
