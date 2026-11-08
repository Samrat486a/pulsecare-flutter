import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/appointment_model.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class DoctorDashboardTab extends StatelessWidget {
  final UserModel? user;
  final VoidCallback? onViewAppointments;

  const DoctorDashboardTab({
    super.key,
    this.user,
    this.onViewAppointments,
  });

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    final doctorId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_hospital_rounded, color: AppTheme.primaryColor, size: 22),
            SizedBox(width: 8),
            Text(
              'Doctor Clinical Portal',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'D',
                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<AppointmentModel>>(
        stream: dbService.getDoctorAppointmentsStream(doctorId),
        builder: (context, snapshot) {
          final appointments = snapshot.data ?? [];
          final pendingCount = appointments.where((a) => a.status == 'pending').length;
          final confirmedCount = appointments.where((a) => a.status == 'confirmed').length;
          final totalCount = appointments.length;
          final totalRevenue = appointments
              .where((a) => a.status == 'confirmed' || a.status == 'completed')
              .fold<double>(0.0, (sum, a) => sum + a.fee);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Executive Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF0369A1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.cardShadow,
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
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified_rounded, size: 14, color: Color(0xFF38BDF8)),
                                SizedBox(width: 4),
                                Text(
                                  'Senior Consultant Access',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.circle, color: AppTheme.successColor, size: 8),
                                SizedBox(width: 4),
                                Text(
                                  'Clinic Live',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        user?.name ?? 'Dr. Specialist',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Monitor incoming consultation requests, confirm slots, and manage patient care.',
                        style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4 Metric Counters (Clinical KPI Cards)
                const Text(
                  'Practice Performance & Queue Stats',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isCompact = screenWidth < 420;

                    final kpi1 = _buildKPI(
                      title: 'Pending',
                      count: '$pendingCount',
                      color: const Color(0xFFD97706),
                      bg: const Color(0xFFFEF3C7),
                      icon: Icons.hourglass_top_rounded,
                    );
                    final kpi2 = _buildKPI(
                      title: 'Confirmed',
                      count: '$confirmedCount',
                      color: const Color(0xFF16A34A),
                      bg: const Color(0xFFDCFCE7),
                      icon: Icons.check_circle_rounded,
                    );
                    final kpi3 = _buildKPI(
                      title: 'Total Visits',
                      count: '$totalCount',
                      color: const Color(0xFF7C3AED),
                      bg: const Color(0xFFF5F3FF),
                      icon: Icons.people_alt_rounded,
                    );
                    final kpi4 = _buildKPI(
                      title: 'Revenue',
                      count: '₹${totalRevenue.toInt()}',
                      color: const Color(0xFF2563EB),
                      bg: const Color(0xFFDBEAFE),
                      icon: Icons.currency_rupee_rounded,
                    );

                    if (isCompact) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: kpi1),
                              const SizedBox(width: 8),
                              Expanded(child: kpi2),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: kpi3),
                              const SizedBox(width: 8),
                              Expanded(child: kpi4),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: kpi1),
                        const SizedBox(width: 8),
                        Expanded(child: kpi2),
                        const SizedBox(width: 8),
                        Expanded(child: kpi3),
                        const SizedBox(width: 8),
                        Expanded(child: kpi4),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Patient Requests Stream
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Patient Action Queue',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onViewAppointments,
                      icon: const Text('Manage All', style: TextStyle(fontWeight: FontWeight.bold)),
                      label: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (appointments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.event_available_rounded, size: 36, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No Pending Consultations',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'When patients request an appointment, they will instantly appear here for your review.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appointments.take(4).length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final appt = appointments[index];

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: AppTheme.subtleShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppTheme.primaryLight,
                                      child: Text(
                                        appt.patientName.isNotEmpty ? appt.patientName[0].toUpperCase() : 'P',
                                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appt.patientName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        Text(
                                          appt.patientPhone,
                                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: appt.status == 'confirmed' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    appt.status.toUpperCase(),
                                    style: TextStyle(
                                      color: appt.status == 'confirmed' ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 15, color: AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  '${DateFormat('dd MMM').format(appt.appointmentDate)} • ${appt.timeSlot}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${appt.fee.toInt()} Paid',
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryColor, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Reason: ${appt.disease}',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            if (appt.status == 'pending') ...[
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        dbService.updateAppointmentStatus(
                                          appointmentId: appt.id,
                                          status: 'rejected',
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.errorColor,
                                        side: const BorderSide(color: AppTheme.errorColor),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: const Text('Decline'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        dbService.updateAppointmentStatus(
                                          appointmentId: appt.id,
                                          status: 'confirmed',
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.successColor,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      child: const Text('Confirm'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKPI({
    required String title,
    required String count,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              count,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
