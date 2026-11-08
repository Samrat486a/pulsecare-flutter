import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import 'home_tab.dart';
import 'find_doctor_screen.dart';
import 'my_appointments_tab.dart';
import 'patient_profile_tab.dart';

class PatientMainScreen extends StatefulWidget {
  final UserModel? user;

  const PatientMainScreen({super.key, this.user});

  @override
  State<PatientMainScreen> createState() => _PatientMainScreenState();
}

class _PatientMainScreenState extends State<PatientMainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      HomeTab(
        user: widget.user,
        onNavigateToSearch: (specialty) => _onTabSelected(1),
      ),
      FindDoctorScreen(patientUser: widget.user),
      MyAppointmentsTab(patientId: widget.user?.uid ?? ''),
      PatientProfileTab(user: widget.user),
    ];

    final navItems = [
      _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
      _NavItemData(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Find Doctor'),
      _NavItemData(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Passes'),
      _NavItemData(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final item = navItems[index];
                  final isSelected = _currentIndex == index;

                  return _AnimatedNavTab(
                    icon: item.icon,
                    activeIcon: item.activeIcon,
                    label: item.label,
                    isSelected: isSelected,
                    onTap: () => _onTabSelected(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _AnimatedNavTab extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedNavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedNavTab> createState() => _AnimatedNavTabState();
}

class _AnimatedNavTabState extends State<_AnimatedNavTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = AppTheme.primaryColor;
    final inactiveColor = const Color(0xFF64748B);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width < 360 ? 10 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFFEFF6FF)
                : (_isHovered ? const Color(0xFFF8FAFC) : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFBFDBFE)
                  : (_isHovered ? const Color(0xFFE2E8F0) : Colors.transparent),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: widget.isSelected ? 1.12 : (_isHovered ? 1.08 : 1.0),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  widget.isSelected ? widget.activeIcon : widget.icon,
                  size: 22,
                  color: widget.isSelected ? activeColor : (_isHovered ? AppTheme.textPrimary : inactiveColor),
                ),
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                AnimatedOpacity(
                  opacity: widget.isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: activeColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
