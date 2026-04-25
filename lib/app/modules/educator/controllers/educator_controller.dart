import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/student_model.dart';
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

  @override
  void onReady() {
    super.onReady();
    fetchStudents();
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
