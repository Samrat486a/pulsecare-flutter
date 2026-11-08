import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String scheduleId;
  final String doctorId;
  final String scheduleDay; // e.g. 'Sunday', 'Wednesday'
  final String scheduleTimeFrom; // e.g. '10:00 AM'
  final String scheduleTimeTo; // e.g. '11:30 AM'
  final String room; // e.g. 'Cabin 3B'
  final String building; // e.g. 'OPD Wing B'
  final DateTime? updateDate;

  ScheduleModel({
    required this.scheduleId,
    required this.doctorId,
    required this.scheduleDay,
    required this.scheduleTimeFrom,
    required this.scheduleTimeTo,
    this.room = 'Cabin 3B',
    this.building = 'OPD Wing B',
    this.updateDate,
  });

  factory ScheduleModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ScheduleModel(
      scheduleId: snapshot.id,
      doctorId: data['doctorId'] ?? '',
      scheduleDay: data['scheduleDay'] ?? 'Sunday',
      scheduleTimeFrom: data['scheduleTimeFrom'] ?? '10:00 AM',
      scheduleTimeTo: data['scheduleTimeTo'] ?? '11:30 AM',
      room: data['room'] ?? 'Cabin 3B',
      building: data['building'] ?? 'OPD Wing B',
      updateDate: (data['updateDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'scheduleDay': scheduleDay,
      'scheduleTimeFrom': scheduleTimeFrom,
      'scheduleTimeTo': scheduleTimeTo,
      'room': room,
      'building': building,
      'updateDate': updateDate != null
          ? Timestamp.fromDate(updateDate!)
          : FieldValue.serverTimestamp(),
    };
  }
}
