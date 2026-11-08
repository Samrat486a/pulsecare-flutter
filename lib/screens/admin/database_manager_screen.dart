import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/seed_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pulsecare_logo.dart';

class DatabaseManagerScreen extends StatefulWidget {
  const DatabaseManagerScreen({super.key});

  @override
  State<DatabaseManagerScreen> createState() => _DatabaseManagerScreenState();
}

class _DatabaseManagerScreenState extends State<DatabaseManagerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isSeeding = false;
  String _statusMessage = 'Connected to Cloud Firestore';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _syncSeedDoctors() async {
    setState(() {
      _isSeeding = true;
      _statusMessage = 'Syncing report-verified doctors to Firebase...';
    });

    try {
      int added = 0;
      for (final doc in SeedData.initialDoctors) {
        await _firestore.collection('doctors').doc(doc.id).set(doc.toMap(), SetOptions(merge: true));
        added++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully synced $added clinical specialists to Firestore!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      setState(() {
        _statusMessage = 'Synced $added specialists to Firestore';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync note: ${e.toString()} (local cache active)'),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  Future<void> _addQuickDemoPatient() async {
    final newId = 'pat_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    try {
      await _firestore.collection('users').doc(newId).set({
        'uid': newId,
        'name': 'Priya Mukherjee',
        'email': 'priya.demo@mail.com',
        'phone': '+91 98300 12345',
        'role': 'patient',
        'bloodType': 'B+',
        'region': 'West Bengal',
        'weight': '58 kg',
        'height': '165 cm',
        'personalDisease': 'None (General Consultation)',
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New Patient "Priya Mukherjee" added to users collection!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firestore write: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            PulseCareLogo(size: 32, showBadge: true, showGlow: false),
            SizedBox(width: 10),
            Text(
              'Firestore Data Explorer',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Explorer',
            onPressed: () => setState(() {}),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.medical_services_rounded, size: 18), text: 'Doctors'),
            Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: 'Users'),
            Tab(icon: Icon(Icons.calendar_month_rounded, size: 18), text: 'Appointments'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Firestore Configuration & Status Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Colors.blueGrey.shade800)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(radius: 4, backgroundColor: Color(0xFF10B981)),
                        SizedBox(width: 8),
                        Text(
                          'PROJECT: doctor-appointment-app-5cb47',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x2210B981),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'CLOUD FIRESTORE',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _statusMessage,
                        style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isSeeding ? null : _syncSeedDoctors,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: _isSeeding
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.cloud_upload_rounded, size: 14),
                      label: const Text('Sync Doctors', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Collection Data Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDoctorsCollectionTab(),
                _buildUsersCollectionTab(),
                _buildAppointmentsCollectionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsCollectionTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('doctors').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          // If empty, show fallback seed items with a quick sync action
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.medical_information_outlined, size: 54, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 12),
                  const Text(
                    'No doctors found in live Firestore',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap the button below to populate verified specialists (Dr. Ashis Ghosh, etc.) directly into Firestore.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: _syncSeedDoctors,
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text('Populate Seed Doctors to Firestore'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: AppTheme.subtleShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['name'] ?? 'Doctor',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '₹${data['ticketPrice'] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Specialty: ${data['specialty'] ?? "N/A"}  •  License: ${data['licenseNo'] ?? "MCI-2016"}',
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Clinic: ${data['clinicAddress'] ?? "Hospital"}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Document ID: ${doc.id}',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUsersCollectionTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Registered Accounts',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF334155)),
              ),
              TextButton.icon(
                onPressed: _addQuickDemoPatient,
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text('Add Demo Patient', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _firestore.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.group_off_rounded, size: 52, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        const Text('No users in Firestore collection yet', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        const Text(
                          'Register a new patient or doctor on the Sign Up screen, or tap "Add Demo Patient" above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data();

                  final role = data['role'] ?? 'patient';
                  final isDoctor = role == 'doctor';

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isDoctor ? const Color(0xFFCCFBF1) : const Color(0xFFEFF6FF),
                          child: Icon(
                            isDoctor ? Icons.medical_services_rounded : Icons.person_rounded,
                            color: isDoctor ? const Color(0xFF0F766E) : AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['name'] ?? 'User',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                data['email'] ?? 'No email',
                                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                              if (data['phone'] != null)
                                Text(
                                  'Phone: ${data['phone']}',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isDoctor ? const Color(0xFFF0FDF4) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDoctor ? AppTheme.successColor : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsCollectionTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No active appointments booked in Firestore yet.\nBook an appointment from the patient home tab to see it here live!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), height: 1.5),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();

            final status = data['status'] ?? 'pending';

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Token #${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primaryColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: status == 'confirmed' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: status == 'confirmed' ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Patient: ${data['patientName'] ?? "N/A"}  →  Doctor: ${data['doctorName'] ?? "N/A"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Text(
                    'Slot: ${data['timeSlot'] ?? "N/A"}  •  Fee: ₹${data['fee'] ?? 0}',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
