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
  var goalMonitoringStatuses = <String, String>{}.obs; // entry, term1, term2 status
  var allNiepidQuestions = <Map<String, dynamic>>[].obs;
  var termQuestionsCache = <String, List<Map<String, dynamic>>>{}.obs; // 'term1', 'term2' -> domains
  
  var assessmentDomains = <Map<String, dynamic>>[].obs;
  var isLoadingQuestions = false.obs;
  var isSavingDraft = false.obs;
  var assessmentAnswers = <String, Map<String, dynamic>>{}.obs;
  var usedPriorities = <int>{}.obs;

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
        if (ans != null && ans['mainOption'] != null && ans['mainOption'].toString().isNotEmpty) {
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
          dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } else if (dobString.contains('/')) {
        final parts = dobString.split('/');
        dob = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        return 0;
      }
      
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
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
      
      print('Educater organisation id: ${currentEducator.value?.organisation?.id}');
      

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

  Future<void> fetchAssessmentQuestions() async {
    // final orgId = currentEducator.value?.organisation?.id;
    final orgId = '68d4e4e20e437cd03453ccd8';
    final studentDetails = selectedIepStudentDetails;
    
    if (orgId == null || studentDetails == null) {
      Get.snackbar('Error', 'Missing organisation or student details',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    final studentId = studentDetails['studentId']?.toString() ??
                   studentDetails['id']?.toString() ??
                   studentDetails['_id']?.toString();
                   
    if (studentId == null || studentId.isEmpty) {
      Get.snackbar('Error', 'Invalid student ID',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
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
          assessmentDomains.value = rawDomains.map((e) => e as Map<String, dynamic>).toList();
        } else {
          assessmentDomains.clear();
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch questions. Status: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }

      // Parse drafted goals using the actual JSON structure
      if (draftResponse.statusCode == 200 || draftResponse.statusCode == 201) {
        try {
          final body = draftResponse.body;
          if (body is Map) {
            // Build helper map for question options
            final qOptionsMap = <String, List<dynamic>>{};
            for (var d in assessmentDomains) {
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
                          
                          String scoreOpt = ansItem['checkboxValue']?.toString() ?? '';
                          
                          final existing = assessmentAnswers[qId] ?? <String, dynamic>{};
                          if (mainOpt.isNotEmpty) existing['mainOption'] = mainOpt;
                          if (scoreOpt.isNotEmpty && scoreOpt != 'null') existing['score'] = scoreOpt;
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
                          final p = int.tryParse(goalItem['priority'].toString());
                          if (p != null) usedPriorities.add(p);
                        }
                        
                        if (qId != null && qId.isNotEmpty && goalItem['isGoal'] == true) {
                          final existing = assessmentAnswers[qId] ?? <String, dynamic>{};
                          existing['isGoal'] = true;
                          existing['goalId'] = goalItem['_id'];
                          existing['priority'] = goalItem['priority'];
                          assessmentAnswers[qId] = existing;
                        }
                      }
                    }
                  }
                }
              }
            }
            print('DEBUG: Pre-filled answers mapped: ${assessmentAnswers.length}');
          }
        } catch (e) {
          print('Error parsing draft goals: $e');
        }
      }
      
    } catch (e) {
      Get.snackbar('Error', 'Could not fetch questions: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingQuestions.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to term changes to refresh the monitoring list
    ever(selectedGoalMonitoringTerm, (_) => _filterGoalMonitoringData());
  }

  void _filterGoalMonitoringData() {
    final termKey = selectedGoalMonitoringTerm.value;
    final yearId = selectedGoalMonitoringYearId.value;

    // For term1 and term2, use the term-specific question list from cache
    if (termKey != 'entry') {
      final cachedDomains = termQuestionsCache[termKey];
      if (cachedDomains != null && cachedDomains.isNotEmpty) {
        goalMonitoringAnswers.clear();
        // Overlay goals data onto the term questions
        final yearGoals = goalMonitoringRawData[yearId];
        if (yearGoals is Map) {
          final termList = yearGoals[termKey] as List?;
          if (termList != null) {
            for (var goalItem in termList) {
              final qId = goalItem['questionId']?.toString();
              if (qId != null && qId.isNotEmpty) {
                final selectedOpt = goalItem['selectedOption']?.toString() ?? 'N/A';
                String grade = selectedOpt;
                String score = 'N/A';
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
                };
              }
            }
          }
        }
        goalMonitoringDomains.value = List<Map<String, dynamic>>.from(cachedDomains);
        print('DEBUG: Showing ${cachedDomains.length} domains for $termKey from cache');
      } else {
        goalMonitoringDomains.clear();
        print('DEBUG: No cached questions for $termKey yet');
      }
      return;
    }

    // --- Baseline (entry) logic ---
    if (goalMonitoringRawData.isEmpty || allNiepidQuestions.isEmpty) return;

    goalMonitoringAnswers.clear();
    final Set<String> goalQuestionIds = {};

    final yearGoals = goalMonitoringRawData[yearId];
    if (yearGoals is Map) {
      final termList = yearGoals[termKey] as List?;
      if (termList != null) {
        for (var goalItem in termList) {
          final qId = goalItem['questionId']?.toString();
          if (qId != null && qId.isNotEmpty) {
            goalQuestionIds.add(qId);
            final selectedOpt = goalItem['selectedOption']?.toString() ?? 'N/A';
            String grade = selectedOpt;
            String score = 'N/A';
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
            };
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
        final Map<String, dynamic> newDomain = Map<String, dynamic>.from(domain);
        newDomain['questions'] = filteredQuestions;
        newDomain['questionsCount'] = filteredQuestions.length;
        filteredDomains.add(newDomain);
      }
    }

    final remainingGoalIds = goalQuestionIds.where((id) => !processedGoalIds.contains(id)).toList();
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
    print('DEBUG: Filtered ${goalMonitoringAnswers.length} goals for term: $termKey');
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
    try {
      // Fetch the full question bank (entry) + term1 and term2 questions in parallel
      final results = await Future.wait([
        _apiProvider.getNiepidQuestions(orgId, studentId),
        _apiProvider.getTermQuestions(orgId, studentId, yearId, 'term1'),
        _apiProvider.getTermQuestions(orgId, studentId, yearId, 'term2'),
      ]);
      final response = results[0];
      final term1Response = results[1];
      final term2Response = results[2];

      // Cache term1 domains
      if (term1Response.statusCode == 200 || term1Response.statusCode == 201) {
        if (term1Response.body is Map && term1Response.body['domains'] is List) {
          termQuestionsCache['term1'] = (term1Response.body['domains'] as List)
              .map((e) => e as Map<String, dynamic>).toList();
          print('DEBUG: Cached ${termQuestionsCache["term1"]?.length} domains for term1');
        }
      }
      // Cache term2 domains
      if (term2Response.statusCode == 200 || term2Response.statusCode == 201) {
        if (term2Response.body is Map && term2Response.body['domains'] is List) {
          termQuestionsCache['term2'] = (term2Response.body['domains'] as List)
              .map((e) => e as Map<String, dynamic>).toList();
          print('DEBUG: Cached ${termQuestionsCache["term2"]?.length} domains for term2');
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body is Map && response.body['domains'] is List) {
          allNiepidQuestions.value = (response.body['domains'] as List).map((e) => e as Map<String, dynamic>).toList();
          
          // Call the correct endpoint: /niepid-disha-assessment/user/{studentId}/{yearId}/entry
          final draftResponse = await _apiProvider.getGoalMonitoringData(studentId, yearId);
          print('DEBUG: Goal Monitoring Data status: ${draftResponse.statusCode}');
          if (draftResponse.statusCode == 200 || draftResponse.statusCode == 201) {
            final body = draftResponse.body;
            if (body is Map) {
              if (body['goals'] is Map) {
                goalMonitoringRawData.value = Map<String, dynamic>.from(body['goals']);
              }
              
              // Parse status block
              if (body['status'] is Map) {
                final statusMap = body['status'] as Map;
                final yearStatus = statusMap[yearId];
                if (yearStatus is Map) {
                  goalMonitoringStatuses.assignAll({
                    'entry': yearStatus['entry']?.toString() ?? 'N/A',
                    'term1': yearStatus['term1']?.toString() ?? 'N/A',
                    'term2': yearStatus['term2']?.toString() ?? 'N/A',
                  });
                  print('DEBUG: Statuses parsed: ${goalMonitoringStatuses}');
                } else {
                  goalMonitoringStatuses.clear();
                }
              }
              
              _filterGoalMonitoringData();
            }
          } else {
            print('DEBUG: getGoalMonitoringData failed: ${draftResponse.statusCode} - ${draftResponse.body}');
          }
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch questions. Status: ${response.statusCode}',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error fetching goal monitoring questions: $e');
      Get.snackbar('Error', 'Could not fetch questions: $e',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingGoalMonitoringQuestions.value = false;
    }
  }

  Future<void> saveDraft() async {
    final orgId = '68d4e4e20e437cd03453ccd8';
    final studentDetails = selectedIepStudentDetails;
    if (studentDetails == null) {
      Get.snackbar('Error', 'No student selected', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    
    final studentId = studentDetails['studentId']?.toString() ??
                   studentDetails['id']?.toString() ??
                   studentDetails['_id']?.toString();
                   
    if (studentId == null || studentId.isEmpty) {
      Get.snackbar('Error', 'Invalid student ID', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (assessmentAnswers.isEmpty) {
      Get.snackbar('Warning', 'No assessment answers to save.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Use the actual academic year ID as the year field and as keys in the payload
    final String yearKey = selectedIepYearId.value.isNotEmpty ? selectedIepYearId.value : "unknown_year";
    
    final List<Map<String, dynamic>> allAnswersList = [];
    final List<Map<String, dynamic>> goalsPayload = [];
    
    // Copy the usedPriorities to locally track new assignments
    final localUsedPriorities = Set<int>.from(usedPriorities);
    
    int getNextPriority() {
      for (int i = 1; i <= 100; i++) { // Increased range to be safe
        if (!localUsedPriorities.contains(i)) {
          localUsedPriorities.add(i);
          return i;
        }
      }
      return 100; // Fallback
    }

    // First pass: Collect all existing priorities from assessmentAnswers to avoid collisions
    for (var ans in assessmentAnswers.values) {
      if (ans['isGoal'] == true && ans['priority'] != null) {
        final p = int.tryParse(ans['priority'].toString());
        if (p != null) localUsedPriorities.add(p);
      }
    }

    for (var domain in assessmentDomains) {
      final questions = domain['questions'] as List? ?? [];

      for (var q in questions) {
        final qId = q['_id']?.toString() ?? '';
        final topicId = q['topicId']?.toString() ?? qId;
        final goalName = q['question']?.toString() ?? '';
        final optionsList = q['options'] as List? ?? [];
        
        final ans = assessmentAnswers[qId];
        if (ans != null) {
          final mainOptionStr = ans['mainOption']?.toString();
          if (mainOptionStr != null && mainOptionStr.isNotEmpty) {
             int optIndex = optionsList.indexWhere((o) => o.toString() == mainOptionStr);
             if (optIndex == -1) optIndex = 0;

             final scoreOpt = ans['score']?.toString();
             allAnswersList.add({
                "questionId": qId,
                "options": optIndex,
                "checkboxValue": (scoreOpt != null && scoreOpt.isNotEmpty && scoreOpt != 'null') ? scoreOpt : null,
                "badgeSelections": []
             });
          }

          if (ans['isGoal'] == true) {
             final goalMap = <String, dynamic>{
                "topicId": topicId,
                "questionId": qId,
                "goalType": ["School"],
                "term": "entry",
                "goalName": goalName,
             };
             if (ans['goalId'] != null) {
                goalMap["_id"] = ans['goalId'];
             }
             
             if (ans['priority'] != null) {
                goalMap["priority"] = ans['priority'];
             } else {
                goalMap["priority"] = getNextPriority();
                // Update local state so UI knows the assigned priority
                ans['priority'] = goalMap["priority"];
             }
             goalsPayload.add(goalMap);
          }
        }
      }
    }

    final payload = {
      "studentId": studentId,
      "year": yearKey,
      "answer": {
        yearKey: {
          "entry": allAnswersList,
          "term1": [],
          "term2": []
        }
      },
      "goals": {
        yearKey: {
          "entry": goalsPayload,
          "term1": [],
          "term2": []
        }
      },
      "activities": [],
      "subject": [],
      "deleteGoalIds": [],
      "remarks": "",
      "note": "",
      "finalSubmitted": false
    };

    isSavingDraft.value = true;
    try {
      print('DEBUG: Saving Draft Payload: $payload');
      final response = await _apiProvider.saveStudentGoals(payload);
      print('DEBUG: Save Draft Response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Assessment saved as draft successfully!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
        await fetchAssessmentQuestions(); // Sync UI with the server after saving
      } else {
        Get.snackbar('Error', 'Failed to save draft. Status: ${response.statusCode}', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not save draft: $e', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
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
    current['isGoal'] = !(current['isGoal'] ?? false);
    assessmentAnswers[questionId] = current;
    assessmentAnswers.refresh();
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
