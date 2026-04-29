class EducatorModel {
  final Address? address;
  final List<String>? roles;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobile;
  final String? designation;
  final String? qualification;
  final String? crrNumber;
  final String? uniqueNumber;
  final Organisation? organisation;
  final bool? isNipiedDisha;

  EducatorModel({
    this.address,
    this.roles,
    this.firstName,
    this.lastName,
    this.email,
    this.mobile,
    this.designation,
    this.qualification,
    this.crrNumber,
    this.uniqueNumber,
    this.organisation,
    this.isNipiedDisha,
  });

  factory EducatorModel.fromJson(Map<String, dynamic> json) {
    return EducatorModel(
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      designation: json['designation']?.toString(),
      qualification: json['qualification']?.toString(),
      crrNumber: json['cRRNumber']?.toString() ?? json['crrNumber']?.toString(),
      uniqueNumber: json['uniqueNumber']?.toString(),
      organisation: json['organisation'] is Map<String, dynamic> 
          ? Organisation.fromJson(json['organisation']) 
          : null,
      isNipiedDisha: json['isNipiedDisha'] == true,
    );
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

class Address {
  final String? country;
  final String? pinCode;
  final String? localAddress;
  final String? district;
  final String? state;

  Address({
    this.country,
    this.pinCode,
    this.localAddress,
    this.district,
    this.state,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      country: json['country']?.toString(),
      pinCode: json['pinCode']?.toString(),
      localAddress: json['localAddress']?.toString(),
      district: json['district']?.toString(),
      state: json['state']?.toString(),
    );
  }
}

class Organisation {
  final String? id;
  final String? schoolName;
  final String? email;
  final String? address;
  final String? district;
  final String? state;

  Organisation({
    this.id,
    this.schoolName,
    this.email,
    this.address,
    this.district,
    this.state,
  });

  factory Organisation.fromJson(Map<String, dynamic> json) {
    return Organisation(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      schoolName: json['schoolName']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      district: json['district']?.toString(),
      state: json['state']?.toString(),
    );
  }
}
