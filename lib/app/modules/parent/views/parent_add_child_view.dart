import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_gradients.dart';
import '../../../utils/responsive_layout.dart';

class ParentAddChildView extends StatefulWidget {
  const ParentAddChildView({super.key});

  @override
  State<ParentAddChildView> createState() => _ParentAddChildViewState();
}

class _ParentAddChildViewState extends State<ParentAddChildView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final udidController = TextEditingController();
  final admissionDateController = TextEditingController();
  final pinCodeController = TextEditingController();
  final permanentAddressController = TextEditingController();
  final presentAddressController = TextEditingController();

  // State
  String? selectedClass;
  String? selectedDisability;
  String? selectedHomeSchool;
  String? selectedGender;
  String? selectedRelation;
  String? selectedCaregiver;
  String? selectedState;
  String? selectedDistrict;
  String? selectedConditions;
  bool sameAsPermanent = false;
  bool isEnrolledInSchool = false;
  bool declarationAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ResponsiveLayout(
                mobile: _buildFormLayout(isMobile: true),
                desktop: _buildFormLayout(isMobile: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLayout({required bool isMobile}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Details'),
          isMobile 
            ? Column(
                children: [
                  _buildInputField('Username*', 'Enter username', usernameController),
                  _buildInputField('Full Name*', 'Enter full name', fullNameController),
                  _buildDateField('Date of birth*', 'dd-mm-yyyy', dobController),
                  _buildDropdownField('Class (optional)', 'Select a class', ['Grade 1', 'Grade 2', 'Grade 3'], (val) => setState(() => selectedClass = val)),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInputField('Username*', 'Enter username', usernameController)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInputField('Full Name*', 'Enter full name', fullNameController)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDateField('Date of birth*', 'dd-mm-yyyy', dobController)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdownField('Class (optional)', 'Select a class', ['Grade 1', 'Grade 2', 'Grade 3'], (val) => setState(() => selectedClass = val))),
                ],
              ),
          _buildPhotoPicker(),
          
          const SizedBox(height: 30),
          _buildSectionTitle('Registration Details'),
          isMobile
            ? Column(
                children: [
                  _buildInputField('UDID Number', 'Enter UDID number', udidController),
                  _buildDropdownField('Disability Type*', 'Select Disability Type', ['Visual Impairment', 'Hearing Impairment', 'Locomotor Disability'], (val) => setState(() => selectedDisability = val)),
                  _buildDropdownField('Home School*', 'Select Yes or No', ['Yes', 'No'], (val) => setState(() => selectedHomeSchool = val)),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInputField('UDID Number', 'Enter UDID number', udidController)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdownField('Disability Type*', 'Select Disability Type', ['Visual Impairment', 'Hearing Impairment', 'Locomotor Disability'], (val) => setState(() => selectedDisability = val))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdownField('Home School*', 'Select Yes or No', ['Yes', 'No'], (val) => setState(() => selectedHomeSchool = val))),
                ],
              ),
          
          isMobile
            ? Column(
                children: [
                  _buildFilePicker('UDID Certificate'),
                  _buildDropdownField('Gender*', 'Select a gender', ['Male', 'Female', 'Other'], (val) => setState(() => selectedGender = val)),
                  _buildDropdownField('Parent Relation*', 'Select relation', ['Father', 'Mother', 'Guardian'], (val) => setState(() => selectedRelation = val)),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildFilePicker('UDID Certificate')),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdownField('Gender*', 'Select a gender', ['Male', 'Female', 'Other'], (val) => setState(() => selectedGender = val))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdownField('Parent Relation*', 'Select relation', ['Father', 'Mother', 'Guardian'], (val) => setState(() => selectedRelation = val))),
                ],
              ),

          isMobile
            ? Column(
                children: [
                  _buildDropdownField('Primary Caregiver*', 'Select Primary Caregiver', ['Mother', 'Father', 'Both', 'Nurse'], (val) => setState(() => selectedCaregiver = val)),
                  _buildFilePicker('Other ID Card'),
                  _buildDateField('Admission Date*', 'dd-mm-yyyy', admissionDateController),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDropdownField('Primary Caregiver*', 'Select Primary Caregiver', ['Mother', 'Father', 'Both', 'Nurse'], (val) => setState(() => selectedCaregiver = val))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildFilePicker('Other ID Card')),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDateField('Admission Date*', 'dd-mm-yyyy', admissionDateController)),
                ],
              ),

          const SizedBox(height: 30),
          _buildSectionTitle('Address & Enrollment'),
          isMobile
            ? Column(
                children: [
                  _buildInputField('Country*', 'India', TextEditingController(text: 'India'), enabled: false),
                  _buildDropdownField('State*', 'Select State', ['Uttar Pradesh', 'Delhi', 'Maharashtra'], (val) => setState(() => selectedState = val)),
                  _buildDropdownField('District / City*', 'Select district / city', ['Lucknow', 'Noida', 'Mumbai'], (val) => setState(() => selectedDistrict = val)),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInputField('Country*', 'India', TextEditingController(text: 'India'), enabled: false)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdownField('State*', 'Select State', ['Uttar Pradesh', 'Delhi', 'Maharashtra'], (val) => setState(() => selectedState = val))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdownField('District / City*', 'Select district / city', ['Lucknow', 'Noida', 'Mumbai'], (val) => setState(() => selectedDistrict = val))),
                ],
              ),

          isMobile
            ? Column(
                children: [
                  _buildInputField('Pin Code / Postal Code*', 'Enter your pin code', pinCodeController, keyboardType: TextInputType.number),
                  _buildDropdownField('Associated Conditions', 'Select Associated Conditions', ['ADHD', 'Epilepsy', 'None'], (val) => setState(() => selectedConditions = val)),
                  _buildInputField('Permanent Address*', 'Enter permanent address', permanentAddressController, maxLines: 3),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildInputField('Pin Code / Postal Code*', 'Enter your pin code', pinCodeController, keyboardType: TextInputType.number)),
                  const SizedBox(width: 20),
                  Expanded(child: _buildDropdownField('Associated Conditions', 'Select Associated Conditions', ['ADHD', 'Epilepsy', 'None'], (val) => setState(() => selectedConditions = val))),
                  const SizedBox(width: 20),
                  Expanded(child: _buildInputField('Permanent Address*', 'Enter permanent address', permanentAddressController, maxLines: 3)),
                ],
              ),
          
          CheckboxListTile(
            value: sameAsPermanent,
            onChanged: (val) {
              setState(() {
                sameAsPermanent = val ?? false;
                if (sameAsPermanent) {
                  presentAddressController.text = permanentAddressController.text;
                }
              });
            },
            title: const Text('Present address is same as permanent address', style: TextStyle(fontSize: 13)),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppTheme.primaryColor,
          ),
          
          if (!sameAsPermanent)
            _buildInputField('Present Address*', 'Enter present address', presentAddressController, maxLines: 3),
          
          SwitchListTile(
            value: isEnrolledInSchool,
            onChanged: (val) => setState(() => isEnrolledInSchool = val),
            title: const Text('Is child enrolled in school?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primaryColor,
          ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: declarationAccepted,
                  onChanged: (val) => setState(() => declarationAccepted = val ?? false),
                  activeColor: AppTheme.primaryColor,
                ),
                const Expanded(
                  child: Text(
                    'I declare that the information provided above is accurate to the best of my knowledge, and I accept responsibility for any incorrect or misleading details.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: isMobile ? double.infinity : 300,
              height: 55,
              child: ElevatedButton(
                onPressed: declarationAccepted ? () {
                  Get.back();
                  Get.snackbar('Success', 'Child profile added successfully',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green.withOpacity(0.1),
                      colorText: Colors.green);
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: const Text('Add Child', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 16, right: 16),
      decoration: const BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              const Expanded(
                child: Text(
                  'Add Child',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool enabled = true, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[100],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
                setState(() => controller.text = formattedDate);
              }
            },
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppTheme.primaryColor),
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String hint, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontSize: 14)));
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choose Child photo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            ),
            child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePicker(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.attach_file, color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 12),
                Text('No file selected', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                const Spacer(),
                Text('Browse', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
