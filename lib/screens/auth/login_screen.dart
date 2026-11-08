import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../patient/patient_main_screen.dart';
import '../doctor/doctor_main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'patient.demo@mail.com');
  final _passwordController = TextEditingController(text: 'password123');
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _activeRoleTab = 'patient'; // 'patient' or 'doctor'

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchRoleTab(String role) {
    setState(() {
      _activeRoleTab = role;
      if (role == 'doctor') {
        _emailController.text = 'doctor.demo@hospital.org';
      } else {
        _emailController.text = 'patient.demo@mail.com';
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProfile = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (userProfile != null && userProfile.role == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DoctorMainScreen(user: userProfile)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PatientMainScreen(user: userProfile)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showFriendlyNotification(
        'Authentication Notice',
        'Could not authenticate with cloud server. Tap "Instant Demo Access" below to preview all features immediately.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Instant VIP Demo Access (Never fails - instant transition)
  Future<void> _launchInstantDemo(String role) async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 350));

    UserModel demoUser;
    if (role == 'doctor') {
      demoUser = AuthService.demoDoctorUser;
      _authService.setDemoSession(demoUser);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DoctorMainScreen(user: demoUser)),
      );
    } else {
      demoUser = AuthService.demoPatientUser;
      _authService.setDemoSession(demoUser);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PatientMainScreen(user: demoUser)),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _showFriendlyNotification(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.brandDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFF334155), width: 1),
        ),
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, color: Colors.white, height: 1.3),
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'DEMO LOGIN',
          textColor: AppTheme.accentColor,
          onPressed: () => _launchInstantDemo(_activeRoleTab),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 880;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: isDesktop
              ? _buildDesktopLayout()
              : _buildMobileLayout(),
        ),
      ),
    );
  }

  // Dual-Pane Executive Desktop Layout
  Widget _buildDesktopLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 720),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          const BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 36,
            offset: Offset(0, 12),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Showcase Panel (Deep Executive Obsidian Navy)
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(44),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF090D16), Color(0xFF0F172A), Color(0xFF1E3A8A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Live Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x2210B981),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x4410B981)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'OPD NETWORK · LIVE & DISPATCHING',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Brand Mark
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PULSECARE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Text(
                                'Clinical Hospital Network & Tele-OPD',
                                style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      const Text(
                        'Next-Generation\nSpecialist Healthcare & Instant OPD Dispatch.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Instant consultation scheduling with senior surgeons, cardiologists, and neurologists. Complete with digital OPD boarding passes, automated clinical triage, and live queue tracking.',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),

                  // Hospital Trust Pillars
                  Column(
                    children: [
                      _buildMetricRow('99.4%', 'Patient Trust Rating', '14,000+ Consultations'),
                      const Divider(color: Color(0x22FFFFFF), height: 28),
                      Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF38BDF8), size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'NABH, ISO 9001:2015 & HIPAA Compliant Security',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Right Form Panel
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
              child: SingleChildScrollView(
                child: _buildFormContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mobile / Small Screen Layout
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              // Mobile Top Executive Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF090D16), Color(0xFF0F172A), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                              CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF10B981)),
                              SizedBox(width: 6),
                              Text(
                                'LIVE OPD ACTIVE',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Row(
                          children: [
                            Icon(Icons.shield_rounded, color: Color(0xFF38BDF8), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'HIPAA SECURE',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PULSECARE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.8,
                              ),
                            ),
                            Text(
                              'Clinical Consultation Portal',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form Content
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 360 ? 16 : 24,
                  vertical: 20,
                ),
                child: _buildFormContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Core Form Content
  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Segmented Role Switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _switchRoleTab('patient'),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeRoleTab == 'patient' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeRoleTab == 'patient'
                            ? [
                                const BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: _activeRoleTab == 'patient' ? AppTheme.primaryColor : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Patient Portal',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _activeRoleTab == 'patient' ? FontWeight.w800 : FontWeight.w600,
                              color: _activeRoleTab == 'patient' ? AppTheme.textPrimary : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _switchRoleTab('doctor'),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeRoleTab == 'doctor' ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeRoleTab == 'doctor'
                            ? [
                                const BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medical_services_rounded,
                            size: 16,
                            color: _activeRoleTab == 'doctor' ? AppTheme.primaryColor : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Doctor Console',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: _activeRoleTab == 'doctor' ? FontWeight.w800 : FontWeight.w600,
                              color: _activeRoleTab == 'doctor' ? AppTheme.textPrimary : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Email Input
          const Text(
            'Email Address',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined, size: 20, color: Color(0xFF64748B)),
              hintText: 'name@hospital.org',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your email address';
              if (!v.contains('@')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Password Input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Access Password',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('For demo evaluation: password123 is pre-filled.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Default: password123',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF64748B)),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 20,
                  color: const Color(0xFF64748B),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              hintText: '••••••••',
            ),
            validator: (v) {
              if (v == null || v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Primary Sign In Button
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Authenticate & Enter',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _activeRoleTab == 'doctor' ? Icons.medical_services_rounded : Icons.arrow_forward_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 22),

          // Quick Instant Demo Action (1-Tap Zero Hassle Presentation Mode)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFD97706)),
                    SizedBox(width: 6),
                    Text(
                      'INSTANT DEMO & REVIEW PREVIEW',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _launchInstantDemo('patient'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 15, color: AppTheme.primaryColor),
                              SizedBox(width: 6),
                              Text(
                                'VIP Patient View',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _launchInstantDemo('doctor'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          side: const BorderSide(color: Color(0xFF99F6E4)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.medical_services_rounded, size: 15, color: Color(0xFF0F766E)),
                              SizedBox(width: 6),
                              Text(
                                'Doctor Console',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F766E)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Register Action
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'New to the clinical portal? ',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  'Register Account',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String value, String title, String subtitle) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF38BDF8),
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
