class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String? doctorSpecialty;
  final String patientId;
  final String patientName;
  final DateTime appointmentDateTime;
  final String reason;
  final String? notes;
  final AppointmentStatus status;
  final bool useInsurance;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    this.doctorSpecialty,
    required this.patientId,
    required this.patientName,
    required this.appointmentDateTime,
    required this.reason,
    this.notes,
    required this.status,
    this.useInsurance = false,
    this.insuranceProvider,
    this.insuranceNumber,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppointmentModel.fromMap(String id, Map<String, dynamic> map) {
    return AppointmentModel(
      id: id,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialty: map['doctorSpecialty'],
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      appointmentDateTime: _parseDateTime(map['appointmentDateTime']),
      reason: map['reason'] ?? '',
      notes: map['notes'],
      status: _parseStatus(map['status']),
      useInsurance: map['useInsurance'] ?? false,
      insuranceProvider: map['insuranceProvider'],
      insuranceNumber: map['insuranceNumber'],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'patientId': patientId,
      'patientName': patientName,
      'appointmentDateTime': appointmentDateTime.toUtc(),
      'reason': reason,
      'notes': notes,
      'status': status.toString().split('.').last,
      'useInsurance': useInsurance,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'createdAt': createdAt.toUtc(),
      'updatedAt': updatedAt?.toUtc(),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    return DateTime.parse(value.toString());
  }

  static AppointmentStatus _parseStatus(dynamic value) {
    if (value == null) return AppointmentStatus.pending;
    final statusString = value.toString().toLowerCase();
    return AppointmentStatus.values.firstWhere(
          (status) => status.toString().split('.').last.toLowerCase() == statusString,
      orElse: () => AppointmentStatus.pending,
    );
  }
}

enum AppointmentStatus {
  pending,
  confirmed,
  cancelled,
  completed
}