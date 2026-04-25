import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/iep_model.dart';
import '../../../data/providers/api_provider.dart';
import 'student_controller.dart';

class IepController extends GetxController {
  final ApiProvider _apiProvider = Get.find<ApiProvider>();
  final StudentController _studentController = Get.find<StudentController>();

  var assessment = Rx<IepAssessmentModel?>(null);
  var isLoading = false.obs;
  var error = ''.obs;

  // Track selected answers: {questionId: selectedOption}
  var selectedAnswers = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchIepAssessment();
  }

  Future<void> fetchIepAssessment() async {
    isLoading.value = true;
    error.value = '';
    try {
      final String studentId = _studentController.studentId;
      final prefs = await SharedPreferences.getInstance();
      // final String educatorId = prefs.getString('last_educator_id') ?? '';
      final String educatorId = '68d4e4e20e437cd03453ccd8';

      print('DEBUG: student id is $studentId, educator id is $educatorId');

      if (studentId.isEmpty) {
        error.value = 'Student ID not found.';
        isLoading.value = false;
        return;
      }

      if (educatorId.isEmpty) {
        error.value =
            'Educator contextual ID not found. Please log in again from the Educator panel.';
        isLoading.value = false;
        return;
      }

      final response =
          await _apiProvider.getIepAssessment(educatorId, studentId);
      print('response is of IEP from student side ${response.statusCode}');
      print('response is of IEP from student side ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body != null) {
          assessment.value = IepAssessmentModel.fromJson(response.body);
        }
      } else {
        error.value = response.body?['message'] ??
            response.statusText ??
            'Failed to load assessment';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Color getCategoryColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}
