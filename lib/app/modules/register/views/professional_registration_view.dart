import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../../../../theme/app_theme.dart';

class ProfessionalRegistrationView extends GetView<RegisterController> {
  const ProfessionalRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextFieldWithLabel(
          label: 'First Name*',
          controller: controller.firstNameController,
          hint: 'Enter your first name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),

        _buildTextFieldWithLabel(
          label: 'Last Name',
          controller: controller.lastNameController,
          hint: 'Enter your last name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),

        const Text(
          'CRR Number',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 4),
        const Text(
          'Enter CRR number\nShould start with a letter and can contain letters and digits\nExample: A1234 or AB12345',
          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller.crrNumberController,
          hint: 'Enter CRR number',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),

        _buildDropdownWithLabel(
          label: 'Designation*',
          hint: 'Select Designation',
          items: controller.designations,
          value: controller.selectedDesignation,
          onChanged: controller.onDesignationChanged,
        ),
        const SizedBox(height: 16),

        _buildDropdownWithLabel(
          label: 'Qualification*',
          hint: 'Select Qualification',
          items: controller.qualifications,
          value: controller.selectedQualification,
          onChanged: (val) =>
              controller.selectedQualification.value = val ?? '',
        ),
        const SizedBox(height: 16),

        _buildTextFieldWithLabel(
          label: 'Mobile Number* (optional if email provided)',
          controller: controller.mobileController,
          hint: 'Enter 10 digit mobile number',
          icon: Icons.phone_android,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),

        _buildTextFieldWithLabel(
          label: 'Email ID * (optional if mobile provided)',
          controller: controller.emailController,
          hint: 'Enter your email id',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        _buildTextFieldWithLabel(
          label: 'Password*',
          controller: controller.passwordController,
          hint: 'Enter your password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 16),

        _buildTextFieldWithLabel(
          label: 'Confirm Password*',
          controller: controller.retypePasswordController,
          hint: 'Enter confirm password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 16),

        _buildDropdownWithLabel(
          label: 'Country*',
          hint:
              'India', // Hardcoded hint as requested, but populated by controller
          items: controller.countries,
          value: controller.selectedCountry.value.isEmpty
              ? 'India'.obs
              : controller.selectedCountry,
          onChanged: controller.onCountryChanged,
        ),
        const SizedBox(height: 16),

        _buildTextFieldWithLabel(
          label: 'Pin code / Postal code*',
          controller: controller.pinCodeController,
          hint: 'Enter your pin code',
          icon: Icons.pin_drop_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        _buildDropdownWithLabel(
          label: 'State*',
          hint: 'State',
          items: controller.states,
          value: controller.selectedState,
          onChanged: (val) => controller.selectedState.value = val ?? '',
        ),
        const SizedBox(height: 16),

        Obx(() => _buildDropdownWithLabel(
              label: 'District / City*',
              hint: 'Select district / city',
              items: controller.selectedCountry.value.isEmpty
                  ? controller.districts['India'] ?? []
                  : controller.districts[controller.selectedCountry.value] ??
                      [],
              value: controller.selectedDistrict,
              onChanged: controller.onDistrictChanged,
            )),
        const SizedBox(height: 16),

        _buildTextFieldWithLabel(
          label: 'Local Address*',
          controller: controller.localAddressController,
          hint: 'Enter your local address',
          icon: Icons.home_outlined,
        ),
        const SizedBox(height: 16),

        // Captcha placeholder
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: controller.captchaController,
                hint: 'Enter captcha code',
                icon: Icons.security,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 55,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
              ),
              alignment: Alignment.center,
              child: const Text(
                '8X2K9L', // Dummy captcha
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  decoration: TextDecoration.lineThrough,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),

        Obx(() => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'I agree to the Terms & Conditions*',
                style: TextStyle(fontSize: 14, color: AppTheme.textPrimary),
              ),
              value: controller.agreeToTerms.value,
              onChanged: controller.toggleTerms,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppTheme.primaryColor,
            )),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'If you are an existing user please login',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldWithLabel({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: controller,
          hint: hint,
          icon: icon,
          isPassword: isPassword,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 12),
            child: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.7)),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDropdownWithLabel({
    required String label,
    required String hint,
    required List<String> items,
    required RxString value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: Text(hint,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                  value: value.value.isEmpty ? null : value.value,
                  items: items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              )),
        ),
      ],
    );
  }
}
