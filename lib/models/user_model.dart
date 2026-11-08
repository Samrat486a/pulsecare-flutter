import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid; // PatientID / DoctorID
  final String name;
  final String email;
  final String phone;
  final String role; // 'patient' or 'doctor'
  final double? weight;
  final int? height;
  final String? region;
  final String? national;
  final String? bloodType;
  final String? personalDisease;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.weight,
    this.height,
    this.region,
    this.national = 'Indian',
    this.bloodType = 'O+',
    this.personalDisease = '',
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'patient',
      weight: (data['weight'] is num) ? (data['weight'] as num).toDouble() : null,
      height: (data['height'] is num) ? (data['height'] as num).toInt() : null,
      region: data['region'] ?? 'West Bengal',
      national: data['national'] ?? 'Indian',
      bloodType: data['bloodType'] ?? 'O+',
      personalDisease: data['personalDisease'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'weight': weight,
      'height': height,
      'region': region,
      'national': national,
      'bloodType': bloodType,
      'personalDisease': personalDisease,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
