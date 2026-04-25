import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/institute_registration_model.dart';
import '../../../data/models/professional_registration_model.dart';
import '../../../data/providers/api_provider.dart';

class RegisterController extends GetxController {
  final ApiProvider _apiProvider = Get.put(ApiProvider());
  var isLoading = false.obs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final retypePasswordController = TextEditingController();

  // 0: Parent, 1: Professional, 2: Institute
  var selectedTypeIndex = 0.obs;

  final List<String> accountTypes = ['Parent', 'Professional', 'Institute'];

  // Institute specific fields
  final instituteNameController = TextEditingController();
  var isNiepidDisha = false.obs;
  // Institute & Professional shared fields
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // Professional specific fields
  final crrNumberController = TextEditingController();
  var selectedQualification = ''.obs;
  final List<String> qualifications = [
    'B.Ed Special Education',
    'D.Ed Special Education',
    'M.Ed Special Education',
    'Diploma in Clinical Psychology',
    'Other'
  ];
  final pinCodeController = TextEditingController();
  var selectedState = ''.obs;
  final List<String> states = [
    'Delhi',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Telangana'
  ];
  final localAddressController = TextEditingController();

  var selectedSchoolType = ''.obs;
  final List<String> schoolTypes = [
    'Public',
    'Private',
    'Government Aided',
    'NGO'
  ];

  var selectedDesignation = ''.obs;
  final List<String> designations = [
    'Principal',
    'Director',
    'Administrator',
    'Head of Department',
    'Other'
  ];

  final mobileController = TextEditingController();
  final landlineController = TextEditingController();

  final captchaController = TextEditingController();
  var agreeToTerms = false.obs;

  var selectedCountry = ''.obs;
  var selectedDistrict = ''.obs;

  final List<String> countries = ['India', 'USA', 'UK', 'Australia'];
  final Map<String, List<String>> districts = {
    'India': ['Delhi', 'Mumbai', 'Bangalore', 'Chennai'],
    'USA': ['New York', 'Los Angeles', 'Chicago', 'Houston'],
    'UK': ['London', 'Birmingham', 'Manchester', 'Glasgow'],
    'Australia': ['Sydney', 'Melbourne', 'Brisbane', 'Perth'],
  };

  void selectType(int index) {
    selectedTypeIndex.value = index;
  }

  void onCountryChanged(String? value) {
    selectedCountry.value = value ?? '';
    selectedDistrict.value = ''; // Reset district
  }

  void onDistrictChanged(String? value) {
    selectedDistrict.value = value ?? '';
  }

  void onSchoolTypeChanged(String? value) {
    selectedSchoolType.value = value ?? '';
  }

  void onDesignationChanged(String? value) {
    selectedDesignation.value = value ?? '';
  }

  void toggleNiepidDisha(bool? value) {
    isNiepidDisha.value = value ?? false;
  }

  void toggleTerms(bool? value) {
    agreeToTerms.value = value ?? false;
  }

  void onRegister() async {
    if (selectedTypeIndex.value == 2) {
      if (!agreeToTerms.value) {
        Get.snackbar("Error", "Please accept Terms & Conditions",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      isLoading.value = true;
      try {
        final request = InstituteRegistrationRequest(
          roles: "Institute",
          organisation: "63451582773595003fe953a6",
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          password: passwordController.text,
          mobile: mobileController.text,
          designation: selectedDesignation.value,
          landLineNumber: landlineController.text,
          isTermsAndConditionsAccepted: agreeToTerms.value,
        );

        final response = await _apiProvider.registerInstitute(request);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar("Success", "Institute Registration Successful!",
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        } else {
          String errorMessage = "Registration failed";
          if (response.body != null &&
              response.body is Map &&
              response.body['message'] != null) {
            errorMessage = response.body['message'];
          }
          Get.snackbar("Error", errorMessage,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar("Error", e.toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        isLoading.value = false;
      }
    } else if (selectedTypeIndex.value == 1) {
      if (!agreeToTerms.value) {
        Get.snackbar("Error", "Please accept Terms & Conditions",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      isLoading.value = true;
      try {
        final request = ProfessionalRegistrationRequest(
          roles: "Educator",
          organisation: "63451582773595643fe953a5", // Default provided
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          password: passwordController.text,
          mobile: mobileController.text,
          userDP: "", // Or upload specific logic later
          isTermsAndConditionsAccepted: agreeToTerms.value,
          qualification: selectedQualification.value,
          crrNumber: crrNumberController.text,
          designation: selectedDesignation.value,
          address: Address(
            pinCode: pinCodeController.text,
            localAddress: localAddressController.text,
            district: selectedDistrict.value,
            state: selectedState.value,
          ),
        );

        final response = await _apiProvider.registerProfessional(request);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar("Success", "Professional Registration Successful!",
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        } else {
          String errorMessage = "Registration failed";
          if (response.body != null &&
              response.body is Map &&
              response.body['message'] != null) {
            errorMessage = response.body['message'];
          }
          Get.snackbar("Error", errorMessage,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        Get.snackbar("Error", e.toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        isLoading.value = false;
      }
    } else {
      Get.snackbar(
        'Registration',
        'Account creation for ${accountTypes[selectedTypeIndex.value]} initiated.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
    instituteNameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    landlineController.dispose();
    captchaController.dispose();
    crrNumberController.dispose();
    pinCodeController.dispose();
    localAddressController.dispose();
    super.onClose();
  }
}
