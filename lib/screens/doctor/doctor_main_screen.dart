import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import 'doctor_dashboard_tab.dart';
import 'doctor_appointments_tab.dart';
import 'doctor_profile_tab.dart';

class DoctorMainScreen extends StatefulWidget {
  final UserModel? user;

  const DoctorMainScreen({super.key, this.user});

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
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
      DoctorDashboardTab(
        user: widget.user,
        onViewAppointments: () => _onTabSelected(1),
      ),
      DoctorAppointmentsTab(doctorId: widget.user?.uid ?? ''),
      DoctorProfileTab(user: widget.user),
    ];

    final navItems = [
      _DoctorNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'OPD Console'),
      _DoctorNavItem(icon: Icons.pending_actions_outlined, activeIcon: Icons.pending_actions_rounded, label: 'Queue Requests'),
      _DoctorNavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Practice'),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = _currentIndex == index;

              return _AnimatedDoctorNavTab(
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
    );
  }
}

class _DoctorNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _DoctorNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _AnimatedDoctorNavTab extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedDoctorNavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AnimatedDoctorNavTab> createState() => _AnimatedDoctorNavTabState();
}

class _AnimatedDoctorNavTabState extends State<_AnimatedDoctorNavTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0F766E); // Surgical Teal
    const inactiveColor = Color(0xFF64748B);

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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0xFFCCFBF1)
                : (_isHovered ? const Color(0xFFF8FAFC) : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFF99F6E4)
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
                    style: const TextStyle(
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
