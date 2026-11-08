import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final double rating;
  final int reviewCount;
  final String clinicAddress;
  final double ticketPrice;
  final String photoUrl;
  final String about;
  final String education;
  final String experience;
  final List<String> availableDays;
  final List<String> availableSlots;

  DoctorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    this.rating = 5.0,
    this.reviewCount = 0,
    required this.clinicAddress,
    required this.ticketPrice,
    required this.photoUrl,
    required this.about,
    required this.education,
    required this.experience,
    required this.availableDays,
    required this.availableSlots,
  });

  factory DoctorModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return DoctorModel(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      specialty: data['specialty'] ?? 'General Physician',
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 5.0,
      reviewCount: (data['reviewCount'] is num) ? (data['reviewCount'] as num).toInt() : 0,
      clinicAddress: data['clinicAddress'] ?? '',
      ticketPrice: (data['ticketPrice'] is num)
          ? (data['ticketPrice'] as num).toDouble()
          : 500.0,
      photoUrl: data['photoUrl'] ?? '',
      about: data['about'] ?? '',
      education: data['education'] ?? '',
      experience: data['experience'] ?? '',
      availableDays: List<String>.from(data['availableDays'] ?? ['Monday', 'Wednesday', 'Friday']),
      availableSlots: List<String>.from(data['availableSlots'] ?? ['10:00 AM - 11:30 AM', '11:30 AM - 02:30 PM']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'specialty': specialty,
      'rating': rating,
      'reviewCount': reviewCount,
      'clinicAddress': clinicAddress,
      'ticketPrice': ticketPrice,
      'photoUrl': photoUrl,
      'about': about,
      'education': education,
      'experience': experience,
      'availableDays': availableDays,
      'availableSlots': availableSlots,
    };
  }
}
