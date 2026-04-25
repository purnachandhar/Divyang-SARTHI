import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/parent_controller.dart';
import 'parent_dashboard_view.dart';
import 'parent_child_list_view.dart';
import '../../../../theme/app_theme.dart';
import '../../../utils/responsive_layout.dart';

class ParentHomeView extends GetView<ParentController> {
  const ParentHomeView({super.key});

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
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const ParentDashboardView(),
            ParentChildListView(),
            const SizedBox.shrink(), // Placeholder for Logout
          ],
        ));
  }

  Widget _buildBottomNav() {
    return Obx(
      () => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
          if (index == 2) {
            _showLogoutDialog();
          } else {
            controller.changeTabIndex(index);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care_outlined),
            activeIcon: Icon(Icons.child_care),
            label: 'Child List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
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
                  'Divyang SARTHI',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSidebarItem(0, Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
              _buildSidebarItem(1, Icons.child_care_outlined, Icons.child_care, 'Child List'),
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

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => controller.logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
