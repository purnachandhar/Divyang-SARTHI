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

  Future<Response> registerInstitute(InstituteRegistrationRequest request) =>
      post('/users/public/register', request.toJson());

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
}
