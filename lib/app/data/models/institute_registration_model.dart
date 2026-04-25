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
      "isTermsAndConditionsAccepted": isTermsAndConditionsAccepted,
    };
  }
}
