import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../controllers/institute_controller.dart';

class InstituteEditProfessionalView extends StatefulWidget {
  const InstituteEditProfessionalView({super.key});

  @override
  State<InstituteEditProfessionalView> createState() =>
      _InstituteEditProfessionalViewState();
}

class _InstituteEditProfessionalViewState
    extends State<InstituteEditProfessionalView> {
  static const List<String> _designations = [
    'Educator',
    'SpecialEducator',
    'OccupationalTherapist',
    'SpeechTherapist',
    'Physiotherapist',
    'Psychologist',
    'Counselor',
    'Other',
  ];

  static const List<String> _qualifications = [
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
  ];

  final InstituteController _controller = Get.find<InstituteController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Map<String, dynamic> _data;
  late String _educatorId;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _mobileController;
  late TextEditingController _crrController;

  String? _designation;
  String? _qualification;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _data =
        (args is Map) ? Map<String, dynamic>.from(args) : <String, dynamic>{};

    _educatorId = (_data['id'] ?? _data['_id'] ?? '').toString();

    String firstName = (_data['firstName'] ?? '').toString();
    String lastName = (_data['lastName'] ?? '').toString();
    final String fullName = (_data['name'] ?? '').toString();

    if (firstName.isEmpty && lastName.isEmpty && fullName.isNotEmpty) {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      firstName = parts.first;
      lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    _firstNameController = TextEditingController(text: firstName);
    _lastNameController = TextEditingController(text: lastName);
    _emailController =
        TextEditingController(text: (_data['email'] ?? '').toString());
    _mobileController =
        TextEditingController(text: (_data['mobile'] ?? '').toString());
    _crrController = TextEditingController(
        text: (_data['cRRNumber'] ?? _data['crr'] ?? '').toString());

    final initialDesignation =
        (_data['designation'] ?? _data['type'] ?? '').toString();
    _designation =
        _designations.contains(initialDesignation) ? initialDesignation : null;

    final initialQualification = (_data['qualification'] ?? '').toString();
    _qualification = _qualifications.contains(initialQualification)
        ? initialQualification
        : null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _crrController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (_educatorId.isEmpty) {
      Get.snackbar('Error', 'Educator ID is missing — cannot update.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    final success = await _controller.updateEducator(
      educatorId: _educatorId,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      designation: _designation ?? '',
      qualification: _qualification ?? '',
      cRRNumber: _crrController.text.trim(),
    );

    if (success && mounted) {
      Get.back(result: true); // Return success to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Edit Professional',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Personal Information'),
              const SizedBox(height: 12),
              _buildEditableField(
                label: 'First Name',
                controller: _firstNameController,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'First name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _buildEditableField(
                label: 'Last Name',
                controller: _lastNameController,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Contact Details'),
              const SizedBox(height: 12),
              _buildEditableField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!GetUtils.isEmail(v.trim())) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildEditableField(
                label: 'Mobile',
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Mobile is required';
                  if (v.trim().length != 10) return 'Mobile must be 10 digits';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Professional Info'),
              const SizedBox(height: 12),
              _buildEditableField(
                label: 'CRR Number',
                controller: _crrController,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (!RegExp(r'^A\d+$').hasMatch(v.trim())) {
                    return 'Must start with A followed by digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                label: 'Designation',
                value: _designation,
                items: _designations,
                onChanged: (val) => setState(() => _designation = val),
                validator: (val) =>
                    val == null ? 'Designation is required' : null,
              ),
              const SizedBox(height: 12),
              _buildDropdownField(
                label: 'Qualification',
                value: _qualification,
                items: _qualifications,
                onChanged: (val) => setState(() => _qualification = val),
                validator: (val) =>
                    val == null ? 'Qualification is required' : null,
              ),
              const SizedBox(height: 32),
              _buildSaveCancelButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveCancelButtons() {
    return Obx(() {
      final isLoading = _controller.isUpdatingEducator.value;
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => Get.back(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: BorderSide(color: Colors.grey[400]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Save Changes',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      );
    });
  }
}
