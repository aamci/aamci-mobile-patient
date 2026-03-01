class DoctorProfile {
  final String id;
  final String? presentation;
  final String? specialty;
  final String? city;

  DoctorProfile({
    required this.id,
    this.presentation,
    this.specialty,
    this.city,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> json) {
    return DoctorProfile(
      id: json['id'] as String,
      presentation: json['presentation'] as String?,
      specialty: json['specialty'] as String?,
      city: json['city'] as String?,
    );
  }
}

class DoctorModel {
  final String id;
  final String? fullName;
  final String email;
  final String? city;
  final String? avatarUrl;
  final DoctorProfile? doctorProfile;

  DoctorModel({
    required this.id,
    this.fullName,
    required this.email,
    this.city,
    this.avatarUrl,
    this.doctorProfile,
  });

  String get displayName => fullName ?? email;
  String get specialty => doctorProfile?.specialty ?? 'Médecin';
  String get displayCity => doctorProfile?.city ?? city ?? '';

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String?,
      email: json['email'] as String,
      city: json['city'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      doctorProfile: json['doctorProfile'] != null
          ? DoctorProfile.fromJson(json['doctorProfile'] as Map<String, dynamic>)
          : null,
    );
  }
}
