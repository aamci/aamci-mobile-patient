class AppointmentModel {
  final String id;
  final String slotId;
  final String patientId;
  final String? kindId;
  final String? notes;
  final String status;
  final String type;
  final DateTime createdAt;
  final String? facilityName;
  final String? facilityAddress;
  final AppointmentSlot? slot;
  final AppointmentPatient? patient;
  final AppointmentKind? kind;
  final AppointmentDoctor? doctor;

  AppointmentModel({
    required this.id,
    required this.slotId,
    required this.patientId,
    this.kindId,
    this.notes,
    required this.status,
    required this.type,
    required this.createdAt,
    this.facilityName,
    this.facilityAddress,
    this.slot,
    this.patient,
    this.kind,
    this.doctor,
  });

  String? get doctorName => doctor?.fullName ?? slot?.doctorName;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final facility = json['facility'] as Map<String, dynamic>?;
    final facilityCity = facility?['city']?.toString();
    final facilityAddr = facility?['address']?.toString();
    final fullAddress = [facilityAddr, facilityCity].where((s) => s != null && s.isNotEmpty).join(', ');

    return AppointmentModel(
      id: json['id']?.toString() ?? '',
      slotId: json['slotId']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      kindId: json['kindId']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      type: json['type']?.toString() ?? 'CONSULTATION',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      facilityName: facility?['name']?.toString(),
      facilityAddress: fullAddress.isNotEmpty ? fullAddress : null,
      slot: json['slot'] is Map
          ? AppointmentSlot.fromJson(json['slot'] as Map<String, dynamic>)
          : null,
      patient: json['patient'] is Map
          ? AppointmentPatient.fromJson(json['patient'] as Map<String, dynamic>)
          : null,
      kind: json['kind'] is Map
          ? AppointmentKind.fromJson(json['kind'] as Map<String, dynamic>)
          : null,
      doctor: json['doctor'] is Map
          ? AppointmentDoctor.fromJson(json['doctor'] as Map<String, dynamic>)
          : null,
    );
  }

  bool get isUpcoming =>
      slot != null && slot!.start.isAfter(DateTime.now()) && status != 'CANCELLED';

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'CONFIRMED':
        return 'Confirmé';
      case 'CANCELLED':
        return 'Annulé';
      case 'COMPLETED':
        return 'Terminé';
      case 'NO_SHOW':
        return 'Absent';
      default:
        return status;
    }
  }
}

class AppointmentSlot {
  final String id;
  final String ownerId;
  final DateTime start;
  final DateTime end;
  final String? doctorName;

  AppointmentSlot({
    required this.id,
    required this.ownerId,
    required this.start,
    required this.end,
    this.doctorName,
  });

  factory AppointmentSlot.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>?;
    return AppointmentSlot(
      id: json['id']?.toString() ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      start: DateTime.tryParse(json['start']?.toString() ?? '') ?? DateTime.now(),
      end: DateTime.tryParse(json['end']?.toString() ?? '') ?? DateTime.now(),
      doctorName: owner?['fullName']?.toString(),
    );
  }
}

class AppointmentDoctor {
  final String id;
  final String? fullName;

  AppointmentDoctor({required this.id, this.fullName});

  factory AppointmentDoctor.fromJson(Map<String, dynamic> json) {
    return AppointmentDoctor(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
    );
  }
}

class AppointmentPatient {
  final String id;
  final String? fullName;
  final String email;

  AppointmentPatient({
    required this.id,
    this.fullName,
    required this.email,
  });

  factory AppointmentPatient.fromJson(Map<String, dynamic> json) {
    return AppointmentPatient(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      email: json['email']?.toString() ?? '',
    );
  }
}

class AppointmentKind {
  final String id;
  final String name;
  final int durationMins;
  final double? price;
  final String? description;
  final bool isTelemedicine;

  AppointmentKind({
    required this.id,
    required this.name,
    required this.durationMins,
    this.price,
    this.description,
    this.isTelemedicine = false,
  });

  factory AppointmentKind.fromJson(Map<String, dynamic> json) {
    return AppointmentKind(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      durationMins: (json['durationMins'] as num?)?.toInt() ?? 0,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      description: json['description']?.toString(),
      isTelemedicine: json['isTelemedicine'] == true,
    );
  }
}
