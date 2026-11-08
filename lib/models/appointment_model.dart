import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String patientId;
  final String patientName;
  final String patientEmail;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String doctorPhotoUrl;
  final DateTime appointmentDate;
  final String timeSlot;
  final String disease;
  final double fee;
  final String status; // 'pending', 'confirmed', 'rejected', 'completed'
  final String paymentStatus; // 'paid', 'pending'
  final DateTime? createdAt;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientEmail,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.doctorPhotoUrl,
    required this.appointmentDate,
    required this.timeSlot,
    required this.disease,
    required this.fee,
    this.status = 'pending',
    this.paymentStatus = 'paid',
    this.createdAt,
  });

  factory AppointmentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return AppointmentModel(
      id: snapshot.id,
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientEmail: data['patientEmail'] ?? '',
      patientPhone: data['patientPhone'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialty: data['doctorSpecialty'] ?? '',
      doctorPhotoUrl: data['doctorPhotoUrl'] ?? '',
      appointmentDate: (data['appointmentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timeSlot: data['timeSlot'] ?? '',
      disease: data['disease'] ?? '',
      fee: (data['fee'] is num) ? (data['fee'] as num).toDouble() : 0.0,
      status: data['status'] ?? 'pending',
      paymentStatus: data['paymentStatus'] ?? 'paid',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientPhone': patientPhone,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'doctorPhotoUrl': doctorPhotoUrl,
      'appointmentDate': Timestamp.fromDate(appointmentDate),
      'timeSlot': timeSlot,
      'disease': disease,
      'fee': fee,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
