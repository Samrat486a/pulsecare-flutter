import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/doctor_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../patient/patient_main_screen.dart';

class DoctorProfileTab extends StatefulWidget {
  final UserModel? user;

  const DoctorProfileTab({super.key, this.user});

  @override
  State<DoctorProfileTab> createState() => _DoctorProfileTabState();
}

class _DoctorProfileTabState extends State<DoctorProfileTab> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  final _feeController = TextEditingController();
  final _clinicController = TextEditingController();
  final _aboutController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isSaving = false;
  DoctorModel? _loadedDoctor;

  @override
  void dispose() {
    _feeController.dispose();
    _clinicController.dispose();
    _aboutController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _populateControllers(DoctorModel doc) {
    if (_loadedDoctor?.id == doc.id) return;
    _loadedDoctor = doc;
    _feeController.text = doc.ticketPrice.toInt().toString();
    _clinicController.text = doc.clinicAddress;
    _aboutController.text = doc.about;
    _educationController.text = doc.education;
    _experienceController.text = doc.experience;
  }

  Future<void> _saveProfile() async {
    if (_loadedDoctor == null) return;
    setState(() => _isSaving = true);

    try {
      final updated = DoctorModel(
        id: _loadedDoctor!.id,
        name: _loadedDoctor!.name,
        email: _loadedDoctor!.email,
        phone: _loadedDoctor!.phone,
        specialty: _loadedDoctor!.specialty,
        rating: _loadedDoctor!.rating,
        reviewCount: _loadedDoctor!.reviewCount,
        clinicAddress: _clinicController.text.trim(),
        ticketPrice: double.tryParse(_feeController.text.trim()) ?? _loadedDoctor!.ticketPrice,
        photoUrl: _loadedDoctor!.photoUrl,
        about: _aboutController.text.trim(),
        education: _educationController.text.trim(),
        experience: _experienceController.text.trim(),
        availableDays: _loadedDoctor!.availableDays,
        availableSlots: _loadedDoctor!.availableSlots,
      );

      await _dbService.updateDoctorProfile(updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Doctor profile updated successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorId = widget.user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Doctor Profile & Schedule'),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<DoctorModel?>(
        stream: _dbService.getDoctorStream(doctorId),
        builder: (context, snapshot) {
          final doc = snapshot.data;
          if (doc != null) {
            _populateControllers(doc);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Doctor Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: AppTheme.subtleShadow,
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          doc?.photoUrl ??
                              'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=500&auto=format&fit=crop&q=80',
                          width: 86,
                          height: 86,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const CircleAvatar(
                            radius: 43,
                            backgroundColor: AppTheme.primaryLight,
                            child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.user?.name ?? doc?.name ?? 'Dr. Ashis Ghosh',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc?.specialty ?? 'Senior Consultant Surgeon',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, size: 14, color: AppTheme.successColor),
                            SizedBox(width: 6),
                            Text(
                              'MCI / NMC REGISTERED PRACTITIONER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.successColor,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Switch to Patient View Demo Capsule
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF0D9488)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Switch to Patient Portal',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              'Test the patient appointment booking flow and checkout.',
                              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final pUser = AuthService.demoPatientUser;
                          _authService.setDemoSession(pUser);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => PatientMainScreen(user: pUser)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Switch', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Edit Clinic Details
                const Text(
                  'Clinical Practice Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Consultation Fee
                const Text('Consultation OPD Fee (₹)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.currency_rupee_rounded, size: 20),
                    hintText: 'e.g. 1000',
                  ),
                ),
                const SizedBox(height: 16),

                // Clinic Address
                const Text('Clinic / Hospital Affiliation', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _clinicController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    hintText: 'Hospital Name & Clinic Location',
                  ),
                ),
                const SizedBox(height: 16),

                // About
                const Text('Clinical Bio', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _aboutController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Summary of specialty and clinical philosophy...',
                  ),
                ),
                const SizedBox(height: 24),

                // Save Profile Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Save Practice Changes'),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await _authService.signOut();
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
                    label: const Text('Sign Out', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFECDD3)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
