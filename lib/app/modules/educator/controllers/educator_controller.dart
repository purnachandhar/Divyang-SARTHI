import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // IEP Assessment Screen state
  var selectedIepAssessmentStudentId = ''.obs;
  var selectedIepLevel = ''.obs;

  // Goal Monitoring Screen state
  var selectedGoalMonitoringYearId = ''.obs;
  var selectedGoalMonitoringStudentId = ''.obs;
  var selectedGoalMonitoringTerm = 'entry'.obs; // entry, term1, term2
  var isLoadingGoalMonitoringQuestions = false.obs;
  var goalMonitoringDomains = <Map<String, dynamic>>[].obs;
  var goalMonitoringAnswers = <String, Map<String, dynamic>>{}.obs;
  var goalMonitoringRawData = <String, dynamic>{}.obs;
  var goalMonitoringStatuses =
      <String, String>{}.obs; // entry, term1, term2 status
  var allNiepidQuestions = <Map<String, dynamic>>[].obs;
  var termQuestionsCache =
      <String, List<Map<String, dynamic>>>{}.obs; // 'term1', 'term2' -> domains
  var goalMonitoringRawDataPerTerm = <String, Map<String, dynamic>>{}
      .obs; // 'entry', 'term1', 'term2' -> goals map
  var isSavingGoalMonitoringDraft = false.obs;
  var isSubmittingGoalMonitoring = false.obs;
  var isGoalMonitoringDataLoaded = false.obs;
  var isGoalMonitoringReviewComplete = false.obs;

  // Care Giver Meeting state
  var careGiverStudents = <dynamic>[].obs;
  var isLoadingCareGiverMeeting = false.obs;
  var selectedCareGiverYearId = ''.obs;

  // Learning Resources state
  var selectedLearningResourcesYearId = ''.obs;
  var selectedLearningResourcesStudentId = ''.obs;
  var isLoadingLearningResources = false.obs;
  var learningResourcesData = <String, dynamic>{}.obs;

  // Language Videos state
  var languageVideosData = <String, dynamic>{}.obs;
  var isLoadingLanguageVideos = false.obs;

  // Student Reports state
  var selectedStudentReportYearId = ''.obs;

  var allAssessmentDomains = <Map<String, dynamic>>[].obs;
  var assessmentDomains = <Map<String, dynamic>>[].obs;
  var isLoadingQuestions = false.obs;
  var isSavingDraft = false.obs;
  var assessmentAnswers = <String, Map<String, dynamic>>{}.obs;
  var goalRemarks = <String, String>{}.obs; // questionId -> remarks
  var usedPriorities = <int>{}.obs;
  var isReviewComplete = false.obs;
  var isSubmitting = false.obs;

  int getDomainTotalQuestionsCount(Map<String, dynamic> domain) {
    final qs = domain['questions'] as List?;
    return qs?.length ?? 0;
  }

  int getDomainAnsweredCount(Map<String, dynamic> domain) {
    int count = 0;
    final qs = domain['questions'] as List?;
    if (qs != null) {
      for (var q in qs) {
        final qId = q['_id']?.toString() ?? '';
        final ans = assessmentAnswers[qId];
        if (ans != null &&
            ans['mainOption'] != null &&
            ans['mainOption'].toString().isNotEmpty) {
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
        final qId = q['_id']?.toString() ?? '';
        final ans = assessmentAnswers[qId];
        if (ans != null && ans['isGoal'] == true) {
          count++;
        }
      }
    }
    return count;
  }

  bool get isAllGoalMonitoringAnswered {
    if (goalMonitoringDomains.isEmpty) return false;
    for (var domain in goalMonitoringDomains) {
      final questions = domain['questions'] as List? ?? [];
      for (var q in questions) {
        final qId = q['_id']?.toString() ?? '';
        final ans = goalMonitoringAnswers[qId];
        if (ans == null ||
            ans['mainOption'] == null ||
            ans['mainOption'].toString().isEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  bool get isAllIepQuestionsAnswered {
    if (assessmentDomains.isEmpty) return false;
    int totalQs = 0;
    int totalAns = 0;
    for (var domain in assessmentDomains) {
      totalQs += getDomainTotalQuestionsCount(domain);
      totalAns += getDomainAnsweredCount(domain);
    }
    return totalQs > 0 && totalAns == totalQs;
  }

  Map<String, dynamic>? get selectedIepStudentDetails {
    if (selectedIepAssessmentStudentId.value.isEmpty) return null;
    try {
      int idx = 0;
      return niepidStudentAssessments.firstWhere((s) {
        final id = s['studentId']?.toString() ??
            s['id']?.toString() ??
            s['_id']?.toString() ??
            'index_$idx';
        idx++;
        return id == selectedIepAssessmentStudentId.value;
      }, orElse: () => <String, dynamic>{}) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic>? get selectedGoalMonitoringStudentDetails {
    if (selectedGoalMonitoringStudentId.value.isEmpty) return null;
    try {
      int idx = 0;
      return niepidStudentAssessments.firstWhere((s) {
        final id = s['studentId']?.toString() ??
            s['id']?.toString() ??
            s['_id']?.toString() ??
            'index_$idx';
        idx++;
        return id == selectedGoalMonitoringStudentId.value;
      }, orElse: () => <String, dynamic>{}) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  int calculateAge(String? dobString) {
    if (dobString == null || dobString.isEmpty) return 0;
    try {
      DateTime dob;
      if (dobString.contains('-')) {
        final parts = dobString.split('-');
        if (parts[0].length == 4) {
          dob = DateTime.parse(dobString);
        } else {
          // Assuming DD-MM-YYYY
          dob = DateTime(
              int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } else if (dobString.contains('/')) {
        final parts = dobString.split('/');
        dob = DateTime(
            int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        return 0;
      }

      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

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
      debugPrint('Student API status: ${response.statusCode}');
      debugPrint('Student API body: ${response.body}');

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

        debugPrint('Parsed ${data.length} students from response');
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
      debugPrint('--- Current User Response ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('---------------------------');

      debugPrint(
          'Educater organisation id: ${currentEducator.value?.organisation?.id}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map<String, dynamic>) {
          final model =
              EducatorModel.fromJson(response.body as Map<String, dynamic>);
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
        debugPrint('Failed to fetch current user data.');
      }
    } catch (e) {
      debugPrint('Error fetching current user: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  Future<void> refreshDashboardData() async {
    await fetchCurrentUser();
    await fetchStudents();
  }

  Future<void> fetchNiepidDashboard() async {
    isLoadingDashboard.value = true;
    try {
      final response = await _apiProvider.getNiepidDishaDashboard();
      debugPrint('--- NIEPID Dashboard Response ---');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map) {
          niepidDashboardData.value = response.body as Map<String, dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Error fetching NIEPID dashboard: $e');
    } finally {
      isLoadingDashboard.value = false;
    }
  }

  Future<void> fetchNiepidStudentAssessments() async {
    isLoadingAssessments.value = true;
    try {
      final response = await _apiProvider.getNiepidStudentAssessments();
      debugPrint('--- NIEPID Student Assessments Response ---');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

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
      debugPrint('Error fetching NIEPID student assessments: $e');
    } finally {
      isLoadingAssessments.value = false;
    }
  }

  Future<void> fetchIepAcademicYears(String orgId) async {
    try {
      final response = await _apiProvider.getIepList(orgId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.body is List ? response.body : [];
        iepAcademicYears.value =
            data.map((e) => e as Map<String, dynamic>).toList();

        if (iepAcademicYears.isNotEmpty) {
          if (selectedIepYearId.value.isEmpty) {
            selectedIepYearId.value =
                iepAcademicYears.first['id']?.toString() ?? '';
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching IEP years: $e');
    }
  }

  Future<void> fetchStudentLearningResources() async {
    final studentId = selectedLearningResourcesStudentId.value;
    if (studentId.isEmpty) {
      learningResourcesData.clear();
      return;
    }

    isLoadingLearningResources.value = true;
    try {
      final response =
          await _apiProvider.getStudentLearningResources(studentId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map) {
          learningResourcesData.value =
              Map<String, dynamic>.from(response.body);
        } else {
          learningResourcesData.clear();
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load learning resources. Status: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not fetch learning resources: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingLearningResources.value = false;
    }
  }

  Future<void> fetchLanguageVideos() async {
    isLoadingLanguageVideos.value = true;
    try {
      final response = await _apiProvider.getVideosByLanguage();
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map) {
          languageVideosData.value = Map<String, dynamic>.from(response.body);
        } else {
          languageVideosData.clear();
        }
      } else {
        debugPrint('Failed to load language videos: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching language videos: $e');
    } finally {
      isLoadingLanguageVideos.value = false;
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

  void goToStudentReports() {
    selectedStudentReportYearId.value = ''; // Reset on open
    Get.toNamed('/educator/student-reports');
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

        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Text('$title Report\n\nData:\n$data'),
              );
            },
          ),
        );

        // Use app-scoped storage (no runtime permission needed on Android 11+)
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          Get.snackbar('Error', 'Could not access storage directory');
          return;
        }

        final fileName =
            'Student_${term}_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());

        print('PDF saved to: $path');
        Get.snackbar('Success', 'Report saved: $fileName',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4));
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
      print("Getting Error for PDF ${e}");
    }
  }

  Future<void> fetchAssessmentQuestions() async {
    // final orgId = currentEducator.value?.organisation?.id;
    final orgId = "68d4e4e20e437cd03453ccd8";
    final studentDetails = selectedIepStudentDetails;

    // if (orgId == null || orgId.isEmpty) {
    //   Get.snackbar('Error', 'Organisation not loaded yet. Please wait and try again.',
    //       snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    //   return;
    // }
    if (studentDetails == null) {
      Get.snackbar('Error', 'No student selected.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    final studentId = studentDetails['studentId']?.toString() ??
        studentDetails['id']?.toString() ??
        studentDetails['_id']?.toString();

    if (studentId == null || studentId.isEmpty) {
      Get.snackbar('Error', 'Invalid student ID',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    isLoadingQuestions.value = true;
    assessmentAnswers.clear(); // Clear old answers on new fetch
    usedPriorities.clear(); // Clear old priorities
    try {
      final response = await _apiProvider.getNiepidQuestions(orgId, studentId);
      final draftResponse = await _apiProvider.getStudentGoals(studentId);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map && response.body['domains'] is List) {
          final List<dynamic> rawDomains = response.body['domains'];

          // ── Debug: log first domain + first question keys to find ageGroup field
          if (rawDomains.isNotEmpty) {
            final d0 = rawDomains.first as Map;
            debugPrint('DEBUG domain keys: ${d0.keys.toList()}');
            final qs = d0['questions'] as List? ?? [];
            if (qs.isNotEmpty) {
              final q0 = qs.first as Map;
              debugPrint('DEBUG question keys: ${q0.keys.toList()}');
              debugPrint('DEBUG first question: $q0');
            }
          }

          allAssessmentDomains.value =
              rawDomains.map((e) => e as Map<String, dynamic>).toList();
          _applyIepLevelFilter();
        } else {
          allAssessmentDomains.clear();
          assessmentDomains.clear();
        }
      } else {
        Get.snackbar('Error',
            'Failed to fetch questions. Status: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }

      // Parse drafted goals using the actual JSON structure
      if (draftResponse.statusCode == 200 || draftResponse.statusCode == 201) {
        print('All Student goles ${draftResponse.body}');
        try {
          final body = draftResponse.body;
          if (body is Map) {
            // Build helper map for question options — use allAssessmentDomains so
            // options are resolved even when the age-group filter hides some questions.
            final qOptionsMap = <String, List<dynamic>>{};
            for (var d in allAssessmentDomains) {
              final qs = d['questions'] as List?;
              if (qs != null) {
                for (var q in qs) {
                  final qId = q['_id']?.toString() ?? '';
                  final opts = q['options'] as List?;
                  if (qId.isNotEmpty && opts != null) {
                    qOptionsMap[qId] = opts;
                  }
                }
              }
            }

            // Parse answers block
            if (body['answer'] is Map) {
              final answerMap = body['answer'] as Map;
              for (var domainEntries in answerMap.values) {
                if (domainEntries is Map) {
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

                          String scoreOpt =
                              ansItem['checkboxValue']?.toString() ?? '';

                          final existing =
                              assessmentAnswers[qId] ?? <String, dynamic>{};
                          if (mainOpt.isNotEmpty)
                            existing['mainOption'] = mainOpt;
                          if (scoreOpt.isNotEmpty && scoreOpt != 'null')
                            existing['score'] = scoreOpt;
                          assessmentAnswers[qId] = existing;
                        }
                      }
                    }
                  }
                }
              }
            }

            // Parse goals block
            if (body['goals'] is Map) {
              final goalsMap = body['goals'] as Map;
              for (var domainEntries in goalsMap.values) {
                if (domainEntries is Map) {
                  for (var termKey in ['entry', 'term1', 'term2']) {
                    final termList = domainEntries[termKey] as List?;
                    if (termList != null) {
                      for (var goalItem in termList) {
                        final qId = goalItem['questionId']?.toString();
                        if (goalItem['priority'] != null) {
                          final p =
                              int.tryParse(goalItem['priority'].toString());
                          if (p != null) usedPriorities.add(p);
                        }

                        if (qId != null &&
                            qId.isNotEmpty &&
                            goalItem['isGoal'] == true) {
                          final existing =
                              assessmentAnswers[qId] ?? <String, dynamic>{};
                          existing['isGoal'] = true;
                          existing['goalId'] = goalItem['_id'];
                          existing['priority'] = goalItem['priority'];
                          assessmentAnswers[qId] = existing;

                          // Load remarks if exists
                          if (goalItem['remarks'] != null &&
                              goalItem['remarks'].toString().isNotEmpty &&
                              goalItem['remarks'].toString() != 'null') {
                            goalRemarks[qId] = goalItem['remarks'].toString();
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
            debugPrint(
                'DEBUG: Pre-filled answers mapped: ${assessmentAnswers.length}');
          }
        } catch (e) {
          debugPrint('Error parsing draft goals: $e');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch questions: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoadingQuestions.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    ever(selectedGoalMonitoringTerm, (_) => _filterGoalMonitoringData());
    ever(selectedIepLevel, (_) => _applyIepLevelFilter());
    ever(selectedIepAssessmentStudentId, (_) => autoSetIepLevel());

    // Reset loaded state when student or year changes
    ever(selectedGoalMonitoringStudentId, (_) {
      isGoalMonitoringDataLoaded.value = false;
      isGoalMonitoringReviewComplete.value = false;
    });
    ever(selectedGoalMonitoringYearId, (_) {
      isGoalMonitoringDataLoaded.value = false;
      isGoalMonitoringReviewComplete.value = false;
    });
    ever(selectedGoalMonitoringTerm, (_) {
      isGoalMonitoringReviewComplete.value = false;
      _filterGoalMonitoringData();
    });
    ever(selectedLearningResourcesStudentId,
        (_) => fetchStudentLearningResources());
  }

  void autoSetIepLevel() {
    final details = selectedIepStudentDetails;
    if (details == null || details.isEmpty) {
      selectedIepLevel.value = '';
      return;
    }
    final dob = details['dateOfBirth']?.toString() ??
        details['dob']?.toString() ??
        details['date_of_birth']?.toString() ??
        details['DOB']?.toString();
    final age = calculateAge(dob);
    debugPrint('DEBUG autoSetIepLevel: dob=$dob age=$age');
    if (age >= 3 && age < 14) {
      selectedIepLevel.value = '3-14 years';
    } else if (age >= 14) {
      selectedIepLevel.value = '14-18 years';
    } else {
      selectedIepLevel.value = '';
    }
    debugPrint('DEBUG autoSetIepLevel: set level="${selectedIepLevel.value}"');
  }

  void _filterGoalMonitoringData() {
    final termKey = selectedGoalMonitoringTerm.value;
    final yearId = selectedGoalMonitoringYearId.value;

    // For term1 and term2, use the term-specific question list from cache
    if (termKey != 'entry') {
      final cachedDomains = termQuestionsCache[termKey];
      if (cachedDomains != null && cachedDomains.isNotEmpty) {
        goalMonitoringAnswers.clear();

        // 1. Get Baseline (entry) goals
        final baselineRaw = goalMonitoringRawDataPerTerm['entry'];
        if (baselineRaw != null && baselineRaw[yearId] is Map) {
          final entryList = baselineRaw[yearId]['entry'] as List?;
          if (entryList != null) {
            for (var goalItem in entryList) {
              final qId = goalItem['questionId']?.toString();
              if (qId != null && qId.isNotEmpty) {
                final selectedOpt =
                    goalItem['selectedOption']?.toString() ?? '';
                String grade = selectedOpt;
                String score = '';
                if (selectedOpt.contains(':')) {
                  final parts = selectedOpt.split(':');
                  grade = parts[0].trim();
                  score = parts.sublist(1).join(':').trim();
                }
                goalMonitoringAnswers[qId] = {
                  'mainOption': grade,
                  'score': score,
                  'goalType': goalItem['goalType'],
                  'goalName': goalItem['goalName'],
                  'remarks': goalItem['remarks'],
                };
              }
            }
          }
        }

        // 2. Override with current term goals
        final termRaw = goalMonitoringRawDataPerTerm[termKey];
        if (termRaw != null && termRaw[yearId] is Map) {
          final termList = termRaw[yearId][termKey] as List?;
          if (termList != null && termList.isNotEmpty) {
            for (var goalItem in termList) {
              final qId = goalItem['questionId']?.toString();
              if (qId != null &&
                  qId.isNotEmpty &&
                  goalMonitoringAnswers.containsKey(qId)) {
                final selectedOpt =
                    goalItem['selectedOption']?.toString() ?? '';
                String grade = selectedOpt;
                String score = '';
                if (selectedOpt.contains(':')) {
                  final parts = selectedOpt.split(':');
                  grade = parts[0].trim();
                  score = parts.sublist(1).join(':').trim();
                }
                final currentAns = goalMonitoringAnswers[qId] ?? {};
                currentAns['mainOption'] = grade;
                currentAns['score'] = score;
                if (goalItem['goalType'] != null)
                  currentAns['goalType'] = goalItem['goalType'];
                if (goalItem['remarks'] != null)
                  currentAns['remarks'] = goalItem['remarks'];
                goalMonitoringAnswers[qId] = currentAns;
              }
            }
          }
        }
        goalMonitoringDomains.value =
            List<Map<String, dynamic>>.from(cachedDomains);
        debugPrint(
            'DEBUG: Showing ${cachedDomains.length} domains for $termKey from cache');
      } else {
        goalMonitoringDomains.clear();
        debugPrint('DEBUG: No cached questions for $termKey yet');
      }
      return;
    }

    // --- Baseline (entry) logic ---
    final rawData = goalMonitoringRawDataPerTerm[termKey];
    if (rawData == null || allNiepidQuestions.isEmpty) return;

    goalMonitoringAnswers.clear();
    final Set<String> goalQuestionIds = {};

    final yearGoals = rawData[yearId];
    if (yearGoals is Map) {
      final entryList = yearGoals['entry'] as List?;
      if (entryList != null) {
        for (var goalItem in entryList) {
          final qId = goalItem['questionId']?.toString();
          if (qId != null && qId.isNotEmpty) {
            goalQuestionIds.add(qId);

            // Extract previously monitored values if they exist in the CURRENT term's goals list
            final selectedOpt = goalItem['selectedOption']?.toString() ?? '';
            String grade = selectedOpt;
            String score = '';
            if (selectedOpt.contains(':')) {
              final parts = selectedOpt.split(':');
              grade = parts[0].trim();
              score = parts.sublist(1).join(':').trim();
            }

            goalMonitoringAnswers[qId] = {
              'mainOption': grade,
              'score': score,
              'goalType': goalItem['goalType'],
              'goalName': goalItem['goalName'],
              'remarks': goalItem['remarks'],
            };
          }
        }
      }

      // Override with current term's saved values if they exist
      if (termKey != 'entry') {
        final currentTermList = yearGoals[termKey] as List?;
        if (currentTermList != null && currentTermList.isNotEmpty) {
          for (var goalItem in currentTermList) {
            final qId = goalItem['questionId']?.toString();
            if (qId != null &&
                qId.isNotEmpty &&
                goalQuestionIds.contains(qId)) {
              final selectedOpt = goalItem['selectedOption']?.toString() ?? '';
              String grade = selectedOpt;
              String score = '';
              if (selectedOpt.contains(':')) {
                final parts = selectedOpt.split(':');
                grade = parts[0].trim();
                score = parts.sublist(1).join(':').trim();
              }

              final currentAns = goalMonitoringAnswers[qId] ?? {};
              currentAns['mainOption'] = grade;
              currentAns['score'] = score;
              if (goalItem['goalType'] != null)
                currentAns['goalType'] = goalItem['goalType'];
              if (goalItem['remarks'] != null)
                currentAns['remarks'] = goalItem['remarks'];
              goalMonitoringAnswers[qId] = currentAns;
            }
          }
        }
      }
    }

    final List<Map<String, dynamic>> filteredDomains = [];
    final Set<String> processedGoalIds = {};

    for (var domain in allNiepidQuestions) {
      final List<dynamic> questions = domain['questions'] ?? [];
      final List<dynamic> filteredQuestions = questions.where((q) {
        final qId = q['_id']?.toString() ?? '';
        if (goalQuestionIds.contains(qId)) {
          processedGoalIds.add(qId);
          return true;
        }
        return false;
      }).toList();

      if (filteredQuestions.isNotEmpty) {
        final Map<String, dynamic> newDomain =
            Map<String, dynamic>.from(domain);
        newDomain['questions'] = filteredQuestions;
        newDomain['questionsCount'] = filteredQuestions.length;
        filteredDomains.add(newDomain);
      }
    }

    final remainingGoalIds =
        goalQuestionIds.where((id) => !processedGoalIds.contains(id)).toList();
    if (remainingGoalIds.isNotEmpty) {
      final List<dynamic> otherQuestions = [];
      for (var qId in remainingGoalIds) {
        final ans = goalMonitoringAnswers[qId];
        otherQuestions.add({
          '_id': qId,
          'question': ans?['goalName'] ?? 'Unknown Goal',
          'subdomain': 'Other Goals',
        });
      }
      filteredDomains.add({
        'domainName': 'Additional Goals',
        'domainIcon': '',
        'questions': otherQuestions,
        'questionsCount': otherQuestions.length,
      });
    }

    goalMonitoringDomains.value = filteredDomains;
    debugPrint(
        'DEBUG: Filtered ${goalMonitoringAnswers.length} goals for term: $termKey');
  }

  // All candidate field names the API might use for age group, in priority order.
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

  /// Returns the first non-empty age-group value found in [obj], or ''.
  String _ageGroupOf(Map obj) {
    for (final f in _ageGroupFields) {
      final v = obj[f];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim().toLowerCase();
      }
    }
    return '';
  }

  /// Case-insensitive check: does [fieldValue] describe [rangeOnly] (e.g. "3-14")?
  bool _ageGroupMatches(String fieldValue, String rangeOnly) {
    final fv = fieldValue.toLowerCase();
    final rv = rangeOnly.toLowerCase();
    // Direct contains in either direction covers "3-14", "3-14 years", "3 to 14" etc.
    return fv.contains(rv) || rv.contains(fv);
  }

  void _applyIepLevelFilter() {
    if (allAssessmentDomains.isEmpty) {
      assessmentDomains.clear();
      return;
    }

    final level = selectedIepLevel.value;
    if (level.isEmpty) {
      assessmentDomains.value = List.from(allAssessmentDomains);
      return;
    }

    // "3-14 years" → "3-14"
    final rangeOnly = level
        .replaceAll(RegExp(r'\s*years\s*', caseSensitive: false), '')
        .trim();

    // ── Auto-detect: scan questions to find which field is actually populated ──
    String? detectedField;
    outer:
    for (final domain in allAssessmentDomains) {
      for (final q in (domain['questions'] as List? ?? [])) {
        if (q is Map) {
          for (final f in _ageGroupFields) {
            final v = q[f];
            if (v != null && v.toString().trim().isNotEmpty) {
              detectedField = f;
              break outer;
            }
          }
        }
      }
    }

    debugPrint(
        'DEBUG IEP filter: level="$level" rangeOnly="$rangeOnly" detectedField=$detectedField');

    // If the API response has no age-group field at all, show everything.
    if (detectedField == null) {
      debugPrint(
          'DEBUG IEP filter: no ageGroup field found — showing all questions');
      assessmentDomains.value = List.from(allAssessmentDomains);
      return;
    }

    final filtered = <Map<String, dynamic>>[];
    for (final domain in allAssessmentDomains) {
      final domainAg = _ageGroupOf(domain);
      if (domainAg.isNotEmpty && !_ageGroupMatches(domainAg, rangeOnly))
        continue;

      final allQs = (domain['questions'] as List? ?? []);
      final filteredQs = allQs.where((q) {
        if (q is! Map) return true;
        final qAg = _ageGroupOf(q);
        return qAg.isEmpty || _ageGroupMatches(qAg, rangeOnly);
      }).toList();

      if (filteredQs.isNotEmpty) {
        final d = Map<String, dynamic>.from(domain);
        d['questions'] = filteredQs;
        d['questionsCount'] = filteredQs.length;
        filtered.add(d);
      }
    }

    debugPrint('DEBUG IEP filter: ${filtered.length} domains, '
        '${filtered.fold(0, (s, d) => s + ((d["questions"] as List?)?.length ?? 0))} questions');
    assessmentDomains.value = filtered;
  }

  Future<void> fetchGoalMonitoringQuestions() async {
    final orgId = '68d4e4e20e437cd03453ccd8';
    final studentId = selectedGoalMonitoringStudentId.value;
    final yearId = selectedGoalMonitoringYearId.value;

    if (studentId.isEmpty || yearId.isEmpty) {
      Get.snackbar('Error', 'Please select student and academic year',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange);
      return;
    }

    isLoadingGoalMonitoringQuestions.value = true;
    termQuestionsCache.clear();
    goalMonitoringRawDataPerTerm.clear();
    goalMonitoringStatuses.clear();

    try {
      // 1. Fetch Baseline (entry)
      final baselineQsRes =
          await _apiProvider.getNiepidQuestions(orgId, studentId);
      if (baselineQsRes.statusCode == 200 || baselineQsRes.statusCode == 201) {
        allNiepidQuestions.value = (baselineQsRes.body['domains'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final baselineDataRes = await _apiProvider.getGoalMonitoringTermData(
            studentId, yearId, 'entry');
        if (baselineDataRes.statusCode == 200 ||
            baselineDataRes.statusCode == 201) {
          final body = baselineDataRes.body;
          if (body is Map) {
            if (body['goals'] is Map)
              goalMonitoringRawDataPerTerm['entry'] =
                  Map<String, dynamic>.from(body['goals']);
            if (body['status'] is Map) _parseStatuses(body['status'], yearId);
          }
        }
      }

      // 2. If Baseline is Approved, fetch Term 1
      if (isTermTabEnabled('term1')) {
        final t1QsRes = await _apiProvider.getTermQuestions(
            orgId, studentId, yearId, 'term1');
        if (t1QsRes.statusCode == 200 || t1QsRes.statusCode == 201) {
          termQuestionsCache['term1'] = (t1QsRes.body['domains'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();

          final t1DataRes = await _apiProvider.getGoalMonitoringTermData(
              studentId, yearId, 'term1');
          if (t1DataRes.statusCode == 200 || t1DataRes.statusCode == 201) {
            final body = t1DataRes.body;
            if (body is Map) {
              if (body['goals'] is Map)
                goalMonitoringRawDataPerTerm['term1'] =
                    Map<String, dynamic>.from(body['goals']);
              if (body['status'] is Map) _parseStatuses(body['status'], yearId);
            }
          }
        }
      }

      // 3. If Term 1 is Approved, fetch Term 2
      if (isTermTabEnabled('term2')) {
        final t2QsRes = await _apiProvider.getTermQuestions(
            orgId, studentId, yearId, 'term2');
        if (t2QsRes.statusCode == 200 || t2QsRes.statusCode == 201) {
          termQuestionsCache['term2'] = (t2QsRes.body['domains'] as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();

          final t2DataRes = await _apiProvider.getGoalMonitoringTermData(
              studentId, yearId, 'term2');
          if (t2DataRes.statusCode == 200 || t2DataRes.statusCode == 201) {
            final body = t2DataRes.body;
            if (body is Map) {
              if (body['goals'] is Map)
                goalMonitoringRawDataPerTerm['term2'] =
                    Map<String, dynamic>.from(body['goals']);
              if (body['status'] is Map) _parseStatuses(body['status'], yearId);
            }
          }
        }
      }

      _filterGoalMonitoringData();
      isGoalMonitoringDataLoaded.value = true;
    } catch (e) {
      debugPrint('Error in fetchGoalMonitoringQuestions: $e');
    } finally {
      isLoadingGoalMonitoringQuestions.value = false;
    }
  }

  void _parseStatuses(dynamic statusMap, String yearId) {
    debugPrint('DEBUG _parseStatuses: raw map=$statusMap, yearId=$yearId');
    if (statusMap is Map) {
      // Check if it's a flat map (keys are directly entry, term1, term2)
      // or if it's nested under yearId
      final Map<String, dynamic> actualStatus;
      if (statusMap.containsKey('entry') || statusMap.containsKey('term1')) {
        actualStatus = Map<String, dynamic>.from(statusMap);
        debugPrint('DEBUG _parseStatuses: Using FLAT status map');
      } else if (statusMap[yearId] is Map) {
        actualStatus = Map<String, dynamic>.from(statusMap[yearId]);
        debugPrint(
            'DEBUG _parseStatuses: Using NESTED status map for year $yearId');
      } else {
        debugPrint(
            'DEBUG _parseStatuses: No matching status format found. Keys: ${statusMap.keys}');
        return;
      }

      goalMonitoringStatuses.assignAll({
        'entry': actualStatus['entry']?.toString() ??
            goalMonitoringStatuses['entry'] ??
            'N/A',
        'term1': actualStatus['term1']?.toString() ??
            goalMonitoringStatuses['term1'] ??
            'N/A',
        'term2': actualStatus['term2']?.toString() ??
            goalMonitoringStatuses['term2'] ??
            'N/A',
      });
      debugPrint(
          'DEBUG _parseStatuses: Updated goalMonitoringStatuses to $goalMonitoringStatuses');
    }
  }

  bool isTermTabEnabled(String termKey) {
    if (termKey == 'entry') return true;
    final entryStatus =
        (goalMonitoringStatuses['entry'] ?? '').toString().toLowerCase().trim();
    final term1Status =
        (goalMonitoringStatuses['term1'] ?? '').toString().toLowerCase().trim();

    debugPrint(
        'DEBUG isTermTabEnabled: term=$termKey entryStatus="$entryStatus" term1Status="$term1Status"');

    if (termKey == 'term1') {
      final canEnable = entryStatus.contains('approve');
      debugPrint('DEBUG isTermTabEnabled: term1 canEnable=$canEnable');
      return canEnable;
    }
    if (termKey == 'term2') {
      final canEnable = term1Status.contains('approve');
      debugPrint('DEBUG isTermTabEnabled: term2 canEnable=$canEnable');
      return canEnable;
    }
    return false;
  }

  Future<void> saveDraft() async {
    final studentDetails = selectedIepStudentDetails;
    if (studentDetails == null) {
      Get.snackbar('Error', 'No student selected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    final studentId = studentDetails['studentId']?.toString() ??
        studentDetails['id']?.toString() ??
        studentDetails['_id']?.toString();

    if (studentId == null || studentId.isEmpty) {
      Get.snackbar('Error', 'Invalid student ID',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (assessmentAnswers.isEmpty) {
      Get.snackbar('Warning', 'No assessment answers to save.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    // Use the actual academic year ID as the year field and as keys in the payload
    final String yearKey = selectedIepYearId.value.isNotEmpty
        ? selectedIepYearId.value
        : "unknown_year";

    final List<Map<String, dynamic>> allAnswersList = [];

    // Use allAssessmentDomains so answers are saved regardless of the active age-group filter.
    for (var domain in allAssessmentDomains) {
      final questions = domain['questions'] as List? ?? [];

      for (var q in questions) {
        final qId = q['_id']?.toString() ?? '';
        if (qId.isEmpty) continue;

        final optionsList = q['options'] as List? ?? [];
        final ans = assessmentAnswers[qId];
        if (ans == null) continue;

        final mainOptionStr = ans['mainOption']?.toString();
        if (mainOptionStr != null && mainOptionStr.isNotEmpty) {
          int optIndex =
              optionsList.indexWhere((o) => o.toString() == mainOptionStr);
          if (optIndex == -1) optIndex = 0;

          final scoreOpt = ans['score']?.toString();
          final answerItem = <String, dynamic>{
            "questionId": qId,
            "options": optIndex,
            "badgeSelections": [],
          };
          // Omit checkboxValue entirely when there is no score — sending null causes 400.
          if (scoreOpt != null && scoreOpt.isNotEmpty && scoreOpt != 'null') {
            answerItem["checkboxValue"] = scoreOpt;
          }
          allAnswersList.add(answerItem);
        }
      }
    }

    final Map<String, dynamic> goalsPayload = {};
    final List<Map<String, dynamic>> entryGoals = [];

    for (var entry in assessmentAnswers.entries) {
      if (entry.value['isGoal'] == true) {
        String qText = '';
        // Find question text for goalName
        for (var d in allAssessmentDomains) {
          final qs = d['questions'] as List?;
          final q = qs?.firstWhere((q) => q['_id']?.toString() == entry.key,
              orElse: () => null);
          if (q != null) {
            qText = q['question']?.toString() ?? '';
            break;
          }
        }

        entryGoals.add({
          "questionId": entry.key,
          "goalName": qText,
          "selectedOption": entry.value['mainOption'] ?? "",
          "goalType": [entry.value['goalType'] ?? "School"],
          "isGoal": true,
          "remarks": goalRemarks[entry.key] ?? ""
        });
      }
    }

    goalsPayload[yearKey] = {"entry": entryGoals, "term1": [], "term2": []};

    final payload = {
      "studentId": studentId,
      "year": yearKey,
      "goals": goalsPayload,
      "answer": {
        yearKey: {"entry": allAnswersList, "term1": [], "term2": []}
      },
      "activities": [],
    };

    isSavingDraft.value = true;
    try {
      final jsonPayload = jsonEncode(payload);
      debugPrint('DEBUG saveDraft payload: $jsonPayload');
      final response = await _apiProvider.saveStudentGoals(payload);
      debugPrint(
          'DEBUG saveDraft response: ${response.statusCode} — ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Assessment saved as draft successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        await fetchAssessmentQuestions();
      } else {
        final apiMsg = response.body is Map
            ? (response.body['message'] ??
                response.body['error'] ??
                response.body.toString())
            : response.body?.toString() ?? 'Unknown error';
        Get.snackbar('Error (${response.statusCode})', apiMsg.toString(),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 6));
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save draft: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isSavingDraft.value = false;
    }
  }

  void setAnswer(String questionId, String option) {
    final current = assessmentAnswers[questionId] ?? <String, dynamic>{};
    if (current['mainOption'] == option) {
      current.remove('mainOption');
      current.remove('score');
    } else {
      current['mainOption'] = option;
      if (option != 'Partially Independent') {
        current.remove('score');
      }
      // If Independent is selected, it cannot be a goal
      if (option == 'Independent') {
        current['isGoal'] = false;
      }
    }
    assessmentAnswers[questionId] = current;
    assessmentAnswers.refresh();
  }

  void setScore(String questionId, String score) {
    final current = assessmentAnswers[questionId] ?? <String, dynamic>{};
    if (current['score'] == score) {
      current.remove('score');
    } else {
      current['score'] = score;
    }
    assessmentAnswers[questionId] = current;
    assessmentAnswers.refresh();
  }

  void toggleGoal(String questionId) {
    final current = assessmentAnswers[questionId] ?? <String, dynamic>{};

    // Rule: Independent selection cannot be a goal
    if (current['mainOption'] == 'Independent') {
      Get.snackbar('Goal Selection',
          'Tasks marked as "Independent" cannot be set as goals.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    bool isGoal = !(current['isGoal'] ?? false);
    current['isGoal'] = isGoal;
    if (isGoal && current['goalType'] == null) {
      current['goalType'] = 'School';
    }
    assessmentAnswers[questionId] = current;
    assessmentAnswers.refresh();
  }

  void showGoalDetailsDialog(String questionId) {
    final remarkController =
        TextEditingController(text: goalRemarks[questionId] ?? '');
    final charCount = (remarkController.text.length).obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Goal Details',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add details :',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            TextField(
              controller: remarkController,
              maxLines: 4,
              maxLength: 300,
              onChanged: (val) => charCount.value = val.length,
              decoration: InputDecoration(
                hintText: 'Enter your remark here...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                counterText: '',
              ),
            ),
            const SizedBox(height: 4),
            Obx(() => Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${charCount.value} / (max-300)',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            charCount.value > 300 ? Colors.red : Colors.grey),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              goalRemarks[questionId] = remarkController.text;
              Get.back();
              Get.snackbar('Success', 'Goal details updated',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Map<String, String> getGoalRemarksFromAllTerms(String questionId) {
    final Map<String, String> remarks = {};
    final yearId = selectedGoalMonitoringYearId.value;
    final terms = ['entry', 'term1', 'term2'];

    for (var term in terms) {
      final rawData = goalMonitoringRawDataPerTerm[term];
      if (rawData != null && rawData[yearId] is Map) {
        final termList = rawData[yearId][term] as List?;
        if (termList != null) {
          for (var item in termList) {
            if (item['questionId']?.toString() == questionId) {
              final rem = item['remarks']?.toString();
              if (rem != null && rem.trim().isNotEmpty && rem != 'null') {
                remarks[term] = rem;
              }
              break;
            }
          }
        }
      }
    }
    return remarks;
  }

  void showGoalMonitoringRemarksDialog(String questionId, String questionText) {
    final currentTerm = selectedGoalMonitoringTerm.value;
    final termStatus =
        (goalMonitoringStatuses[currentTerm] ?? '').toLowerCase();
    final isPending = termStatus == 'pending' || termStatus == 'rework';

    final allRemarks = getGoalRemarksFromAllTerms(questionId);

    final List<String> allowedTerms = [];
    if (currentTerm == 'entry') {
      allowedTerms.add('entry');
    } else if (currentTerm == 'term1') {
      allowedTerms.addAll(['entry', 'term1']);
    } else if (currentTerm == 'term2') {
      allowedTerms.addAll(['entry', 'term1', 'term2']);
    }

    // Get current remark from local edits if any, otherwise from allRemarks
    final currentAns = goalMonitoringAnswers[questionId] ?? {};
    final localRemark =
        currentAns['remarks']?.toString() ?? allRemarks[currentTerm] ?? '';

    final remarkController = TextEditingController(text: localRemark);
    final charCount = (remarkController.text.length).obs;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Goal Details',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(questionText,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 16),
                ...allowedTerms.map((term) {
                  String title = term == 'entry'
                      ? 'Baseline Goals'
                      : (term == 'term1' ? 'Term 1 Goals' : 'Term 2 Goals');

                  if (term == currentTerm && isPending) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.blue)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: remarkController,
                          maxLines: 4,
                          maxLength: 300,
                          onChanged: (val) => charCount.value = val.length,
                          decoration: InputDecoration(
                            hintText: 'Enter goal details here...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${charCount.value} / (max-300)',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: charCount.value > 300
                                        ? Colors.red
                                        : Colors.grey),
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],
                    );
                  }

                  String remark = allRemarks[term] ?? '';
                  if (term == currentTerm) {
                    remark = currentAns['remarks']?.toString() ?? remark;
                  }

                  if (remark.trim().isEmpty) {
                    remark = 'No goal details available.';
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue)),
                        const SizedBox(height: 6),
                        Text(remark,
                            style: TextStyle(
                                fontSize: 13,
                                color: remark == 'No goal details available.'
                                    ? Colors.grey
                                    : Colors.black87)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
          if (isPending)
            ElevatedButton(
              onPressed: () {
                final ans = Map<String, dynamic>.from(
                    goalMonitoringAnswers[questionId] ?? {});
                ans['remarks'] = remarkController.text;
                goalMonitoringAnswers[questionId] = ans;
                Get.back();
                Get.snackbar('Success', 'Goal details updated',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  void toggleGoalType(String questionId) {
    final current = assessmentAnswers[questionId] ?? <String, dynamic>{};
    if (current['isGoal'] == true) {
      current['goalType'] = current['goalType'] == 'Home' ? 'School' : 'Home';
      assessmentAnswers[questionId] = current;
      assessmentAnswers.refresh();
    }
  }

  Future<void> reviewAssessment() async {
    // 1. Identify goals from local state (don't call API yet)
    final List<Map<String, dynamic>> goalsToReview = [];
    for (var entry in assessmentAnswers.entries) {
      if (entry.value['isGoal'] == true) {
        String qText = 'Unknown Question';
        // Find question text from domains
        for (var d in allAssessmentDomains) {
          final qs = d['questions'] as List?;
          final q = qs?.firstWhere((q) => q['_id']?.toString() == entry.key,
              orElse: () => null);
          if (q != null) {
            qText = q['question']?.toString() ?? qText;
            break;
          }
        }
        goalsToReview.add({
          'id': entry.key,
          'question': qText,
          'goalType': entry.value['goalType'] ?? 'School',
        });
      }
    }

    if (goalsToReview.isEmpty) {
      Get.snackbar('Review', 'No goals selected to review.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    // 3. Show dialog
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Color(0xFF64B5F6)]),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: const Row(
            children: [
              Icon(Icons.rate_review, color: Colors.white),
              SizedBox(width: 12),
              Text('Review Goals',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                    'Please verify the goals identified from this assessment.',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: goalsToReview.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final goal = goalsToReview[index];
                    final qId = goal['id'];

                    return Obx(() {
                      final currentData = assessmentAnswers[qId] ?? {};
                      final gType = currentData['goalType'] ?? 'School';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal['question'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => toggleGoalType(qId),
                              child: Row(
                                children: [
                                  const Text('Goal Type: ',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: gType == 'School'
                                          ? Colors.blue.shade50
                                          : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: gType == 'School'
                                              ? Colors.blue.shade200
                                              : Colors.green.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          gType == 'School'
                                              ? Icons.school
                                              : Icons.home,
                                          size: 12,
                                          color: gType == 'School'
                                              ? Colors.blue
                                              : Colors.green.shade800,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          gType == 'School'
                                              ? 'School Goal'
                                              : 'Home Goal',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: gType == 'School'
                                                ? Colors.blue
                                                : Colors.green.shade800,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.sync,
                                            size: 10, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Get.back();
                    await saveDraft(); // Save again if types were toggled
                    isReviewComplete.value = true;
                    Get.snackbar(
                        'Success', 'Goals confirmed and saved successfully!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Save',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> submitAssessment() async {
    final studentDetails = selectedIepStudentDetails;
    if (studentDetails == null) return;

    final studentId = studentDetails['studentId']?.toString() ??
        studentDetails['id']?.toString() ??
        studentDetails['_id']?.toString();

    final String yearKey = selectedIepYearId.value.isNotEmpty
        ? selectedIepYearId.value
        : "unknown_year";

    if (studentId == null || studentId.isEmpty) {
      Get.snackbar('Error', 'Invalid student ID',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final payload = {
      "studentId": studentId,
      "year": yearKey,
      "status": {"entry": "submitted"}
    };

    isSubmitting.value = true;
    try {
      final response = await _apiProvider.saveStudentGoals(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Assessment submitted successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        // Update local status in the list so UI updates immediately
        final index = niepidStudentAssessments.indexWhere((s) {
          final id = s['studentId']?.toString() ??
              s['id']?.toString() ??
              s['_id']?.toString();
          return id == studentId;
        });

        if (index != -1) {
          final student =
              Map<String, dynamic>.from(niepidStudentAssessments[index]);
          if (student['status'] == null) student['status'] = {};
          student['status']['entry'] = 'submitted';
          niepidStudentAssessments[index] = student;
          niepidStudentAssessments.refresh();
        }

        isReviewComplete.value = false; // Reset for next time
      } else {
        Get.snackbar('Error', 'Failed to submit: ${response.body}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Submission error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
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

  void goToIepAssessment() {
    Get.toNamed('/educator-iep-assessment');
  }

  void goToGoalMonitoring() {
    Get.toNamed('/educator-goal-monitoring');
  }

  void viewStudentDetail(Map<String, dynamic> student) {
    Get.toNamed('/educator-student-detail', arguments: student);
  }

  Future<void> performStudentLogin(String userName, String dob) async {
    isLoggingInStudent.value = true;
    try {
      final response = await _apiProvider.studentLogin(userName, dob);
      debugPrint('Student login response status: ${response.statusCode}');
      debugPrint('Student login response body: ${response.body}');

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

  void goToCareGiverMeeting() {
    Get.toNamed('/educator-care-giver-meeting');
  }

  Future<void> fetchCareGiverMeetingData() async {
    isLoadingCareGiverMeeting.value = true;
    careGiverStudents.clear();
    try {
      final response = await _apiProvider.getCareGiverMeetingData();
      debugPrint('--- Care Giver Meeting Response ---');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map) {
          final students = response.body['students'];
          if (students is List) {
            careGiverStudents.value = students;
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to load care giver meeting data',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('Error fetching care giver meeting data: $e');
      Get.snackbar('Error', 'Could not load data: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoadingCareGiverMeeting.value = false;
    }
  }

  void setGoalMonitoringAnswer(String questionId, String option) {
    final current = goalMonitoringAnswers[questionId] ?? <String, dynamic>{};
    if (current['mainOption'] == option) {
      current.remove('mainOption');
      current.remove('score');
    } else {
      current['mainOption'] = option;
      if (option != 'Partially Independent') {
        current.remove('score');
      }
    }
    goalMonitoringAnswers[questionId] = current;
    goalMonitoringAnswers.refresh();
  }

  void setGoalMonitoringScore(String questionId, String score) {
    final current = goalMonitoringAnswers[questionId] ?? <String, dynamic>{};
    current['score'] = score;
    goalMonitoringAnswers[questionId] = current;
    goalMonitoringAnswers.refresh();
  }

  Future<void> saveGoalMonitoringDraft() async {
    final studentId = selectedGoalMonitoringStudentId.value;
    final yearId = selectedGoalMonitoringYearId.value;
    final term = selectedGoalMonitoringTerm.value;

    if (studentId.isEmpty || yearId.isEmpty) return;

    final List<Map<String, dynamic>> goalsList = [];

    goalMonitoringAnswers.forEach((qId, ans) {
      final grade = ans['mainOption']?.toString() ?? '';
      final score = ans['score']?.toString() ?? '';
      if (grade.isNotEmpty) {
        final combinedVal = score.isNotEmpty ? "$grade : $score" : grade;

        goalsList.add({
          "questionId": qId,
          "goalName": ans['goalName'] ?? 'Unknown Goal',
          "selectedOption": combinedVal,
          "goalType": ans['goalType'] is List
              ? ans['goalType']
              : [ans['goalType'] ?? "School"],
          "isGoal": true,
          "remarks": ans['remarks'] ?? ""
        });
      }
    });

    final payload = {
      "studentId": studentId,
      "year": yearId,
      "goals": {
        yearId: {
          "entry": term == 'entry' ? goalsList : [],
          "term1": term == 'term1' ? goalsList : [],
          "term2": term == 'term2' ? goalsList : [],
        }
      },
    };

    isSavingGoalMonitoringDraft.value = true;
    try {
      final response = await _apiProvider.saveStudentGoals(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Goal progress saved successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        await fetchGoalMonitoringQuestions(); // Refresh statuses and data
      } else {
        Get.snackbar('Error', 'Failed to save: ${response.body}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Save error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isSavingGoalMonitoringDraft.value = false;
    }
  }

  Future<void> submitGoalMonitoring() async {
    if (!isGoalMonitoringReviewComplete.value) {
      Get.snackbar('Error', 'Please review the goals before submitting.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    final studentId = selectedGoalMonitoringStudentId.value;
    final yearId = selectedGoalMonitoringYearId.value;
    final term = selectedGoalMonitoringTerm.value;

    if (studentId.isEmpty || yearId.isEmpty) return;

    // First save the current data
    await saveGoalMonitoringDraft();

    // Then send the submit status payload
    final payload = {
      "studentId": studentId,
      "year": yearId,
      "status": {term: "submitted"}
    };

    isSubmittingGoalMonitoring.value = true;
    try {
      final response = await _apiProvider.saveStudentGoals(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Goal progress submitted successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        await fetchGoalMonitoringQuestions();
      } else {
        Get.snackbar('Error', 'Failed to submit: ${response.body}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Submission error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isSubmittingGoalMonitoring.value = false;
    }
  }

  void resetGoalMonitoring() {
    goalMonitoringAnswers.clear();
    goalMonitoringAnswers.refresh();
  }

  void toggleGoalMonitoringType(String questionId) {
    final current = goalMonitoringAnswers[questionId] ?? <String, dynamic>{};
    final gRaw = current['goalType'];
    final gStr = gRaw is List
        ? (gRaw.isNotEmpty ? gRaw.first.toString() : 'School')
        : (gRaw?.toString() ?? 'School');
    current['goalType'] = gStr == 'Home' ? 'School' : 'Home';
    goalMonitoringAnswers[questionId] = current;
    goalMonitoringAnswers.refresh();
  }

  void reviewGoalMonitoring() {
    final List<Map<String, dynamic>> goalsToReview = [];
    for (var domain in goalMonitoringDomains) {
      final questions = domain['questions'] as List? ?? [];
      for (var q in questions) {
        final qId = q['_id']?.toString() ?? '';
        final ans = goalMonitoringAnswers[qId];
        if (ans != null) {
          goalsToReview.add({
            'id': qId,
            'question':
                ans['goalName'] ?? q['question']?.toString() ?? 'Unknown Goal',
            'goalType': ans['goalType'] ?? 'School',
          });
        }
      }
    }

    if (goalsToReview.isEmpty) {
      Get.snackbar('Review', 'No monitored goals to review.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white);
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Color(0xFF64B5F6)]),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: const Row(
            children: [
              Icon(Icons.rate_review, color: Colors.white),
              SizedBox(width: 12),
              Text('Review Goals',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Verify the goal types for this term.',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: goalsToReview.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final goal = goalsToReview[index];
                    final qId = goal['id'];

                    return Obx(() {
                      final currentData = goalMonitoringAnswers[qId] ?? {};
                      final gRaw = currentData['goalType'];
                      final gType = gRaw is List
                          ? (gRaw.isNotEmpty ? gRaw.first.toString() : 'School')
                          : (gRaw?.toString() ?? 'School');

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal['question'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => toggleGoalMonitoringType(qId),
                              child: Row(
                                children: [
                                  const Text('Goal Type: ',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: gType == 'School'
                                          ? Colors.blue.shade50
                                          : Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: gType == 'School'
                                              ? Colors.blue.shade200
                                              : Colors.green.shade200),
                                    ),
                                    child: Text(gType,
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: gType == 'School'
                                                ? Colors.blue.shade700
                                                : Colors.green.shade700)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              isGoalMonitoringReviewComplete.value = true;
              Get.back();
              Get.snackbar('Success', 'Review complete. You can now submit.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save & Complete',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> saveCareGiverMeetingDraft({
    required String term,
    required Map<String, String?> studentStatuses,
  }) async {
    isLoadingCareGiverMeeting.value = true;
    try {
      final List<Map<String, dynamic>> studentsList = [];
      studentStatuses.forEach((studentId, status) {
        if (status != null && status.isNotEmpty) {
          studentsList.add({
            "studentId": studentId,
            "meetingstatus": status,
          });
        }
      });

      final payload = {
        "term": term,
        "students": studentsList,
      };

      final response = await _apiProvider.saveCareGiverMeeting(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
            'Success', 'Caregiver meeting statuses saved successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        await fetchCareGiverMeetingData();
      } else {
        Get.snackbar('Error', 'Failed to save caregiver meeting statuses.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Save error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoadingCareGiverMeeting.value = false;
    }
  }

  Future<void> submitCareGiverMeeting({
    required String term,
    required Map<String, String?> studentStatuses,
  }) async {
    isLoadingCareGiverMeeting.value = true;
    try {
      final List<Map<String, dynamic>> studentsList = [];
      studentStatuses.forEach((studentId, status) {
        if (status != null && status.isNotEmpty) {
          studentsList.add({
            "studentId": studentId,
            "meetingstatus": status,
          });
        }
      });

      final payload = {
        "term": term,
        "students": studentsList,
      };

      final response = await _apiProvider.submitCareGiverMeeting(payload);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Caregiver meeting submitted successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        await fetchCareGiverMeetingData();
      } else {
        Get.snackbar('Error', 'Failed to submit caregiver meeting.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Submission error: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoadingCareGiverMeeting.value = false;
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('user_id');
    Get.offAllNamed('/login');
  }
}
