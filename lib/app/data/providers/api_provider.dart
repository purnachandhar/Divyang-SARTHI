import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/institute_registration_model.dart';
import '../models/professional_registration_model.dart';

class ApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = 'https://backend.divyangsarthi.in';
    httpClient.timeout = const Duration(seconds: 20);
  }

  Future<Map<String, String>> _buildAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'x-access-token': token,
      'Content-Type': 'application/json',
    };
  }

  Future<Response> searchSchool(String query) =>
      get('/users/public/searchschool', query: {'search': query});

  Future<Response> checkUserExists({String? mobile, String? email}) {
    final query = <String, String>{};
    if (mobile != null && mobile.trim().isNotEmpty) query['mobile'] = mobile.trim();
    if (email != null && email.trim().isNotEmpty) query['email'] = email.trim();
    return get('/users/public/check-user-exists', query: query);
  }

  Future<Response> sendOtp({required String to}) => post(
        '/service/sms/register-otp',
        {
          "to": to,
          "deviceInfo": {
            "platform": Platform.operatingSystem,
            "browser": "Flutter",
            "version": Platform.operatingSystemVersion,
          },
        },
      );

  Future<Response> verifyOtp({
    required String otp,
    required String otpId,
    required String otpToken,
  }) =>
      post('/service/sms/verify-otp', {
        "otp": otp,
        "otpId": otpId,
        "otpToken": otpToken,
      });

  Future<Response> getDropdown(String name, {bool onlyActive = true}) =>
      get('/dropdown',
          query: {'name': name, 'onlyActive': onlyActive.toString()});

  Future<Response> registerInstitute(InstituteRegistrationRequest request) =>
      post('/users/public/register', request.toJson());

  Future<Response> registerParent(Map<String, dynamic> body) =>
      post('/users/public/register', body);

  Future<Response> registerProfessional(
          ProfessionalRegistrationRequest request) =>
      post('/users/public/register', request.toJson());

  Future<Response> login(String emailOrPhone, String password) =>
      post('/users/public/login', {
        "emailorphone": emailOrPhone,
        "password": password,
      });

  Future<Response> studentLogin(String userName, String dateOfBirth) =>
      post('/student/public/loginstudent', {
        "userName": userName,
        "dateOfBirth": dateOfBirth,
      });

  Future<Response> getAllStudentsByAccessId(String accessId) async {
    final headers = await _buildAuthHeaders();
    return get(
      '/student/users/getallstudentbyaccessid/$accessId',
      headers: headers,
    );
  }

  Future<Response> getIepAssessment(String educatorId, String studentId) async {
    final headers = await _buildAuthHeaders();
    // Add Bearer token as well, as some newer DISHA endpoints might require it
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final url =
        '/niepid-disha-assessment/student/questions/$educatorId/$studentId';
    print('DEBUG: Calling IEP API: ${httpClient.baseUrl}$url');
    return get(
      url,
      headers: headers,
    );
  }

  Future<Response> getNiepidQuestions(String orgId, String studentId) async {
    final headers = await _buildAuthHeaders();
    final url = '/niepid-disha-assessment/user/questions/$orgId/$studentId';
    print('DEBUG: Calling NIEPID Questions API: ${httpClient.baseUrl}$url');
    return get(
      url,
      headers: headers,
    );
  }

  Future<Response> saveStudentGoals(Map<String, dynamic> data) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return put(
      '/niepid-disha-assessment/user/student-goals',
      data,
      headers: headers,
    );
  }

  Future<Response> getStudentGoals(String studentId) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return get(
      '/niepid-disha-assessment/user/student-goals/$studentId',
      headers: headers,
    );
  }

  Future<Response> getCurrentUser() async {
    final headers = await _buildAuthHeaders();
    return get(
      '/users/private/getcurrent/',
      headers: headers,
    );
  }

  Future<Response> getEducatorsByOrganisation({
    required bool isApproved,
    required bool isActivate,
    required String organisationId,
  }) async {
    final headers = await _buildAuthHeaders();
    return get(
      '/educator/ai/geteducator',
      query: {
        'isApproved': isApproved.toString(),
        'isActivate': isActivate.toString(),
        'organisation': organisationId,
      },
      headers: headers,
    );
  }

  Future<Response> updateEducator(String id, Map<String, dynamic> data) async {
    final headers = await _buildAuthHeaders();
    return put(
      '/users/private/educator/update/$id',
      data,
      headers: headers,
    );
  }

  Future<Response> getIepList(String orgId) async {
    final headers = await _buildAuthHeaders();
    return get(
      '/admin/school/getiep/$orgId',
      headers: headers,
    );
  }

  Future<Response> getNiepidDishaDashboard() async {
    final headers = await _buildAuthHeaders();
    return get(
      '/niepid-disha-assessment/institute/teacher-dashboard',
      headers: headers,
    );
  }

  Future<Response> getNiepidStudentAssessments() async {
    final headers = await _buildAuthHeaders();
    return get(
      '/niepid-disha-assessment/institute/students-assessments-list',
      headers: headers,
    );
  }

  Future<Response> getStudentLearningResources(String studentId) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return get(
      '/niepid-disha-assessment/user/student-learning-resources/$studentId',
      headers: headers,
    );
  }

  Future<Response> getVideosByLanguage() async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return get(
      '/portal/videos-list/by-language',
      headers: headers,
    );
  }

  Future<Response> getCareGiverMeetingData() async {
    final headers = await _buildAuthHeaders();
    return get(
      '/niepid-disha-assessment/institute/care-giver',
      headers: headers,
    );
  }

  Future<Response> getGoalMonitoringQuestions(
      String orgId, String studentId, String yearId) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url =
        '/niepid-disha-assessment/user/questions/$orgId/$studentId/$yearId/entry';
    print(
        'DEBUG: Calling Goal Monitoring Questions API: ${httpClient.baseUrl}$url');
    return get(
      url,
      headers: headers,
    );
  }

  /// Fetch questions for a specific term: entry, term1, term2
  Future<Response> getTermQuestions(
      String orgId, String studentId, String yearId, String term) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url =
        '/niepid-disha-assessment/user/questions/$orgId/$studentId/$yearId/$term';
    print(
        'DEBUG: Calling Term Questions API ($term): ${httpClient.baseUrl}$url');
    return get(
      url,
      headers: headers,
    );
  }

  Future<Response> getGoalMonitoringData(
      String studentId, String yearId) async {
    return getGoalMonitoringTermData(studentId, yearId, 'entry');
  }

  Future<Response> getGoalMonitoringTermData(
      String studentId, String yearId, String term) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url = '/niepid-disha-assessment/user/$studentId/$yearId/$term';
    print(
        'DEBUG: Calling Goal Monitoring Data API ($term): ${httpClient.baseUrl}$url');
    return get(
      url,
      headers: headers,
    );
  }

  Future<Response> getStudentsBySchoolId(String schoolId) async {
    final headers = await _buildAuthHeaders();
    return get(
      '/admin/school/getstudentbyschoolid/$schoolId',
      headers: headers,
    );
  }

  Future<Response> addStudent(Map<String, dynamic> data) async {
    final headers = await _buildAuthHeaders();
    headers.remove('Content-Type');

    final formData = FormData({});

    data.forEach((key, value) {
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          formData.fields.add(MapEntry('$key[$i]', value[i].toString()));
        }
      } else if ((key == 'studentDP' || key == 'idCard') &&
          value != null &&
          value.toString().isNotEmpty &&
          File(value.toString()).existsSync()) {
        formData.files.add(MapEntry(
            key,
            MultipartFile(File(value.toString()),
                filename: value.toString().split('/').last)));
      } else {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    return post(
      '/student/users/addstudent',
      formData,
      headers: headers,
    );
  }

  Future<Response> getDisabilityTypes() async {
    return get('/dropdown?name=disability&onlyActive=true');
  }

  Future<Response> getQualifications() async {
    return get('/dropdown?name=qualification&onlyActive=true');
  }

  Future<Response> getPincodeDetails(String pincode) async {
    return get('/pincode/$pincode');
  }

  Future<Response> verifyStudentGoals(String studentId) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url =
        '/niepid-disha-assessment/institute/verify-student-goals/$studentId';
    print('DEBUG: Calling Verify Student Goals API: ${httpClient.baseUrl}$url');
    return get(
      url,
      headers: headers,
    );
  }

  Future<Response> getTermStudentGoals(
      String studentId, String yearId, String term) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url = '/niepid-disha-assessment/user/$studentId/$yearId/$term';
    return get(url, headers: headers);
  }

  Future<Response> revokeSubmission(
      String studentId, String term, String comment) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url =
        '/niepid-disha-assessment/institute/final-submission-revoke/$studentId/$term';
    return put(url, {'comment': comment}, headers: headers);
  }

  Future<Response> updateCareGiverStatus({
    required String term,
    required String action,
    required List<String> studentIds,
    String? comment,
  }) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final body = {
      'term': term,
      'action': action,
      'studentIds': studentIds,
      if (comment != null) 'comment': comment,
    };
    return put('/niepid-disha-assessment/institute/care-giver/update', body,
        headers: headers);
  }

  Future<Response> approveSubmission(String studentId, String term) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url =
        '/niepid-disha-assessment/institute/final-submission/$studentId/$term';
    return put(url, {}, headers: headers);
  }

  Future<Response> addIep(Map<String, dynamic> body) async {
    final headers = await _buildAuthHeaders();
    return post(
      '/admin/school/addiep',
      body,
      headers: headers,
    );
  }

  Future<Response> updateIep(String id, Map<String, dynamic> body) async {
    final headers = await _buildAuthHeaders();
    return put(
      '/admin/school/updateiep/$id',
      body,
      headers: headers,
    );
  }

  Future<Response> saveCareGiverMeeting(Map<String, dynamic> body) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return put(
      '/niepid-disha-assessment/institute/care-giver/save',
      body,
      headers: headers,
    );
  }

  Future<Response> submitCareGiverMeeting(Map<String, dynamic> body) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return put(
      '/niepid-disha-assessment/institute/care-giver/submit',
      body,
      headers: headers,
    );
  }

  Future<Response> getStudentOverview(
      String studentId, String yearId, String term) async {
    final headers = await _buildAuthHeaders();
    final String token = headers['x-access-token'] ?? '';
    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final url =
        '/niepid-disha-assessment/user/student-overview/$studentId?year=$yearId&term=$term';
    return get(url, headers: headers);
  }

  Future<Response> uploadProfileImage(File file) async {
    final headers = await _buildAuthHeaders();
    headers.remove('Content-Type');
    final bytes = await file.readAsBytes();
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData({
      'file':
          MultipartFile(bytes, filename: fileName, contentType: 'image/jpeg')
    });
    return post('/api/upload-profile-image', formData, headers: headers);
  }

  Future<Response> uploadFilePortal(File file) async {
    final headers = await _buildAuthHeaders();
    headers.remove('Content-Type');
    final bytes = await file.readAsBytes();
    final fileName = file.path.split(Platform.pathSeparator).last;
    final formData = FormData({
      'file':
          MultipartFile(bytes, filename: fileName, contentType: 'image/jpeg')
    });
    return post('/portal/file/upload', formData, headers: headers);
  }

  Future<Response> updateStudent(
      String studentId, Map<String, dynamic> data) async {
    final headers = await _buildAuthHeaders();
    return patch('/student/users/updatestudentid/$studentId', data,
        headers: headers);
  }

  Future<Response> deleteStudent(String studentId, String remark) async {
    final headers = await _buildAuthHeaders();
    return get(
      '/student/users/deletestudentbyid/$studentId',
      query: {'remark': remark},
      headers: headers,
    );
  }

  Future<Response> approveProfessional(String educatorId) async {
    final headers = await _buildAuthHeaders();
    return patch('/admin/activity/$educatorId/approve', {"isApproved": true},
        headers: headers);
  }

  Future<Response> disapproveProfessional(String educatorId) async {
    final headers = await _buildAuthHeaders();
    return patch(
        '/educator/ai/approveeducator/$educatorId', {"isApproved": false},
        headers: headers);
  }

  Future<Response> deleteAcademicYear(String id) async {
    final headers = await _buildAuthHeaders();
    return delete('/admin/school/deleteiep/$id', headers: headers);
  }
}
