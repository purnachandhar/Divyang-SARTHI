import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../theme/app_theme.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/models/professional_registration_model.dart';
import '../views/iep_questionnaire_view.dart';


class InstituteController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  var currentIndex = 0.obs;
  
  var profileData = Rxn<Map<String, dynamic>>();
  var isProfileLoading = false.obs;
  
  var educators = <Map<String, dynamic>>[].obs;
  var isEducatorsLoading = false.obs;

  var academicYears = <Map<String, dynamic>>[].obs;
  var isAcademicYearsLoading = false.obs;

  var isNipiedDisha = false.obs;
  var niepidDashboardData = Rxn<Map<String, dynamic>>();
  var isNiepidDashboardLoading = false.obs;
  
  var niepidStudentAssessments = Rxn<Map<String, dynamic>>();
  var isNiepidStudentAssessmentsLoading = false.obs;
  var filteredNiepidStudents = <Map<String, dynamic>>[].obs;

  var selectedNiepidTeachers = <String>[].obs;
  var availableNiepidTeachers = <String>[].obs;
  var availableNiepidYears = <String>[].obs;
  var selectedNiepidYear = Rxn<String>();
  var availableNiepidStudents = <String>[].obs;
  var selectedNiepidStudent = Rxn<String>();
  var showAssessmentResult = false.obs;
  var selectedStudentData = Rxn<Map<String, dynamic>>();
  var availableIepLevels = ['3-14 Years', '14+ Years'].obs;
  var selectedIepLevel = Rxn<String>();
  
  var niepidQuestions = Rxn<Map<String, dynamic>>();
  var isQuestionsLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentProfile();
  }

  Future<void> fetchCurrentProfile() async {
    try {
      isProfileLoading.value = true;
      final response = await _apiProvider.getCurrentUser();
      
      print('Current User Response Status: ${response.statusCode}');
      print('Current User Response Body: ${response.body}');

      if (response.statusCode == 200) {
        profileData.value = response.body;
        
        // Check for isNipiedDisha
        isNipiedDisha.value = response.body['isNipiedDisha'] ?? false;
        if (isNipiedDisha.value) {
          fetchNiepidDashboard();
          fetchNiepidStudentAssessments();
          fetchAcademicYears();
        }

        // After fetching profile, fetch educators
        fetchEducators();
      } else {
        print('Error fetching profile: ${response.statusText}');
      }
    } catch (e) {
      print('Exception fetching profile: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> fetchEducators() async {
    if (profileData.value == null) return;

    try {
      isEducatorsLoading.value = true;
      
      // The profile returns 'organisation' as a fully populated Map object
      // e.g., {_id: "68f729a7...", schoolName: "TestSchool", country: "India", ...}
      String? orgId;
      final org = profileData.value!['organisation'];
      final isApproved=profileData.value!['isApproved'];
      final isActive=profileData.value!['isActivate'];
      if (isApproved==false) {
        Get.snackbar('Error', 'Your organisation is not approved',snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.red);
        logout();
      }
      if (isActive==false) {
        Get.snackbar('Error', 'Your organisation is not active',snackPosition: SnackPosition.BOTTOM,backgroundColor: Colors.red);
        logout();
      }
      print('isApproved: $isApproved');
      print('isActive: $isActive');
      print('org: $org');
      if (org is Map) {
        // Populated object — API returns 'id' (not '_id') in the serialized JSON
        orgId = (org['id'] ?? org['_id'])?.toString();
        print('DEBUG: Extracted org from Map → id: $orgId');
      } else if (org is String && org.isNotEmpty) {
        // Already a plain string ID
        orgId = org;
        print('DEBUG: Extracted org from String → $orgId');
      }

      if (orgId == null || orgId.isEmpty) {
        print('Error: Organisation ID not found in profile. Organisation data: $org');
        return;
      }

      print('Fetching educators for organisation: $orgId');

      final response = await _apiProvider.getEducatorsByOrganisation(
        isApproved: isApproved,
        isActivate: isActive,
        organisationId: orgId,
      );

      print('Educators Response Status: ${response.statusCode}');
      print('Educators Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body is List) {
          educators.assignAll(List<Map<String, dynamic>>.from(response.body));
        } else if (response.body is Map && response.body['educators'] is List) {
           educators.assignAll(List<Map<String, dynamic>>.from(response.body['educators']));
        }
      } else {
        print('Error fetching educators: ${response.statusText}');
      }
    } catch (e) {
      print('Exception fetching educators: $e');
    } finally {
      isEducatorsLoading.value = false;
    }
  }

  Future<void> fetchNiepidDashboard() async {
    try {
      isNiepidDashboardLoading.value = true;
      final response = await _apiProvider.getNiepidDishaDashboard();
      
      print('NIEPID Dashboard Response Status: ${response.statusCode}');
      print('NIEPID Dashboard Response Body: ${response.body}');

      if (response.statusCode == 200) {
        niepidDashboardData.value = response.body;
        // Extract year logic: handle string or map structure
        final yearData = response.body['academicYear'] ?? response.body['year'];
        if (yearData != null) {
          String formattedYear = '';
          if (yearData is Map) {
            final from = yearData['fromYear'] ?? yearData['startYear'];
            final to = yearData['toYear'] ?? yearData['endYear'];
            if (from != null && to != null) {
              formattedYear = '$from-$to';
            }
          } else {
            formattedYear = yearData.toString();
          }
          
          if (formattedYear.isNotEmpty) {
            availableNiepidYears.assignAll([formattedYear]);
            selectedNiepidYear.value = formattedYear;
          }
        }
      }
    } catch (e) {
      print('Exception fetching NIEPID dashboard: $e');
    } finally {
      isNiepidDashboardLoading.value = false;
    }
  }

  Future<void> fetchNiepidStudentAssessments() async {
    try {
      isNiepidStudentAssessmentsLoading.value = true;
      final response = await _apiProvider.getNiepidStudentAssessments();
      
      print('NIEPID Student Assessments Response Status: ${response.statusCode}');
      print('NIEPID Student Assessments Response Body: ${response.body}');

      if (response.statusCode == 200) {
        niepidStudentAssessments.value = response.body;
        // Extract unique teacher names
        final List? data = response.body['data'];
        if (data != null) {
          final teachers = data
              .map((e) => e['teacherName']?.toString())
              .whereType<String>()
              .toSet()
              .toList();
          availableNiepidTeachers.assignAll(teachers);
          
          final students = data
              .map((e) => e['studentName']?.toString())
              .whereType<String>()
              .toSet()
              .toList();
          availableNiepidStudents.assignAll(students);
          
          filteredNiepidStudents.assignAll(List<Map<String, dynamic>>.from(data));
        }
      }
    } catch (e) {
      print('Exception fetching NIEPID student assessments: $e');
    } finally {
      isNiepidStudentAssessmentsLoading.value = false;
    }
  }

  void applyNiepidFilters() {
    final allData = niepidStudentAssessments.value?['data'] as List?;
    if (allData == null) return;

    var filtered = List<Map<String, dynamic>>.from(allData);

    if (selectedNiepidTeachers.isNotEmpty) {
      filtered = filtered
          .where((s) => selectedNiepidTeachers.contains(s['teacherName']))
          .toList();
    }

    filteredNiepidStudents.assignAll(filtered);
  }

  void clearTeacherFilters() {
    selectedNiepidTeachers.clear();
    applyNiepidFilters();
  }

  void toggleTeacherFilter(String teacher) {
    if (selectedNiepidTeachers.contains(teacher)) {
      selectedNiepidTeachers.remove(teacher);
    } else {
      selectedNiepidTeachers.add(teacher);
    }
    applyNiepidFilters();
  }

  Future<void> fetchAcademicYears() async {
    final org = profileData.value?['organisation'];
    String orgId = '';
    if (org is Map) {
      orgId = (org['id'] ?? org['_id'] ?? '').toString();
    } else if (org is String) {
      orgId = org;
    }

    if (orgId.isEmpty) {
      orgId = '68f729a7a1529d51538519bb'; // Fallback to provided orgId if not found
    }

    try {
      isAcademicYearsLoading.value = true;
      final response = await _apiProvider.getIepList(orgId);
      
      print('IEP Response Status: ${response.statusCode}');
      print('IEP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> data = [];
        if (response.body is List) {
          data = List<Map<String, dynamic>>.from(response.body);
        } else if (response.body is Map && response.body['data'] is List) {
          data = List<Map<String, dynamic>>.from(response.body['data']);
        }
        academicYears.assignAll(data);

        // Populate NIEPID dropdown years
        if (isNipiedDisha.value) {
          final years = data.map((item) {
            final yearlyIEP = item['yearlyIEP'];
            if (yearlyIEP != null && yearlyIEP is Map) {
              final fromDate = DateTime.tryParse(yearlyIEP['from']?.toString() ?? '');
              final toDate = DateTime.tryParse(yearlyIEP['to']?.toString() ?? '');
              if (fromDate != null && toDate != null) {
                return '${fromDate.year}-${toDate.year}';
              }
            }
            return null;
          }).whereType<String>().toSet().toList();
          
          if (years.isNotEmpty) {
            availableNiepidYears.assignAll(years);
            if (selectedNiepidYear.value == null || !years.contains(selectedNiepidYear.value)) {
              selectedNiepidYear.value = years.first;
            }
          }
        }
      } else {
        print('Error fetching IEP: ${response.statusText}');
      }
    } catch (e) {
      print('Exception fetching IEP: $e');
    } finally {
      isAcademicYearsLoading.value = false;
    }
  }


  void changeTabIndex(int index) {
    currentIndex.value = index;
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    Get.offAllNamed('/login');
  }

  void goToProfile() {
    Get.toNamed('/institute-profile');
  }

  void openMessages() {
    Get.snackbar('Messaging', 'Opening message center...',
        snackPosition: SnackPosition.BOTTOM);
  }

  void viewTransferDetail(Map<String, String> studentData) {
    Get.toNamed('/institute-transfer-detail', arguments: studentData);
  }

  void goToSearchTransfer() {
    searchResult.value = null;
    Get.toNamed('/institute-search-transfer');
  }

  var searchResult = Rxn<Map<String, String>>();
  var isSearching = false.obs;

  void searchStudent(String username, String enrollment) {
    if (username.isEmpty && enrollment.isEmpty) {
      Get.snackbar('Error', 'Please enter username or enrollment number',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    isSearching.value = true;
    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      isSearching.value = false;
      // Dummy logic: if either matches or is 'test', return a result
      if (username.toLowerCase() == 'rahul' ||
          enrollment == '2026DIVG053175' ||
          username == 'test') {
        searchResult.value = {
          'studentName': 'Rahul Kumar',
          'username': username.isEmpty ? 'rahul_k' : username,
          'enrollment': enrollment.isEmpty ? '2026DIVG053175' : enrollment,
          'class': 'Class 10',
          'status': 'Eligible'
        };
      } else {
        searchResult.value = null;
        Get.snackbar('Not Found', 'No student found with these details',
            snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  void transferStudent(String studentName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Transfer'),
        content: Text(
            'Are you sure you want to transfer $studentName for the current session?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', '$studentName transferred successfully!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  colorText: Colors.green);
              Get.back(); // Return to previous screen
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void viewProfessionalDetail(Map<String, String> profData) {
    Get.toNamed('/institute-professional-detail', arguments: profData);
  }

  var isAddingProfessional = false.obs;

  Future<void> addProfessional({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
    required String designation,
    required String qualification,
    // required String crrNumber,
    required bool agreeToTerms,
    required String localAddress,
    required String pinCode,
    required String district,
    required String state,
  }) async {
    // Extract org ID and passcode from profileData
    final org = profileData.value?['organisation'];
    String orgId = '';
    if (org is Map) {
      orgId = (org['id'] ?? org['_id'] ?? '').toString();
    } else if (org is String) {
      orgId = org;
    }

    if (orgId.isEmpty) {
      Get.snackbar('Error', 'Organisation ID not available. Please restart the app.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isAddingProfessional.value = true;
    try {
      final request = ProfessionalRegistrationRequest(
        roles: 'Educator',
        organisation: orgId,
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        mobile: mobile,
        userDP: '',
        isTermsAndConditionsAccepted: agreeToTerms,
        qualification: qualification,
        // crrNumber: crrNumber,
        designation: designation,
        address: Address(
          pinCode: pinCode,
          localAddress: localAddress,
          district: district,
          state: state,
        ),
      );

      print('Add Professional Request: ${request.toJson()}');
      final response = await _apiProvider.registerProfessional(request);
      print('Add Professional Response Status: ${response.statusCode}');
      print('Add Professional Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Return to professionals list first
        fetchEducators(); // Refresh the list
        // Snackbar shows on the parent screen after back()
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Professional added successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3));
        });
      } else {
        final errorMessage = (response.body is Map && response.body['message'] != null)
            ? response.body['message'].toString()
            : 'Failed to add professional. Please try again.';
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Exception adding professional: $e');
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isAddingProfessional.value = false;
    }
  }

  void goToAddProfessional() {
    Get.toNamed('/institute-add-professional');
  }

  void viewStudentDetail(Map<String, String> studentData) {
    Get.toNamed('/institute-student-detail', arguments: studentData);
  }

  void goToAddStudent() {
    Get.toNamed('/institute-add-student');
  }

  void goToVerificationCenter() {
    Get.toNamed('/institute-verification-center');
  }

  void viewProfVerificationDetail(Map<String, String> data) {
    Get.toNamed('/institute-prof-verify-detail', arguments: data);
  }

  void viewStudentVerificationDetail(Map<String, String> data) {
    Get.toNamed('/institute-student-verify-detail', arguments: data);
  }

  void goToChatList() {
    Get.toNamed('/institute-chat-list');
  }

  void goToChatDetail(Map<String, String> userData) {
    Get.toNamed('/institute-chat-detail', arguments: userData);
  }

  void deleteAcademicYear(String id) {
    Get.defaultDialog(
      title: 'Confirm Delete',
      middleText: 'Are you sure you want to delete this academic year?',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      textCancel: 'Cancel',
      onConfirm: () {
        // Here we would call the API to delete
        // e.g. await _apiProvider.deleteIep(id);
        Get.back(); // close dialog
        Get.snackbar('Success', 'Academic year deleted successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        fetchAcademicYears(); // refresh list
      },
    );
  }

  void goToAcademicYear() {
    fetchAcademicYears();
    Get.toNamed('/institute-academic-year');
  }

  Future<void> getAssessment() async {
    final studentData = selectedStudentData.value;
    if (studentData == null) {
      Get.snackbar('Error', 'No student selected for assessment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    final org = profileData.value?['organisation'];
    String orgId = '';
    if (org is Map) {
      orgId = (org['id'] ?? org['_id'] ?? '').toString();
    } else if (org is String) {
      orgId = org;
    }

    if (orgId.isEmpty) {
      Get.snackbar('Error', 'Organisation ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    final studentId = studentData['id'] ?? studentData['_id'] ?? studentData['studentId'];
    if (studentId == null) {
      Get.snackbar('Error', 'Student ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    try {
      isQuestionsLoading.value = true;
      final response = await _apiProvider.getNiepidQuestions("68d4e4e20e437cd03453ccd8", studentId.toString());
      
      print('NIEPID Questions Response Status: ${response.statusCode}');
      print('NIEPID Questions Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        niepidQuestions.value = response.body;
        Get.to(() => const IepQuestionnaireView());
      } else {
        Get.snackbar('Error', 'Failed to fetch questions: ${response.statusText}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red);
      }
    } catch (e) {
      print('Exception fetching NIEPID questions: $e');
      Get.snackbar('Error', 'An error occurred while fetching questions',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
    } finally {
      isQuestionsLoading.value = false;
    }
  }

  void updateSelectedStudent(String? studentName) {
    selectedNiepidStudent.value = studentName;
    if (studentName == null) {
      selectedStudentData.value = null;
      showAssessmentResult.value = false;
    } else {
      final allData = niepidStudentAssessments.value?['data'] as List?;
      if (allData != null) {
        selectedStudentData.value = Map<String, dynamic>.from(
          allData.firstWhere(
            (s) => s['studentName'] == studentName,
            orElse: () => {},
          ),
        );
        if (selectedStudentData.value!.isEmpty) {
          selectedStudentData.value = null;
          showAssessmentResult.value = false;
        } else {
          showAssessmentResult.value = true;
        }
      }
    }
  }

  String calculateAge(dynamic dobValue) {
    if (dobValue == null) return "-";
    
    // If it's already a number (age)
    if (dobValue is num) return dobValue.toString();
    
    // If it's a string, try to parse as date
    try {
      final dob = DateTime.tryParse(dobValue.toString());
      if (dob == null) {
        // Maybe it's a string representing a number
        final ageNum = int.tryParse(dobValue.toString());
        if (ageNum != null) return ageNum.toString();
        return "-";
      }
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return "-";
    }
  }
}
