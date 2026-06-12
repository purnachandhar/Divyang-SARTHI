class InstituteRegistrationRequest {
  final String roles;
  final String organisation;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String mobile;
  final String designation;
  final String landLineNumber;
  final bool isTermsAndConditionsAccepted;
  final String schoolType;
  final bool isNipiedDisha;
  final Map<String, dynamic>? address;

  InstituteRegistrationRequest({
    required this.roles,
    required this.organisation,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.mobile,
    required this.designation,
    required this.landLineNumber,
    required this.isTermsAndConditionsAccepted,
    this.schoolType = '',
    this.isNipiedDisha = false,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      "roles": roles,
      "organisation": organisation,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "mobile": mobile,
      "designation": designation,
      "landLineNumber": landLineNumber,
      "schoolType": schoolType,
      if (address != null) "address": address,
      "isNipiedDisha": isNipiedDisha,
      "isTermsAndConditionsAccepted": isTermsAndConditionsAccepted,
    };
  }
}
