import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/institute_registration_model.dart';
import '../../../data/models/professional_registration_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../../theme/app_theme.dart';

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

  // School search (autocomplete) state
  var schoolSearchResults = <Map<String, dynamic>>[].obs;
  var isSearchingSchool = false.obs;
  var selectedSchoolId = ''.obs;
  Timer? _schoolSearchDebounce;

  /// Debounced search triggered as the user types the institute name.
  void onInstituteNameChanged(String value) {
    // A fresh keystroke invalidates any previously selected school.
    selectedSchoolId.value = '';

    _schoolSearchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      schoolSearchResults.clear();
      isSearchingSchool.value = false;
      return;
    }
    _schoolSearchDebounce =
        Timer(const Duration(milliseconds: 400), () => _searchSchools(query));
  }

  Future<void> _searchSchools(String query) async {
    isSearchingSchool.value = true;
    try {
      final response = await _apiProvider.searchSchool(query);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        List list = [];
        if (body is List) {
          list = body;
        } else if (body is Map) {
          list = body['data'] ?? body['schools'] ?? body['users'] ?? [];
        }
        schoolSearchResults.assignAll(
          list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      } else {
        schoolSearchResults.clear();
      }
    } catch (e) {
      schoolSearchResults.clear();
    } finally {
      isSearchingSchool.value = false;
    }
  }

  /// Reads a display name from a school search result.
  String schoolName(Map<String, dynamic> school) {
    return (school['schoolName'] ??
            school['name'] ??
            school['organisationName'] ??
            'Unknown School')
        .toString();
  }

  /// Called when the user picks a school from the dropdown.
  void selectSchool(Map<String, dynamic> school) {
    instituteNameController.text = schoolName(school);
    selectedSchoolId.value = (school['id'] ?? school['_id'] ?? '').toString();
    schoolSearchResults.clear();
  }

  // Institute & Professional shared fields
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  // Professional specific fields
  final crrNumberController = TextEditingController();
  var selectedQualification = ''.obs;
  // Fetched from the qualifications API; seeded with defaults as a fallback.
  final List<String> qualifications = [
    'B.Ed Special Education',
    'D.Ed Special Education',
    'M.Ed Special Education',
    'Diploma in Clinical Psychology',
    'Other'
  ];
  var qualificationOptions = <String>[].obs;
  var isQualificationsLoading = false.obs;

  Future<void> fetchQualifications() async {
    isQualificationsLoading.value = true;
    try {
      final response = await _apiProvider.getQualifications();
      if (response.statusCode == 200) {
        List list = [];
        final body = response.body;
        if (body is List) {
          list = body;
        } else if (body is Map) {
          list = body['data'] ?? body['items'] ?? [];
        }

        final options = <String>[];
        for (final item in list) {
          if (item is String) {
            if (item.trim().isNotEmpty) options.add(item.trim());
          } else if (item is Map) {
            final label = (item['label'] ?? item['name'] ?? item['value'] ?? '')
                .toString()
                .trim();
            if (label.isNotEmpty) options.add(label);
          }
        }

        if (options.isNotEmpty) {
          qualificationOptions.assignAll(options);
          if (!qualificationOptions.contains(selectedQualification.value)) {
            selectedQualification.value = '';
          }
        }
      }
    } catch (_) {
      // Keep the seeded defaults on failure.
    } finally {
      isQualificationsLoading.value = false;
    }
  }

  final pinCodeController = TextEditingController();
  final stateController = TextEditingController();
  var selectedState = ''.obs;
  final List<String> states = [
    'Delhi',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Telangana'
  ];
  final localAddressController = TextEditingController();

  // Pincode lookup state — fills State + District/City automatically.
  var availableDistricts = <String>[].obs;
  var isPincodeLoading = false.obs;

  /// Looks up [pincode] and auto-fills the State and District/City fields.
  Future<void> lookupPincode(String pincode) async {
    if (pincode.length != 6) return;

    try {
      isPincodeLoading.value = true;
      final response = await _apiProvider.getPincodeDetails(pincode);

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
            selectedState.value = postOffices[0]['State']?.toString() ?? '';
            stateController.text = selectedState.value;
            final districts = postOffices
                .map((po) =>
                    po['District']?.toString() ?? po['Block']?.toString() ?? '')
                .where((d) => d.isNotEmpty)
                .toSet()
                .toList();
            availableDistricts.assignAll(districts);
            if (districts.isNotEmpty) selectedDistrict.value = districts.first;
          }
        }
      }
    } catch (e) {
      // Ignore lookup failures; the user can still fill manually.
    } finally {
      isPincodeLoading.value = false;
    }
  }

  var selectedSchoolType = ''.obs;
  // Fetched from /dropdown?name=schoolType; seeded with defaults as a fallback.
  var schoolTypeOptions = <String>['Special', 'Inclusive'].obs;
  var isLoadingSchoolTypes = false.obs;

  // Captcha states
  var captchaSvg = ''.obs;
  var isMathCaptcha = false.obs;
  var captchaVerified = false.obs;
  var isFetchingCaptcha = false.obs;
  String correctCaptchaAnswer = '';
  var captchaId = ''.obs;

  // OTP states
  final otpController = TextEditingController();
  var isCheckingUser = false.obs;
  var otpSecondsRemaining = 0.obs; // counts down from 300 (5:00)
  var isSubmittingOtp = false.obs;
  Timer? _otpTimer;
  static const int _otpDurationSeconds = 300; // 5:00 minutes
  String _otpId = '';
  String _otpToken = '';

  String get otpTargetMobile => mobileController.text.trim();

  String formatOtpTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startOtpTimer() {
    _otpTimer?.cancel();
    otpSecondsRemaining.value = _otpDurationSeconds;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpSecondsRemaining.value <= 0) {
        timer.cancel();
      } else {
        otpSecondsRemaining.value--;
      }
    });
  }

  Future<void> resendOtp() async {
    // Only allow resend once the countdown has finished.
    if (otpSecondsRemaining.value > 0) return;
    otpController.clear();
    final sent = await _sendOtp();
    if (sent) {
      _startOtpTimer();
      Get.snackbar("OTP Sent", "A new OTP has been sent to $otpTargetMobile",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// Builds the `to` number expected by the OTP API: 91 + 10-digit mobile.
  String get _otpToNumber {
    var m = otpTargetMobile.replaceAll(RegExp(r'\D'), '');
    if (m.length == 10) m = '91$m';
    return m;
  }

  /// Requests an OTP for the entered mobile and stores the returned
  /// otpId / otpToken needed for verification. Returns true on success.
  Future<bool> _sendOtp() async {
    try {
      final response = await _apiProvider.sendOtp(to: _otpToNumber);
      final body = response.body;
      print("otp response: $body");

      // The id/token may sit at the top level or under a `data` object.
      final Map data = (body is Map && body['data'] is Map)
          ? body['data'] as Map
          : (body is Map ? body : {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        _otpId = (data['otpId'] ?? data['id'] ?? '').toString();
        _otpToken = (data['otpToken'] ?? data['token'] ?? '').toString();
        if (_otpId.isNotEmpty && _otpToken.isNotEmpty) return true;
      }

      final message = (body is Map && body['message'] != null)
          ? body['message'].toString()
          : "Failed to send OTP. Please try again.";
      Get.snackbar("Error", message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  void cancelOtp() {
    _otpTimer?.cancel();
    otpController.clear();
  }

  /// Checks whether a user already exists (by mobile/email). If not, starts the
  /// OTP timer and shows the OTP dialog before registering.
  Future<void> _checkUserThenSendOtp() async {
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();

    if (mobile.isEmpty && email.isEmpty) {
      Get.snackbar("Error", "Please enter a mobile number or email",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isCheckingUser.value = true;
    try {
      final response = await _apiProvider.checkUserExists(
          mobile: mobile.isNotEmpty ? mobile : null,
          email: email.isNotEmpty ? email : null);

      final body = response.body;
      final exists = body is Map && body['exists'] == true;

      print("user body request ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (exists) {
          Get.snackbar("Error",
              "An account with this mobile/email already exists. Please login.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
        // New user → send the OTP, then show the OTP dialog.
        otpController.clear();
        final sent = await _sendOtp();
        if (!sent) return;
        _startOtpTimer();
        _showOtpDialog();
      } else {
        Get.snackbar("Error", "Could not verify user. Please try again.",
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
      isCheckingUser.value = false;
    }
  }

  void _showOtpDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verify OTP',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter OTP sent to your: $otpTargetMobile',
                style:
                    const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: 'Enter OTP',
                  counterText: '',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              // Resend countdown
              Obx(() {
                final remaining = otpSecondsRemaining.value;
                if (remaining > 0) {
                  return Text(
                    'Resend OTP in ${formatOtpTime(remaining)}',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  );
                }
                return GestureDetector(
                  onTap: resendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        decoration: TextDecoration.underline),
                  ),
                );
              }),
              const SizedBox(height: 6),
              const Text(
                'Note: OTP will expire after 5:00 minutes.',
                style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        cancelOtp();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                          onPressed: isSubmittingOtp.value ? null : submitOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: isSubmittingOtp.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : const Text('Submit',
                                  style: TextStyle(color: Colors.white)),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> submitOtp() async {
    if (otpController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter the OTP",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (otpSecondsRemaining.value <= 0) {
      Get.snackbar("Error", "OTP has expired. Please resend.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmittingOtp.value = true;
    try {
      final response = await _apiProvider.verifyOtp(
        otp: otpController.text.trim(),
        otpId: _otpId,
        otpToken: _otpToken,
      );

      final body = response.body;
      final verified =
          (response.statusCode == 200 || response.statusCode == 201) &&
              !(body is Map && body['success'] == false);

      if (!verified) {
        final message = (body is Map && body['message'] != null)
            ? body['message'].toString()
            : "Invalid OTP. Please try again.";
        Get.snackbar("Error", message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // OTP verified → proceed with the actual registration for the
      // currently selected account type.
      _otpTimer?.cancel();
      Get.back(); // close the OTP dialog
      if (selectedTypeIndex.value == 1) {
        await _performProfessionalRegistration();
      } else {
        await _performInstituteRegistration();
      }
    } catch (e) {
      Get.snackbar("Error", "OTP verification failed: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmittingOtp.value = false;
    }
  }

  Future<void> _performInstituteRegistration() async {
    isLoading.value = true;
    try {
      final request = InstituteRegistrationRequest(
        roles: "Institute",
        organisation: selectedSchoolId.value.isNotEmpty
            ? selectedSchoolId.value
            : "63451582773595003fe953a6",
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        password: passwordController.text,
        mobile: mobileController.text,
        designation: selectedDesignation.value,
        landLineNumber: landlineController.text,
        schoolType: selectedSchoolType.value,
        isNipiedDisha: isNiepidDisha.value,
        isTermsAndConditionsAccepted: agreeToTerms.value,
      );

      final response = await _apiProvider.registerInstitute(request);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showVerificationLinkDialog(emailController.text.trim());
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
  }

  Future<void> _performProfessionalRegistration() async {
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
        _showVerificationLinkDialog(emailController.text.trim());
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
  }

  /// Shown after a successful registration, prompting the user to verify their
  /// email before logging in.
  void _showVerificationLinkDialog(String email) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_read_outlined,
                  color: AppTheme.primaryColor, size: 56),
              const SizedBox(height: 16),
              Text(
                'Account Verification Link Sent To Your Mail Id, $email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kindly Check Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.back(); // close dialog
                  Get.offAllNamed('/login');
                },
                child: const Text(
                  'Click Here to login',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'If you did not get activation link ',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  GestureDetector(
                    onTap: resendActivationLink,
                    child: const Text(
                      'Re-Send',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void resendActivationLink() {
    Get.snackbar(
        "Activation Link", "A new activation link has been sent to your email.",
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  void onInit() {
    super.onInit();
    fetchSchoolTypes();
    fetchQualifications();
    fetchDesignations();
    fetchVisualCaptcha();
  }

  // --- Captcha Methods ---

  Future<void> fetchVisualCaptcha() async {
    isFetchingCaptcha.value = true;
    captchaVerified.value = false;
    captchaController.clear();
    try {
      final response = await GetConnect()
          .get('https://backend.divyangsarthi.in/recaptcha/visual');
      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null && data['success'] == true) {
          captchaSvg.value = data['captchaSvg'] ?? '';
          captchaId.value = data['captchaId'] ?? '';
          _extractVisualAnswer(captchaSvg.value);
        }
      } else {
        Get.snackbar("Error", "Failed to load visual captcha",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load visual captcha: $e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetchingCaptcha.value = false;
    }
  }

  Future<void> fetchMathCaptcha() async {
    isFetchingCaptcha.value = true;
    captchaVerified.value = false;
    captchaController.clear();
    try {
      final response = await GetConnect()
          .get('https://backend.divyangsarthi.in/recaptcha/math');
      if (response.statusCode == 200) {
        final data = response.body;
        if (data != null && data['success'] == true) {
          captchaSvg.value = data['questionSvg'] ?? '';
          captchaId.value = data['captchaId'] ?? '';
          _extractMathAnswer(data['question'] ?? '');
        }
      } else {
        Get.snackbar("Error", "Failed to load math captcha",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load math captcha: $e",
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isFetchingCaptcha.value = false;
    }
  }

  void _extractVisualAnswer(String svg) {
    final RegExp textRegExp = RegExp(r'<text[^>]*>([^<]+)</text>');
    final Iterable<Match> matches = textRegExp.allMatches(svg);
    String answer = '';
    for (var match in matches) {
      answer += match.group(1)?.trim() ?? '';
    }
    correctCaptchaAnswer = answer;
  }

  void _extractMathAnswer(String question) {
    try {
      final parts = question.split(' ');
      if (parts.length == 3) {
        final a = int.parse(parts[0]);
        final op = parts[1];
        final b = int.parse(parts[2]);
        if (op == '+') {
          correctCaptchaAnswer = (a + b).toString();
        } else if (op == '-') {
          correctCaptchaAnswer = (a - b).toString();
        } else if (op == '*') {
          correctCaptchaAnswer = (a * b).toString();
        } else if (op == '/') {
          correctCaptchaAnswer = (a ~/ b).toString();
        } else {
          correctCaptchaAnswer = '';
        }
      }
    } catch (e) {
      correctCaptchaAnswer = '';
    }
  }

  void verifyCaptcha() {
    if (captchaController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter captcha code",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    if (captchaController.text.trim().toLowerCase() ==
        correctCaptchaAnswer.toLowerCase()) {
      captchaVerified.value = true;
      Get.snackbar("Success", "✓ Captcha verified successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white);
    } else {
      captchaVerified.value = false;
      Get.snackbar("Error", "Invalid captcha code. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      refreshCaptcha();
    }
  }

  void refreshCaptcha() {
    if (isMathCaptcha.value) {
      fetchMathCaptcha();
    } else {
      fetchVisualCaptcha();
    }
  }

  void toggleCaptchaType() {
    isMathCaptcha.value = !isMathCaptcha.value;
    refreshCaptcha();
  }

  Future<void> fetchSchoolTypes() async {
    isLoadingSchoolTypes.value = true;
    try {
      final response = await _apiProvider.getDropdown('schoolType');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        List list = [];
        if (body is List) {
          list = body;
        } else if (body is Map) {
          list = body['items'] ??
              body['data'] ??
              body['dropdown'] ??
              body['values'] ??
              [];
        }

        final options = <String>[];
        for (final item in list) {
          if (item is String) {
            if (item.trim().isNotEmpty) options.add(item.trim());
          } else if (item is Map) {
            final label = (item['label'] ??
                    item['name'] ??
                    item['value'] ??
                    item['title'] ??
                    '')
                .toString()
                .trim();
            if (label.isNotEmpty) options.add(label);
          }
        }

        if (options.isNotEmpty) {
          schoolTypeOptions.assignAll(options);
          // Drop a stale selection that is no longer valid.
          if (!schoolTypeOptions.contains(selectedSchoolType.value)) {
            selectedSchoolType.value = '';
          }
        }
      }
    } catch (_) {
      // Keep the seeded defaults on failure.
    } finally {
      isLoadingSchoolTypes.value = false;
    }
  }

  var selectedDesignation = ''.obs;
  // Fetched from /dropdown?name=professional; seeded with defaults as fallback.
  final List<String> designations = [
    "Adhyaksh",
    "Author and Hon. Secretary",
    "Chair Man",
    "Chair Person",
    "Chairman",
    "Chairman cum Managing Trustee",
    "Chief Executive Officer",
    "Chief Functionary",
    "Chief Trusty",
    "Correspondent",
    "Deputy Director Chief Functionary",
    "Director",
    "Director Founder Secretary",
    "Executive Director",
    "Executive President",
    "Executive Secretary",
    "Founder President",
    "Founder Trustee",
    "General Secretary",
    "General Secretary cum Director",
    "Head of Trustee",
    "Hon. Gen. Secretary",
    "Hon Secretary",
    "Hon.Secretary",
    "Honorary Chairman",
    "Honorary President",
    "Honorary Secretary",
    "Hony Director",
    "Hony Director General Secy",
    "Joint Secretary",
    "Manager",
    "Manager cum Secretary",
    "Managing Director",
    "Managing Trustee",
    "President",
    "President cum Chief Trustee",
    "Principal",
    "Principal cum Member Secretary",
    "Programs Manager",
    "RO-Manager",
    "Secretary",
    "Secretary and Managing Trustee",
    "Settlor and Trustee of the Charitable Trust",
    "Treasurer",
    "Trustee",
    "Vice President",
    "Village Incharge",
  ];
  var designationOptions = <String>[].obs;
  var isLoadingDesignations = false.obs;

  Future<void> fetchDesignations() async {
    isLoadingDesignations.value = true;
    try {
      final response = await _apiProvider.getDropdown('professional');
      print("designation response: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.body;
        List list = [];
        if (body is List) {
          list = body;
        } else if (body is Map) {
          list = body['items'] ??
              body['data'] ??
              body['dropdown'] ??
              body['values'] ??
              [];
        }

        final options = <String>[];
        for (final item in list) {
          if (item is String) {
            if (item.trim().isNotEmpty) options.add(item.trim());
          } else if (item is Map) {
            final label = (item['label'] ??
                    item['name'] ??
                    item['value'] ??
                    item['title'] ??
                    '')
                .toString()
                .trim();
            if (label.isNotEmpty) options.add(label);
          }
        }

        if (options.isNotEmpty) {
          designationOptions.assignAll(options);
          if (!designationOptions.contains(selectedDesignation.value)) {
            selectedDesignation.value = '';
          }
        }
      }
    } catch (_) {
      // Keep the seeded defaults on failure.
    } finally {
      isLoadingDesignations.value = false;
    }
  }

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
    if (selectedTypeIndex.value == index) return;
    selectedTypeIndex.value = index;
    // Each account type is a separate registration. Clear the shared form so
    // values typed under one type don't carry over to another.
    _clearForm();
  }

  /// Resets every shared input field and selection back to its empty state.
  /// Called when the user switches between Parent / Professional / Institute.
  void _clearForm() {
    // Text fields
    firstNameController.clear();
    lastNameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
    retypePasswordController.clear();
    landlineController.clear();
    instituteNameController.clear();
    crrNumberController.clear();
    pinCodeController.clear();
    stateController.clear();
    localAddressController.clear();
    captchaController.clear();

    // Dropdown / selection state
    selectedDesignation.value = '';
    selectedQualification.value = '';
    selectedSchoolType.value = '';
    selectedSchoolId.value = '';
    selectedCountry.value = '';
    selectedDistrict.value = '';
    selectedState.value = '';

    // Toggles
    isNiepidDisha.value = false;
    agreeToTerms.value = false;

    // Transient lists / captcha verification
    availableDistricts.clear();
    schoolSearchResults.clear();
    captchaVerified.value = false;
    refreshCaptcha();
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
      if (!captchaVerified.value) {
        Get.snackbar("Error", "Please verify the captcha",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      if (!agreeToTerms.value) {
        Get.snackbar("Error", "Please accept Terms & Conditions",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Verify the user is new, then collect an OTP before registering.
      await _checkUserThenSendOtp();
    } else if (selectedTypeIndex.value == 1) {
      if (!captchaVerified.value) {
        Get.snackbar("Error", "Please verify the captcha",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      if (!agreeToTerms.value) {
        Get.snackbar("Error", "Please accept Terms & Conditions",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Verify the user is new, then collect an OTP before registering.
      await _checkUserThenSendOtp();
    } else {
      // Parent registration
      if (!captchaVerified.value) {
        Get.snackbar("Error", "Please verify the captcha",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      if (!agreeToTerms.value) {
        Get.snackbar("Error", "Please accept Terms & Conditions",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      await _checkUserThenRegisterParent();
    }
  }

  /// Parent flow: confirm the user is new, then register directly (no OTP).
  Future<void> _checkUserThenRegisterParent() async {
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();

    if (mobile.isEmpty && email.isEmpty) {
      Get.snackbar("Error", "Please enter a mobile number or email",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isCheckingUser.value = true;
    try {
      final response = await _apiProvider.checkUserExists(
          mobile: mobile.isNotEmpty ? mobile : null,
          email: email.isNotEmpty ? email : null);

      final body = response.body;
      final exists = body is Map && body['exists'] == true;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (exists) {
          Get.snackbar("Error",
              "An account with this mobile/email already exists. Please login.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
        await _performParentRegistration();
      } else {
        Get.snackbar("Error", "Could not verify user. Please try again.",
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
      isCheckingUser.value = false;
    }
  }

  Future<void> _performParentRegistration() async {
    isLoading.value = true;
    try {
      final body = {
        "roles": "Parent",
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "isTermsAndConditionsAccepted": agreeToTerms.value,
        "address": {
          "country":
              selectedCountry.value.isEmpty ? "India" : selectedCountry.value,
          "pinCode": pinCodeController.text,
          "localAddress": localAddressController.text,
          "district": selectedDistrict.value,
          "state": selectedState.value,
        },
        "mobile": mobileController.text,
      };

      final response = await _apiProvider.registerParent(body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showVerificationLinkDialog(emailController.text.trim());
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
  }

  @override
  void onClose() {
    _schoolSearchDebounce?.cancel();
    _otpTimer?.cancel();
    otpController.dispose();
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
    stateController.dispose();
    localAddressController.dispose();
    super.onClose();
  }
}
