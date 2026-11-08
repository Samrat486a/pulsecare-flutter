import 'package:flutter/material.dart';
import '../../models/doctor_model.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import 'doctor_details_screen.dart';

class FindDoctorScreen extends StatefulWidget {
  final String? initialSpecialty;
  final UserModel? patientUser;

  const FindDoctorScreen({
    super.key,
    this.initialSpecialty,
    this.patientUser,
  });

  @override
  State<FindDoctorScreen> createState() => _FindDoctorScreenState();
}

class _FindDoctorScreenState extends State<FindDoctorScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedSpecialty = 'All';

  final List<String> _specialties = [
    'All',
    'Surgeon',
    'Neurologist',
    'Cardiologist',
    'Obstetrician & Gynecologist',
    'Oncologist',
    'General Physician',
    'Psychiatrist',
  ];

  final List<Color> _avatarColors = [
    const Color(0xFFFBBF24), // Amber/Orange
    const Color(0xFF38BDF8), // Cyan
    const Color(0xFF818CF8), // Indigo
    const Color(0xFF34D399), // Emerald
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialSpecialty != null) {
      _selectedSpecialty = widget.initialSpecialty!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Find a Specialist'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() => _searchQuery = val.toLowerCase().trim());
                          },
                          decoration: InputDecoration(
                            hintText: 'Search doctor, condition or hospital...',
                            hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _searchQuery = _searchController.text.toLowerCase().trim();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Specialty filter chips with hover and animations
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialties.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final item = _specialties[idx];
                      final isSelected = _selectedSpecialty == item;
                      return _FilterHoverChip(
                        label: item,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() => _selectedSpecialty = item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Doctor List
          Expanded(
            child: StreamBuilder<List<DoctorModel>>(
              stream: _dbService.getDoctorsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allDoctors = snapshot.data ?? [];

                // Filter logic
                final filtered = allDoctors.where((doc) {
                  final matchesQuery = _searchQuery.isEmpty ||
                      doc.name.toLowerCase().contains(_searchQuery) ||
                      doc.specialty.toLowerCase().contains(_searchQuery) ||
                      doc.clinicAddress.toLowerCase().contains(_searchQuery);

                  final matchesSpecialty = _selectedSpecialty == 'All' ||
                      doc.specialty.toLowerCase().contains(_selectedSpecialty.toLowerCase());

                  return matchesQuery && matchesSpecialty;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No specialists found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Try clearing search or filters',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: ListView.separated(
                    key: ValueKey('list_${_selectedSpecialty}_$_searchQuery'),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final frameBgColor = _avatarColors[index % _avatarColors.length];

                      return _DoctorItemCard(
                        doctor: doc,
                        frameBgColor: frameBgColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailsScreen(
                                doctor: doc,
                                patientUser: widget.patientUser,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Hoverable Filter Chip with animated scale & color transition
class _FilterHoverChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterHoverChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  State<_FilterHoverChip> createState() => _FilterHoverChipState();
}

class _FilterHoverChipState extends State<_FilterHoverChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryColor
                : (_isHovered ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primaryColor
                  : (_isHovered ? const Color(0xFFCBD5E1) : Colors.transparent),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// Hoverable Doctor Card
class _DoctorItemCard extends StatefulWidget {
  final DoctorModel doctor;
  final Color frameBgColor;
  final VoidCallback onTap;

  const _DoctorItemCard({
    required this.doctor,
    required this.frameBgColor,
    required this.onTap,
  });

  @override
  State<_DoctorItemCard> createState() => _DoctorItemCardState();
}

class _DoctorItemCardState extends State<_DoctorItemCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final doc = widget.doctor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
              width: _isHovered ? 1.4 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    const BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ]
                : AppTheme.subtleShadow,
          ),
          child: Row(
            children: [
              // Doctor photo in colorful frame
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: widget.frameBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    doc.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
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
                        const Icon(Icons.star_rounded, size: 16, color: AppTheme.accentColor),
                        Text(
                          ' (${doc.reviewCount})',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      doc.clinicAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Fee & Circular Arrow Action (Matches Report Page 27)
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
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered ? AppTheme.primaryColor : const Color(0xFFF1F5F9),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: _isHovered ? Colors.white : const Color(0xFF334155),
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
  }
}
