import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../controllers/institute_controller.dart';
import '../../../data/providers/api_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';

class InstituteAddStudentView extends GetView<InstituteController> {
  const InstituteAddStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    // Form Controllers
    final usernameController = TextEditingController();
    final fullNameController = TextEditingController();
    final dobController = TextEditingController();
    final parentNameController = TextEditingController();
    final parentEmailController = TextEditingController();
    final parentMobileController = TextEditingController();
    final admissionDateController = TextEditingController();
    final pinCodeController = TextEditingController();
    final stateController = TextEditingController();
    final cityController = TextEditingController();
    final udidNumberController = TextEditingController();
    final permanentAddressController = TextEditingController();
    final presentAddressController = TextEditingController();

    // Observable States
    final studentClass = RxnString();
    final gender = RxnString();
    final parentRelation = RxnString();
    final assignedProfessional = RxnString();
    final disabilityTypes = <String>[].obs;
    final selectedCity = RxnString();
    final childPhotoPath = RxnString();
    final childPhotoUrl = RxnString();
    final udidCertPath = RxnString();
    final udidCertUrl = RxnString();
    final otherIdPath = RxnString();
    final otherIdUrl = RxnString();
    final sameAsPermanent = false.obs;
    final agreeToDeclaration = false.obs;

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
                    _buildSectionTitle('Student Personal Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Username*',
                        hint: 'Enter username',
                        controller: usernameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Username is required' : null),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Full Name*',
                        hint: 'Enter full name',
                        controller: fullNameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Full name is required' : null),
                    const SizedBox(height: 16),
                    _buildDateField(context,
                        label: 'Date Of Birth*',
                        hint: 'dd-mm-yyyy',
                        controller: dobController,
                        validator: (v) =>
                            v!.isEmpty ? 'DOB is required' : null),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                        label: 'Class (optional)',
                        hint: 'Select a class',
                        items: [
                          'Preprimary',
                          'Primary-I',
                          'Primary-II',
                          'Secondary',
                          'Pre-Vocational'
                        ],
                        value: studentClass),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                        label: 'Gender*',
                        hint: 'Select Gender',
                        items: ['Male', 'Female', 'Other'],
                        value: gender,
                        validator: (v) =>
                            v == null ? 'Gender is required' : null),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Parent Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Parent Name*',
                        hint: 'Enter parent name',
                        controller: parentNameController,
                        validator: (v) =>
                            v!.isEmpty ? 'Parent name is required' : null),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: 'Parent Email* (optional if mobile provided)',
                      hint: 'Enter parent email address',
                      controller: parentEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v!.isEmpty && parentMobileController.text.isEmpty)
                          return 'Email or Mobile is required';
                        if (v.isNotEmpty && !GetUtils.isEmail(v))
                          return 'Invalid email format';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label:
                          'Parent Mobile Number*(optional if email provided)',
                      hint: 'Enter mobile number',
                      controller: parentMobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      validator: (v) {
                        if (v!.isEmpty && parentEmailController.text.isEmpty)
                          return 'Email or Mobile is required';
                        if (v.isNotEmpty && v.length != 10)
                          return 'Invalid mobile number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                        label: 'Parent Relation*',
                        hint: 'Select relation',
                        items: ['Father', 'Mother', 'Guardian', 'Other'],
                        value: parentRelation,
                        validator: (v) =>
                            v == null ? 'Relation is required' : null),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Academic & Location Info'),
                    const SizedBox(height: 16),
                    _buildDateField(context,
                        label: 'Admission Date*',
                        hint: 'dd-mm-yyyy',
                        controller: admissionDateController,
                        validator: (v) =>
                            v!.isEmpty ? 'Admission date is required' : null),
                    const SizedBox(height: 16),
                    Obx(() => _buildDropdownField(
                        label: 'Assign Professional*',
                        hint: controller.isEducatorsLoading.value
                            ? 'Loading professionals...'
                            : 'Select professional',
                        items: controller.educators
                            .map((e) =>
                                "${e['firstName'] ?? ''} ${e['lastName'] ?? ''}"
                                    .trim())
                            .toList(),
                        value: assignedProfessional,
                        validator: (v) =>
                            v == null ? 'Professional is required' : null)),
                    const SizedBox(height: 16),
                    _buildReadOnlyField(label: 'Country*', value: 'India'),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Pin Code / Postal Code*',
                        hint: 'Enter your pin code',
                        controller: pinCodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        onChanged: (val) async {
                          if (val.length == 6) {
                            final data = await controller.lookupPincode(val);
                            if (data != null) {
                              stateController.text = data['state'] ?? '';
                              if (data['districts'] != null &&
                                  (data['districts'] as List).isNotEmpty) {
                                selectedCity.value = data['districts'][0];
                              }
                            }
                          }
                        },
                        validator: (v) =>
                            v!.isEmpty ? 'Pin code is required' : null),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'State*',
                        hint: 'Enter State',
                        controller: stateController,
                        validator: (v) =>
                            v!.isEmpty ? 'State is required' : null),
                    const SizedBox(height: 16),
                    Obx(() => _buildDropdownField(
                        label: 'District / City*',
                        hint: controller.isPincodeLoading.value
                            ? 'Loading cities...'
                            : 'Select District / City',
                        items: controller.availableDistricts,
                        value: selectedCity,
                        validator: (v) =>
                            v == null ? 'City is required' : null)),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Documents & Disability Details'),
                    const SizedBox(height: 16),
                    _buildImagePickerField(
                        label: 'Choose Child photo',
                        path: childPhotoPath,
                        urlStr: childPhotoUrl),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'UDID Number',
                        hint: 'Enter UDID number',
                        controller: udidNumberController),
                    const SizedBox(height: 16),
                    _buildDocumentPickerField(
                        label: 'UDID Certificate',
                        path: udidCertPath,
                        urlStr: udidCertUrl),
                    const SizedBox(height: 16),
                    _buildDocumentPickerField(
                        label: 'Other ID Card',
                        path: otherIdPath,
                        urlStr: otherIdUrl),
                    const SizedBox(height: 16),
                    Obx(() => _buildMultiSelectField(
                        label: 'Disability Type*',
                        hint: controller.isDisabilityLoading.value
                            ? 'Loading disability types...'
                            : 'Select Disability Type',
                        items: controller.disabilityTypesList
                            .map((e) => e['label']?.toString() ?? '')
                            .toList(),
                        selectedItems: disabilityTypes)),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Address Details'),
                    const SizedBox(height: 16),
                    _buildTextField(
                        label: 'Permanent Address*',
                        hint: 'Enter permanent address',
                        controller: permanentAddressController,
                        maxLines: 3,
                        validator: (v) => v!.isEmpty
                            ? 'Permanent address is required'
                            : null),
                    const SizedBox(height: 8),
                    Obx(() => CheckboxListTile(
                          value: sameAsPermanent.value,
                          onChanged: (val) {
                            sameAsPermanent.value = val!;
                            if (val)
                              presentAddressController.text =
                                  permanentAddressController.text;
                          },
                          title: const Text(
                              'Present address is same as permanent address',
                              style: TextStyle(fontSize: 14)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppTheme.primaryColor,
                        )),
                    const SizedBox(height: 8),
                    _buildTextField(
                        label: 'Present Address*',
                        hint: 'Enter present address',
                        controller: presentAddressController,
                        maxLines: 3,
                        validator: (v) =>
                            v!.isEmpty ? 'Present address is required' : null),
                    const SizedBox(height: 24),
                    Obx(() => CheckboxListTile(
                          value: agreeToDeclaration.value,
                          onChanged: (val) => agreeToDeclaration.value = val!,
                          title: const Text(
                            'I declare that the information provided above is accurate to the best of my knowledge, and I accept responsibility for any incorrect or misleading details.',
                            style: TextStyle(fontSize: 12),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppTheme.primaryColor,
                        )),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: Obx(() => ElevatedButton(
                            onPressed: controller.isAddingStudent.value
                                ? null
                                : () {
                                    if (formKey.currentState!.validate()) {
                                      if (!agreeToDeclaration.value) {
                                        Get.snackbar('Declaration Required',
                                            'Please accept the declaration to proceed',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor:
                                                Colors.orange.withOpacity(0.1));
                                        return;
                                      }

                                      // Collect disability types
                                      // Note: The view uses a list of checkboxes or similar

                                      // Find selected professional ID
                                      List<String> profIds = [];
                                      if (assignedProfessional.value != null) {
                                        try {
                                          final prof = controller.educators
                                              .firstWhere((e) =>
                                                  "${e['firstName'] ?? ''} ${e['lastName'] ?? ''}"
                                                      .trim() ==
                                                  assignedProfessional.value);
                                          final id = prof['_id']?.toString() ??
                                              prof['id']?.toString();
                                          if (id != null) profIds.add(id);
                                        } catch (e) {
                                          print(
                                              'Error finding professional: $e');
                                        }
                                      }

                                      controller.addStudent(
                                        userName: usernameController.text,
                                        fullName: fullNameController.text,
                                        dateOfBirth: dobController.text,
                                        studentClass: studentClass.value,
                                        gender: gender.value!,
                                        parentName: parentNameController.text,
                                        parentEmail: parentEmailController.text,
                                        parentMobile:
                                            parentMobileController.text,
                                        parentRelation: parentRelation.value!,
                                        admissionDate:
                                            admissionDateController.text,
                                        pinCode: pinCodeController.text,
                                        state: stateController.text,
                                        district: selectedCity.value ?? '',
                                        localAddress:
                                            permanentAddressController.text,
                                        presentAddress: sameAsPermanent.value
                                            ? permanentAddressController.text
                                            : presentAddressController.text,
                                        certificateUDID:
                                            udidNumberController.text,
                                        numberUDID: udidNumberController.text,
                                        disability: disabilityTypes.toList(),
                                        studentDP: childPhotoUrl.value ?? '',
                                        idCard: otherIdUrl.value ?? '',
                                        assignedProfessionalIds: profIds,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: controller.isAddingStudent.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Register Student',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                          )),
                    ),
                    const SizedBox(height: 48),
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
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Get.back()),
          const SizedBox(width: 8),
          const Text('Add Student',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor)),
        const Divider(height: 20, thickness: 1),
      ],
    );
  }

  Widget _buildTextField(
      {required String label,
      required String hint,
      required TextEditingController controller,
      int maxLines = 1,
      bool isPassword = false,
      TextInputType keyboardType = TextInputType.text,
      int? maxLength,
      void Function(String)? onChanged,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          obscureText: isPassword,
          keyboardType: keyboardType,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context,
      {required String label,
      required String hint,
      required TextEditingController controller,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          validator: validator,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2101),
              builder: (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                          primary: AppTheme.primaryColor)),
                  child: child!),
            );
            if (pickedDate != null)
              controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.calendar_today,
                color: AppTheme.primaryColor, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      {required String label,
      required String hint,
      required List<String> items,
      required RxnString value,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<String>(
              value: value.value,
              isExpanded: true,
              hint: Text(hint, overflow: TextOverflow.ellipsis),
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (val) => value.value = val,
              validator: validator,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
              ),
            )),
      ],
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!)),
          child:
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildImagePickerField(
      {required String label,
      required RxnString path,
      required RxnString urlStr}) {
    final ImagePicker picker = ImagePicker();
    final isUploading = false.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Obx(() {
          if (isUploading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return InkWell(
            onTap: () async {
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                CroppedFile? croppedFile = await ImageCropper().cropImage(
                  sourcePath: image.path,
                  compressQuality: 50,
                  maxWidth: 800,
                  maxHeight: 800,
                  uiSettings: [
                    AndroidUiSettings(
                        toolbarTitle: 'Crop Image',
                        toolbarColor: AppTheme.primaryColor,
                        toolbarWidgetColor: Colors.white,
                        initAspectRatio: CropAspectRatioPreset.original,
                        lockAspectRatio: false),
                    IOSUiSettings(
                      title: 'Crop Image',
                    ),
                  ],
                );
                if (croppedFile != null) {
                  isUploading.value = true;
                  try {
                    final apiProvider = Get.find<ApiProvider>();
                    final File file = File(croppedFile.path);

                    final res1 = await apiProvider.uploadProfileImage(file);
                    print(
                        "Response for image ${res1.body} and status code ${res1.statusCode}");
                    if (res1.statusCode == 200 || res1.statusCode == 201) {
                      final res2 = await apiProvider.uploadFilePortal(file);
                      print(
                          "Response for file ${res2.body} and status code ${res2.statusCode}");
                      if (res2.statusCode == 200 || res2.statusCode == 201) {
                        path.value = croppedFile.path;
                        if (res2.body is Map) {
                          urlStr.value = res2.body['fileId']?.toString() ??
                              res2.body['data']?.toString() ??
                              res2.body['url']?.toString();
                        }
                        Get.snackbar('Success',
                            'Image cropped and uploaded successfully!',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.withOpacity(0.1));
                      } else {
                        Get.snackbar(
                            'Upload Error', 'Failed to upload photo to portal',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.1));
                      }
                    } else {
                      Get.snackbar('Upload Error',
                          'Failed to upload profile image format',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.1));
                    }
                  } catch (e) {
                    Get.snackbar('Error', 'An error occurred during upload',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.1));
                  } finally {
                    isUploading.value = false;
                  }
                }
              }
            },
            child: path.value != null
                ? Stack(
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          image: DecorationImage(
                            image: FileImage(File(path.value!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            path.value = null;
                            urlStr.value = null;
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_photo_alternate,
                            color: AppTheme.primaryColor),
                        SizedBox(width: 12),
                        Text('Choose Photo',
                            style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
          );
        }),
      ],
    );
  }

  Widget _buildDocumentPickerField(
      {required String label,
      required RxnString path,
      required RxnString urlStr}) {
    final isUploading = false.obs;
    final imageExts = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Obx(() {
          if (isUploading.value) {
            return Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (path.value != null) {
            final ext = path.value!.split('.').last.toLowerCase();
            final isImage = imageExts.contains(ext);
            return Stack(
              children: [
                isImage
                    ? Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          image: DecorationImage(
                            image: FileImage(File(path.value!)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                path.value!.split(Platform.pathSeparator).last,
                                style: const TextStyle(color: Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      path.value = null;
                      urlStr.value = null;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            );
          }

          return InkWell(
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'bmp'],
              );
              if (result != null && result.files.single.path != null) {
                isUploading.value = true;
                try {
                  final apiProvider = Get.find<ApiProvider>();
                  final File file = File(result.files.single.path!);
                  final res = await apiProvider.uploadFilePortal(file);
                  if (res.statusCode == 200 || res.statusCode == 201) {
                    path.value = result.files.single.path;
                    if (res.body is Map) {
                      urlStr.value = res.body['fileId']?.toString() ??
                          res.body['data']?.toString() ??
                          res.body['url']?.toString();
                    }
                    Get.snackbar('Success', '$label uploaded successfully!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green.withOpacity(0.1));
                  } else {
                    Get.snackbar('Upload Error', 'Failed to upload $label',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red.withOpacity(0.1));
                  }
                } catch (e) {
                  Get.snackbar('Error', 'An error occurred during upload',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.1));
                } finally {
                  isUploading.value = false;
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.upload_file, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Text('Choose $label',
                      style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMultiSelectField(
      {required String label,
      required String hint,
      required List<String> items,
      required RxList<String> selectedItems}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            Get.dialog(
              AlertDialog(
                title: Text(hint),
                content: SingleChildScrollView(
                  child: Column(
                    children: items
                        .map((item) => Obx(() => CheckboxListTile(
                              title: Text(item),
                              value: selectedItems.contains(item),
                              onChanged: (val) {
                                if (val!)
                                  selectedItems.add(item);
                                else
                                  selectedItems.remove(item);
                              },
                              activeColor: AppTheme.primaryColor,
                            )))
                        .toList(),
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Get.back(), child: const Text('OK'))
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Obx(() => Text(
                        selectedItems.isEmpty ? hint : selectedItems.join(', '),
                        style: TextStyle(
                            color: selectedItems.isEmpty
                                ? Colors.grey
                                : Colors.black87),
                        overflow: TextOverflow.ellipsis))),
                const Icon(Icons.arrow_drop_down,
                    color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
