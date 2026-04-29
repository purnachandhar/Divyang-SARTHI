import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/educator_model.dart';
import '../../../data/providers/api_provider.dart';

class EducatorController extends GetxController {
  final ApiProvider _apiProvider = Get.put(ApiProvider());

  final currentIndex = 0.obs;
  final selectedDate = DateTime.now().obs;

  // Students list from API
  var students = <StudentModel>[].obs;
  var isLoadingStudents = false.obs;
  var isLoggingInStudent = false.obs;
  var studentsError = ''.obs;

  // NIEPID Dashboard data
  var niepidDashboardData = <String, dynamic>{}.obs;
  var isLoadingDashboard = false.obs;

  // NIEPID Student Assessments data
  var niepidStudentAssessments = <dynamic>[].obs;
  var isLoadingAssessments = false.obs;
  var niepidStudentsCount = 0.obs;
  var niepidTeachersCount = 0.obs;

  // IEP Academic Years data
  var iepAcademicYears = <Map<String, dynamic>>[].obs;
  var selectedIepYearId = ''.obs;

  // Current user details from API
  var currentEducator = Rxn<EducatorModel>();
  var isLoadingProfile = false.obs;

  @override
  void onReady() {
    super.onReady();
    fetchStudents();
    fetchCurrentUser();
  }

  Future<void> fetchStudents() async {
    isLoadingStudents.value = true;
    studentsError.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessId = prefs.getString('user_id') ?? '';
      if (accessId.isEmpty) {
        studentsError.value = 'No user session found. Please log in again.';
        return;
      }

      final response = await _apiProvider.getAllStudentsByAccessId(accessId);
      print('Student API status: ${response.statusCode}');
      print('Student API body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        List<dynamic> data = [];

        // API returns { StudentList: [...] }
        if (body is List) {
          data = body;
        } else if (body is Map) {
          data = body['StudentList'] ??
              body['studentList'] ??
              body['data'] ??
              body['students'] ??
              body['result'] ??
              [];
        }

        print('Parsed ${data.length} students from response');
        students.value = data
            .map((item) => StudentModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        studentsError.value =
            response.body?['message'] ?? 'Failed to load students';
        Get.snackbar('Error', studentsError.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      studentsError.value = e.toString();
      Get.snackbar('Error', 'Could not fetch students: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoadingStudents.value = false;
    }
  }

  Future<void> fetchCurrentUser() async {
    isLoadingProfile.value = true;
    try {
      final response = await _apiProvider.getCurrentUser();
      print('--- Current User Response ---');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('---------------------------');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map<String, dynamic>) {
          final model = EducatorModel.fromJson(response.body as Map<String, dynamic>);
          currentEducator.value = model;

          if (model.isNipiedDisha == true) {
            fetchNiepidDashboard();
            fetchNiepidStudentAssessments();
            
            if (model.organisation?.id != null) {
              fetchIepAcademicYears(model.organisation!.id!);
            }
          }
        }
      } else {
        print('Failed to fetch current user data.');
      }
    } catch (e) {
      print('Error fetching current user: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> fetchNiepidDashboard() async {
    isLoadingDashboard.value = true;
    try {
      final response = await _apiProvider.getNiepidDishaDashboard();
      print('--- NIEPID Dashboard Response ---');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map) {
          niepidDashboardData.value = response.body as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print('Error fetching NIEPID dashboard: $e');
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  Future<void> fetchNiepidStudentAssessments() async {
    isLoadingAssessments.value = true;
    try {
      final response = await _apiProvider.getNiepidStudentAssessments();
      print('--- NIEPID Student Assessments Response ---');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map) {
          if (response.body['data'] is List) {
            niepidStudentAssessments.value = response.body['data'];
          }
          if (response.body['studentscount'] != null) {
            niepidStudentsCount.value = response.body['studentscount'] is int 
                ? response.body['studentscount'] 
                : int.tryParse(response.body['studentscount'].toString()) ?? 0;
          }
          if (response.body['teacherscount'] != null) {
            niepidTeachersCount.value = response.body['teacherscount'] is int 
                ? response.body['teacherscount'] 
                : int.tryParse(response.body['teacherscount'].toString()) ?? 0;
          }
        }
      }
    } catch (e) {
      print('Error fetching NIEPID student assessments: $e');
    } finally {
      isLoadingAssessments.value = false;
    }
  }

  Future<void> fetchIepAcademicYears(String orgId) async {
    try {
      final response = await _apiProvider.getIepList(orgId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.body is List ? response.body : [];
        iepAcademicYears.value = data.map((e) => e as Map<String, dynamic>).toList();
        
        if (iepAcademicYears.isNotEmpty && selectedIepYearId.value.isEmpty) {
          selectedIepYearId.value = iepAcademicYears.first['id']?.toString() ?? '';
        }
      }
    } catch (e) {
      print('Error fetching IEP years: $e');
    }
  }

  String formatIepYear(Map<String, dynamic> iep) {
    final yearly = iep['yearlyIEP'];
    if (yearly != null) {
      final fromStr = yearly['from']?.toString() ?? '';
      final toStr = yearly['to']?.toString() ?? '';
      if (fromStr.length >= 4 && toStr.length >= 4) {
        return '${fromStr.substring(0, 4)}-${toStr.substring(0, 4)}';
      }
    }
    return 'Unknown Year';
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }

  void updateSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  void goToChatList() {
    Get.toNamed('/institute-chat-list');
  }

  void goToProfile() {
    Get.toNamed('/educator-profile');
  }

  void goToAddStudent() {
    Get.toNamed('/institute-add-student');
  }

  void viewStudentDetail(Map<String, dynamic> student) {
    Get.toNamed('/educator-student-detail', arguments: student);
  }

  Future<void> performStudentLogin(String userName, String dob) async {
    isLoggingInStudent.value = true;
    try {
      final response = await _apiProvider.studentLogin(userName, dob);
      print('Student login response status: ${response.statusCode}');
      print('Student login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        final String accessToken = body['accessToken'] ?? '';
        final String refreshToken = body['refreshToken'] ?? '';
        final Map<String, dynamic> studentData = body['student'] ?? {};

        if (accessToken.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();

          // Save the educator ID so the student portal can use it for IEP assessments
          final educatorId = prefs.getString('user_id') ?? '';
          if (educatorId.isNotEmpty) {
            await prefs.setString('last_educator_id', educatorId);
          }

          // Persist the student's tokens for the session
          await prefs.setString('access_token', accessToken);
          await prefs.setString('refresh_token', refreshToken);

          // Navigate to student home with the actual student object from login
          Get.toNamed('/student-home', arguments: studentData);
        } else {
          Get.snackbar('Login Failed', 'No access token received.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } else {
        Get.snackbar('Login Failed',
            response.body?['message'] ?? 'Failed to authenticate student',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Student login failed: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoggingInStudent.value = false;
    }
  }

  void goToMoodBoardSubmission(Map<String, String> student) {
    Get.toNamed('/educator-mood-board-submission', arguments: student);
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    Get.offAllNamed('/login');
  }
}
