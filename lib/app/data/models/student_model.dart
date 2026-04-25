class StudentModel {
  final String id;
  final String fullName;
  final String username;
  final String enrollmentId;
  final String className;
  final String gender;
  final String dateOfBirth;
  final String status;
  final String? profilePhoto;
  final List<String> disability;
  final StudentAddress? address;
  final ParentDetails? parentDetails;
  final UdidDetails? udid;
  final List<String> classHistory;
  final String admissionDate;
  final String parentRelation;
  final bool isVerified;
  final String addedBy;
  final String organisation;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> rawJson;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.enrollmentId,
    required this.className,
    required this.gender,
    required this.dateOfBirth,
    required this.status,
    this.profilePhoto,
    this.disability = const [],
    this.address,
    this.parentDetails,
    this.udid,
    this.classHistory = const [],
    this.admissionDate = '',
    this.parentRelation = '',
    this.isVerified = false,
    this.addedBy = '',
    this.organisation = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.rawJson = const {},
  });

  String get displayName => fullName;

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['userName'] ?? json['username'] ?? '',
      enrollmentId: json['enrollmentNumber'] ??
          json['enrollmentId'] ??
          json['enrollment'] ??
          '',
      className: json['class'] ?? json['className'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? json['dob'] ?? '',
      status: json['profileStatus'] ?? json['status'] ?? 'Active',
      profilePhoto: json['studentDP'] ?? json['profilePhoto'] ?? json['userDP'],
      disability: List<String>.from(json['disability'] ?? []),
      address: json['address'] != null
          ? StudentAddress.fromJson(json['address'])
          : null,
      parentDetails: json['ParentDetails'] != null
          ? ParentDetails.fromJson(json['ParentDetails'])
          : null,
      udid: json['udid'] != null ? UdidDetails.fromJson(json['udid']) : null,
      classHistory: List<String>.from(json['classHistory'] ?? []),
      admissionDate: json['admissionDate'] ?? '',
      parentRelation: json['parentRelation'] ?? '',
      isVerified: json['isVerified'] ?? false,
      addedBy: json['addedBy'] ?? '',
      organisation: json['organisation'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      rawJson: json,
    );
  }

  Map<String, dynamic> toFullMap() {
    return rawJson;
  }

  Map<String, String> toDisplayMap() {
    return {
      'name': displayName,
      'username': username,
      'enrollment': enrollmentId,
      'class': className,
      'gender': gender,
      'dob': dateOfBirth,
      'status': status,
    };
  }
}

class StudentAddress {
  final String country;
  final String pinCode;
  final String localAddress;
  final String presentAddress;
  final String district;
  final String state;

  StudentAddress({
    required this.country,
    required this.pinCode,
    required this.localAddress,
    required this.presentAddress,
    required this.district,
    required this.state,
  });

  factory StudentAddress.fromJson(Map<String, dynamic> json) {
    return StudentAddress(
      country: json['country'] ?? '',
      pinCode: json['pinCode']?.toString() ?? '',
      localAddress: json['localAddress'] ?? '',
      presentAddress: json['presentAddress'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
    );
  }
}

class ParentDetails {
  final String parentName;
  final String contactNumber;
  final String email;

  ParentDetails({
    required this.parentName,
    required this.contactNumber,
    required this.email,
  });

  factory ParentDetails.fromJson(Map<String, dynamic> json) {
    return ParentDetails(
      parentName: json['parentName'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class UdidDetails {
  final String certificateUDID;
  final String numberUDID;

  UdidDetails({
    required this.certificateUDID,
    required this.numberUDID,
  });

  factory UdidDetails.fromJson(Map<String, dynamic> json) {
    return UdidDetails(
      certificateUDID: json['certificateUDID'] ?? '',
      numberUDID: json['numberUDID'] ?? '',
    );
  }
}
