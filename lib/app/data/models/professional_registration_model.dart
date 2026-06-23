class Address {
  final String pinCode;
  final String localAddress;
  final String district;
  final String state;
  final String country;

  Address({
    required this.pinCode,
    required this.localAddress,
    required this.district,
    required this.state,
    this.country = 'India',
  });

  Map<String, dynamic> toJson() {
    return {
      "pinCode": pinCode,
      "localAddress": localAddress,
      "district": district,
      "state": state,
      "country": country,
    };
  }
}

class ProfessionalRegistrationRequest {
  final String roles;
  final String organisation;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String mobile;
  final String userDP;
  final bool isTermsAndConditionsAccepted;
  final String qualification;
  final String? crrNumber;
  final String? designation;
  final Address address;
  final bool isApproved;
  final bool isNipiedDisha;

  ProfessionalRegistrationRequest({
    required this.roles,
    required this.organisation,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.mobile,
    required this.userDP,
    required this.isTermsAndConditionsAccepted,
    required this.qualification,
    this.crrNumber,
    this.designation,
    required this.address,
    this.isApproved = false,
    this.isNipiedDisha = false,
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
      "userDP": userDP,
      "isTermsAndConditionsAccepted": isTermsAndConditionsAccepted,
      "qualification": qualification,
      if (crrNumber != null && crrNumber!.isNotEmpty) "crrNumber": crrNumber,
      if (designation != null && designation!.isNotEmpty)
        "designation": designation,
      "address": address.toJson(),
      "isApproved": isApproved,
      "isNipiedDisha": isNipiedDisha,
    };
  }
}
