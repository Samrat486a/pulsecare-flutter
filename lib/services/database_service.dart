import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import 'seed_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal() {
    _initFallbackData();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local reactive cache for offline / demo presentation resilience
  final List<AppointmentModel> _localAppointments = [];
  final StreamController<List<AppointmentModel>> _appointmentsController =
      StreamController<List<AppointmentModel>>.broadcast();

  void _initFallbackData() {
    // Pre-populate with realistic clinical appointments for instant live demo
    if (_localAppointments.isEmpty) {
      _localAppointments.addAll([
        AppointmentModel(
          id: 'apt_demo_101',
          patientId: 'patient_demo_vip_001',
          patientName: 'Rahul Sharma',
          patientEmail: 'patient.demo@mail.com',
          patientPhone: '+91 98765 00000',
          doctorId: 'doc_ashis_ghosh',
          doctorName: 'Dr. Ashis Ghosh',
          doctorSpecialty: 'Surgeon',
          doctorPhotoUrl:
              'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=500&auto=format&fit=crop&q=80',
          appointmentDate: DateTime.now().add(const Duration(days: 1)),
          timeSlot: '10:00 AM - 11:30 AM',
          disease: 'Follow-up consultation for post-operative recovery check',
          fee: 1000.0,
          status: 'confirmed',
          paymentStatus: 'paid',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        AppointmentModel(
          id: 'apt_demo_102',
          patientId: 'patient_demo_vip_001',
          patientName: 'Rahul Sharma',
          patientEmail: 'patient.demo@mail.com',
          patientPhone: '+91 98765 00000',
          doctorId: 'doc_vivek_roy',
          doctorName: 'Dr. Vivek Roy',
          doctorSpecialty: 'Cardiologist',
          doctorPhotoUrl:
              'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=500&auto=format&fit=crop&q=80',
          appointmentDate: DateTime.now().add(const Duration(days: 3)),
          timeSlot: '02:00 PM - 03:30 PM',
          disease: 'Routine annual cardiovascular checkup & ECG review',
          fee: 1500.0,
          status: 'pending',
          paymentStatus: 'paid',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ]);
    }
  }

  // Doctors Collection Reference
  CollectionReference<Map<String, dynamic>> get _doctorsCol =>
      _firestore.collection('doctors');

  // Appointments Collection Reference
  CollectionReference<Map<String, dynamic>> get _appointmentsCol =>
      _firestore.collection('appointments');

  // Seed sample doctors if collection is empty
  Future<void> seedInitialDoctorsIfEmpty() async {
    try {
      final snapshot = await _doctorsCol.limit(1).get().timeout(const Duration(seconds: 3));
      if (snapshot.docs.isEmpty) {
        for (var doc in SeedData.initialDoctors) {
          await _doctorsCol.doc(doc.id).set(doc.toMap());
        }
      }
    } catch (e) {
      // Ignored if permissions are restricted or offline
    }
  }

  // Stream all doctors (falls back to seed data if firestore has permissions/offline issue)
  Stream<List<DoctorModel>> getDoctorsStream() {
    try {
      return _doctorsCol.snapshots().map(
        (snapshot) {
          if (snapshot.docs.isEmpty) {
            return SeedData.initialDoctors;
          }
          return snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
        },
      ).handleError((_) => SeedData.initialDoctors);
    } catch (_) {
      return Stream.value(SeedData.initialDoctors);
    }
  }

  // Stream a specific doctor by ID
  Stream<DoctorModel?> getDoctorStream(String doctorId) {
    try {
      return _doctorsCol.doc(doctorId).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          return DoctorModel.fromFirestore(doc);
        }
        return SeedData.initialDoctors.firstWhere(
          (d) => d.id == doctorId,
          orElse: () => SeedData.initialDoctors.first,
        );
      }).handleError((_) {
        return SeedData.initialDoctors.firstWhere(
          (d) => d.id == doctorId,
          orElse: () => SeedData.initialDoctors.first,
        );
      });
    } catch (_) {
      return Stream.value(SeedData.initialDoctors.firstWhere(
        (d) => d.id == doctorId,
        orElse: () => SeedData.initialDoctors.first,
      ));
    }
  }

  // Update Doctor Profile
  Future<void> updateDoctorProfile(DoctorModel doctor) async {
    try {
      await _doctorsCol.doc(doctor.id).update(doctor.toMap());
    } catch (_) {}
  }

  // Book an Appointment
  Future<String> bookAppointment(AppointmentModel appointment) async {
    // Add to local cache immediately for instant UI update
    _localAppointments.insert(0, appointment);
    _appointmentsController.add(List.from(_localAppointments));

    try {
      final docRef = await _appointmentsCol.add(appointment.toMap()).timeout(const Duration(seconds: 4));
      return docRef.id;
    } catch (e) {
      // Return local ID if Firestore is offline
      return appointment.id;
    }
  }

  // Stream Patient's Appointments
  Stream<List<AppointmentModel>> getPatientAppointmentsStream(String patientId) {
    try {
      return _appointmentsCol
          .where('patientId', isEqualTo: patientId)
          .snapshots()
          .map(
            (snapshot) {
              if (snapshot.docs.isEmpty) {
                return _localAppointments
                    .where((a) => a.patientId == patientId || patientId.isEmpty || patientId.contains('patient_demo'))
                    .toList();
              }
              final list = snapshot.docs
                  .map((doc) => AppointmentModel.fromFirestore(doc))
                  .toList();
              list.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
              return list;
            },
          )
          .handleError((_) {
        return _localAppointments
            .where((a) => a.patientId == patientId || patientId.isEmpty || patientId.contains('patient_demo'))
            .toList();
      });
    } catch (_) {
      return Stream.value(_localAppointments);
    }
  }

  // Stream Doctor's Appointments
  Stream<List<AppointmentModel>> getDoctorAppointmentsStream(String doctorId) {
    try {
      return _appointmentsCol
          .where('doctorId', isEqualTo: doctorId)
          .snapshots()
          .map(
            (snapshot) {
              if (snapshot.docs.isEmpty) {
                return _localAppointments
                    .where((a) => a.doctorId == doctorId || doctorId.isEmpty || doctorId.contains('doc_ashis'))
                    .toList();
              }
              final list = snapshot.docs
                  .map((doc) => AppointmentModel.fromFirestore(doc))
                  .toList();
              list.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
              return list;
            },
          )
          .handleError((_) {
        return _localAppointments
            .where((a) => a.doctorId == doctorId || doctorId.isEmpty || doctorId.contains('doc_ashis'))
            .toList();
      });
    } catch (_) {
      return Stream.value(_localAppointments);
    }
  }

  // Update Appointment Status (confirm, reject, complete, cancel)
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    // Update local cache
    final index = _localAppointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      final old = _localAppointments[index];
      _localAppointments[index] = AppointmentModel(
        id: old.id,
        patientId: old.patientId,
        patientName: old.patientName,
        patientEmail: old.patientEmail,
        patientPhone: old.patientPhone,
        doctorId: old.doctorId,
        doctorName: old.doctorName,
        doctorSpecialty: old.doctorSpecialty,
        doctorPhotoUrl: old.doctorPhotoUrl,
        appointmentDate: old.appointmentDate,
        timeSlot: old.timeSlot,
        disease: old.disease,
        fee: old.fee,
        status: status,
        paymentStatus: old.paymentStatus,
        createdAt: old.createdAt,
      );
      _appointmentsController.add(List.from(_localAppointments));
    }

    try {
      await _appointmentsCol.doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  // --- Logic explicitly specified in the Report (Section 4.7 & 5.7 Class Diagram) ---

  // makeAppointment alias for Class Diagram 'makeAppointment()'
  Future<String> makeAppointment(AppointmentModel appointment) => bookAppointment(appointment);

  // cancelAppointment alias for Class Diagram 'cancelAppointment()'
  Future<void> cancelAppointment(String appointmentId) =>
      updateAppointmentStatus(appointmentId: appointmentId, status: 'cancelled');

  // acceptAppointment / rejectAppointment for Use Case 'Accept/Reject Appointment Status'
  Future<void> acceptAppointment(String appointmentId) =>
      updateAppointmentStatus(appointmentId: appointmentId, status: 'confirmed');

  Future<void> rejectAppointment(String appointmentId) =>
      updateAppointmentStatus(appointmentId: appointmentId, status: 'rejected');

  // deletePatient (from DFD Level 1 for Patient)
  Future<void> deletePatient(String patientId) async {
    try {
      await _firestore.collection('users').doc(patientId).delete();
    } catch (_) {}
  }

  // deleteDoctor (from DFD Level 1 for Doctor)
  Future<void> deleteDoctor(String doctorId) async {
    try {
      await _doctorsCol.doc(doctorId).delete();
    } catch (_) {}
  }
}
