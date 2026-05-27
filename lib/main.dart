import 'package:divyangsarthi/app/modules/parent/views/parent_home_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'theme/app_theme.dart';
import 'app/modules/institute/bindings/institute_binding.dart';
import 'app/modules/institute/views/institute_home_view.dart';
import 'app/modules/institute/views/institute_profile_view.dart';
import 'app/modules/institute/views/institute_transfer_detail_view.dart';
import 'app/modules/institute/views/institute_search_transfer_view.dart';
import 'app/modules/institute/views/institute_professional_detail_view.dart';
import 'app/modules/institute/views/institute_add_professional_view.dart';
import 'app/modules/institute/views/institute_student_detail_view.dart';
import 'app/modules/institute/views/institute_add_student_view.dart';
import 'app/modules/institute/views/institute_verification_view.dart';
import 'app/modules/institute/views/institute_prof_verification_detail_view.dart';
import 'app/modules/institute/views/institute_student_verification_detail_view.dart';
import 'app/modules/institute/views/institute_chat_list_view.dart';
import 'app/modules/institute/views/institute_chat_detail_view.dart';
import 'app/modules/institute/views/institute_academic_year_view.dart';
import 'app/modules/institute/views/institute_academic_year_detail_view.dart';
import 'app/modules/home/views/professional_home_view.dart';
import 'app/modules/parent/bindings/parent_binding.dart';
import 'app/modules/educator/bindings/educator_binding.dart';
import 'app/modules/educator/views/educator_home_view.dart';
import 'app/modules/educator/views/educator_profile_view.dart';
import 'app/modules/educator/views/educator_mood_board_submission_view.dart';
import 'app/modules/educator/views/educator_student_detail_view.dart';
import 'app/modules/educator/views/educator_iep_assessment_view.dart';
import 'app/modules/educator/views/educator_goal_monitoring_view.dart';
import 'app/modules/educator/views/educator_care_giver_meeting_view.dart';
import 'app/modules/educator/views/educator_student_reports_view.dart';
import 'app/modules/parent/views/parent_add_child_view.dart';
import 'app/modules/parent/views/parent_child_profile_view.dart';
import 'app/modules/login/bindings/login_binding.dart';
import 'app/modules/login/views/login_view.dart';
import 'app/modules/student/bindings/student_binding.dart';
import 'app/modules/student/views/student_home_view.dart';
import 'app/modules/splash/views/splash_view.dart';
import 'app/modules/onboarding/views/onboarding_view.dart';
import 'app/modules/register/bindings/register_binding.dart';
import 'app/modules/register/views/register_view.dart';
import 'app/data/providers/api_provider.dart';

void main() {
  Get.put(ApiProvider());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Divyang SARTHI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashView(),
        ),
        GetPage(
          name: '/onboarding',
          page: () => OnboardingView(),
        ),
        GetPage(
          name: '/institute-home',
          page: () => const InstituteHomeView(),
          binding: InstituteBinding(),
        ),
        GetPage(
          name: '/institute-profile',
          page: () => const InstituteProfileView(),
        ),
        GetPage(
          name: '/institute-transfer-detail',
          page: () => const InstituteTransferDetailView(),
        ),
        GetPage(
          name: '/institute-search-transfer',
          page: () => const InstituteSearchTransferView(),
        ),
        GetPage(
          name: '/institute-professional-detail',
          page: () => const InstituteProfessionalDetailView(),
        ),
        GetPage(
          name: '/institute-add-professional',
          page: () => const InstituteAddProfessionalView(),
        ),
        GetPage(
          name: '/institute-student-detail',
          page: () => const InstituteStudentDetailView(),
        ),
        GetPage(
          name: '/institute-add-student',
          page: () => const InstituteAddStudentView(),
        ),
        GetPage(
          name: '/institute-verification-center',
          page: () => const InstituteVerificationView(),
        ),
        GetPage(
          name: '/institute-prof-verify-detail',
          page: () => const InstituteProfVerificationDetailView(),
        ),
        GetPage(
          name: '/institute-student-verify-detail',
          page: () => const InstituteStudentVerificationDetailView(),
        ),
        GetPage(
          name: '/institute-chat-list',
          page: () => const InstituteChatListView(),
        ),
        GetPage(
          name: '/institute-chat-detail',
          page: () => const InstituteChatDetailView(),
        ),
        GetPage(
          name: '/institute-academic-year',
          page: () => const InstituteAcademicYearView(),
        ),
        GetPage(
          name: '/institute-academic-year-detail',
          page: () => const InstituteAcademicYearDetailView(),
        ),
        GetPage(
          name: '/parent-home',
          page: () => const ParentHomeView(),
          binding: ParentBinding(),
        ),
        GetPage(
          name: '/parent-add-child',
          page: () => const ParentAddChildView(),
        ),
        GetPage(
          name: '/parent-child-profile',
          page: () => const ParentChildProfileView(),
        ),
        GetPage(
          name: '/professional-home',
          page: () => const ProfessionalHomeView(),
        ),
        GetPage(
          name: '/educator-home',
          page: () => const EducatorHomeView(),
          binding: EducatorBinding(),
        ),
        GetPage(
          name: '/educator-profile',
          page: () => const EducatorProfileView(),
        ),
        GetPage(
          name: '/educator-mood-board-submission',
          page: () => const EducatorMoodBoardSubmissionView(),
        ),
        GetPage(
          name: '/educator-student-detail',
          page: () => const EducatorStudentDetailView(),
        ),
        GetPage(
          name: '/educator-iep-assessment',
          page: () => const EducatorIepAssessmentView(),
        ),
        GetPage(
          name: '/educator-goal-monitoring',
          page: () => const EducatorGoalMonitoringView(),
        ),
        GetPage(
          name: '/educator-care-giver-meeting',
          page: () => const EducatorCareGiverMeetingView(),
        ),
        GetPage(
          name: '/educator/student-reports',
          page: () => const EducatorStudentReportsView(),
        ),
        GetPage(
          name: '/student-home',
          page: () => const StudentHomeView(),
          binding: StudentBinding(),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginView(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterView(),
          binding: RegisterBinding(),
        ),
      ],
    );
  }
}
