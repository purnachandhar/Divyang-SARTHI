import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../controllers/institute_controller.dart';
import 'institute_edit_professional_view.dart';

class InstituteProfessionalDetailView extends StatefulWidget {
  const InstituteProfessionalDetailView({super.key});

  @override
  State<InstituteProfessionalDetailView> createState() =>
      _InstituteProfessionalDetailViewState();
}

class _InstituteProfessionalDetailViewState
    extends State<InstituteProfessionalDetailView> {
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
  bool _isApproved = false;
  bool _isUpdatingStatus = false;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _data =
        (args is Map) ? Map<String, dynamic>.from(args) : <String, dynamic>{};

    _educatorId = (_data['id'] ?? _data['_id'] ?? '').toString();

    final String fullName = (_data['name'] ?? '').toString();
    String firstName = (_data['firstName'] ?? '').toString();
    String lastName = (_data['lastName'] ?? '').toString();
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

    final statusVal = _data['isApproved'];
    if (statusVal is bool) {
      _isApproved = statusVal;
    } else if (statusVal is String) {
      _isApproved = statusVal.toLowerCase() == 'true';
    } else {
      _isApproved = false;
    }
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
      setState(() => _isEditing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 32),
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
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
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
                        if (v == null || v.trim().isEmpty) {
                          return 'Mobile is required';
                        }
                        if (v.trim().length != 10) {
                          return 'Mobile must be 10 digits';
                        }
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
                    const SizedBox(height: 24),
                    _buildStatusSection(),
                    const SizedBox(height: 32),
                    if (_isEditing) _buildSaveCancelButtons() else Container(),
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
    final headerName =
        '${_firstNameController.text} ${_lastNameController.text}'.trim();
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
          Expanded(
            child: Text(
              headerName.isEmpty ? 'Professional Detail' : headerName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: 'Edit',
              onPressed: () async {
                final result = await Get.to(
                    () => const InstituteEditProfessionalView(),
                    arguments: _data);
                if (result == true) {
                  Get.back();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final name =
        '${_firstNameController.text} ${_lastNameController.text}'.trim();
    final designation = _designation ?? '';
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.psychology, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          name.isEmpty ? 'Unknown' : name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          designation.isEmpty ? 'Specialist' : designation,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ],
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
          readOnly: !_isEditing,
          keyboardType: keyboardType,
          maxLength: maxLength,
          validator: validator,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            counterText: '',
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey[100],
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
          onChanged: _isEditing ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: _isEditing ? Colors.white : Colors.grey[100],
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

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Status'),
        const SizedBox(height: 8),
        Obx(() {
          final isGlobalLoading =
              _controller.isUpdatingProfessionalStatus.value;
          final currentLoading = isGlobalLoading && _isUpdatingStatus;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Active',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    value: true,
                    groupValue: _isApproved,
                    activeColor: Colors.green,
                    onChanged: (val) => _handleStatusChange(val),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Inactive',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    value: false,
                    groupValue: _isApproved,
                    activeColor: Colors.red,
                    onChanged: (val) => _handleStatusChange(val),
                  ),
                ),
                if (currentLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _handleStatusChange(bool? newVal) async {
    if (newVal == null || newVal == _isApproved) return;

    if (newVal == true) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Verify Professional?'),
          content: const Text(
            'Are you sure you want to verify this professional?\n\n'
            'This action cannot be undone. Once verified, the professional will have access to the platform.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No, cancel!',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, verify it!'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    } else if (newVal == false) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'You want to Suspend this!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    await _controller.updateProfessionalStatus(_educatorId, newVal);

    if (mounted) {
      setState(() {
        _isApproved = newVal;
        _isUpdatingStatus = false;
      });
    }
  }

  Widget _buildSaveCancelButtons() {
    return Obx(() {
      final isLoading = _controller.isUpdatingEducator.value;
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  isLoading ? null : () => setState(() => _isEditing = false),
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

  Widget _buildBottomActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.message_outlined),
            label: const Text('Send Message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
