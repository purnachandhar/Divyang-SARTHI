import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/institute_controller.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class InstituteAddProfessionalView extends GetView<InstituteController> {
  const InstituteAddProfessionalView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final crrController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final designation = RxnString();
    final qualification = RxnString();
    final agreeToTerms = false.obs;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Institute Passcode'),
                    const SizedBox(height: 8),
                    // Read passcode dynamically from profile
                    Obx(() {
                      final org = controller.profileData.value?['organisation'];
                      final passCode = org is Map
                          ? (org['passCode'] ?? 'Loading...').toString()
                          : 'Loading...';
                      return _buildReadOnlyField(passCode);
                    }),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'First Name*',
                      hint: 'Enter first name',
                      controller: firstNameController,
                      validator: (value) =>
                          value!.isEmpty ? 'First name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Last Name',
                      hint: 'Enter last name',
                      controller: lastNameController,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Professional Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'CRR Number',
                      hint: 'Enter CRR number',
                      controller: crrController,
                      helperText:
                          'Should Start with A letter followed by Digits (Example: A5362371625312)',
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        if (!RegExp(r'^A\d+$').hasMatch(value)) {
                          return 'Must start with A followed by digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Designation*',
                      hint: 'Select Designation',
                      items: const [
                        'Educator',
                        'SpecialEducator',
                        'OccupationalTherapist',
                        'SpeechTherapist',
                        'Physiotherapist',
                        'Psychologist',
                        'Counselor',
                        'Other',
                      ],
                      value: designation,
                      validator: (val) =>
                          val == null ? 'Designation is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Qualification*',
                      hint: 'Select Qualification',
                      items: const [
                        'B.Ed Special Education',
                        'D.Ed Special Education',
                        'M.Ed Special Education',
                        'Diploma in Clinical Psychology',
                        'diploma-behavioural-therapy',
                        'certificate-behaviour-therapy',
                        'diploma-speech-language-pathology',
                        'ma-psychology',
                        'mpt',
                        'phd-physiotherapy',
                        'phd-speech-hearing',
                        'Other',
                      ],
                      value: qualification,
                      validator: (val) =>
                          val == null ? 'Qualification is required' : null,
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Contact Information'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Email ID *',
                      hint: 'Enter your email id',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.isEmpty && mobileController.text.isEmpty) {
                          return 'Email or Mobile is required';
                        }
                        if (value.isNotEmpty && !GetUtils.isEmail(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Mobile Number *',
                      hint: 'Enter 10 digit mobile number',
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (value) {
                        if (value!.isEmpty && emailController.text.isEmpty) {
                          return 'Email or Mobile is required';
                        }
                        if (value.isNotEmpty && value.length != 10) {
                          return 'Mobile number must be 10 digits';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Security'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Password*',
                      hint: 'Enter password',
                      controller: passwordController,
                      isPassword: true,
                      validator: (value) => value!.length < 6
                          ? 'Password must be at least 6 chars'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Confirm Password*',
                      hint: 'Confirm password',
                      controller: confirmPasswordController,
                      isPassword: true,
                      validator: (value) => value != passwordController.text
                          ? 'Passwords do not match'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    Obx(() => CheckboxListTile(
                          value: agreeToTerms.value,
                          onChanged: (val) => agreeToTerms.value = val!,
                          title: const Text(
                              'I agree to the Terms & Conditions*',
                              style: TextStyle(fontSize: 14)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppTheme.primaryColor,
                        )),
                    const SizedBox(height: 32),
                    Obx(() => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.isAddingProfessional.value
                                ? null
                                : () {
                                    if (!formKey.currentState!.validate()) return;
                                    if (!agreeToTerms.value) {
                                      Get.snackbar(
                                          'Error',
                                          'Please agree to Terms & Conditions',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor:
                                              Colors.red.withOpacity(0.1),
                                          colorText: Colors.red);
                                      return;
                                    }
                                     controller.addProfessional(
                                      firstName: firstNameController.text.trim(),
                                      lastName: lastNameController.text.trim(),
                                      email: emailController.text.trim(),
                                      mobile: mobileController.text.trim(),
                                      password: passwordController.text,
                                      designation: designation.value ?? '',
                                      qualification: qualification.value ?? '',
                                      agreeToTerms: agreeToTerms.value,
                                     );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: controller.isAddingProfessional.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Submit',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                          ),
                        )),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Add Professional',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        value,
        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? helperText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 2,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    required RxnString value,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              value: value.value,
              hint: Text(hint),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => value.value = val,
              validator: validator,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            )),
      ],
    );
  }
}
