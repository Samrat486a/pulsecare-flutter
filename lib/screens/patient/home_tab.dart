import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/doctor_model.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import 'doctor_details_screen.dart';
import 'find_doctor_screen.dart';

class HomeTab extends StatelessWidget {
  final UserModel? user;
  final Function(String? specialty)? onNavigateToSearch;

  const HomeTab({
    super.key,
    this.user,
    this.onNavigateToSearch,
  });

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emergency_rounded, color: AppTheme.errorColor, size: 28),
            SizedBox(width: 10),
            Text('Hospital Emergency Desk', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If you or someone near you requires urgent critical resuscitation or ambulance transit:',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Color(0xFFFEE2E2), child: Icon(Icons.phone_in_talk, color: Colors.red)),
              title: Text('National Ambulance SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('Dial 108 (24x7 Immediate Response)'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.local_hospital, color: Colors.blue)),
              title: Text('Doctor Now Emergency Triage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text('+91 1800-419-0099 (Priority Line)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Call 108 Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();

    final triageSymptoms = [
      {'label': 'Chest Discomfort', 'specialty': 'Cardiologist', 'icon': Icons.favorite_rounded, 'color': const Color(0xFF2563EB)},
      {'label': 'Migraine & Spine', 'specialty': 'Neurologist', 'icon': Icons.psychology_rounded, 'color': const Color(0xFF16A34A)},
      {'label': 'Surgical Consult', 'specialty': 'Surgeon', 'icon': Icons.medical_services_rounded, 'color': const Color(0xFF9333EA)},
      {'label': 'Maternal Care', 'specialty': 'Obstetrician & Gynecologist', 'icon': Icons.pregnant_woman_rounded, 'color': const Color(0xFFE11D48)},
      {'label': 'Oncology & Chemo', 'specialty': 'Oncologist', 'icon': Icons.healing_rounded, 'color': const Color(0xFFD97706)},
    ];

    // 6 Core Medical Services (Exactly matching Internship Project Report Page 25)
    final medicalServices = [
      {
        'number': '1',
        'title': 'Cancer Care',
        'desc': 'We provide advanced cancer care with cutting-edge treatments, expert medical teams and personalized support for every patient.',
        'specialty': 'Oncologist',
        'numBg': const Color(0xFFFEF3C7),
        'numColor': const Color(0xFFD97706),
      },
      {
        'number': '2',
        'title': 'Labor & Delivery',
        'desc': 'Our labor and delivery team offers expert care for mothers and newborns. Our team ensures a safe, supportive childbirth experience.',
        'specialty': 'Obstetrician & Gynecologist',
        'numBg': const Color(0xFFF3E8FF),
        'numColor': const Color(0xFF7E22CE),
      },
      {
        'number': '3',
        'title': 'Heart & Vascular',
        'desc': 'Our heart and vascular specialists deliver expert care with advanced treatments. We provide personalized support for every patient.',
        'specialty': 'Cardiologist',
        'numBg': const Color(0xFFCCFBF1),
        'numColor': const Color(0xFF0F766E),
      },
      {
        'number': '4',
        'title': 'Mental Health',
        'desc': 'We offer compassionate mental health care with personalized treatment plans. Our team supports patients on their path to wellness.',
        'specialty': 'Psychiatrist',
        'numBg': const Color(0xFFE0F2FE),
        'numColor': const Color(0xFF0369A1),
      },
      {
        'number': '5',
        'title': 'Neurology',
        'desc': 'Our neurology team provides expert care for complex brain and nerve conditions. We offer personalized treatment for every patient.',
        'specialty': 'Neurologist',
        'numBg': const Color(0xFFFEF3C7),
        'numColor': const Color(0xFFB45309),
      },
      {
        'number': '6',
        'title': 'Burn Treatment',
        'desc': 'We offer specialized burn treatment with advanced care techniques. Our team provides personalized support for each patient\'s recovery.',
        'specialty': 'Surgeon',
        'numBg': const Color(0xFFF1F5F9),
        'numColor': const Color(0xFF475569),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF0D9488)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DOCTOR NOW',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 0.8,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Aura Clinical Hospital Network',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'OPD LIVE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'P',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Executive Hero Showcase Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF090D16), Color(0xFF0F172A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.floatingShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x2210B981),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x4410B981)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 13, color: Color(0xFF34D399)),
                            SizedBox(width: 4),
                            Text(
                              'VERIFIED CLINICAL CONSULTANTS',
                              style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
                          SizedBox(width: 4),
                          Text('99.4% Trust', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome back, ${user?.name ?? "Patient"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Book certified in-clinic consultations and obtain instant digital OPD boarding passes.',
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search Bar inside Hero
                  GestureDetector(
                    onTap: () {
                      if (onNavigateToSearch != null) {
                        onNavigateToSearch!(null);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FindDoctorScreen()),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppTheme.primaryColor, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search doctor, hospital, symptom or condition...',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Icon(Icons.tune_rounded, color: AppTheme.textSecondary, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Smart Symptom Rapid Triage Bar
            const Text(
              'Rapid Clinical Symptom Triage',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF334155),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: triageSymptoms.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final s = triageSymptoms[idx];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FindDoctorScreen(
                            initialSpecialty: s['specialty'] as String,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: AppTheme.subtleShadow,
                      ),
                      child: Row(
                        children: [
                          Icon(s['icon'] as IconData, size: 16, color: s['color'] as Color),
                          const SizedBox(width: 6),
                          Text(
                            s['label'] as String,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // Emergency SOS Ribbon
            InkWell(
              onTap: () => _showEmergencyDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11D48),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '24/7 Hospital Critical Hotline & Ambulance',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9F1239),
                            ),
                          ),
                          Text(
                            'Direct emergency triage desk • Call 108 / 102',
                            style: TextStyle(fontSize: 11, color: Color(0xFFBE123C)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Dial SOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Clinical Specialties Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical Departments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Select a medical division to view consultants',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    if (onNavigateToSearch != null) onNavigateToSearch!(null);
                  },
                  icon: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  label: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Clinical Services Grid (Matching Report Page 25)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              itemCount: medicalServices.length,
              itemBuilder: (context, index) {
                final item = medicalServices[index];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FindDoctorScreen(
                            initialSpecialty: item['specialty'] as String,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: AppTheme.subtleShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Text(
                              item['desc'] as String,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.45,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Circular Arrow Button (Matches Report Page 25)
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                                ),
                                child: const Center(
                                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF334155)),
                                ),
                              ),
                              // Number Badge (Matches Report Page 25: 1, 2, 3, 4, 5, 6)
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: item['numBg'] as Color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    item['number'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: item['numColor'] as Color,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Featured Specialists Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On-Duty Specialists',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Currently in-clinic and accepting immediate tokens',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    if (onNavigateToSearch != null) onNavigateToSearch!(null);
                  },
                  child: const Text('See All (5)', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            StreamBuilder<List<DoctorModel>>(
              stream: dbService.getDoctorsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final doctors = snapshot.data ?? [];
                if (doctors.isEmpty) {
                  return const Center(child: Text('No doctors available right now.'));
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: doctors.take(5).length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = doctors[index];

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailsScreen(
                                doctor: doc,
                                patientUser: user,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: AppTheme.subtleShadow,
                          ),
                          child: Row(
                            children: [
                              // Photo with verified checkmark
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      doc.photoUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 80,
                                        height: 80,
                                        color: AppTheme.primaryLight,
                                        child: const Icon(Icons.person, size: 36, color: AppTheme.primaryColor),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppTheme.successColor,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 14),

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryLight,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            doc.specialty,
                                            style: const TextStyle(
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.star_rounded, size: 15, color: AppTheme.accentColor),
                                        Text(
                                          ' ${doc.rating}',
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      doc.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            doc.clinicAddress,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF64748B),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Fee & Action
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${doc.ticketPrice.toInt()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const Text(
                                    'OPD Fee',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppTheme.primaryColor, Color(0xFF1E3A8A)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Consult',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 28),

            // Hospital Quality & Accreditation Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppTheme.primaryColor, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NABH & JCI Accredited Medical Facility',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'All practitioners hold verified medical council registrations with 100% verified credentials.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
