import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/doctor_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role, // 'patient' or 'doctor'
    String specialty = 'General Physician',
    double ticketPrice = 800.0,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('User creation failed');
    }

    final userModel = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );

    // Save to users collection
    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

    // If doctor, initialize doctor profile
    if (role == 'doctor') {
      final doctorModel = DoctorModel(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        specialty: specialty,
        rating: 5.0,
        reviewCount: 1,
        clinicAddress: 'DMS & Private Clinic',
        ticketPrice: ticketPrice,
        photoUrl: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=400&auto=format&fit=crop&q=80',
        about: 'Dedicated $specialty specialist offering comprehensive diagnosis, treatment, and preventive care.',
        education: 'MBBS, MD',
        experience: '5+ years clinical experience',
        availableDays: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
        availableSlots: [
          '09:00 AM - 10:30 AM',
          '11:00 AM - 12:30 PM',
          '02:00 PM - 03:30 PM',
          '05:00 PM - 06:30 PM',
        ],
      );
      await _firestore.collection('doctors').doc(user.uid).set(doctorModel.toMap());
    }

    return userModel;
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) return null;

    return await getUserProfile(user.uid);
  }

  // Fetch User Profile
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
