import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import 'seed_data.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Doctors Collection Reference
  CollectionReference<Map<String, dynamic>> get _doctorsCol =>
      _firestore.collection('doctors');

  // Appointments Collection Reference
  CollectionReference<Map<String, dynamic>> get _appointmentsCol =>
      _firestore.collection('appointments');

  // Seed sample doctors if collection is empty
  Future<void> seedInitialDoctorsIfEmpty() async {
    try {
      final snapshot = await _doctorsCol.limit(1).get();
      if (snapshot.docs.isEmpty) {
        for (var doc in SeedData.initialDoctors) {
          await _doctorsCol.doc(doc.id).set(doc.toMap());
        }
      }
    } catch (e) {
      // Ignored if permissions are restricted or offline
    }
  }

  // Stream all doctors
  Stream<List<DoctorModel>> getDoctorsStream() {
    return _doctorsCol.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => DoctorModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Stream a specific doctor by ID
  Stream<DoctorModel?> getDoctorStream(String doctorId) {
    return _doctorsCol.doc(doctorId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return DoctorModel.fromFirestore(doc);
      }
      return null;
    });
  }

  // Update Doctor Profile
  Future<void> updateDoctorProfile(DoctorModel doctor) async {
    await _doctorsCol.doc(doctor.id).update(doctor.toMap());
  }

  // Book an Appointment
  Future<String> bookAppointment(AppointmentModel appointment) async {
    final docRef = await _appointmentsCol.add(appointment.toMap());
    return docRef.id;
  }

  // Stream Patient's Appointments
  Stream<List<AppointmentModel>> getPatientAppointmentsStream(String patientId) {
    return _appointmentsCol
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => AppointmentModel.fromFirestore(doc))
                .toList();
            // Sort by appointment date descending
            list.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
            return list;
          },
        );
  }

  // Stream Doctor's Appointments
  Stream<List<AppointmentModel>> getDoctorAppointmentsStream(String doctorId) {
    return _appointmentsCol
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map(
          (snapshot) {
            final list = snapshot.docs
                .map((doc) => AppointmentModel.fromFirestore(doc))
                .toList();
            list.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
            return list;
          },
        );
  }

  // Update Appointment Status (confirm, reject, complete, cancel)
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    await _appointmentsCol.doc(appointmentId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
