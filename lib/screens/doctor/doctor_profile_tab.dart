import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/doctor_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

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
          if (snapshot.connectionState == ConnectionState.waiting && _loadedDoctor == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final doc = snapshot.data;
          if (doc != null) {
            _populateControllers(doc);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Card Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.medical_services_rounded,
                          size: 34,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc?.name ?? widget.user?.name ?? 'Dr. Specialist',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doc?.specialty ?? 'General Physician',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user?.email ?? '',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Editable Fields
                const Text(
                  'Manage Clinic & Practice Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Fee
                const Text(
                  'Consultation Fee (Ticket Price in ₹)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.currency_rupee),
                    hintText: '1000',
                  ),
                ),
                const SizedBox(height: 16),

                // Clinic Address
                const Text(
                  'Clinic Address & Location',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _clinicController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: 'Clinic location',
                  ),
                ),
                const SizedBox(height: 16),

                // About
                const Text(
                  'About Bio',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _aboutController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Summary of clinical expertise...',
                  ),
                ),
                const SizedBox(height: 16),

                // Education
                const Text(
                  'Education & Degrees',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _educationController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.school_outlined),
                    hintText: 'MBBS - AIIMS Delhi',
                  ),
                ),
                const SizedBox(height: 16),

                // Experience
                const Text(
                  'Experience & History',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _experienceController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.work_outline),
                    hintText: 'Surgeon intern at Dhanbad Medical College',
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Out
                SizedBox(
                  width: double.infinity,
                  height: 50,
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
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.errorColor, width: 1.5),
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
