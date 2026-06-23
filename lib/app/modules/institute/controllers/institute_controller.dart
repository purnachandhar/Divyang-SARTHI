import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
  var isUpdatingProfessionalStatus = false.obs;
  var educatorSearchQuery = ''.obs;

  List<Map<String, dynamic>> get filteredEducators {
    if (educatorSearchQuery.value.trim().isEmpty) return educators;
    final q = educatorSearchQuery.value.trim().toLowerCase();
    return educators.where((e) {
      final firstName = (e['firstName'] ?? '').toString().toLowerCase();
      final lastName = (e['lastName'] ?? '').toString().toLowerCase();
      final fullName = '$firstName $lastName';
      final roles = e['roles'] is List
          ? (e['roles'] as List).join(' ').toLowerCase()
          : (e['roles'] ?? '').toString().toLowerCase();
      final email = (e['email'] ?? '').toString().toLowerCase();
      final design = (e['designation'] ?? '').toString().toLowerCase();
      return fullName.contains(q) ||
          roles.contains(q) ||
          email.contains(q) ||
          design.contains(q);
    }).toList();
  }

  var students = <Map<String, dynamic>>[].obs;
  var isStudentsLoading = false.obs;

  var academicYears = <Map<String, dynamic>>[].obs;
  var isAcademicYearsLoading = false.obs;

  var disabilityTypesList = <Map<String, dynamic>>[].obs;
  var isDisabilityLoading = false.obs;

  var availableDistricts = <String>[].obs;
  var isPincodeLoading = false.obs;

  var qualificationList = <Map<String, dynamic>>[].obs;
  var isQualificationsLoading = false.obs;

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
  var allNiepidDomains = <Map<String, dynamic>>[].obs;
  var filteredNiepidDomains = <Map<String, dynamic>>[].obs;
  var niepidStudentGoals = Rxn<Map<String, dynamic>>();
  var assessmentAnswers = <String, Map<String, dynamic>>{}.obs;
  var isQuestionsLoading = false.obs;

  var careGiverMeetingData = Rxn<Map<String, dynamic>>();
  var isCareGiverLoading = false.obs;
  var selectedCareGiverTeacher = Rxn<String>();
  var filteredCareGiverStudents = <Map<String, dynamic>>[].obs;
  var availableCareGiverTeachers = <Map<String, dynamic>>[].obs;

  // --- Goal Monitoring State ---
  var selectedGoalMonitoringYear = Rxn<String>();
  var selectedGoalMonitoringStudent = Rxn<String>();
  var goalMonitoringData = Rxn<Map<String, dynamic>>();
  var isGoalMonitoringLoading = false.obs;
  var activeGoalTab = 0.obs; // 0: Baseline, 1: Term1, 2: Term2
  var showGoalMonitoringDetails = false.obs;
  var goalMonitoringDomains = <Map<String, dynamic>>[].obs;
  var goalMonitoringStatuses = <String, String>{}.obs;
  var baselineGoalsCache = <dynamic>[].obs;
  var baselineDomainGoalsCache = <String, List<dynamic>>{}.obs;
  var goalMonitoringAnswers = <String, Map<String, dynamic>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentProfile();
    fetchDisabilityTypes();
    fetchQualifications();

    // Listen for changes to questions or level to re-filter
    ever(niepidQuestions, (_) => _initializeDomains());
    ever(selectedIepLevel, (_) => applyIepLevelFilter());
    ever(activeGoalTab, (index) {
      if (index is int) {
        fetchTermStudentGoals(index);
      }
    });
  }

  void _initializeDomains() {
    if (niepidQuestions.value != null &&
        niepidQuestions.value!['domains'] is List) {
      allNiepidDomains.assignAll(
          List<Map<String, dynamic>>.from(niepidQuestions.value!['domains']));
      applyIepLevelFilter();
    } else {
      allNiepidDomains.clear();
      filteredNiepidDomains.clear();
    }
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

        // After fetching profile, fetch educators and students
        fetchEducators();
        fetchStudents();
      } else {
        print('Error fetching profile: ${response.statusText}');
      }
    } catch (e) {
      print('Exception fetching profile: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> refreshDashboardData() async {
    await fetchCurrentProfile();
  }

  Future<void> fetchEducators() async {
    if (profileData.value == null) return;

    try {
      isEducatorsLoading.value = true;

      // The profile returns 'organisation' as a fully populated Map object
      // e.g., {_id: "68f729a7...", schoolName: "TestSchool", country: "India", ...}
      String? orgId;
      final org = profileData.value!['organisation'];
      final isApproved = profileData.value!['isApproved'];
      final isActive = profileData.value!['isActivate'];
      if (isApproved == false) {
        Get.snackbar('Error', 'Your organisation is not approved',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
        logout();
      }
      if (isActive == false) {
        Get.snackbar('Error', 'Your organisation is not active',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
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
        print(
            'Error: Organisation ID not found in profile. Organisation data: $org');
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
        List<Map<String, dynamic>> fetchedList = [];
        if (response.body is List) {
          fetchedList = List<Map<String, dynamic>>.from(response.body);
        } else if (response.body is Map && response.body['educators'] is List) {
          fetchedList =
              List<Map<String, dynamic>>.from(response.body['educators']);
        }

        // Filter to only include those with the "Educator" role
        final filtered = fetchedList.where((e) {
          final roles = e['roles'];
          if (roles is List) {
            return roles.contains('Educator');
          }
          return false;
        }).toList();

        educators.assignAll(filtered);
      } else {
        print('Error fetching educators: ${response.statusText}');
      }
    } catch (e) {
      print('Exception fetching educators: $e');
    } finally {
      isEducatorsLoading.value = false;
    }
  }

  Future<void> fetchStudents() async {
    if (profileData.value == null) return;

    try {
      isStudentsLoading.value = true;
      String? orgId;
      final org = profileData.value!['organisation'];

      if (org is Map) {
        orgId = (org['id'] ?? org['_id'])?.toString();
      } else if (org is String && org.isNotEmpty) {
        orgId = org;
      }

      if (orgId == null || orgId.isEmpty) {
        print('Error: Organisation ID not found in profile.');
        return;
      }

      print('Fetching students for organisation: $orgId');
      final response = await _apiProvider.getStudentsBySchoolId(orgId);

      print('Students Response Status: ${response.statusCode}');
      print('Students Response Body of the student details: ${response.body}');
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> fetchedList = [];
        if (response.body is List) {
          fetchedList = List<Map<String, dynamic>>.from(response.body);
        } else if (response.body is Map && response.body['data'] is List) {
          fetchedList = List<Map<String, dynamic>>.from(response.body['data']);
        } else if (response.body is Map && response.body['user'] is List) {
          fetchedList = List<Map<String, dynamic>>.from(response.body['user']);
        } else if (response.body is Map) {
          fetchedList = [response.body];
        }
        students.assignAll(fetchedList);
      } else {
        print('Error fetching students: ${response.statusText}');
      }
    } catch (e) {
      print('Exception fetching students: $e');
    } finally {
      isStudentsLoading.value = false;
    }
  }

  Future<void> fetchDisabilityTypes() async {
    try {
      isDisabilityLoading.value = true;
      final response = await _apiProvider.getDisabilityTypes();
      print('Disability Types Response Status: ${response.statusCode}');
      print('Disability Types Response Body: ${response.body}');
      if (response.statusCode == 200) {
        if (response.body is List) {
          disabilityTypesList
              .assignAll(List<Map<String, dynamic>>.from(response.body));
        } else if (response.body is Map && response.body['data'] is List) {
          disabilityTypesList.assignAll(
              List<Map<String, dynamic>>.from(response.body['data']));
        } else if (response.body is Map && response.body['items'] is List) {
          disabilityTypesList.assignAll(
              List<Map<String, dynamic>>.from(response.body['items']));
        }
      }
    } catch (e) {
      print('Error fetching disability types: $e');
    } finally {
      isDisabilityLoading.value = false;
    }
  }

  Future<void> fetchQualifications() async {
    try {
      isQualificationsLoading.value = true;
      final response = await _apiProvider.getQualifications();
      print('Qualifications Response Status: ${response.statusCode}');
      print('Qualifications Response Body: ${response.body}');
      if (response.statusCode == 200) {
        if (response.body is List) {
          qualificationList
              .assignAll(List<Map<String, dynamic>>.from(response.body));
        } else if (response.body is Map && response.body['data'] is List) {
          qualificationList.assignAll(
              List<Map<String, dynamic>>.from(response.body['data']));
        } else if (response.body is Map && response.body['items'] is List) {
          qualificationList.assignAll(
              List<Map<String, dynamic>>.from(response.body['items']));
        }
      } else {
        print('Error fetching qualifications: ${response.statusText}');
      }
    } catch (e) {
      print('Exception fetching qualifications: $e');
    } finally {
      isQualificationsLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> lookupPincode(String pincode) async {
    if (pincode.length != 6) return null;

    try {
      isPincodeLoading.value = true;
      final response = await _apiProvider.getPincodeDetails(pincode);

      print('Pincode Response Status: ${response.statusCode}');
      print('Pincode Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // New backend returns a Map; legacy postalpincode.in returned a List.
        dynamic data;
        if (response.body is Map) {
          data = response.body;
        } else if (response.body is List && response.body.isNotEmpty) {
          data = response.body[0];
        }

        if (data != null && data['Status'] == 'Success') {
          final List postOffices = data['PostOffice'] ?? [];
          if (postOffices.isNotEmpty) {
            final state = postOffices[0]['State'];
            final districts = postOffices
                .map((po) =>
                    po['District']?.toString() ?? po['Block']?.toString() ?? '')
                .where((d) => d.isNotEmpty)
                .toSet()
                .toList();

            availableDistricts.assignAll(districts);
            return {
              'state': state,
              'districts': districts,
            };
          }
        }
      }
    } catch (e) {
      print('Error looking up pincode: $e');
    } finally {
      isPincodeLoading.value = false;
    }
    return null;
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

      print(
          'NIEPID Student Assessments Response Status: ${response.statusCode}');
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

          filteredNiepidStudents
              .assignAll(List<Map<String, dynamic>>.from(data));
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
      orgId =
          '68f729a7a1529d51538519bb'; // Fallback to provided orgId if not found
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
          final years = data
              .map((item) {
                final yearlyIEP = item['yearlyIEP'];
                if (yearlyIEP != null && yearlyIEP is Map) {
                  final fromDate =
                      DateTime.tryParse(yearlyIEP['from']?.toString() ?? '');
                  final toDate =
                      DateTime.tryParse(yearlyIEP['to']?.toString() ?? '');
                  if (fromDate != null && toDate != null) {
                    return '${fromDate.year}-${toDate.year}';
                  }
                }
                return null;
              })
              .whereType<String>()
              .toSet()
              .toList();

          if (years.isNotEmpty) {
            availableNiepidYears.assignAll(years);
            if (selectedNiepidYear.value == null ||
                !years.contains(selectedNiepidYear.value)) {
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

  Future<void> deleteAcademicYear(String id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Academic Year?'),
        content: const Text(
            'Are you sure you want to delete this academic year record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      isAcademicYearsLoading.value = true;
      try {
        final response = await _apiProvider.deleteAcademicYear(id);
        if (response.statusCode == 200 || response.statusCode == 204) {
          fetchAcademicYears();
          Get.snackbar('Success', 'Academic year deleted successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        } else {
          Get.snackbar('Error', 'Failed to delete academic year',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        }
      } catch (e) {
        print('Error deleting academic year: $e');
        Get.snackbar('Error', 'An error occurred',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      } finally {
        isAcademicYearsLoading.value = false;
      }
    }
  }

  var isAddingAcademicYear = false.obs;

  Future<void> addAcademicYear({
    required String yearlyFrom,
    required String yearlyTo,
    required List<Map<String, String>> terms,
  }) async {
    final org = profileData.value?['organisation'];
    String orgId = '';
    if (org is Map) {
      orgId = (org['id'] ?? org['_id'] ?? '').toString();
    } else if (org is String) {
      orgId = org;
    }

    if (orgId.isEmpty) {
      orgId = '68f729a7a1529d51538519bb';
    }

    // Convert dd-mm-yyyy to yyyy-mm-dd
    String convertDate(String ddmmyyyy) {
      final parts = ddmmyyyy.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return ddmmyyyy;
    }

    final body = {
      'organisation': orgId,
      'yearlyIEP': {
        'from': convertDate(yearlyFrom),
        'to': convertDate(yearlyTo),
      },
      'termIEP': terms
          .map((t) => {
                'from': convertDate(t['from']!),
                'to': convertDate(t['to']!),
              })
          .toList(),
    };

    print('Add Academic Year Request: $body');

    isAddingAcademicYear.value = true;
    try {
      final response = await _apiProvider.addIep(body);
      print('Add Academic Year Response Status: ${response.statusCode}');
      print('Add Academic Year Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        fetchAcademicYears();
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Academic Year added successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3));
        });
      } else {
        final errorMessage =
            (response.body is Map && response.body['message'] != null)
                ? response.body['message'].toString()
                : 'Failed to add Academic Year. Please try again.';
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Exception adding academic year: $e');
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isAddingAcademicYear.value = false;
    }
  }

  var isUpdatingAcademicYear = false.obs;

  Future<void> updateAcademicYear({
    required String id,
    required String yearlyFrom,
    required String yearlyTo,
    required List<Map<String, String>> terms,
  }) async {
    final org = profileData.value?['organisation'];
    String orgId = '';
    if (org is Map) {
      orgId = (org['id'] ?? org['_id'] ?? '').toString();
    } else if (org is String) {
      orgId = org;
    }

    if (orgId.isEmpty) {
      orgId = '68f729a7a1529d51538519bb';
    }

    // Convert dd-mm-yyyy to yyyy-mm-dd
    String convertDate(String ddmmyyyy) {
      final parts = ddmmyyyy.split('-');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
      return ddmmyyyy;
    }

    final body = {
      'organisation': orgId,
      'yearlyIEP': {
        'from': convertDate(yearlyFrom),
        'to': convertDate(yearlyTo),
      },
      'termIEP': terms
          .map((t) => {
                'from': convertDate(t['from']!),
                'to': convertDate(t['to']!),
              })
          .toList(),
    };

    print('Update Academic Year Request: $body');

    isUpdatingAcademicYear.value = true;
    try {
      final response = await _apiProvider.updateIep(id, body);
      print('Update Academic Year Response Status: ${response.statusCode}');
      print('Update Academic Year Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        fetchAcademicYears();
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Academic Year updated successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3));
        });
      } else {
        final errorMessage =
            (response.body is Map && response.body['message'] != null)
                ? response.body['message'].toString()
                : 'Failed to update Academic Year. Please try again.';
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Exception updating academic year: $e');
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isUpdatingAcademicYear.value = false;
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

  void handleAutoFetchIepAssessment(String? studentName, String? year) {
    if (year != null && availableNiepidYears.contains(year)) {
      selectedNiepidYear.value = year;
    }

    if (studentName != null) {
      // Find the student in the list
      final student =
          availableNiepidStudents.firstWhereOrNull((s) => s == studentName);
      if (student != null) {
        updateSelectedStudent(student);
        // After updating student, show the result card
        showAssessmentResult.value = true;
      }
    }
  }

  void viewTransferDetail(Map<String, dynamic> studentData) {
    Get.toNamed('/institute-transfer-detail', arguments: studentData);
  }

  Future<void> handleAutoFetchGoalMonitoring(
      String? studentName, String? year, int termIndex) async {
    if (year != null && availableNiepidYears.contains(year)) {
      selectedGoalMonitoringYear.value = year;
    }

    if (studentName != null && availableNiepidStudents.contains(studentName)) {
      selectedGoalMonitoringStudent.value = studentName;
      activeGoalTab.value = termIndex;
      await fetchGoalMonitoring();
    }
  }

  void goToSearchTransfer() {
    searchResult.value = null;
    Get.toNamed('/institute-search-transfer');
  }

  var searchResult = Rxn<Map<String, dynamic>>();
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

  void viewProfessionalDetail(Map<String, dynamic> profData) {
    Get.toNamed('/institute-professional-detail', arguments: profData);
  }

  var isAddingProfessional = false.obs;
  var isAddingStudent = false.obs;

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
      Get.snackbar(
          'Error', 'Organisation ID not available. Please restart the app.',
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
          pinCode: '500031',
          localAddress: 'Gacchibowli',
          district: 'Hyderabad',
          state: 'Telangana',
          country: 'India',
        ),
        isApproved: true,
        // Inherit the NIEPID DISHA flag from the logged-in institute's profile
        // (set in fetchCurrentProfile from response.body['isNipiedDisha']).
        isNipiedDisha: isNipiedDisha.value,
      );

      print('Add Professional Request: ${request.toJson()}');
      final response = await _apiProvider.registerProfessional(request);
      print('Add Professional Response Status: ${response.statusCode}');
      print('Add Professional Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Return to professionals list first
        fetchEducators(); // Refresh the list

        final successMessage =
            (response.body is Map && response.body['message'] != null)
                ? response.body['message'].toString()
                : 'Professional added successfully!';

        // Snackbar shows on the parent screen after back()
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', successMessage,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 4));
        });
      } else {
        final errorMessage =
            (response.body is Map && response.body['message'] != null)
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

  Future<void> addStudent({
    required String userName,
    required String fullName,
    required String dateOfBirth,
    String? studentClass,
    required String gender,
    required String parentName,
    required String parentEmail,
    required String parentMobile,
    required String parentRelation,
    required String admissionDate,
    required String pinCode,
    required String state,
    required String district,
    required String localAddress,
    required String presentAddress,
    String? certificateUDID,
    String? numberUDID,
    List<String>? disability,
    String? studentDP,
    String? idCard,
    List<String>? assignedProfessionalIds,
  }) async {
    final org = profileData.value?['organisation'];
    String orgId = '';
    if (org is Map) {
      orgId = (org['id'] ?? org['_id'] ?? '').toString();
    } else if (org is String) {
      orgId = org;
    }

    if (orgId.isEmpty) {
      Get.snackbar('Error', 'Organisation ID not available.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isAddingStudent.value = true;
    try {
      String formatDate(String date) {
        try {
          final parts = date.split('-');
          if (parts.length == 3) {
            // Convert dd-MM-yyyy to yyyy-MM-dd
            return '${parts[2]}-${parts[1]}-${parts[0]}';
          }
        } catch (e) {}
        return date;
      }

      String? userId;
      if (profileData.value != null) {
        userId =
            (profileData.value!['id'] ?? profileData.value!['_id'])?.toString();
      }

      final List<String> accessIds = [];
      if (assignedProfessionalIds != null &&
          assignedProfessionalIds.isNotEmpty) {
        accessIds.addAll(assignedProfessionalIds);
      }
      if (userId != null) {
        accessIds.add(userId);
      }

      final Map<String, dynamic> requestBody = {
        "roles": "Student",
        "role": "Student",
        "addedBy": "Institute",
        "organisation": orgId,
        "accessId": accessIds,
        "userName": userName,
        "fullName": fullName,
        "dateOfBirth": formatDate(dateOfBirth),
        "class": studentClass ?? "",
        "gender": gender.toLowerCase(),
        "parentRelation": parentRelation,
        "idCard": idCard ?? "",
        "admissionDate": formatDate(admissionDate),
        "pinCode": pinCode,
        "localAddress": localAddress,
        "presentAddress": presentAddress,
        "district": district,
        "state": state,
        "country": "India",
        "parentName": parentName,
        "contactNumber": parentMobile,
        "email": parentEmail,
        "certificateUDID": certificateUDID ?? "",
        "numberUDID": numberUDID ?? "",
        "disability": (disability ?? []).map((label) {
          try {
            final type =
                disabilityTypesList.firstWhere((e) => e['label'] == label);
            return type['value'] ?? label;
          } catch (e) {
            return label;
          }
        }).toList(),
        "studentDP": studentDP ?? "",
        "acceptedTerms": true,
        "isVerified": true,
        "currentId": "",
        "homeSchool": "",
        "testId": [],
        "classHistory": studentClass != null ? [studentClass] : [],
        "previousClass": "",
        "organizationName": "",
        "organizationEmail": "",
      };

      print('Add Student Request: $requestBody');
      final response = await _apiProvider.addStudent(requestBody);
      print('Add Student Response Status: ${response.statusCode}');
      print('Add Student Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        fetchStudents(); // Refresh list
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Student added successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        });
      } else {
        final errorMessage =
            (response.body is Map && response.body['message'] != null)
                ? response.body['message'].toString()
                : 'Failed to add student. Please try again.';
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Exception adding student: $e');
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isAddingStudent.value = false;
    }
  }

  Future<void> updateStudent({
    required String studentId,
    required String userName,
    required String fullName,
    required String dateOfBirth,
    String? studentClass,
    required String gender,
    required String parentName,
    required String parentEmail,
    required String parentMobile,
    required String parentRelation,
    required String admissionDate,
    required String pinCode,
    required String state,
    required String district,
    required String localAddress,
    required String presentAddress,
    String? certificateUDID,
    String? numberUDID,
    List<String>? disability,
    String? studentDP,
    String? idCard,
    List<String>? assignedProfessionalIds,
  }) async {
    final org = profileData.value?['organisation'];
    String orgId = '';
    if (org is Map) {
      orgId = (org['id'] ?? org['_id'] ?? '').toString();
    } else if (org is String) {
      orgId = org;
    }

    if (orgId.isEmpty) {
      Get.snackbar('Error', 'Organisation ID not available.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isAddingStudent.value = true;
    try {
      String formatDate(String date) {
        try {
          final parts = date.split('-');
          if (parts.length == 3) {
            // Convert dd-MM-yyyy to yyyy-MM-dd
            return '${parts[2]}-${parts[1]}-${parts[0]}';
          }
        } catch (e) {}
        return date;
      }

      String? userId;
      if (profileData.value != null) {
        userId =
            (profileData.value!['id'] ?? profileData.value!['_id'])?.toString();
      }

      final List<String> accessIds = [];
      if (assignedProfessionalIds != null &&
          assignedProfessionalIds.isNotEmpty) {
        accessIds.addAll(assignedProfessionalIds);
      }
      if (userId != null) {
        accessIds.add(userId);
      }

      final Map<String, dynamic> requestBody = {
        "roles": "Student",
        "role": "Student",
        "addedBy": "Institute",
        "organisation": orgId,
        "accessId": accessIds,
        "userName": userName,
        "fullName": fullName,
        "dateOfBirth": formatDate(dateOfBirth),
        "class": studentClass ?? "",
        "gender": gender.toLowerCase(),
        "parentRelation": parentRelation,
        "idCard": idCard ?? "",
        "admissionDate": formatDate(admissionDate),
        "pinCode": pinCode,
        "localAddress": localAddress,
        "presentAddress": presentAddress,
        "district": district,
        "state": state,
        "country": "India",
        "parentName": parentName,
        "contactNumber": parentMobile,
        "email": parentEmail,
        "certificateUDID": certificateUDID ?? "",
        "numberUDID": numberUDID ?? "",
        "disability": (disability ?? []).map((label) {
          try {
            final type =
                disabilityTypesList.firstWhere((e) => e['label'] == label);
            return type['value'] ?? label;
          } catch (e) {
            return label;
          }
        }).toList(),
        "studentDP": studentDP ?? "",
        "acceptedTerms": true,
        "isVerified": true,
        "currentId": "",
        "homeSchool": "",
        "classHistory": studentClass != null ? [studentClass] : [],
        "previousClass": "",
        "organizationName": "",
        "organizationEmail": "",
      };

      print('Update Student Request: $requestBody');
      final response = await _apiProvider.updateStudent(studentId, requestBody);
      print('Update Student Response Status: ${response.statusCode}');
      print('Update Student Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Pop the Edit (and the Student Detail) screens to return to the
        // student list on the institute home dashboard.
        currentIndex.value = 3; // Students tab in the home IndexedStack
        Get.until((route) => route.settings.name == '/institute-home');
        fetchStudents(); // Refresh list
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Student updated successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white);
        });
      } else {
        final errorMessage =
            (response.body is Map && response.body['message'] != null)
                ? response.body['message'].toString()
                : 'Failed to update student. Please try again.';
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Exception updating student: $e');
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isAddingStudent.value = false;
    }
  }

  void goToAddProfessional() {
    Get.toNamed('/institute-add-professional');
  }

  void viewStudentDetail(Map<String, dynamic> studentData) {
    Get.toNamed('/institute-student-detail', arguments: studentData);
  }

  void goToAddStudent() {
    Get.toNamed('/institute-add-student');
  }

  void goToVerificationCenter() {
    Get.toNamed('/institute-verification-center');
  }

  void viewProfVerificationDetail(Map<String, dynamic> data) {
    Get.toNamed('/institute-prof-verify-detail', arguments: data);
  }

  void viewStudentVerificationDetail(Map<String, dynamic> data) {
    Get.toNamed('/institute-student-verify-detail', arguments: data);
  }

  void goToChatList() {
    Get.toNamed('/institute-chat-list');
  }

  void goToChatDetail(Map<String, dynamic> userData) {
    Get.toNamed('/institute-chat-detail', arguments: userData);
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

    final studentId =
        studentData['id'] ?? studentData['_id'] ?? studentData['studentId'];
    if (studentId == null) {
      Get.snackbar('Error', 'Student ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
      return;
    }

    try {
      isQuestionsLoading.value = true;

      // 1. Calculate age from student data
      final ageStr = calculateAge(studentData['dateOfBirth'] ??
          studentData['dob'] ??
          studentData['age']);
      final age = int.tryParse(ageStr) ?? 0;

      // 2. Set IEP level based on age (According to Disha/NIEPID standards)
      if (age >= 14) {
        selectedIepLevel.value = '14+ Years';
      } else if (age >= 3) {
        selectedIepLevel.value = '3-14 Years';
      } else {
        selectedIepLevel.value = '3-14 Years'; // Default for under 3
      }

      print(
          'DEBUG: Getting assessment for Student ID: $studentId, Age: $age, Level: ${selectedIepLevel.value}');

      // 3. Fetch Student Goals (Existing Answers)
      // Link: https://backend.divyangsarthi.in/niepid-disha-assessment/user/student-goals/<studentId>
      final goalsResponse =
          await _apiProvider.getStudentGoals(studentId.toString());
      if (goalsResponse.statusCode == 200) {
        niepidStudentGoals.value = goalsResponse.body;
        print('DEBUG: Student Goals fetched successfully');
      } else {
        print(
            'DEBUG: No existing goals found or error fetching goals: ${goalsResponse.statusText}');
        niepidStudentGoals.value = null;
      }

      // 4. Fetch Assessment Questions
      // Link: https://backend.divyangsarthi.in/niepid-disha-assessment/user/questions/<orgId>/<studentId>
      // Using the specific Disha Assessment Org ID provided in the request
      const String dishaOrgId = "68d4e4e20e437cd03453ccd8";
      final response = await _apiProvider.getNiepidQuestions(
          dishaOrgId, studentId.toString());

      if (response.statusCode == 200) {
        niepidQuestions.value = response.body;
        print('DEBUG: Questions fetched successfully');

        // 5. Parse goals/answers into assessmentAnswers map
        _parseStudentGoals();

        Get.to(() => const IepQuestionnaireView());
      } else {
        Get.snackbar(
            'Error', 'Failed to fetch questions: ${response.statusText}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red);
      }
    } catch (e) {
      print('Exception in getAssessment: $e');
      Get.snackbar('Error', 'An error occurred while fetching assessment data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red);
    } finally {
      isQuestionsLoading.value = false;
    }
  }

  void _parseStudentGoals() {
    assessmentAnswers.clear();
    final goalsData = niepidStudentGoals.value;
    final questionsData = niepidQuestions.value;

    if (goalsData == null || questionsData == null) return;

    // Helper: Map questionId to options
    final qOptionsMap = <String, List<dynamic>>{};
    final domainsList = questionsData['domains'] as List?;
    if (domainsList != null) {
      for (var d in domainsList) {
        final qs = d['questions'] as List?;
        if (qs != null) {
          for (var q in qs) {
            final qId = q['_id']?.toString() ?? q['id']?.toString() ?? '';
            final opts = q['options'] as List?;
            if (qId.isNotEmpty && opts != null) {
              qOptionsMap[qId] = opts;
            }
          }
        }
      }
    }

    try {
      // Parse answers
      if (goalsData['answer'] is Map) {
        final answerMap = goalsData['answer'] as Map;
        for (var domainEntries in answerMap.values) {
          if (domainEntries is Map) {
            // Usually we care about 'entry' for baseline assessment
            for (var termKey in ['entry', 'term1', 'term2']) {
              final termList = domainEntries[termKey] as List?;
              if (termList != null) {
                for (var ansItem in termList) {
                  final qId = ansItem['questionId']?.toString();
                  if (qId != null && qId.isNotEmpty) {
                    final optIndex = ansItem['options'];
                    String mainOpt = '';
                    if (optIndex != null && optIndex is int) {
                      final optsList = qOptionsMap[qId] ?? [];
                      if (optIndex >= 0 && optIndex < optsList.length) {
                        mainOpt = optsList[optIndex].toString();
                      }
                    }

                    final score = ansItem['checkboxValue']?.toString();

                    final existing =
                        assessmentAnswers[qId] ?? <String, dynamic>{};
                    if (mainOpt.isNotEmpty) existing['mainOption'] = mainOpt;
                    if (score != null && score.isNotEmpty)
                      existing['score'] = score;
                    assessmentAnswers[qId] = existing;
                  }
                }
              }
            }
          }
        }
      }

      // Parse goals
      if (goalsData['goals'] is Map) {
        final goalsMap = goalsData['goals'] as Map;
        for (var domainEntries in goalsMap.values) {
          if (domainEntries is Map) {
            for (var termKey in ['entry', 'term1', 'term2']) {
              final termList = domainEntries[termKey] as List?;
              if (termList != null) {
                for (var goalItem in termList) {
                  final qId = goalItem['questionId']?.toString();
                  if (qId != null &&
                      qId.isNotEmpty &&
                      goalItem['isGoal'] == true) {
                    final existing =
                        assessmentAnswers[qId] ?? <String, dynamic>{};
                    existing['isGoal'] = true;
                    existing['priority'] = goalItem['priority'];
                    assessmentAnswers[qId] = existing;
                  }
                }
              }
            }
          }
        }
      }
      print('DEBUG: Parsed ${assessmentAnswers.length} answers/goals');
    } catch (e) {
      print('Error parsing student goals: $e');
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
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age.toString();
    } catch (e) {
      return "-";
    }
  }

  Future<void> fetchCareGiverMeetingData() async {
    try {
      isCareGiverLoading.value = true;
      final response = await _apiProvider.getCareGiverMeetingData();

      print('Care Giver Meeting Response Status: ${response.statusCode}');
      print('Care Giver Meeting Response Body: ${response.body}');

      if (response.statusCode == 200) {
        careGiverMeetingData.value = response.body;

        // Extract teachers
        final List? teachers = response.body['teacherStatus'];
        if (teachers != null) {
          availableCareGiverTeachers
              .assignAll(List<Map<String, dynamic>>.from(teachers));
        }

        // Initially show all students or filter if a teacher is already selected
        applyCareGiverFilters();
      }
    } catch (e) {
      print('Exception fetching care giver meeting data: $e');
    } finally {
      isCareGiverLoading.value = false;
    }
  }

  void applyCareGiverFilters() {
    final allStudents = careGiverMeetingData.value?['students'] as List?;
    if (allStudents == null) {
      filteredCareGiverStudents.clear();
      return;
    }

    var filtered = List<Map<String, dynamic>>.from(allStudents);

    if (selectedCareGiverTeacher.value != null) {
      filtered = filtered
          .where((s) => s['teacherId'] == selectedCareGiverTeacher.value)
          .toList();
    }

    filteredCareGiverStudents.assignAll(filtered);
  }

  void onCareGiverTeacherChanged(String? teacherId) {
    selectedCareGiverTeacher.value = teacherId;
    applyCareGiverFilters();
  }

  String? getAnswerForQuestion(String questionId) {
    return assessmentAnswers[questionId]?['mainOption']?.toString();
  }

  String? getScoreForQuestion(String questionId) {
    return assessmentAnswers[questionId]?['score']?.toString();
  }

  bool isGoalForQuestion(String questionId) {
    return assessmentAnswers[questionId]?['isGoal'] == true;
  }

  // --- Statistics Getters ---

  int getDomainTotalQuestionsCount(Map<String, dynamic> domain) {
    return (domain['questions'] as List?)?.length ?? 0;
  }

  int getDomainAnsweredCount(Map<String, dynamic> domain) {
    int count = 0;
    final qs = domain['questions'] as List?;
    if (qs != null) {
      for (var q in qs) {
        final id = q['_id']?.toString() ?? q['id']?.toString() ?? '';
        if (assessmentAnswers.containsKey(id) &&
            assessmentAnswers[id]!['mainOption'] != null) {
          count++;
        }
      }
    }
    return count;
  }

  int getDomainGoalsCount(Map<String, dynamic> domain) {
    int count = 0;
    final qs = domain['questions'] as List?;
    if (qs != null) {
      for (var q in qs) {
        final id = q['_id']?.toString() ?? q['id']?.toString() ?? '';
        if (assessmentAnswers[id]?['isGoal'] == true) {
          count++;
        }
      }
    }
    return count;
  }

  int get totalQuestionsCount {
    return filteredNiepidDomains.fold(
        0, (sum, d) => sum + getDomainTotalQuestionsCount(d));
  }

  int get totalAnsweredCount {
    return filteredNiepidDomains.fold(
        0, (sum, d) => sum + getDomainAnsweredCount(d));
  }

  int get totalGoalsCount {
    return filteredNiepidDomains.fold(
        0, (sum, d) => sum + getDomainGoalsCount(d));
  }

  // Age Filtering Logic
  static const _ageGroupFields = [
    'ageGroup',
    'age_group',
    'agegroup',
    'AgeGroup',
    'level',
    'Level',
    'type',
    'Type',
    'category',
    'Category',
    'group',
    'Group',
    'standard',
    'Standard',
    'ageRange',
    'age_range',
  ];

  String _ageGroupOf(Map obj) {
    for (final f in _ageGroupFields) {
      final v = obj[f];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim().toLowerCase();
      }
    }
    return '';
  }

  bool _ageGroupMatches(String fieldValue, String rangeOnly) {
    final fv = fieldValue.toLowerCase();
    final rv = rangeOnly.toLowerCase();
    return fv.contains(rv) || rv.contains(fv);
  }

  void applyIepLevelFilter() {
    if (allNiepidDomains.isEmpty) {
      filteredNiepidDomains.clear();
      return;
    }

    final level = selectedIepLevel.value;
    if (level == null || level.isEmpty) {
      filteredNiepidDomains.assignAll(allNiepidDomains);
      return;
    }

    // "3-14 Years" -> "3-14"
    final rangeOnly = level
        .replaceAll(RegExp(r'\s*years\s*', caseSensitive: false), '')
        .trim();

    final filtered = <Map<String, dynamic>>[];
    for (final domain in allNiepidDomains) {
      // Check domain level first
      final domainAg = _ageGroupOf(domain);
      // If domain has a level and it doesn't match, skip the whole domain
      if (domainAg.isNotEmpty && !_ageGroupMatches(domainAg, rangeOnly))
        continue;

      final allQs = (domain['questions'] as List? ?? []);
      final filteredQs = allQs.where((q) {
        if (q is! Map) return true;
        final qAg = _ageGroupOf(q);
        // If question has no level info, keep it. If it has, must match.
        return qAg.isEmpty || _ageGroupMatches(qAg, rangeOnly);
      }).toList();

      if (filteredQs.isNotEmpty) {
        final d = Map<String, dynamic>.from(domain);
        d['questions'] = filteredQs;
        d['questionsCount'] = filteredQs.length;
        filtered.add(d);
      }
    }

    filteredNiepidDomains.assignAll(filtered);
    print(
        'DEBUG: Filtered to ${filteredNiepidDomains.length} domains for level $level');
  }

  // --- Goal Monitoring Methods ---

  Future<void> fetchGoalMonitoring() async {
    final studentName = selectedGoalMonitoringStudent.value;
    if (studentName == null || studentName.isEmpty) {
      Get.snackbar('Error', 'Please select a student',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Find student ID from assessment list
    final allData = niepidStudentAssessments.value?['data'] as List?;
    if (allData == null) return;

    final student = allData.firstWhere((s) => s['studentName'] == studentName,
        orElse: () => null);
    if (student == null) {
      Get.snackbar('Error', 'Student data not found',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final studentId = student['studentId']?.toString() ??
        student['id']?.toString() ??
        student['_id']?.toString();
    if (studentId == null) return;

    isGoalMonitoringLoading.value = true;
    showGoalMonitoringDetails.value = false;
    try {
      final response = await _apiProvider.verifyStudentGoals(studentId);
      if (response.statusCode == 200) {
        goalMonitoringData.value = response.body;

        // Extract statuses
        if (response.body['status'] is Map) {
          final statusMap = response.body['status'] as Map;
          goalMonitoringStatuses.assignAll({
            'entry': statusMap['entry']?.toString() ?? 'pending',
            'term1': statusMap['term1']?.toString() ?? 'pending',
            'term2': statusMap['term2']?.toString() ?? 'pending',
          });
        }

        // Fetch questions if not already loaded for this student
        if (allNiepidDomains.isEmpty) {
          final orgId = "68d4e4e20e437cd03453ccd8";
          final qResponse =
              await _apiProvider.getNiepidQuestions(orgId, studentId);
          if (qResponse.statusCode == 200 &&
              qResponse.body['domains'] is List) {
            allNiepidDomains.assignAll(
                List<Map<String, dynamic>>.from(qResponse.body['domains']));
          }
        }
        await fetchTermStudentGoals(activeGoalTab.value);
        showGoalMonitoringDetails.value = true;
      } else {
        Get.snackbar('Error', 'Failed to fetch goal monitoring data',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Exception fetching goal monitoring: $e');
    } finally {
      isGoalMonitoringLoading.value = false;
    }
  }

  Future<void> fetchTermStudentGoals(int tabIndex) async {
    final studentName = selectedGoalMonitoringStudent.value;
    final yearLabel = selectedGoalMonitoringYear.value;
    if (studentName == null || yearLabel == null) return;

    // Find student ID
    final allData = niepidStudentAssessments.value?['data'] as List?;
    final student = allData?.firstWhere((s) => s['studentName'] == studentName,
        orElse: () => null);
    final studentId = student?['studentId']?.toString() ??
        student?['id']?.toString() ??
        student?['_id']?.toString();

    // Find year ID
    final yearObj = academicYears.firstWhere((y) {
      final yearlyIEP = y['yearlyIEP'];
      if (yearlyIEP != null && yearlyIEP is Map) {
        final fromDate = DateTime.tryParse(yearlyIEP['from']?.toString() ?? '');
        final toDate = DateTime.tryParse(yearlyIEP['to']?.toString() ?? '');
        if (fromDate != null && toDate != null) {
          return '${fromDate.year}-${toDate.year}' == yearLabel;
        }
      }
      return false;
    }, orElse: () => <String, dynamic>{});
    final yearId = yearObj?['id']?.toString() ?? yearObj?['_id']?.toString();

    if (studentId == null || yearId == null) return;

    final termKeys = ['entry', 'term1', 'term2'];
    final termKey = termKeys[tabIndex];

    isGoalMonitoringLoading.value = true;
    try {
      final response =
          await _apiProvider.getTermStudentGoals(studentId, yearId, termKey);
      if (response.statusCode == 200) {
        final body = response.body;
        if (termKey == 'entry') {
          final yearIdStr = body['year']?.toString();
          if (yearIdStr != null && body['goals'] != null) {
            final goalsMap = body['goals'] as Map;
            if (goalsMap.containsKey(yearIdStr)) {
              baselineGoalsCache.value =
                  goalsMap[yearIdStr]?['entry'] as List? ?? [];
            }
          }
          if (body['goals'] != null) {
            final goalsMap = body['goals'] as Map;
            baselineDomainGoalsCache.clear();
            goalsMap.forEach((key, value) {
              if (value is Map && value.containsKey('entry')) {
                baselineDomainGoalsCache[key.toString()] =
                    value['entry'] as List? ?? [];
              }
            });
          }
        }
        goalMonitoringData.value = Map<String, dynamic>.from(body);
        prepareGoalMonitoringDomains();
      }
    } catch (e) {
      print('Exception fetching term goals: $e');
    } finally {
      isGoalMonitoringLoading.value = false;
    }
  }

  void prepareGoalMonitoringDomains() {
    if (goalMonitoringData.value == null) return;

    final termKeys = ['entry', 'term1', 'term2'];
    final termKey = termKeys[activeGoalTab.value];

    var answers = goalMonitoringData.value!['answer'] as Map?;
    var goals = goalMonitoringData.value!['goals'] as Map?;

    // Handle year-keyed response (Type B)
    final yearId = goalMonitoringData.value!['year']?.toString();
    if (yearId != null && answers != null && answers.containsKey(yearId)) {
      final yearAnswers = answers[yearId]?[termKey] as List?;
      final yearGoals = goals?[yearId]?[termKey] as List?;
      final baselineGoals = baselineGoalsCache;

      final List<Map<String, dynamic>> prepared = [];

      for (var domain in allNiepidDomains) {
        final List<Map<String, dynamic>> filteredQuestions = [];
        final questions = domain['questions'] as List? ?? [];

        for (var q in questions) {
          final qId = q['_id']?.toString() ?? q['id']?.toString() ?? "";

          final qAnswer = yearAnswers?.firstWhere(
              (a) => a['questionId']?.toString() == qId,
              orElse: () => null);

          // A goal should be shown if it has answers/goals for the current term OR if it was a goal in the baseline
          var qGoal = yearGoals?.firstWhere(
              (g) => g['questionId']?.toString() == qId,
              orElse: () => null);
          if (qGoal == null && baselineGoals.isNotEmpty) {
            qGoal = baselineGoals.firstWhere(
                (g) => g['questionId']?.toString() == qId,
                orElse: () => null);
          }

          if (qAnswer != null || qGoal != null) {
            final qData = Map<String, dynamic>.from(q);
            qData['assessmentAnswer'] = qAnswer;
            qData['goalData'] = qGoal;
            filteredQuestions.add(qData);
          }
        }

        if (filteredQuestions.isNotEmpty) {
          final domainCopy = Map<String, dynamic>.from(domain);
          domainCopy['questions'] = filteredQuestions;
          prepared.add(domainCopy);
        }
      }
      goalMonitoringDomains.assignAll(prepared);
      return;
    }

    // Handle domain-keyed response (Type A - verifyStudentGoals)
    final List<Map<String, dynamic>> prepared = [];
    for (var domain in allNiepidDomains) {
      final domainId =
          domain['_id']?.toString() ?? domain['id']?.toString() ?? "";
      final domainAnswers = answers?[domainId]?[termKey] as List?;
      final domainGoals = goals?[domainId]?[termKey] as List?;
      final baselineGoals = baselineDomainGoalsCache[domainId] ?? [];

      if ((domainAnswers != null && domainAnswers.isNotEmpty) ||
          (domainGoals != null && domainGoals.isNotEmpty) ||
          baselineGoals.isNotEmpty) {
        final questions = domain['questions'] as List? ?? [];
        final List<Map<String, dynamic>> filteredQuestions = [];

        for (var q in questions) {
          final qId = q['_id']?.toString() ?? q['id']?.toString() ?? "";
          final qAnswer = domainAnswers?.firstWhere(
              (a) => a['questionId']?.toString() == qId,
              orElse: () => null);

          var qGoal = domainGoals?.firstWhere(
              (g) => g['questionId']?.toString() == qId,
              orElse: () => null);
          if (qGoal == null && baselineGoals.isNotEmpty) {
            qGoal = baselineGoals.firstWhere(
                (g) => g['questionId']?.toString() == qId,
                orElse: () => null);
          }

          if (qAnswer != null || qGoal != null) {
            final qData = Map<String, dynamic>.from(q);
            qData['assessmentAnswer'] = qAnswer;
            qData['goalData'] = qGoal;
            filteredQuestions.add(qData);
          }
        }

        if (filteredQuestions.isNotEmpty) {
          final domainCopy = Map<String, dynamic>.from(domain);
          domainCopy['questions'] = filteredQuestions;
          prepared.add(domainCopy);
        }
      }
    }
    goalMonitoringDomains.assignAll(prepared);
  }

  String getStudentName() {
    return selectedGoalMonitoringStudent.value ?? 'N/A';
  }

  String getStudentAge() {
    final student = getGoalMonitoringStudentDetails();
    if (student == null) return 'N/A';
    final dob =
        student['dateOfBirth']?.toString() ?? student['dob']?.toString();
    return calculateAge(dob);
  }

  String getGoalStatus(String termKey) {
    return (goalMonitoringStatuses[termKey] ?? 'pending').toLowerCase();
  }

  Map<String, dynamic>? getGoalMonitoringStudentDetails() {
    final studentName = selectedGoalMonitoringStudent.value;
    if (studentName == null) return null;
    final allData = niepidStudentAssessments.value?['data'] as List?;
    return allData?.firstWhere((s) => s['studentName'] == studentName,
        orElse: () => null);
  }

  List<Map<String, dynamic>> getGoalsForTerm(String termKey) {
    if (goalMonitoringData.value == null) return [];
    final goalsMap = goalMonitoringData.value!['goals'];
    if (goalsMap is! Map) return [];

    List<Map<String, dynamic>> flattenedGoals = [];
    goalsMap.forEach((domainId, terms) {
      if (terms is Map && terms[termKey] is List) {
        flattenedGoals.addAll(List<Map<String, dynamic>>.from(terms[termKey]));
      }
    });
    return flattenedGoals;
  }

  Future<void> submitRework(String remarks) async {
    final student = getGoalMonitoringStudentDetails();
    final studentId = student?['studentId']?.toString() ??
        student?['id']?.toString() ??
        student?['_id']?.toString();
    if (studentId == null) return;

    final termKeys = ['entry', 'term1', 'term2'];
    final currentTerm = termKeys[activeGoalTab.value];

    isGoalMonitoringLoading.value = true;
    try {
      final response =
          await _apiProvider.revokeSubmission(studentId, currentTerm, remarks);
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Assessment sent for rework',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.withOpacity(0.1),
            colorText: Colors.orange);
        // Refresh data to update status
        fetchGoalMonitoring();
      } else {
        Get.snackbar('Error',
            'Failed to revoke submission: ${response.body?['message'] ?? response.statusText}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Exception revoking submission: $e');
      Get.snackbar('Error', 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGoalMonitoringLoading.value = false;
    }
  }

  Future<void> submitCareGiverAction({
    required String term,
    required String action,
    String? comment,
  }) async {
    if (filteredCareGiverStudents.isEmpty) return;

    final studentIds = filteredCareGiverStudents
        .map((s) =>
            s['studentId']?.toString() ??
            s['id']?.toString() ??
            s['_id']?.toString())
        .whereType<String>()
        .toList();

    isCareGiverLoading.value = true;
    try {
      final response = await _apiProvider.updateCareGiverStatus(
        term: term,
        action: action,
        studentIds: studentIds,
        comment: comment,
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Assessment status updated to $action',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green);
        // Refresh data
        fetchCareGiverMeetingData();
      } else {
        Get.snackbar('Error', 'Failed to update status',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Exception updating care giver status: $e');
    } finally {
      isCareGiverLoading.value = false;
    }
  }

  Future<void> submitApprove() async {
    final student = getGoalMonitoringStudentDetails();
    final studentId = student?['studentId']?.toString() ??
        student?['id']?.toString() ??
        student?['_id']?.toString();
    if (studentId == null) return;

    final termKeys = ['entry', 'term1', 'term2'];
    final currentTerm = termKeys[activeGoalTab.value];

    isGoalMonitoringLoading.value = true;
    try {
      final response =
          await _apiProvider.approveSubmission(studentId, currentTerm);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Assessment approved successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green);
        // Refresh data to update status
        fetchGoalMonitoring();
      } else {
        Get.snackbar('Error',
            'Failed to approve submission: ${response.body?['message'] ?? response.statusText}',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Exception approving submission: $e');
      Get.snackbar('Error', 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isGoalMonitoringLoading.value = false;
    }
  }

  var selectedStudentReportYearId = ''.obs;

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

  Future<void> downloadStudentReport(
    String studentId,
    String yearId,
    String term,
    String title, {
    bool withGoalDetails = true,
    String goalType = 'Both',
    bool withRemarks = true,
  }) async {
    try {
      Get.snackbar('Download', 'Fetching data for $title report...',
          snackPosition: SnackPosition.BOTTOM);
      final response =
          await _apiProvider.getStudentOverview(studentId, yearId, term);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body;
        // Log once so the field mapping below can be tuned to the real shape.
        print('DEBUG student-overview response: $data');

        final pdf = await _buildIepReportPdf(
          data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
          term: term,
          goalTypeFilter: goalType,
          withRemarks: withRemarks,
        );

        final file = await _savePdfToDownloads(pdf, studentId, term);
        if (file == null) return;

        print('PDF saved to: ${file.path}');
        Get.snackbar('Success', 'Report saved to Downloads:\n${file.path.split('/').last}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5));
      } else {
        Get.snackbar('Error', 'Failed to fetch data: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate PDF: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      print("Getting Error for PDF $e");
    }
  }

  // ─── PDF helpers ──────────────────────────────────────────────────────────

  /// Reads the first non-empty value among [keys] from [map].
  String _readField(Map map, List<String> keys, {String fallback = '-'}) {
    for (final k in keys) {
      final v = map[k];
      if (v != null && v.toString().trim().isNotEmpty && v.toString() != 'null') {
        return v.toString().trim();
      }
    }
    return fallback;
  }

  /// Extracts a flat list of goal rows grouped by domain from the overview
  /// response. Defensive about the exact JSON shape.
  List<Map<String, dynamic>> _extractGoalGroups(Map<String, dynamic> data) {
    final groups = <Map<String, dynamic>>[];

    // Find the goals container under a few likely keys.
    dynamic goalsRoot = data['goals'] ??
        data['goalList'] ??
        data['domains'] ??
        data['report'] ??
        data['data'];

    void addGoal(String domain, Map goal) {
      final domainGroup = groups.firstWhere(
        (g) => g['domain'] == domain,
        orElse: () {
          final g = <String, dynamic>{'domain': domain, 'goals': <Map>[]};
          groups.add(g);
          return g;
        },
      );
      (domainGroup['goals'] as List).add(goal);
    }

    Map<String, dynamic> normalizeGoal(Map g) {
      return {
        'name': _readField(g, ['goalName', 'question', 'name', 'goal'], fallback: ''),
        'grade': _readField(g, ['grade', 'mainOption', 'option', 'level'], fallback: '-'),
        'score': _readField(g, ['score', 'checkboxValue'], fallback: '-'),
        'goalType': _readField(g, ['goalType', 'type'], fallback: '-'),
        'remarks': _readField(g, ['remarks', 'remark', 'comment'], fallback: '-'),
      };
    }

    if (goalsRoot is List) {
      // Either a list of domain groups, or a flat list of goals.
      for (final item in goalsRoot) {
        if (item is Map) {
          final domain = _readField(
              item, ['domain', 'domainName', 'subdomain', 'title'],
              fallback: '');
          final inner = item['goals'] ?? item['questions'] ?? item['items'];
          if (inner is List) {
            for (final g in inner) {
              if (g is Map) addGoal(domain.isEmpty ? 'Goals' : domain, normalizeGoal(g));
            }
          } else {
            // Flat goal entry
            final d = domain.isEmpty ? 'Goals' : domain;
            addGoal(d, normalizeGoal(item));
          }
        }
      }
    } else if (goalsRoot is Map) {
      // Map keyed by domain name → list / term-map of goals.
      goalsRoot.forEach((domainKey, value) {
        final domain = domainKey.toString();
        if (value is List) {
          for (final g in value) {
            if (g is Map) addGoal(domain, normalizeGoal(g));
          }
        } else if (value is Map) {
          for (final termKey in ['entry', 'term1', 'term2']) {
            final list = value[termKey];
            if (list is List) {
              for (final g in list) {
                if (g is Map) addGoal(domain, normalizeGoal(g));
              }
            }
          }
        }
      });
    }

    return groups;
  }

  static const List<String> _romanNumerals = [
    'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
    'XI', 'XII', 'XIII', 'XIV', 'XV', 'XVI', 'XVII', 'XVIII', 'XIX', 'XX',
  ];

  String _toRoman(int n) =>
      (n >= 1 && n <= _romanNumerals.length) ? _romanNumerals[n - 1] : '$n';

  Future<pw.Document> _buildIepReportPdf(
    Map<String, dynamic> data, {
    required String term,
    required String goalTypeFilter,
    required bool withRemarks,
  }) async {
    final pdf = pw.Document();

    // Header / student details with multiple key fallbacks.
    final schoolName = _readField(
        data, ['schoolName', 'organisationName', 'instituteName'],
        fallback: (() {
      final org = profileData.value?['organisation'];
      if (org is Map) return (org['name'] ?? 'School').toString();
      return (profileData.value?['name'] ?? 'School').toString();
    })());

    final academicYear = _readField(
        data, ['academicYear', 'year', 'yearName'],
        fallback: selectedNiepidYear.value ?? '-');
    final studentName = _readField(data, ['studentName', 'name'], fallback: '-');
    final className = _readField(data, ['class', 'className', 'grade'], fallback: '-');
    final teacherName = _readField(data, ['teacherName', 'teacher'], fallback: '-');
    final enrollmentNo = _readField(
        data, ['enrollmentNo', 'enrollmentNumber', 'enrollment', 'admissionNo'],
        fallback: '-');

    final dateStr = _formatToday();

    // Try to load the app logo (optional, ignored if missing).
    pw.MemoryImage? logo;
    try {
      final bytes = await rootBundle.load('assets/images/logo.png');
      logo = pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      logo = null;
    }

    var goalGroups = _extractGoalGroups(data);

    // Apply goal-type filter (School / Home / Both).
    if (goalTypeFilter != 'Both') {
      for (final g in goalGroups) {
        (g['goals'] as List).retainWhere((goal) =>
            (goal['goalType'] ?? '').toString().toLowerCase() ==
            goalTypeFilter.toLowerCase());
      }
      goalGroups = goalGroups.where((g) => (g['goals'] as List).isNotEmpty).toList();
    }

    final headers = <String>[
      'No.',
      'Goal Name',
      'Grade',
      'Score',
      'Goal Type',
      if (withRemarks) 'Remarks',
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(32, 28, 32, 28),
        header: (context) => context.pageNumber == 1
            ? pw.SizedBox()
            : pw.SizedBox(),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'https://dashboard.divyangsarthi.in/all-reports',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.blue700),
          ),
        ),
        build: (context) => [
          // Date (top-left)
          pw.Text(dateStr, style: const pw.TextStyle(fontSize: 9)),
          pw.SizedBox(height: 16),
          // Logo centered
          if (logo != null)
            pw.Center(child: pw.Image(logo, width: 90))
          else
            pw.Center(
              child: pw.Text('DIVYANG SARTHI',
                  style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800)),
            ),
          pw.SizedBox(height: 18),
          // School name + IEP line
          pw.Center(
            child: pw.Text(schoolName,
                style: pw.TextStyle(fontSize: 20)),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'IEP for Academic Year: $academicYear | Term: $term',
              style: const pw.TextStyle(fontSize: 11),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 0.8, color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          // Student details
          _detailLine('Student: ', studentName),
          _detailLine('Class: ', className),
          _detailLine('Teacher: ', teacherName),
          _detailLine('Enrollment No: ', enrollmentNo),
          pw.SizedBox(height: 16),
          // Goals table
          _buildGoalsTable(headers, goalGroups, withRemarks),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _detailLine(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: label, style: const pw.TextStyle(fontSize: 11)),
            pw.TextSpan(
                text: value,
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildGoalsTable(
    List<String> headers,
    List<Map<String, dynamic>> goalGroups,
    bool withRemarks,
  ) {
    final colCount = headers.length;

    // Column widths.
    final columnWidths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(28), // No.
      1: const pw.FlexColumnWidth(4), // Goal Name
      2: const pw.FlexColumnWidth(1.6), // Grade
      3: const pw.FlexColumnWidth(1.4), // Score
      4: const pw.FlexColumnWidth(1.6), // Goal Type
      if (withRemarks) 5: const pw.FlexColumnWidth(1.4), // Remarks
    };

    final rows = <pw.TableRow>[];

    // Title row "Goals"
    rows.add(
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Goals',
                style: pw.TextStyle(
                    fontSize: 13, fontWeight: pw.FontWeight.bold)),
          ),
          for (int i = 1; i < colCount; i++) pw.SizedBox(),
        ],
      ),
    );

    // Header row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: headers
            .map((h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(h,
                      textAlign:
                          h == 'Goal Name' ? pw.TextAlign.left : pw.TextAlign.center,
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ))
            .toList(),
      ),
    );

    if (goalGroups.isEmpty) {
      rows.add(
        pw.TableRow(children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('No goals found.',
                style: const pw.TextStyle(fontSize: 10)),
          ),
          for (int i = 1; i < colCount; i++) pw.SizedBox(),
        ]),
      );
    }

    for (int d = 0; d < goalGroups.length; d++) {
      final group = goalGroups[d];
      final domain = group['domain']?.toString() ?? '';
      final goals = (group['goals'] as List);

      // Domain section row (spans visually as a bold label).
      rows.add(
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey50),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text('${_toRoman(d + 1)}. $domain',
                  style: pw.TextStyle(
                      fontSize: 10.5, fontWeight: pw.FontWeight.bold)),
            ),
            for (int i = 1; i < colCount; i++) pw.SizedBox(),
          ],
        ),
      );

      for (int gi = 0; gi < goals.length; gi++) {
        final goal = goals[gi] as Map;
        rows.add(
          pw.TableRow(
            children: [
              _cell('${gi + 1}', align: pw.TextAlign.center),
              _cell(goal['name']?.toString() ?? '-', align: pw.TextAlign.left),
              _cell(goal['grade']?.toString() ?? '-', align: pw.TextAlign.center),
              _cell(goal['score']?.toString() ?? '-', align: pw.TextAlign.center),
              _cell(goal['goalType']?.toString() ?? '-', align: pw.TextAlign.center),
              if (withRemarks)
                _cell(goal['remarks']?.toString() ?? '-',
                    align: pw.TextAlign.center),
            ],
          ),
        );
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
      columnWidths: columnWidths,
      children: rows,
    );
  }

  pw.Widget _cell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(text, textAlign: align, style: const pw.TextStyle(fontSize: 9.5)),
    );
  }

  String _formatToday() {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final yyyy = now.year.toString();
    return '$dd/$mm/$yyyy';
  }

  /// Saves [pdf] into the device's public Downloads folder, requesting
  /// storage permission as required by the Android version.
  Future<File?> _savePdfToDownloads(
      pw.Document pdf, String studentId, String term) async {
    Directory? directory;

    if (Platform.isAndroid) {
      // Request the right permission for the running Android version.
      final granted = await _ensureStoragePermission();
      if (!granted) {
        Get.snackbar('Permission required',
            'Storage permission is needed to save the report.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return null;
      }

      // Public Downloads directory.
      const downloadsPath = '/storage/emulated/0/Download';
      directory = Directory(downloadsPath);
      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }
    } else {
      directory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      Get.snackbar('Error', 'Could not access storage directory',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return null;
    }

    final fileName =
        'IEP_Report_${term}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // Android 13+: writing to public Downloads needs manage-external-storage
      // for arbitrary paths; try it, otherwise fall back to app storage.
      if (await Permission.manageExternalStorage.isGranted) return true;
      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    } else if (sdkInt >= 30) {
      // Android 11–12
      if (await Permission.manageExternalStorage.isGranted) return true;
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;
      // Fall back to legacy storage permission.
      return (await Permission.storage.request()).isGranted;
    } else {
      // Android 10 and below
      return (await Permission.storage.request()).isGranted;
    }
  }

  var isUpdatingEducator = false.obs;

  Future<bool> updateEducator({
    required String educatorId,
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String designation,
    required String qualification,
    required String cRRNumber,
  }) async {
    final org = profileData.value?['organisation'];
    String orgId = '';
    if (org is Map) {
      orgId = (org['id'] ?? org['_id'] ?? '').toString();
    } else if (org is String) {
      orgId = org;
    }

    isUpdatingEducator.value = true;
    try {
      final body = {
        "roles": "Educator",
        if (orgId.isNotEmpty) "organisation": orgId,
        "firstName": firstName,
        "lastName": lastName,
        "cRRNumber": cRRNumber,
        "email": email,
        "designation": designation,
        "mobile": mobile,
        "qualification": qualification,
        "isNipiedDisha": isNipiedDisha.value,
      };

      print('Update Educator Body request: $body');

      final response = await _apiProvider.updateEducator(educatorId, body);

      print('Update Educator Status: ${response.statusCode}');
      print('Update Educator Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchEducators(); // Refresh the list
        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar('Success', 'Educator updated successfully!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3));
        });
        return true;
      } else {
        Get.snackbar('Error', 'Failed to update educator',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        return false;
      }
    } catch (e) {
      print('Exception updating educator: $e');
      Get.snackbar('Error', 'An error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return false;
    } finally {
      isUpdatingEducator.value = false;
    }
  }

  Future<void> updateProfessionalStatus(
      String educatorId, bool isActive) async {
    try {
      isUpdatingProfessionalStatus.value = true;
      final response = isActive
          ? await _apiProvider.approveProfessional(educatorId)
          : await _apiProvider.disapproveProfessional(educatorId);

      print('Update Status (${isActive ? "Approve" : "Disapprove"}):');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchEducators(); // Refresh the list
        Get.snackbar(
          'Success',
          'Professional status updated to ${isActive ? "Active" : "Inactive"}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        final message = (response.body is Map)
            ? response.body['message'] ?? 'Failed to update status'
            : 'Failed to update status';
        Get.snackbar(
          'Error',
          message.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Exception updating status: $e');
      Get.snackbar(
        'Error',
        'An error occurred while updating status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingProfessionalStatus.value = false;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    // Phase 1: Confirmation Dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Are you sure you want to delete this PwID?'),
        content: const Text(
            'This action cannot be undone. The PwID will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No, cancel!'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showRemarksDialog(studentId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, delete it!',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRemarksDialog(String studentId) {
    final remarksController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Please provide remarks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Remarks (required)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                hintText: 'Enter your remarks here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (remarksController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Remarks are required',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white);
                return;
              }
              Get.back();
              _performStudentDelete(studentId, remarksController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performStudentDelete(String studentId, String remark) async {
    try {
      final response = await _apiProvider.deleteStudent(studentId, remark);
      print('Delete Student Status: ${response.statusCode}');
      print('Delete Student Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Record Deleted Successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        fetchStudents(); // Refresh the list
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.back(); // Go back from detail view to the list
        });
      } else {
        Get.snackbar(
            'Error', response.body?['message'] ?? 'Failed to delete record',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Exception deleting student: $e');
      Get.snackbar('Error', 'An error occurred',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }
}
